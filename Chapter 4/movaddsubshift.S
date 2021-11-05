@
@ Examples of the MOV/ADD/SUB/Shift instructions.
@

.thumb_func		    @ Necessary because sdk uses BLX
.global main	            @ Provide program starting address to linker

main:	BL	stdio_init_all	@ initialize uart or usb

after:	MOV	R2, #3		@ Move 3 into register R2
	MOV	R1, R2		@ R1 is now also 3
	MOVS	R1, R2		@ the S explicitly states we want the first version.
	MOV	R9, R2		@ R9 now is 3

@ we shouldn't play with SP or PC until we know what we're doing.
	@ MOV	SP, R10	@ SP = R13
	@ MOV	PC, R11	@ PC = R15

	ADD	R4, R2, #7	@ this immediate allows 3 bits, so values 0-7
@ R4 is now 10 (3 + 7)
	ADD	R4, R4, #255	@ this one allows 8-bits, so 0-255
@ R4 is now 265 (10 + 255)
	ADD	R4, #255	@ alternate for for R4 = R4 + 255
@ R4 is now 520(265 + 255) 
	MOV	R7, #23		@ Can't load high registers with immediate
	MOV	R11, R7		@ So load R7 and move it
	MOV	R7, #54
	MOV	R10, R7		@ if one source register is the destination, it can be omitted
	ADD	R10, R10, R11	@ The one instruction to allow high registers
@ R10 is now 77 (23 + 54)
	ADD	SP, SP, #508	@ shouldn’t do this without matching subtraction
	SUB	SP, SP, #508	@ Undo the damage.
	ADD	R4, SP, #1020	@ 8-bit immediate but multiples of 4 so 0-1020 valid
@ need to check R4 in the debugger since it depends on the value of SP
@ when I ran I got 0x200423fc but if SDK changes this could change.

@ Repeat the above shifts using the Assembler mnemonics.

	MOV	R3, #8		@ will use this to shift or rotate 1-byte
	MOV	R2, #0xFF	@ R2 = 255
	MOV	R1, #4		@ R1 = 4
	LSL	R1, R1, #2	@ Shift register R1 left 2 bits (multiply by 4)
	LSL	R1, #2		@ Shorter form if the registers are the same
	LSR	R1, R2, #8	@ Shift R2 right by one bytes and place the result in R1
	LSR	R1, R3		@ Shift R1 right by the value in R3
	ASR	R1, #8		@ Arithmetic shift R1 right by one byte
	ROR	R1, R3		@ Rotate R1 right by value of R3

@ Load 0x12345678 into R3
@ Initialize R3 with the leftmost byte
	MOV	R3, #0x12	@ load the first 8-bits
	LSL	R3, #24	@ shift it left 24 bits into place
@ Load the next byte into R1
	MOV	R1, #0x34	@ load the second byte
	LSL	R1, #16	@ shift it into place
	ADD	R3, R1		@ add it into R1
@ repeat for the third byte
	MOV	R1, #0x56	@ load the third byte
	LSL	R1, #8		@ shit it into place
	ADD	R3, R1		@ add it to the sum
@ for the last byte no shift required
	MOV	R1, #0x78	@ load the fourth bytes
	ADD	R3, R1

@ Other registers for our upcoming 64-bit addition
	MOV	R2, #0x12
	MOV	R4, #0x54
	MOV	R5, #0xf0
	LSL	R5, #24		@ shift f0 over to the high byte

@ 64-bit Addition (rigged to cause a carry)
@ Do sum:
@		R2 R3	0x12 0x12345678
@		R4 R5   0x54 0xF0000000
@		-----
@		R0 R1   0x67 0x02345678

	ADD	R1, R3, R5	@ Lower order word
	ADC	R2, R4		@ Higher order word
	MOV	R0, R2		@ Move the result to where we want it

@ Save R0, R1 since printf will overwrite them
	MOV	R6, R0		@ R6 = R0
	MOV	R7, R1		@ R7 = R1

@ print out the sum
loop:	MOV	R1, R6		@ R1 is param2
	MOV	R2, R7		@ R2 is param3
	LDR	R0, =sumstr	@ load address of sumstr to param1
	BL	printf		@ call printf
	B	loop		@ loop in case uart monitoring not started
.data
	       .align  4	@ necessary alignment
sumstr: .asciz   "The sum is %x %x\n"



