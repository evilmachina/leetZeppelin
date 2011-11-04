import cwiid
import logging
import inspect
from time import sleep

class Wiimote:
   

    def __init__(self,connect=True):
        if connect == True:
            self.connect()

    def connect(self):
        print 'Put Wiimote in discoverable mode now (press 1 & 2)'
        self.led=0
        self.wiimote = cwiid.Wiimote()
        self.wiimote.rpt_mode =  cwiid.RPT_NUNCHUK|cwiid.RPT_ACC|cwiid.RPT_BTN
        self.toggleLED('1')
        self.toggleLED('4')
        self.rumble()
        print "Connection established"
        return self.wiimote

    def toggleLED(self,c):
       
        if c == '1':
                self.led ^= cwiid.LED1_ON
        elif c == '2':
                self.led ^= cwiid.LED2_ON
        elif c == '3':
                self.led ^= cwiid.LED3_ON
        elif c == '4':
                self.led ^= cwiid.LED4_ON
        self.wiimote.led = self.led
       
    def rumble(self,time=0.5):
        self.wiimote.rumble = 1
        sleep(time)
        self.wiimote.rumble = 0

    def get_accelerometer(self):
        x = self.wiimote.state['acc'][cwiid.X]
        y = self.wiimote.state['acc'][cwiid.Y]
        return x,y
               
    def print_accelerometer(self):
        x,y = self.get_accelerometer()
        return "pitch: %d %d" % (x, y)
       
    def get_status(self):
        return self.wiimote.state
       

    def calc_action(self):
        x = self.wiimote.state['acc'][cwiid.X]
        y = self.wiimote.state['acc'][cwiid.Y]
        if(x<120): #left
            return "l"
        elif(x>130): #right
            return "r"
        elif(y>130): #down
            return "f"
        elif(y<120): #up
            return "b"
        else:
            return "s"


