@
@ Assembly Language program to answer polls from
@ a server and respond with the current temperature.
@

@ States for the state machine
.EQU	SOH_State, 1
.EQU	ADDR_State, 2
.EQU	ETX_State, 3

@ Special protocol characters
.EQU	SOHChar, 1
.EQU	STXChar, 2
.EQU	ETXChar, 3
.EQU	TermAddrChar, 49

.thumb_func
.global main	        @ Provide program starting address

main:
@ Init the devices
	BL	initTempSensor
	BL	initUART

loop:
@ Starting state is waiting for SOH
	MOV	R7, #SOH_State @ state
       
waitforpoll:
	BL	readUART	@ read next char

	@ switch( state = R7 )
	CMP	R7, #SOH_State	@ are we waiting for SOH?
	BNE	AddrStateCheck  @ no, check address state
	CMP	R0, #SOHChar	@ did we read an SOH?
	BNE	waitforpoll	@ no read another character
	MOV	R7, #ADDR_State @ yes switch to address state
	B	waitforpoll	@ wait for next character
AddrStateCheck:	
	CMP	R7, #ADDR_State @ are we waiting for address?
	BNE	EtxStateCheck	@ no, check ETX state
	CMP	R0, #TermAddrChar @ is it our address?
	BEQ	gotaddr		@ yes, goto gotaddr
	MOV	R7, #SOH_State	@ no, go back to SOH state
	B	waitforpoll	@ get next char
gotaddr:MOV	R7, #ETX_State	@ got address, so goto ETX state
	B	waitforpoll	@ get next char

EtxStateCheck:
	CMP	R0, #ETXChar 	@ did we get an ETX char?
	BEQ	gotetx		@ yes, goto gotetx
	MOV	R7, #SOH_State	@ no, go back to SOH state
	B	waitforpoll	@ get next char

gotetx: 
@ received a poll, so send a response packet
	MOV	R0, #SOHChar
	BL	sendUART	@ send SOH
	MOV	R0, #TermAddrChar
	BL	sendUART	@ send Address
	MOV	R0, #STXChar
	BL	sendUART	@ send STX

	BL	readTemp	@ read the temperature

	BL	calcTempCelc	@ convert to degrees C

	LDR	R1, =tempStr	@ msg template
	ADD	R1, #6	@ after Temp:
	BL	itoa	@ raw temp value is still in R0
	
	LDR	R5, =tempStr

@ Copy the msg string pointed to by R5 out the UART
nextchar:	LDRB	R0, [R5]
	CMP	R0, #0	@ String is null terminated
	BEQ	done	@ Are we done (at null)?
	BL	sendUART@ No, then send the character
	ADD	R5, #1	@ Next character
	B	nextchar	

@ Message is sent, so just need to send ETX character
done:
	MOV	R0, #ETXChar
	BL	sendUART

@ This poll is finished, go back and wait for another
        B       loop	@ loop forever

.data
@ template for temperature message string
tempStr:	.asciz  "Temp:           "

