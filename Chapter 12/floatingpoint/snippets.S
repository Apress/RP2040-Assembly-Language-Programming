@
@ Examples of the floating point routines.
@

#include "pico/bootrom/sf_table.h"

.thumb_func		    @ Necessary because sdk uses BLX
.global main	            @ Provide program starting address to linker

	.EQU	datatable, 0x16
	.EQU	helperfn, 0x18

main:	BL	stdio_init_all	@ initialize uart or usb
next:	MOV	R3, #datatable	@ Load data table
	LDRH	R0, [R3]	@ Address of FP routines
	LDRH	R1, code	@ Load the code SF for software float
	MOV	R5, #helperfn	@ address of the helper function
	LDR	R5, [R5]	@ load the helper function start
	BLX	R5		@ call the helper function
	MOV	R5, R0		@ Keep the SF table in R5
	LDR	R4, [R5, #SF_TABLE_FADD] @ Address of add routine
	LDR	R0, number1	@ First number to add
	LDR	R1, number2	@ Second number to add
	BLX	R4		@ Call the _fadd routine
	MOV	R7, R0		@ To calculate the square root later
	LDR	R4, [R5, #SF_TABLE_FLOAT2DOUBLE]	
	BLX	R4	@ Call the _ftod routine
	MOV	R3, R1  @ Move results to input for printf
	MOV	R2, R0  @ ...
done:	LDR	R0, =sumstr
	BL	printf	@ print the sum
	MOV	R0, R7	@ Original sum (32-bit)
	LDR	R4, [R5, #SF_TABLE_FSQRT]
	BLX	R4	@ Perform square root
	LDR	R4, [R5, #SF_TABLE_FLOAT2DOUBLE]	
	BLX	R4	@ Call the _ftod routine
	MOV	R3, R1
	MOV	R2, R0
	LDR	R0, =sqrootstr
	BL	printf

loop:	
	B	loop

.align 4

number1:	.float	12.345
number2:	.float	23.232
result:		.float	35.577
double:		.double 35.577
code:		.ascii	"SF"
.data
	       .align  4	@ necessary alignment
sumstr: .asciz   "The sum is %f\n"
sqrootstr: .asciz "Square root = %f\n"



