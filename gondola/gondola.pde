#include <Ports.h>
#include <RF12.h>
#include <Servo.h> 


char payload[5] = "100";

MilliTimer sendTimer;
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
    
    SetUpMotors();
}

void SetUpMotors()
{
  verticalMotor.attach(9); 
  verticalMotor.write(90);
  leftMotor.attach(5); 
  leftMotor.write(90);
  rightMotor.attach(6);
  rightMotor.write(90); 
}

void loop () 
{
    if (rf12_recvDone() && rf12_crc == 0) {
       // for (byte i = 0; i < rf12_len; ++i)
        steamControll();
       //     Serial.print(rf12_data[i]);
        Serial.println();
        delay(100);      
    }
    
   if (sendTimer.poll(3000))
        needToSend = 1;

   if (needToSend && rf12_canSend()) {
        needToSend = 0;
         // readFule();
        rf12_sendStart(0, payload, sizeof payload);
       
    }
}

void steamControll()
{
    for (byte i = 0; i < rf12_len; ++i)
          Serial.print(rf12_data[i]);
    
    Serial.println(rf12_len);
    if(rf12_len == 3){
        setLeftMotor(rf12_data[0]);
        setRightMotor(rf12_data[1]);
        setVerticalMotor(rf12_data[2]);
    }
}

void setLeftMotor(char dir){
     if(dir == 'F')
         leftMotor.write(180); 
     else if(dir == 'R')
         leftMotor.write(0); 
     else
         leftMotor.write(90);     
}

void setRightMotor(char dir){
     if(dir == 'F')
         verticalMotor.write(180); 
     else if(dir == 'R')
         verticalMotor.write(0); 
     else
         verticalMotor.write(90);     
}

void setVerticalMotor(char dir){
     if(dir == 'D'){
         verticalMotor.write(180); 
         Serial.println('D');
     }
     else if(dir == 'U'){
         verticalMotor.write(0);
        Serial.println('U'); 
     }
     else
     {
         verticalMotor.write(90);
        Serial.print('#'); 
     }    
}


