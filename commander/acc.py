import cwiid
import math

class TiltCalculator:

   def __init__(self,connect=True):
        self.acc_zero = None
	self.acc_one = None
	self.acc = [0,0,0]

	self.NEW_AMOUNT = 0.5
	self.OLD_AMOUNT = 1 - self.NEW_AMOUNT

	self.Roll_Scale = 1
	self.Pitch_Scale = 1
	self.X_Scale = 1
	self.Y_Scale = 1

   def wmplugin_init(self, wiimote):
	self.acc_zero, self.acc_one = wiimote.get_acc_cal(cwiid.EXT_NONE)
	return

   def wmplugin_exec(self, m):
	
	axes = [None, None, None, None]


	self.acc = [self.NEW_AMOUNT*(new-zero)/(one-zero) + self.OLD_AMOUNT*old
	       for old,new,zero,one in zip(self.acc,m,self.acc_zero,self.acc_one)]
	a = math.sqrt(sum(map(lambda x: x**2, self.acc)))

	roll = math.atan(self.acc[cwiid.X]/self.acc[cwiid.Z])
	if self.acc[cwiid.Z] <= 0:
		if self.acc[cwiid.X] > 0: roll += math.pi
		else: roll -= math.pi

	pitch = math.atan(self.acc[cwiid.Y]/self.acc[cwiid.Z]*math.cos(roll))

	axes[0] = int(roll  * 1000 * self.Roll_Scale)
	axes[1] = int(pitch * 1000 * self.Pitch_Scale)

	if (a > 0.85) and (a < 1.15):
		if (math.fabs(roll)*(180/math.pi) > 10) and \
		   (math.fabs(pitch)*(180/math.pi) < 80):
			axes[2] = int(roll * 5 * self.X_Scale)

		if (math.fabs(pitch)*(180/math.pi) > 10):
			axes[3] = int(pitch * 10 * self.Y_Scale)

	return math.degrees(pitch), math.degrees(roll)

