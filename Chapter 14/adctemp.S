@
@ Module to interface to the RP2040 ADC controller
@ as well as the built-in analog temperature sensor.
@

#include "hardware/regs/addressmap.h"
#include "hardware/regs/adc.h"

.EQU	TEMPADC, 4

.thumb_func
.global calcTempCelc, initTempSensor, readTemp

@ Function to convert raw ADC data to degrees celcius.
@ Calculates degrees = 437 - 100 * R0 / 215
@
@ Registers:
@ Input:	R0 - raw 12-bit ADC value
@ Output:	R0 - degrees celcius
@ Other:	R1 - values to multiply or divide
@
calcTempCelc:
	PUSH	{LR}		@ needed since calls intDivide
	MOV	R1, #100
	MUL	R0, R1		@ R0 = R0 * 100
	MOV	R1, #215
	BL	intDivide	@ R0 = R0 / 215
	LDR	R1, tempcalcoff
	SUB	R0, R1, R0	@ R0 = 437 - R0
	POP	{PC}

@ Initialize the ADC and temperature sensor.
@ No input parameters or return values.
@ Registers used: R1, R2, R3
initTempSensor:
@ Turn on ADC and Temperature Sensor
@ We set the bits to enable the ADC, the temp sensor
@ and select ADC line 4 (tempadc). All these bits are
@ in the ADC status register.
	MOV	R1, #TEMPADC
	LSL	R1, #ADC_CS_AINSEL_LSB
	ADD	R1, #(ADC_CS_TS_EN_BITS+ADC_CS_EN_BITS)
	LDR	R2, adcbase
	STR	R1, [R2, #ADC_CS_OFFSET]

@ It takes a few cycles for these to start up, so wait
@ for the status register to say it is ready.
notReady2:LDR	R1, [R2, #ADC_CS_OFFSET]
	MOV	R3, #1
	LSL	R3, #ADC_CS_READY_LSB
	AND	R1, R3
	BEQ	notReady2	@ not ready, branch
	BX	LR

@ Function to read the temperature raw value.
@ Inputs - none
@ Outputs: 	R0 - the raw ADC temperature value
@ Function requests a reading from the status reguiter
@  then waits for it to complete, then reads and returns
@  the value.
readTemp:
	LDR	R2, adcbase
	LDR	R1, [R2, #ADC_CS_OFFSET]    @ load status register
	ADD	R1, #ADC_CS_START_ONCE_BITS @ add read value once
	STR	R1, [R2, #ADC_CS_OFFSET]    @ write to do it
notReady:LDR	R1, [R2, #ADC_CS_OFFSET]    @ wait for read to complete
	MOV	R3, #1
	LSL	R3, #ADC_CS_READY_LSB	    @ done yet?
	AND	R1, R3
	BEQ	notReady
	LDR	R0, [R2, #ADC_RESULT_OFFSET] @ read result
	BX	LR			     @ return value

		.align	4
adcbase:	.word	ADC_BASE	@ base for analog to digital
tempcalcoff:	.word	437
