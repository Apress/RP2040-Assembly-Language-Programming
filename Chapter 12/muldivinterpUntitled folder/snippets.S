@
@ Examples of the MOV/ADD/SUB/Shift instructions.
@

#include "hardware/regs/addressmap.h"
#include "hardware/regs/sio.h"

.thumb_func		    @ Necessary because sdk uses BLX
.global main	            @ Provide program starting address to linker

.macro	divider_delay
	// delay 8 cycles
	b	1f
1:	b	1f
1:	b	1f
1:	b	1f
1:
.endm

main:	BL	stdio_init_all	@ initialize uart or usb

multi:  @ multiplication examples
	MOV	R2, #25
	MOV	R3, #5
	MUL	R2, R3		@ R2 = 125
	NEG	R3, R3		@ R3 = -5
	MUL	R2, R3		@ R2 = -625

divis:	@ Division examples
	MOV	R0, #11
	MOV	R1, #3
	LDR	R3, =SIO_BASE
	STR	R0, [R3, #SIO_DIV_SDIVIDEND_OFFSET]
	STR	R1, [R3, #SIO_DIV_SDIVISOR_OFFSET]
	divider_delay
	LDR	R1, [R3, #SIO_DIV_REMAINDER_OFFSET]
	LDR	R0, [R3, #SIO_DIV_QUOTIENT_OFFSET]

divis2:	@ Unsigned example
	MOV	R0, #100
	MOV	R1, #3
	LDR	R3, =SIO_BASE
	STR	R0, [R3, #SIO_DIV_UDIVIDEND_OFFSET]
	STR	R1, [R3, #SIO_DIV_UDIVISOR_OFFSET]
	divider_delay
	LDR	R1, [R3, #SIO_DIV_REMAINDER_OFFSET]
	LDR	R0, [R3, #SIO_DIV_QUOTIENT_OFFSET]

.EQU INTERP0_CTRL_LANE0_OFF, (SIO_INTERP0_CTRL_LANE0_OFFSET-SIO_INTERP0_ACCUM0_OFFSET)
.EQU INTERP0_ACCUM0_OFF, (SIO_INTERP0_ACCUM0_OFFSET-SIO_INTERP0_ACCUM0_OFFSET)
.EQU INTERP0_ACCUM0_ADD_OFF, (SIO_INTERP0_ACCUM0_ADD_OFFSET-SIO_INTERP0_ACCUM0_OFFSET)

@ Simple Addition using the interpolator
interp: MOV	R0, #0  @ init value for accum0
	MOV	R1, #4	@ increment for array of nums
	MOV	R2, #1	@ decrement for counter
	LDR	R3, INTERP_BASE	
	MOV	R4, #1
	LSL	R4, #SIO_INTERP0_CTRL_LANE0_ADD_RAW_LSB
	STR	R4, [R3, #INTERP0_CTRL_LANE0_OFF]
	STR	R0, [R3, #INTERP0_ACCUM0_OFF]
	LDR	R7, numsumdata
	LDR	R6, =sumdata	
nextnum:LDR	R4, [R6]
	STR	R4, [R3,#INTERP0_ACCUM0_ADD_OFF]
	ADD	R6, R1
	SUB	R7, R2
	BNE	nextnum
	LDR	R0, [R3, #INTERP0_ACCUM0_OFF]
done:	NOP

.EQU INTERP0_BASE0_OFF, (SIO_INTERP0_BASE0_OFFSET-SIO_INTERP0_ACCUM0_OFFSET)
.EQU INTERP0_BASE1_OFF, (SIO_INTERP0_BASE1_OFFSET-SIO_INTERP0_ACCUM0_OFFSET)
.EQU INTERP0_ACCUM1_OFF, (SIO_INTERP0_ACCUM1_OFFSET-SIO_INTERP0_ACCUM0_OFFSET)
.EQU INTERP0_PEEK1_OFF, (SIO_INTERP0_PEEK_LANE1_OFFSET-SIO_INTERP0_ACCUM0_OFFSET)
.EQU INTERP0_POP1_OFF, (SIO_INTERP0_POP_LANE1_OFFSET-SIO_INTERP0_ACCUM0_OFFSET)
.EQU INTERP0_CTRL_LANE1_OFF, (SIO_INTERP0_CTRL_LANE1_OFFSET-SIO_INTERP0_ACCUM0_OFFSET)

@ Simple interpolation
interp2:MOV	R0, #0  @ init value for accum1
	MOV	R1, #4	@ increment for array of nums
	MOV	R2, #1	@ decrement for counter
	MOV	R3, #63
	MOV	R8, R3
	LDR	R3, INTERP_BASE	
	MOV	R4, #1
	LSL	R4, #SIO_INTERP0_CTRL_LANE0_BLEND_LSB
	MOV	R5, #1
	LSL	R5, #SIO_INTERP0_CTRL_LANE0_ADD_RAW_LSB
	ORR	R4, R5
	STR	R4, [R3, #INTERP0_CTRL_LANE0_OFF]
	MOV	r4, #248	@ 0xf8
	LSL	r4, r4, #7	@ becomes 0x7c00
	STR	R4, [R3, #INTERP0_CTRL_LANE1_OFF]
	STR	R0, [R3, #INTERP0_ACCUM0_OFF]
	LDR	R7, numsumdata
	LDR	R6, =sumdata	
nextnum2:LDR	R4, [R6]
	STR	R4, [R3,#INTERP0_BASE0_OFF]
	ADD	R6, R1
	LDR	R4, [R6]
	STR	R4, [R3,#INTERP0_BASE1_OFF]
	STR	R0, [R3,#INTERP0_ACCUM1_OFF]
	ADD	R0, R8
	LDR	R4, [R3,#INTERP0_PEEK1_OFF]
	STR	R4, [R3,#INTERP0_ACCUM0_ADD_OFF]
	ADD	R6, R1
	SUB	R7, R2
	BNE	nextnum2
	@ Read the sum stored in accumulator 0
	LDR	R0, [R3, #INTERP0_ACCUM0_OFF]
done2:	NOP

@ print out the sum
loop:	MOV	R1, R6		@ R1 is param2
	MOV	R2, R7		@ R2 is param3
	LDR	R0, =sumstr	@ load address of sumstr to param1
	BL	printf		@ call printf
	B	loop		@ loop in case uart monitoring not started

.align 4

INTERP_BASE:	.word	SIO_BASE + SIO_INTERP0_ACCUM0_OFFSET
numsumdata:	.word	4
sumdata:	.word	1, 100, 56, 66, 1000, 2000, 43, 97

.data
	       .align  4	@ necessary alignment
sumstr: .asciz   "The sum is %x %x\n"



