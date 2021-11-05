@
@ Assembler program to flash three LEDs connnected to the
@ Raspberry Pi GPIO using timer interrupts to trigger the
@ next LED to flash.
@

#include "hardware/regs/addressmap.h"
#include "hardware/regs/sio.h"
#include "hardware/regs/timer.h"
#include "hardware/regs/io_bank0.h"
#include "hardware/regs/pads_bank0.h"
#include "hardware/regs/m0plus.h"

	.EQU LED_PIN1, 18
	.EQU LED_PIN2, 19
	.EQU LED_PIN3, 20

	.EQU alarm0_isr_offset, 0x40

.thumb_func		@ Needed since SDK uses BX to call us
.global main	        @ Provide program starting address

	.align  4	@ necessary alignment
main:
	BL	stdio_init_all	@ initialize uart or usb

@ Init each of the three pins and set them to output
	MOV	R0, #LED_PIN1		
	BL	gpioinit
	MOV	R0, #LED_PIN2
	BL	gpioinit
	MOV	R0, #LED_PIN3
	BL	gpioinit

	BL	set_alarm0_isr	@ set the interrupt handler
	LDR	R0, alarmtime	@ load the time to sleep
	BL	set_alarm0	@ set the first alarm

	MOV	R7, #0		@ counter
loop:
	LDR	R0, =printstr	@ string to print
	MOV	R1, R7		@ counter
	BL	printf		@ print counter
	MOV	R0, #1		@ add 1
	ADD	R7, R0		@   to counter
       
        B       loop	@ loop forever

set_alarm0:
	@ Set's the next alarm on alarm 0
	@ R0 is the length of the alarm

	@ Enable timer 0 interrupt
	LDR	R2, timerbase
	MOV	R1, #1		@ for alarm 0
	STR	R1, [R2, #TIMER_INTE_OFFSET]

	@ Set alarm 
	LDR	R1, [R2, #TIMER_TIMELR_OFFSET]
	ADD	R1, R0
	STR	R1, [R2, #TIMER_ALARM0_OFFSET]

	BX	LR

.thumb_func	@ necessary for interrupt handlers
@ Alarm 0 interrupt handler and state machine.
alarm_isr:
	PUSH	{LR}	@ calls other routines
	@ Clear the interrupt
	LDR	R2, timerbase
	MOV	R1, #1		@ for alarm 0
	STR	R1, [R2, #TIMER_INTR_OFFSET]

	@ Disable/enable LEDs based on state
	LDR	R2, =state @ load address of state
	LDR	R3, [R2]   @ load value of state
	MOV	R0, #1
	ADD	R3, R0	   @ increment state
	STR	R3, [R2]   @ save state
step1:	MOV	R1, #1	   @ case state == 1
	CMP	R3, R1
	BNE	step2	   @ not == 1 check next
	MOV	R0, #LED_PIN1	
	BL	gpio_on
	MOV	R0, #LED_PIN2
	BL	gpio_off
	MOV	R0, #LED_PIN3
	BL	gpio_off
	B	finish
step2:	MOV	R1, #2	@ case state == 2
	CMP	R3, R1
	BNE	step3	@ not == 2 then case else
	MOV	R0, #LED_PIN1	
	BL	gpio_off
	MOV	R0, #LED_PIN2
	BL	gpio_on
	MOV	R0, #LED_PIN3
	BL	gpio_off	
	B	finish
step3:	MOV	R0, #LED_PIN1	@ case else
	BL	gpio_off
	MOV	R0, #LED_PIN2
	BL	gpio_off
	MOV	R0, #LED_PIN3
	BL	gpio_on
	MOV	R3, #0	   @ set state back to zero
	LDR	R2, =state @ load address of state
	STR	R3, [R2]   @ save state == 0

finish:	LDR	R0, alarmtime	@ sleep time
	BL	set_alarm0	@ set next alarm
	POP	{PC}		@ return from interrupt

set_alarm0_isr:
	@ Set IRQ Handler to our routine
	LDR	R2, ppbbase
	LDR	R1, vtoroffset
	ADD	R2, R1
	LDR	R1, [R2]
	MOV	R2, #alarm0_isr_offset @ slot for alarm 0
	ADD	R2, R1
	LDR	R0, =alarm_isr
	STR	R0, [R2]

	@ Enable alarm 0 IRQ (clear then set)
	MOV	R0, #1	@ alarm 0 is IRQ0
	LDR	R2, ppbbase
	LDR	R1, clearint
	ADD	R1, R2
	STR	R0, [R1]
	LDR	R1, setint
	ADD	R1, R2
	STR	R0, [R1]
	
	BX	LR

@ Initialize the GPIO to SIO. r0 = pin to init.
gpioinit:
@ Initialize the GPIO	
	MOV	R3, #1
	LSL	R3, R0	@ shift over to pin position
	LDR	R2, gpiobase	@ address we want	
	STR	R3, [R2, #SIO_GPIO_OE_SET_OFFSET]
	STR	R3, [R2, #SIO_GPIO_OUT_CLR_OFFSET]

@ Enable input and output for the pin
	LDR	R2, padsbank0
	LSL	R3, R0, #2	@ pin * 4 for register address
	ADD	R2, R3		@ Actual set of registers for pin
	MOV	R1, #PADS_BANK0_GPIO0_IE_BITS
	LDR	R4, setoffset
	ORR	R2, R4
	STR	R1, [R2, #PADS_BANK0_GPIO0_OFFSET]

@ Set the function number to SIO.
	LSL	R0, #3		@ each GPIO has 8 bytes of registers
	LDR	R2, iobank0	@ address we want
	ADD	R2, R0		@ add the offset for the pin number
	MOV	R1, #IO_BANK0_GPIO3_CTRL_FUNCSEL_VALUE_SIO_3
	STR	R1, [R2, #IO_BANK0_GPIO0_CTRL_OFFSET]
	BX	LR

@ Turn on a GPIO pin.
gpio_on:
	MOV	R3, #1
	LSL	R3, R0	@ shift over to pin position
	LDR	R2, gpiobase	@ address we want
	STR	R3, [R2, #SIO_GPIO_OUT_SET_OFFSET]
	BX	LR

@ Turn off a GPIO pin.
gpio_off:
	MOV	R3, #1
	LSL	R3, R0	@ shift over to pin position
	LDR	R2, gpiobase	@ address we want
	STR	R3, [R2, #SIO_GPIO_OUT_CLR_OFFSET]
	BX	LR

	      	.align  4	@ necessary alignment
gpiobase:	.word	SIO_BASE     @ base of the GPIO registers
iobank0:	.word	IO_BANK0_BASE @ base of io config registers
padsbank0:	.word	PADS_BANK0_BASE
setoffset:	.word	REG_ALIAS_SET_BITS
timerbase:	.word	TIMER_BASE
ppbbase:	.word	PPB_BASE
vtoroffset:	.word	M0PLUS_VTOR_OFFSET
clearint:	.word	M0PLUS_NVIC_ICPR_OFFSET
setint:		.word	M0PLUS_NVIC_ISER_OFFSET
alarmtime:	.word	200000
printstr:	.asciz	"Couting %d\n"

.data
state:		.word	0




