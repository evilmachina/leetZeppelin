from wiimote import Wiimote
import time, sys, serial
import os

import math
import cwiid
from acc import TiltCalculator
import wx
from driver import Driver


class hexCommander(wx.Frame):
	ID_PORT=wx.NewId()
	ID_WIIMOTE=wx.NewId()

	TIMER_ID = 100
	ID_TIMER=wx.NewId()

	ser = None

	def __init__(self): 
		wx.Frame.__init__(self, None, -1, "leet Commander", style = wx.DEFAULT_FRAME_STYLE & ~ (wx.RESIZE_BORDER | wx.MAXIMIZE_BOX))
 
		#self.ser = ser 
                self.port = None 
		self.wiimote = None  
		menubar = wx.MenuBar()
		configmenu = wx.Menu()
		controller = wx.Menu()

        	configmenu.Append(self.ID_PORT,"port")
		menubar.Append(configmenu, "config") 
                wx.EVT_MENU(self, self.ID_PORT, self.doPort)

		controller.Append(self.ID_WIIMOTE,"wiimote")
		menubar.Append(controller, "connect") 
                wx.EVT_MENU(self, self.ID_WIIMOTE, self.doWiimote)

	 	self.sb = self.CreateStatusBar(3)
		self.sb.SetStatusWidths([-1,150])
		self.sb.SetStatusText('robot not connected',1)
		self.sb.SetStatusText('wiimote not connected',2)
		self.SetMenuBar(menubar)

			

		self.timer = wx.Timer(self, self.ID_TIMER)
        	self.timeout = 0

		self.timer = wx.Timer(self, self.TIMER_ID)
        	self.timer.Start(33)
        	wx.EVT_CLOSE(self, self.onClose)
        	wx.EVT_TIMER(self, self.TIMER_ID, self.onTimer)
		self.Show(True)

		
	def onTimer(self, event=None):
		# configure output
		if self.port != None and self.wiimote != None:		
			
			status = self.wiimote.get_status()
		
			
			mpitch, mroll = self.moteTilt.wmplugin_exec(status['acc'])
			tilt = 127 + int(mroll)
			if tilt > 217:
			   tilt = 217
			if tilt < 37:
			   tilt = 37
			
			leftMotor = 127	
			rightMotor = 127

			if (int(status['buttons'])&1) > 0:
			   leftMotor = 126	
			   rightMotor = 126
			elif (int(status['buttons'])&2) > 0:
			   leftMotor = 128	
			   rightMotor = 128
			elif (int(status['buttons'])&2048) > 0:
			   leftMotor = 128	
			   rightMotor = 126
			elif (int(status['buttons'])&1024) > 0:
			   leftMotor = 126	
			   rightMotor = 128

			if mpitch > 45:
			   leftMotor = 127
			if mpitch < -45:
			   rightMotor = 127
			
			tvb = 0;
			if (int(status['buttons'])&4) > 0:
			 tvb = 255;

			self.sendPacket(leftMotor, rightMotor, tilt, tvb)
			self.timer.Start(200)
		if self.ser != None:
			value = self.ser.read(3)
			if value == "low":
				self.wiimote.rumble = 1


	def sendPacket(self, leftMotor, rightMotor, tilt, tvb):
		self.ser.write(chr(int('13', 10)))
		
		self.ser.write(chr(leftMotor))
		self.ser.write(chr(rightMotor))
		self.ser.write(chr(tilt))
		self.ser.write(chr(tvb))
		self.ser.write(chr(int('10', 10)))

    	def onClose(self, event):
		try:
        		self.timer.Stop()
        		self.sendPacket(128,128,128,128,0)
        		self.Destroy()
		except:
		        pass

	
        
        def findPorts(self):
		""" return a list of serial ports """
		self.ports = list()
		# windows first
		for i in range(20):
		    try:
		        s = serial.Serial("COM"+str(i))
		        s.close()
		        self.ports.append("COM"+str(i))
		    except:
		        pass
		if len(self.ports) > 0:
		    return self.ports
		# mac specific next:        
		try:
		    for port in os.listdir("/dev/"):
		        if port.startswith("tty.usbserial"):
		            self.ports.append("/dev/"+port)
		except:
		    pass
		# linux/some-macs
		for k in ["/dev/ttyUSB","/dev/ttyACM","/dev/ttyS"]:
		        for i in range(6):
		            try:
		                s = serial.Serial(k+str(i))
		                s.close()
		                self.ports.append(k+str(i))
		            except:
		                pass
		return self.ports

	def doPort(self, e=None):
		""" open a serial port """
		if self.port == None:
		    self.findPorts()
		dlg = wx.SingleChoiceDialog(self,'Port (Ex. COM4 or /dev/ttyUSB0)','Select Communications Port',self.ports)
		#dlg = PortDialog(self,'Select Communications Port',self.ports)
		if dlg.ShowModal() == wx.ID_OK:
		    if self.port != None:
		        self.port.ser.close()
		    print "Opening port: " + self.ports[dlg.GetSelection()]
		    try:
		        # TODO: add ability to select type of driver
		    	self.port = Driver(self.ports[dlg.GetSelection()], 57600, True) # w/ interpolation
			self.sb.SetStatusText("",0) 
		        self.sb.SetStatusText(self.ports[dlg.GetSelection()] + "@57600",1)
			self.sb.SetBackgroundColour(wx.NullColor)
			self.ser = self.port.ser
		    except:
		        self.port = None
		        self.sb.SetBackgroundColour('RED')
		        self.sb.SetStatusText("Could Not Open Port",0) 
		        self.sb.SetStatusText('not connected',1)
		        self.timer.Start(20)
		    dlg.Destroy()

	def doWiimote(self, e=None):
		try:
		    self.setupWiiMote()
		    self.sb.SetStatusText('wiimote connected',2)
		except:
		    self.sb.SetStatusText('not connected',2)

	def setupWiiMote(self):
		self.wiimote = Wiimote()
		self.nunchukTilt = TiltCalculator()
		self.nunchukTilt.wmplugin_init(self.wiimote.wiimote)
		self.moteTilt = TiltCalculator()
		self.moteTilt.wmplugin_init(self.wiimote.wiimote)

if __name__ == "__main__":
    print "hexCommander starting... "
    app = wx.PySimpleApp()
    frame = hexCommander()
    app.MainLoop()
#while(1):
#  os.system("clear")
#  print mote.get_status()
#  status = mote.get_status()
#  print "mote pitch: %d roll: %d" % moteTilt.wmplugin_exec(status['acc'])
#  print "nunchukTilt pitch: %d roll: %d" % nunchukTilt.wmplugin_exec(status['nunchuk']['acc'])


#  sleep(0.2)
#mote.connect()
