#include <Servo.h> 

char payload[5] = "100";


unsigned long timeLastCommand;

Servo tiltServo; 
Servo leftMotor; 
Servo rightMotor; 
int tiltServoPin = 6;         
int leftMotorPin = 9;
int rightMotorPin = 10;
int ledPin = 13;  
int lipolPin = 7;

void setup () 
{
    tiltServo.attach(tiltServoPin);
    tiltServo.write(90);
    Serial.begin(57600);
    Serial.println("Go");
    pinMode(ledPin, OUTPUT);
    pinMode(lipolPin, INPUT);
   
}

byte inByte = 0;
char code[4]; 
int bytesread = 0;
void loop () 
{
    handleIncomingData();     

   if( (millis() - timeLastCommand) > 1000){
     stopMotors();
   } 
}

void handleIncomingData(){
  
  if (Serial.available() > 0) {
       
         inByte = Serial.read();
         Serial.println(inByte);
         if(inByte == 13){
            bytesread = 0;
            digitalWrite(ledPin, HIGH);
            while(bytesread<4) {              
              if( Serial.available() > 0) { 
                  inByte = Serial.read(); 
                  if((inByte == 10)||(inByte == 13)) { 
                    break;                       
                  } 
                  code[bytesread] = inByte;                
                  bytesread++;                   
                } 
            } 
            if(bytesread == 4) {             
               setLeftMotor(code[0]); 
               setRightMotor(code[1]);
               setTilt(code[2]);  
             
            Serial.flush();   
            } 
            digitalWrite(ledPin, LOW);
            bytesread = 0;
            timeLastCommand = millis();
     }
   }
}

void stopMotors(){
      leftMotor.detach();
      rightMotor.detach();
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
          setMoterSpeed(rightMotor, rightMotorPin, 69); 
      else if(dir > 127)
          setMoterSpeed(rightMotor, rightMotorPin, 73); 
        
}

void setTilt(byte dir){
     int degreas = (int)dir - 37; // 127b = 90°
     if(degreas > 60 && degreas < 125)
       tiltServo.write(degreas);
     else if(degreas <= 60)
       tiltServo.write(60); 
     else if(degreas >= 125)
       tiltServo.write(125);
    
}

void setMoterSpeed(Servo s,int pin, int _speed)
{
  if(!s.attached()){
    s.attach(pin);
  }
  s.write(_speed);
  
}

