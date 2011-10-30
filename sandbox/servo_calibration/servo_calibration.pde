#include <Servo.h> 

Servo verticalMotor; 
int verticalMotorPin = 9; 

void setup()
{
  Serial.begin(57600);
   Serial.println("\n Test");
   verticalMotor.attach(9); 
}

void loop()
{
  for(int i = 70; i < 95; i++)
  {
    Serial.println(i);
    verticalMotor.write(i);       
    delay(3000);
  }
  for(int i = 95; i > 70; i--)
  {
    Serial.println(i);
    verticalMotor.write(i);       
    delay(3000);
  } 
}
