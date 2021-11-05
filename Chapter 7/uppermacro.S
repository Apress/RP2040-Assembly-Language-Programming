@
@ Assembler program to convert a string to
@ all upper case.
@
@ R1 - address of output string
@ R0 - address of input string
@ R2 - original output string for length calc.
@ R3 - current character being processed
@

@ label 1 = loop
@ label 2 = cont

.MACRO	toupper	instr, outstr
	LDR	R0, =\instr
	LDR	R1, =\outstr
	MOV	R2, R1
@ The loop is until byte pointed to by R1 is non-zero
1:	LDRB	R3, [R0]	@ load character
	ADD	R0, #1		@ increment instr poitner
@ If R5 > 'z' then goto cont
	CMP	R3, #'z'	    @ is letter > 'z'?
	BGT	2f
@ Else if R5 < 'a' then goto end if
	CMP	R3, #'a'
	BLT	2f	@ goto to end if
@ if we got here then the letter is lower case, so convert it.
	SUB	R3, #('a'-'A')
2:	@ end if
	STRB	R3, [R1]	@ store character to output str
	ADD	R1, #1		@ increment outstr pointer
	CMP	R3, #0		@ stop on hitting a null character
	BNE	1b		@ loop if character isn't null
	SUB	R0, R1, R2	@ get the length by subtracting the pointers
.ENDM
