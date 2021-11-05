@
@ Example using the second core for processing.
@ Protecting a memory table with a spin lock.
@

#include "hardware/regs/addressmap.h"
#include "hardware/regs/m0plus.h"
#include "hardware/regs/sio.h"

.thumb_func		    @ Necessary because sdk uses BLX
.global main	            @ Provide program starting address to linker

	.EQU	numEntries, 100
	.EQU	coreOffset, 0
	.EQU	numOffset, 4
	.EQU	numSquaredOffset, 8
	.EQU	sizeTabRow, 12
	.EQU	emptyRow, 255

main:	BL	stdio_init_all	@ initialize uart or usb

	BL	launch_core1

	BL	coremain

@ ensure everything finishes
	MOV	R0, #255
	BL	sleep_ms

@ print out the table
	MOV	R4, #0		@ i = 0
	LDR	R5, =numEntries
	LDR	R6, =table
printtab:
	LDR	R0, =printstr
	LDR	R1, [R6, #coreOffset]
	LDR	R2, [R6, #numOffset]
	LDR	R3, [R6, #numSquaredOffset]
	BL	printf
	ADD	R4, #1		@ i = i + 1
	ADD	R6, #sizeTabRow
	CMP	R4, R5		@ i = numEntries?
	BLT	printtab

mainloop:
	WFE	@ lower power now that we are done
	B	mainloop

.align 4
printstr:	.ASCIZ	"Core %d n = %d n * n = %d\n"
.align 4

.thumb_func
coremain:
	PUSH	{R4, R5, R6, R7, LR}
	MOV	R4, #0		@ i = 0
	LDR	R5, =numEntries
	LDR	R6, =table
	MOV	R7, #emptyRow
forloop:
	@ lock spinlock
	BL	lockSpinLock
	@ determine if current row is free
	LDRB	R0, [R6]
	CMP	R0, R7
	BNE 	next	@ not free, continue
	@ update table with core number, i, i*i
	LDR	R2, =SIO_BASE
	LDR	R2, [R2, #SIO_CPUID_OFFSET]
	@ unlock spinlock after marking row for this core
	BL	unlockSpinLock
	@ update next two fields
	STR	R2, [R6, #coreOffset]
	STR	R4, [R6, #numOffset]
	MOV	R0, R4
	MUL	R0, R0
	STR	R0, [R6, #numSquaredOffset]
@ Perform extra work, otherwise core 1 stays ahead
@ of core 0 and allocates all the table slots.
	.REPT	10
	NOP
	.ENDR
@ spinlock already unlocked, so jump ahead
	B	cont
next:	
	@ unlock spinlock in case table entry taken
	BL	unlockSpinLock
cont:	ADD	R4, #1		@ i = i + 1
	ADD	R6, #sizeTabRow
	CMP	R4, R5
	BLT	forloop
	
	@ Only return if we are core 0.
	LDR	R2, =SIO_BASE
	LDR	R2, [R2, #SIO_CPUID_OFFSET]
	CMP	R2, #0
	BEQ	ret
sleep:	WFE
	B	sleep

ret:	POP	{R4, R5, R6, R7, PC}

lockSpinLock:
	LDR	R1, spinbase
repeat:	LDR	R0, [R1]
@ if spinlock is non-zero then we got it, else try again.
	CMP	R0, #0
	BEQ	repeat
	BX	LR

unlockSpinLock:
	LDR	R1, spinbase
	@ value written doesn't matter
	STR	R0, [R1]	
	BX	LR

fifo_push:
@ Push data to the fifo, without waiting.
	LDR	R1, siobase
	STR	R0, [R1, #SIO_FIFO_WR_OFFSET]
	SEV		@ Wake up the other core
	BX	LR

fifo_pop:
@ If there is data in the fifo, then read it.
	LDR	R1, siobase
	LDR	R0, [R1, #SIO_FIFO_ST_OFFSET]
	MOV	R2, #SIO_FIFO_ST_VLD_BITS
	AND	R0, R2
	BNE	gotone
	WFE		@ No data so go back to sleep
	B	fifo_pop @ try again if woken
gotone:	LDR	R0, [R1, #SIO_FIFO_RD_OFFSET]
	BX	LR

fifo_drain:
@ Read the fifo 8 times to ensure its empty then wake up
@ the other core.
	LDR	R1, siobase	
	LDR	R0, [R1, #SIO_FIFO_RD_OFFSET]
	LDR	R0, [R1, #SIO_FIFO_RD_OFFSET]
	LDR	R0, [R1, #SIO_FIFO_RD_OFFSET]
	LDR	R0, [R1, #SIO_FIFO_RD_OFFSET]
	LDR	R0, [R1, #SIO_FIFO_RD_OFFSET]
	LDR	R0, [R1, #SIO_FIFO_RD_OFFSET]
	LDR	R0, [R1, #SIO_FIFO_RD_OFFSET]
	LDR	R0, [R1, #SIO_FIFO_RD_OFFSET]
	SEV
	BX	LR

launch_core1:
@ To start core1, writes the magic sequence:
@	0, 0, 1, ivt, stack, routine
@ to core1's FIFO.
	PUSH	{LR}
	BL	fifo_drain	@ Clear anything left over
	MOV	R0, #0
	BL	fifo_push
	BL	fifo_pop
	MOV	R0, #0
	BL	fifo_push
	BL	fifo_pop
	MOV	R0, #1
	BL	fifo_push
	BL	fifo_pop
	LDR	R2, ppbbase
	LDR	R1, vtoroffset
	ADD	R2, R1
	LDR	R0, [R2]
	BL	fifo_push
	BL	fifo_pop
	LDR	R0, =stack1_end
	BL	fifo_push
	BL	fifo_pop
	LDR	R0, =coremain
	BL	fifo_push
	BL	fifo_pop
	POP	{PC}

.align 4
siobase:	.WORD	SIO_BASE
ppbbase:	.WORD	PPB_BASE
vtoroffset:	.WORD	M0PLUS_VTOR_OFFSET
@ Spinlock 24 is first one available for exlucive use.
spinbase:	.WORD	SIO_BASE + SIO_SPINLOCK24_OFFSET

.align 4
.data
stack1:		.FILL	0x800, 1, 0
stack1_end:	.WORD	0
table:		.FILL	numEntries * sizeTabRow, 1, emptyRow
