@
@ Assembler program to convert a string to
@ all upper case.
@
@ R1 - address of output string
@ R0 - address of input string
@ R4 - original output string for length calc.
@ R5 - current character being processed
@

.global mytoupper	     @ Allow other files to call this routine

mytoupper:	PUSH	{R4-R5}	@ Save the registers we use.
	MOV	R4, R1
@ The loop is until byte pointed to by R1 is non-zero
loop:	LDRB	R5, [R0]	@ load character
	ADD	R0, #1		@ increment instr pointer
@ If R5 > 'z' then goto cont
	CMP	R5, #'z'	    @ is letter > 'z'?
	BGT	cont
@ Else if R5 < 'a' then goto end if
	CMP	R5, #'a'
	BLT	cont	@ goto to end if
@ if we got here then the letter is lower case, so convert it.
	SUB	R5, #('a'-'A')
cont:	@ end if
	STRB	R5, [R1]	@ store character to output str
	ADD	R1, #1		@ increment outstr pointer
	CMP	R5, #0		@ stop on hitting a null character
	BNE	loop		@ loop if character isn't null
	SUB	R0, R1, R4  @ get the length by subtracting the pointers
	POP	{R4-R5}		@ Restore the register we use.
	BX	LR		@ Return to caller
