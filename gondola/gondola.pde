#include <Servo.h> 


char payload[5] = "100";


byte needToSend;

Servo tiltServo; 
Servo leftMotor; 
Servo rightMotor; 
int tiltServoPin = 11;         
int leftMotorPin = 9;
int rightMotorPin = 10;

void setup () 
{
     tiltServo.attach(tiltServoPin);
     tiltServo.write(90);
    Serial.begin(57600);
    Serial.println("Go");
    
}

boolean startBitOne = false;
boolean startBitTwo = false;
byte inByte;
void loop () 
{
     if (Serial.available() > 0) {
         inByte = Serial.read();
         Serial.println(inByte);
         if(inByte == 0x13){
           startBitOne = true;
           startBitTwo = false;
         }
         if(startBitOne && inByte == 0x37){
            startBitTwo = true;
            Serial.println("headerRecived");
         } 
         if(startBitOne && startBitTwo){
           setLeftMotor(Serial.read()); 
           setRightMotor(Serial.read());
           setTilt(Serial.read());
         }       
      }

}



void setLeftMotor(byte dir){
  
     if(dir == 127)
        leftMotor.detach();
     else if(dir < 127)
         setMoterSpeed(leftMotor, leftMotorPin, 81);
     else if(dir > 127)
         setMoterSpeed(leftMotor, leftMotorPin, 90);
}

void setRightMotor(byte dir){
     if(dir == 127)
         rightMotor.detach();   
      else if(dir < 127)
          setMoterSpeed(rightMotor, rightMotorPin, 68); 
      else if(dir > 127)
          setMoterSpeed(rightMotor, rightMotorPin, 77); 
        
}

void setTilt(byte dir){
     if(dir == 127)
          tiltServo.write(90); 
     else if(dir < 127)
          tiltServo.write(70); 
      else if(dir > 127)
          tiltServo.write(120);
}

void setMoterSpeed(Servo s,int pin, int _speed)
{
  if(!s.attached()){
    s.attach(pin);
  }
  s.write(_speed);
  
}


