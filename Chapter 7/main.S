@
@ Assembly Language program to convert a string to
@ all upper case by calling a function.
@
@ R0 - parameters to printf
@ R1 - address of output string
@ R0 - address of input string
@ R5 - current character being processed
@

.thumb_func	@ Necessary because sdk uses BLX
.global main	@ Provide program starting address to linker

main: 	BL	stdio_init_all	@ initialize uart or usb

repeat:
	LDR	R0, =instr @ start of input string
	LDR	R1, =outstr @ address of output string
	MOV	R4, #12
	MOV	R5, #13

	BL	toupper

	LDR	R0, =outstr @ string to print
	BL	printf

@ Call macro version.
	BL	mainmacro

@ Call code snippets
	BL	codesnippets

	B	repeat	@ loop forever
	
.data
instr:  .asciz  "This is our Test String that we will convert.\n"
outstr:	.fill	255, 1, 0

