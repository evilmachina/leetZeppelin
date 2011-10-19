#include <Ports.h>
#include <RF12.h>

byte dataToSend = 0;
byte sendBuffer[3];

void setup()
{
   Serial.begin(57600);
   rf12_initialize(13, RF12_868MHZ, 33);
}

/**
  Proto:
    Up: u
    Down: d
    Left: l
    Right: r
    Forward: f
    Reverse: b
    
    X|Y|Z
    -----
     | |
    
    # = blank
  */

void loop()
{
  if(rf12_recvDone() && rf12_crc == 0) {
    Serial.print("Gots data");
    for(byte i = 0; i < rf12_len; ++i){
      Serial.print(rf12_data[i]);
    }  
    Serial.println();
  }
  
  if(Serial.available() > 0 && rf12_canSend()){
    fillSendBuffer();
    Serial.print("Data: ");
    rf12_sendStart(0, &sendBuffer, sizeof(sendBuffer));
  }
  
  delay(200);
}

void fillSendBuffer() {
  for(byte i=0; i < 3; i++)
    sendBuffer[i] = "#";
  
  int readamt = 0;
  while(Serial.available() > 0) {
    sendBuffer[readamt++] = Serial.read();  
    if(readamt >= 3)
      break;
  }
}
