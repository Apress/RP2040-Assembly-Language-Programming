@
@ Example using the second core for processing.
@

#include "hardware/regs/addressmap.h"
#include "hardware/regs/m0plus.h"
#include "hardware/regs/sio.h"

.thumb_func		    @ Necessary because sdk uses BLX
.global main	            @ Provide program starting address to linker

main:	BL	stdio_init_all	@ initialize uart or usb

	BL	launch_core1

	MOV	R4, #0		@ i = 0
	LDR	R5, numNumbers
	LDR	R6, =numbers 
forloop: CMP	R4, R5
	BGE	mainloop
	LDR	R0, [R6]	@ next number
	BL	fifo_push
	LDR	R0, [R6]
	BL	fibonacci
	MOV	R2, R0
	LDR	R1, [R6]
	LDR	R0, =fibprintstr
	BL	printf
	ADD	R4, #1		@ i = i + 1
	ADD	R6, #4		@ next word in numbers
	
	B	forloop
mainloop:
	B	mainloop

.align 4
numNumbers:	.WORD	5
numbers:	.WORD	3, 5, 7, 10, 12
fibprintstr:	.ASCIZ	"Core 0 n = %d fibonacci = %d\n"
factprintstr: 	.ASCIZ	"Core 1 n = %d factorial = %d\n"

.thumb_func
core1entry:
	PUSH	{LR}
infinite:	BL	fifo_pop @ read number to calculate
	MOV	R4, R0	@ keep n for the printf
	BL	factorial	@ call factorial
	MOV	R2, R0		@ set parameters for printf
	MOV	R1, R4
	LDR	R0, =factprintstr
	BL	printf
	B	infinite	@ repeat for next number
	POP	{PC}		@ never called.

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
	LDR	R0, =core1entry
	BL	fifo_push
	BL	fifo_pop
	POP	{PC}

.align 4
siobase:	.WORD	SIO_BASE
ppbbase:	.word	PPB_BASE
vtoroffset:	.word	M0PLUS_VTOR_OFFSET
@ stack1:		.word   0x20040800

@ R0 = fibonacci - in R0 since this is what is returned
@ R1 = f0
@ R2 = f1
@ R3 = i
@ R4 = n
fibonacci:
	PUSH	{R4}
	MOV	R4, R0	@ Move n to R4
	MOV	R1, #0	@ Initial f0
	MOV	R2, #1	@ Initial f1
	MOV	R3, #2	@ Initial i = 2
loop:	CMP	R3, R4
	BGT	done
	ADD	R0, R1, R2	@ fibonacci = f0 + f1
	MOV	R1, R2		@ f0 = f1
	MOV	R2, R0		@ f1 = fibonacci
	ADD	R3, #1		@ i = i + 1
	B	loop
done:	POP	{R4}
	BX	LR		@ result is in R0

@ R0 = factorial
@ R1 = i
@ R2 = n
factorial:
	MOV	R2, R0	@ Move n to R2
	MOV	R0, #1	@ Initial factorial
	MOV	R1, #2	@ i = 2
loop2:	CMP	R1, R2
	BGT	done2
	MUL	R0, R1	@ factorial *= i
	ADD	R1, #1	@ i = i + 1
	B	loop2
done2:	BX	LR	@ result is in R0

.align 4
.data
stack1:		.FILL	0x800, 1, 0
stack1_end:	.WORD	0

