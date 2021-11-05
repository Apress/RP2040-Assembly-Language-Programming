@
@ This file contains the various code
@ snippets from Chapter 6. This ensures
@ they compile and gives you a chance
@ to single step through them.
@ They are labeled, so you can set a
@ breakpoint at the one you are interested in.

.global codesnippets

codesnippets: 
	PUSH	{R3-R7, LR}

l1:	PUSH	{r0, r5-r7}
	POP	{r0, r5-r7}
	PUSH	{r0-r4, r6}
	POP 	{r0-r4, r6}

l2:	BL	myfunc
	MOV	R1, #4
	B	l3

myfunc:	@ do some work
	BX	LR

l3:	BL	myfuncb
	MOV	R1, #4
	B 	l4

myfuncb:PUSH {LR}
@ do some work …
	BL	myfuncb2
@ do some more work...
	POP {PC}

myfuncb2:	@ do some work ....
	BX LR

l4:	SUB	SP, #12

l5:	STR	R0, [SP]	@ Store a
	STR	R1, [SP, #4]	@ Store b
	STR	R2, [SP, #8]	@ Store c 

l6:	ADD	SP, #12

@l7:	MOV	R0, #4
@	SUB	FP, SP, R0
@	SUB	SP, #12

@l8:	STR	R0, [FP]	@ Store a
@	STR	R1, [FP, #-4]	@ Store b
@	STR	R2, [FP, #-8]	@ Store c
@	ADD	SP, #12

l9:	BL	SUMFN
	B	l10

@ Simple function that takes 2 parameters
@ VAR1 and VAR2. The function adds them,
@ storing the result in a variable SUM.
@ The function returns the sum.
@ It is assumed this function does other work,
@ including other functions.

@ Define our variables
	.EQU	VAR1, 0
	.EQU	VAR2, 4
	.EQU	SUM,  8

SUMFN:	PUSH	{R4-R7, LR}
	SUB	SP, #12	@ room for three 32-bit values
	STR	R0, [SP, #VAR1]	@ save passed in param.
	STR	R1, [SP, #VAR2]	@ save second param.

@ Do bunch of other work, but don’t change SP.

	LDR	R4, [SP, #VAR1]
	LDR	R5, [SP, #VAR2]
	ADD	R6, R4, R5
	STR	R6, [SP, #SUM]

@ Do other work

@ Function Epilog
	LDR	R0, [SP, #SUM]	@ load sum to return
	ADD	SP, #12	@ Release local vars
	POP	{R4-R7, PC} @ Restore regs and return

l10: 	
	POP	{R3-R7, PC}

