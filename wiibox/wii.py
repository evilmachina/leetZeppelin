# easy_install -U pyserial

import io
import serial
import array

def a2s(arr):
    """ Array of integer byte values --> binary string
    """
    return ''.join(chr(b) for b in arr)

clear = [0x13, 0x37, 0x7f, 0x7f, 0x7f]

clearstr = a2s(clear)

print clearstr

ser = serial.Serial('/dev/tty.usbserial', 57600)
ser.write(clearstr)