// Sweep
// by BARRAGAN <http://barraganstudio.com> 
// This example code is in the public domain.

#include <RF12.h>
#include <Ports.h>
#include <Servo.h> 
 
Servo verticalMotor; 
Servo leftMotor; 
Servo rightMotor; 
int verticalMotorPin = 9;                // a maximum of eight servo objects can be created 
int leftMotorPin = 5;
int rightMotorPin = 6;

int pos = 0;    // variable to store the servo position 
 
void setup() 
{ 
   Serial.begin(57600);
   Serial.println("\n Test");
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
 
void loop() 
{ 
  
  
  
  
 /*  for(pos = 0; pos < 180; pos += 1)  // goes from 0 degrees to 180 degrees 
  {                                  // in steps of 1 degree 
    myservo.write(pos);              // tell servo to go to position in variable 'pos' 
    delay(15);                       // waits 15ms for the servo to reach the position 
  } 
  for(pos = 180; pos>=1; pos-=1)     // goes from 180 degrees to 0 degrees 
  {                                
    myservo.write(pos);              // tell servo to go to position in variable 'pos' 
    delay(15);                       // waits 15ms for the servo to reach the position 
  }*/ 
  verticalMotor.write(180);       
  delay(2500);
  /*myservo.detach();
  delay(2500);
  myservo.attach(9);
  myservo.write(0);       
  delay(2500);*/ 
}
