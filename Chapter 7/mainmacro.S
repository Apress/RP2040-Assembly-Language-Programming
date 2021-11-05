@
@ Assembler program to convert a string to
@ all upper case by calling a function.
@
@ R0 - parameters to printf
@ R1 - address of output string
@ R0 - address of input string
@ R5 - current character being processed
@

.include "uppermacro.S"

.global mainmacro	            @ Provide program starting address to linker

mainmacro: PUSH	{LR}

	toupper tststr, buffer

	LDR	R0, =buffer @ string to print
	BL	printf

	toupper tststr2, buffer

	LDR	R0, =buffer @ string to print
	BL	printf

	POP	{PC}

.data
tststr:  .asciz  "This is our Test String that we will convert.\n"
tststr2: .asciz	 "A second string to upper case!!\n"
buffer:	.fill	255, 1, 0

