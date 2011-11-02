#include <Servo.h> 

Servo leftMotor; 
Servo rightMotor; 
int leftMotorPin = 9; 

void setup()
{
  Serial.begin(57600);
   Serial.println("\n Test");
   //leftMotor.attach(9); 
   rightMotor.attach(10);
}

void loop()
{
  for(int i = 70; i < 95; i++)
  {
    Serial.println(i);
    //leftMotor.write(i); 
     rightMotor.write(i-10);    
    delay(3000);
  }
  for(int i = 95; i > 70; i--)
  {
    Serial.println(i);
    //leftMotor.write(i);
    rightMotor.write(i-10);      
    delay(3000);
  } 
}
