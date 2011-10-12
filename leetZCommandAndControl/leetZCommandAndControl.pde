#include <Ports.h>
#include <RF12.h>

byte dataToSend = 0;

void setup()
{
   // initialize the serial port and the RF12 driver
   Serial.begin(57600);
   Serial.print("Hai!");
   rf12_config();
   // set up easy transmissions at maximum rate
   rf12_easyInit(0);
}

void loop()
{
  rf12_easyPoll();
  
  if(Serial.available() > 0){
    dataToSend = Serial.read();
    
    rf12_easySend(&dataToSend, sizeof(dataToSend));
  }
}

