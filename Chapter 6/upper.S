@
@ Assembler program to convert a string to
@ all upper case.
@
@ R0-R2 - parameters to linux function services
@ R3 - address of output string
@ R4 - address of input string
@ R5 - current character being processed
@ R7 - linux function number
@

.global toupper           @ Provide program starting address to linker

toupper: PUSH	{LR}	@ Save return address

	LDR	R4, =instr @ start of input string
	LDR	R3, =outstr @ address of output string
@ The loop is until byte pointed to by R1 is non-zero
loop:	LDRB	R5, [R4]	@ load character
	ADD	R4, #1		@ increment pointer
@ If R5 > 'z' then goto cont
	CMP	R5, #'z'	    @ is letter > 'z'?
	BGT	cont
@ Else if R5 < 'a' then goto end if
	CMP	R5, #'a'
	BLT	cont	@ goto to end if
@ if we got here then the letter is lower case, so convert it.
	SUB	R5, #('a'-'A')
cont:	@ end if
	STRB	R5, [R3]	@ store character to output str
	ADD	R3, #1		@ incrment pointer
	CMP	R5, #0		@ stop on hitting a null character
	BNE	loop		@ loop if character isn't null

@ Setup the parameters to printf our upper case string
	LDR	R0, =outstr @ string to print
	BL	printf 	    @ Call printf to output

	POP	{PC}	    @ Pop return address into PC to return

.data
instr:  .asciz  "This is our Test String that we will convert.\n"
outstr:	.fill	255, 1, 0

