@
@ Routines to handle the UART
@

#include "hardware/regs/addressmap.h"
#include "hardware/regs/uart.h"
#include "hardware/regs/io_bank0.h"
#include "hardware/regs/pads_bank0.h"

.thumb_func
.global initUART, readUART, sendUART

@ Function to initialize UART0.
@ Sets 115200 baud, 8 bits, no parity.
@ Enables the devices and configures the gpio pins.
@ No inputs or outputs.
@ Registers used: R0, R1.
@
initUART:
	PUSH	{LR}
	LDR	R1, uart0base
	@ Set baud rate to 115200
	@ See the RP2040 datasheet for the magic values 67 and 52
	MOV	R0, #67
	STR	R0, [R1, #UART_UARTIBRD_OFFSET]
	MOV	R0, #52
	STR	R0, [R1, #UART_UARTFBRD_OFFSET]
	@ Set 8 bits no parity
	MOV	R0, #(UART_UARTLCR_H_WLEN_BITS+UART_UARTLCR_H_FEN_BITS)
	STR	R0, [R1, #UART_UARTLCR_H_OFFSET]
	@ Enable receive and transmit
	MOV	R0, #3		@ enable TX and RX in one shot
	LSL	R0, #UART_UARTCR_TXE_LSB
	ADD	R0, #UART_UARTCR_UARTEN_BITS
	STR	R0, [R1, #UART_UARTCR_OFFSET]

	MOV	R0, #0
	BL	gpioInit
	MOV	R0, #1
	BL	gpioInit
	
	POP	{PC}

@ Function to read a character from the UART.
@ Waits for a character (no timeout) then reads the character.
@ Inputs: none
@ Outputs:	R0 - character read
@ Registers used: R0, R1, R2
readUART:
	LDR	R1, uart0base	@ UART hardware register bank
	@ Wait for a character - that receive fifo isn't empty
waitr:	LDR	R0, [R1, #UART_UARTFR_OFFSET] @ read flag register
	MOV	R2, #UART_UARTFR_RXFE_BITS    @ bits for rx fifo empty
	AND	R0, R2
	BNE	waitr			@ set means fifo empty
	@ Read the character
	LDR	R0, [R1, #UART_UARTDR_OFFSET] @ read the received character
	BX	LR

@ Function to send a character from the UART.
@ Waits for room in the transmit fifo then sends the character.
@ Inputs:	R0 - character to send
@ Outputs: none
@ Registers used: R0, R1, R2, R3
sendUART:
	LDR	R1, uart0base
	@ Wait for transmitter free
waitt:	LDR	R3, [R1, #UART_UARTFR_OFFSET] @ read flag register
	MOV	R2, #UART_UARTFR_TXFF_BITS    @ tx fifo full bits
	AND	R3, R2
	BNE	waitt			      @ set means fifo full
	@ Write the character
	STR	R0, [R1, #UART_UARTDR_OFFSET] @ send the character
	BX	LR



@ Function to initialize the GPIO to UART function.
@ Inputs:	R0 - pin number
@
gpioInit:
@ Enable input and output for the pin
	LDR	R2, padsbank0
	LSL	R3, R0, #2	@ pin * 4 for register address
	ADD	R2, R3		@ Actual set of registers for pin
	MOV	R1, #PADS_BANK0_GPIO0_IE_BITS
	LDR	R4, setoffset
	ORR	R2, R4
	STR	R1, [R2, #PADS_BANK0_GPIO0_OFFSET]

@ Set the function number to UART.
	LSL	R0, #3		@ each GPIO has 8 bytes of registers
	LDR	R2, iobank0	@ address we want
	ADD	R2, R0		@ add the offset for the pin number
	MOV	R1, #IO_BANK0_GPIO0_CTRL_FUNCSEL_VALUE_UART0_TX
	STR	R1, [R2, #IO_BANK0_GPIO0_CTRL_OFFSET]
	BX	LR

		.align	4
uart0base:	.word	UART0_BASE
gpiobase:	.word	SIO_BASE     @ base of the GPIO registers
iobank0:	.word	IO_BANK0_BASE @ base of io config registers
padsbank0:	.word	PADS_BANK0_BASE
setoffset:	.word	REG_ALIAS_SET_BITS
