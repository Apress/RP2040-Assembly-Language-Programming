import serial
import time
from enum import Enum

class protocolState(Enum):
    SOH = 1
    ADDR = 2
    STX = 3
    MSG = 4
    
def sendPollreadResp(addr):
    ser.write(bytearray([1, addr, 3]))
    state = protocolState.SOH
    msg = bytes()
    while 1:
        x = ser.read()
        if x == b'':
                return( bytearray([0]) )
        elif state == protocolState.SOH:
                if x[0] == 1:
                    state = protocolState.ADDR
        elif state == protocolState.ADDR:
                if x[0] == addr:
                    state = protocolState.STX
                else:
                    return( bytearray([0]) )
        elif state == protocolState.STX:
                if x[0] == 2:
                    state = protocolState.MSG
                else:
                    return( bytearray([0]) )
        elif state == protocolState.MSG:
                if x[0] == 3:
                    return msg
                else:
                    msg = msg + x 
    
    return( bytearray([0]) )
            
ser = serial.Serial(
        port = '/dev/serial0',
        baudrate = 115200,
        timeout=1
        )

while 1:
    for addr in range(49, 53):
        msg = sendPollreadResp(addr)
        print( msg )
        # time.sleep(1)
        
