#!/usr/bin/env python

import serial
import time
import sys
from binascii import b2a_hex

class Driver:
    def __init__(self, port="/dev/ttyUSB0",baud=38400, interpolation=False, direct=False):
        """ This may throw errors up the line -- that's a good thing. """
        self.ser = serial.Serial()
        self.ser.baudrate = baud
        self.ser.port = port
        self.ser.timeout = 0.5
        self.ser.open()
        self.error = 0
        self.hasInterpolation = interpolation
        self.direct = direct

  

    

