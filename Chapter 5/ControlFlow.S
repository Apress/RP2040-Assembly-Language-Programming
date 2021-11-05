@
@ This file contains the various code
@ snippets from Chapter 5. This ensures
@ they compile and gives you a chance
@ to single step through them.
@ They are labeled, so you can set a
@ breakpoint at the one you are interested in.
@
@ After the code snippets is the routine
@ to convert the contents of a register to ASCII.
@

.thumb_func		    @ Necessary because sdk uses BLX
.global main	            @ Provide program starting address to linker

main:	BL	stdio_init_all	@ initialize uart or usb

@ uncomment the next 2 lines if you want to see
@ an infinite loop
l1:	@ MOV R1, #1
	@B l1

l2:	CMP R4, #45
	BEQ l1

l3:	MOV R2, #1 @ R2 holds I
loop:	@ body of the loop goes here.
	@ Most of the logic is at the end
	ADD R2, #1 @ I = I + 1
	CMP R2, #10
	BLE loop @ IF I &lt;= 10 goto loop

l4:	MOV R2, #10 @R2 holds I
loop2:	@ body of the loop goes here.
	@ The CMP is redundant since we
	@ are doing SUBS.
	SUB R2, #1 @ I = I -1
	BNE loop2 @ branch until I = 0

l5:	@ R4 is X and has been initialized
	MOV R4, #5
loop3:	CMP R4, #5
	BGE loopdone
	@ … other statements in the loop body …
	MOV r4, #6
	B loop3
loopdone: @program continues

l6:	CMP R5, #10
	BGE elseclause
	@ … if statements …
	B endif
elseclause:
	@ … else statements …
endif: @ continue on after the /then/else …

l7:	@ mask off the high order byte
	MOV R5, #0xFF
	LSL R5, #24	@ R5 = 0xFF000000
	AND R6, R5

l8:	MOV R5, #0xFF
	ORR R6, R5

l9:	BIC R6, R5

@ Example to convert contents of register to ASCII
@
@ R0-R1 - parameters printf
@ R1 - is also address of byte we are writing
@ R4 - register to print
@ R5 - loop index
@ R6 - current character
@ R7 - temp register

printexample:
	@ Load R4 with 0x12AB
        MOV	R4, #0x12 @ number to print
	LSL	R4, #8
	MOV	R7, #0xAB
	ADD	R4, R7
	LDR	R1, =hexstr @ start of string
	ADD	R1, #9	    @ start at least sig digit
@ The loop is FOR r5 = 8 TO 1 STEP -1
	MOV	R5, #8	    @ 8 digits to print
loop4:	MOV	R6, R4
	MOV	R7, #0xf
	AND	R6, R7 @ mask of least sig digit
@ If R6 >= 10 then goto letter
	CMP	R6, #10	    @ is 0-9 or A-F
	BGE	letter
@ Else its a number so convert to an ASCII digit
	ADD	R6, #'0'
	B	cont	@ goto to end if
letter: @ handle the digits A to F
	ADD	R6, #('A'-10)
cont:	@ end if
	STRB	R6, [R1]	@ store ascii digit
	SUB	R1, #1		@ decrement address for next digit
	LSR	R4, #4	@ shift off the digit we just processed

	@ next R5
	SUB	R5, #1		@ step R5 by -2
	BNE	loop4		@ another for loop if not done

repeat:
	LDR	R0, =printstr
	LDR	R1, =hexstr @ string to print
	BL	printf
	B	repeat

.align 4
.data
hexstr:      .asciz  "0x12345678"
printstr:    .asciz  "Register = %s\n"