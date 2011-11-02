#include <Ports.h>
#include <RF12.h>
#include <Servo.h> 


char payload[5] = "100";

MilliTimer sendTimer;
MilliTimer lastSignalTime;
byte needToSend;

Servo verticalMotor; 
Servo leftMotor; 
Servo rightMotor; 
int verticalMotorPin = 9;         
int leftMotorPin = 5;
int rightMotorPin = 6;

void setup () 
{
    Serial.begin(57600);
    Serial.println("Go");
    rf12_initialize(30, RF12_868MHZ, 33);
}


void loop () 
{
    if (rf12_recvDone() && rf12_crc == 0) {
       // for (byte i = 0; i < rf12_len; ++i)
        steamControll();
       //     Serial.print(rf12_data[i]);
        Serial.println();
              
    }
    delay(100);
  /* if (sendTimer.poll(3000))
        needToSend = 1;

   if (needToSend && rf12_canSend()) {
        needToSend = 0;
         // readFule();
        rf12_sendStart(0, payload, sizeof payload);
      
    }*/
}

void steamControll()
{
    for (byte i = 0; i < rf12_len; ++i)
          Serial.print(rf12_data[i]);
    
    if(rf12_len == 3){
        setLeftMotor(rf12_data[1]);
        setRightMotor(rf12_data[0]);
        setVerticalMotor(rf12_data[2]);
    }
}

void setLeftMotor(char dir){
     if(dir == 'F')
         setMoterSpeed(leftMotor, leftMotorPin, 100);
     else if(dir == 'R')
         setMoterSpeed(leftMotor, leftMotorPin, 70);
     else
         leftMotor.detach();    
}

void setRightMotor(char dir){
     if(dir == 'F')
          setMoterSpeed(rightMotor, rightMotorPin, 70); 
     else if(dir == 'R')
          setMoterSpeed(rightMotor, rightMotorPin, 100); 
     else
         rightMotor.detach();     
}

void setVerticalMotor(char dir){
     if(dir == 'D'){
          setMoterSpeed(verticalMotor, verticalMotorPin, 100); 
     }
     else if(dir == 'U'){
          setMoterSpeed(verticalMotor, verticalMotorPin, 70);
     }
     else
     {
         verticalMotor.detach();  
     }    
}

void setMoterSpeed(Servo s,int pin, int _speed)
{
  if(!s.attached()){
    s.attach(pin);
  }
  s.write(_speed);
  
}


