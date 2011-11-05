from wiimote import Wiimote
import os
from time import sleep
import math
import cwiid
from acc import TiltCalculator

def calculate_tilt(acc1):
  X = acc1[cwiid.X]
  Y = acc1[cwiid.Y]
  Z = acc1[cwiid.Z]
  pitch = math.atan(Y/math.sqrt(X*X + Z*Z))  
  roll = math.atan(X/math.sqrt(Y*Y + Z*Z))
  return 30 - math.degrees(pitch), 30 - math.degrees(roll)


mote = Wiimote()
#nunchukTilt = TiltCalculator()
#nunchukTilt.wmplugin_init(mote.wiimote)
moteTilt = TiltCalculator()
moteTilt.wmplugin_init(mote.wiimote)
while(1):
  os.system("clear")
  print mote.get_status()
  status = mote.get_status()
  print "mote pitch: %d roll: %d" % moteTilt.wmplugin_exec(status['acc'])
  #print "nunchukTilt pitch: %d roll: %d" % nunchukTilt.wmplugin_exec(status['nunchuk']['acc'])
  #print "nunchuk stick: X: %d Y: %d" % status['nunchuk']['stick'] 
  print 'Button Report: %.4X' % (int(status['buttons'])&4)


 # sleep(0.2)
#mote.connect()


