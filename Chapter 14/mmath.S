@
@ Some useful math support routines including:
@   1. Divide two integers using the coprocessor
@   2. Convert an integer to ascii (in decimal)
@

#include "hardware/regs/addressmap.h"
#include "hardware/regs/sio.h"

.thumb_func
.global intDivide, itoa

@ macro to delay 8 clock cyles,
@ the time it takes to divide
.macro	divider_delay
	// delay 8 cycles
	b	1f
1:	b	1f
1:	b	1f
1:	b	1f
1:
.endm

@ Function to divide two 32-bit integers
@ Inputs:	R0 - Dividend
@		R1 - Divisor
@ Outputs:	R0 - Quotient
@		R1 - Remainder
@
intDivide:
	LDR	R3, =SIO_BASE
	STR	R0, [R3, #SIO_DIV_SDIVIDEND_OFFSET]	
	STR	R1, [R3, #SIO_DIV_SDIVISOR_OFFSET]
	divider_delay
	LDR	R1, [R3, #SIO_DIV_REMAINDER_OFFSET]
	LDR	R0, [R3, #SIO_DIV_QUOTIENT_OFFSET]
	BX	LR

@ Function to convert a 32 bit integer to ASCII
@ Inputs:	R0 - number to convert
@		R1 - pointer to buffer for ASCII string
@ Outputs:	R1 - contains the string
@
@ R7 - flag whether number positive or negative.
@ R6 - original buffer (since we increment R1 as we go along).
@ R4 - holds R1 around function calls (since they overwrite it)
@ R2, R3 - temp variables for reversing buffer
@
@ Builds the buffer in reverse by dividing by 10, placing the
@ remainder in the buffer and repeating, then at the end adding
@ a minus sign if needed. Then reverses the buffer to get
@ the correct order
itoa:
	PUSH	{R4, R6, R7, LR}
	MOV	R6, R1	@ original buffer
	MOV	R7, #0	@ assume number is positive
	CMP	R0, #0	@ is number positive
	BPL	convertdigits
	MOV	R7, #1	@ number is negative
	NEG	R0, R0  @ make number positive

convertdigits:
	MOV	R4, R1	@ preserve R1
	MOV	R1, #10 @ get least sig digit
	BL	intDivide
	ADD	R1, #'0' @ convert digit to ascii
	STRB	R1, [R4] @ store ascii digit in buffer
	MOV	R1, R4	 @ restore R1
	ADD	R1, #1	 @ increment R1 for next character
	CMP	R0, #0	 @ are we done (no more digits)?
	BEQ	finish	 @ yes, go to finish up
	B	convertdigits @ no, loop to do next digit
	
finish:
	CMP	R7, #0		@ is the number negative?
	BEQ	plus
	MOV	R0, #'-'	@ yes, add neg sign	
	STRB	R0, [R1]	@ store neg
	ADD	R1, #1		@ next position for null
plus:	MOV	R0, #0		@ null terminator
	STRB	R0, [R1]	@ null terminate	
	SUB	R1, #1		@ move pointer before null

	@ reverse the buffer
	SUB	R2, R1, R6	@ length of buffer
revloop:	LDRB	R0, [R1] @ get chars to reverse
	LDRB	R3, [R6]	
	STRB	R0, [R6]	@ store reversed
	STRB	R3, [R1]
	SUB	R1, #1		@ decrement end
	ADD	R6, #1		@ increment start
	SUB	R2, #2		@ done two characters
	BPL	revloop		@ still chars to process
	POP	{R4, R6, R7, PC}
