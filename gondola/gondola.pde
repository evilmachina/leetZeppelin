#include <Servo.h> 
#include "TVB.h"
#include <avr/sleep.h>


char payload[5] = "100";


byte needToSend;

Servo tiltServo; 
Servo leftMotor; 
Servo rightMotor; 
int tiltServoPin = 11;         
int leftMotorPin = 9;
int rightMotorPin = 10;
int ledPin = 13;  

//tv-b-gone code

void xmitCodeElement(uint16_t ontime, uint16_t offtime, uint8_t PWM_code );
void quickflashLEDx( uint8_t x );
void delay_ten_us(uint16_t us);
void quickflashLED( void );
uint8_t read_bits(uint8_t count);

#define putstring_nl(s) Serial.println(s)
#define putstring(s) Serial.print(s)
#define putnum_ud(n) Serial.print(n, DEC)
#define putnum_uh(n) Serial.print(n, HEX)

extern PGM_P *NApowerCodes[] PROGMEM;
extern PGM_P *EUpowerCodes[] PROGMEM;
extern uint8_t num_NAcodes, num_EUcodes;

void xmitCodeElement(uint16_t ontime, uint16_t offtime, uint8_t PWM_code )
{
  TCNT2 = 0;
  if(PWM_code) {
    pinMode(IRLED, OUTPUT);
    TCCR2A = _BV(COM2A0) | _BV(COM2B1) | _BV(WGM21) | _BV(WGM20);
    TCCR2B = _BV(WGM22) | _BV(CS21);
  }
  else {
    digitalWrite(IRLED, HIGH);
  }
  delay_ten_us(ontime);
  TCCR2A = 0;
  TCCR2B = 0;
  digitalWrite(IRLED, LOW);
  delay_ten_us(offtime);
}

uint8_t bitsleft_r = 0;
uint8_t bits_r=0;
PGM_P code_ptr;

uint8_t read_bits(uint8_t count)
{
  uint8_t i;
  uint8_t tmp=0;

  
  for (i=0; i<count; i++) {
    if (bitsleft_r == 0) {
      bits_r = pgm_read_byte(code_ptr++);
      bitsleft_r = 8;
    }
    bitsleft_r--;
    tmp |= (((bits_r >> (bitsleft_r)) & 1) << (count-1-i));
  }
  return tmp;
}

uint16_t ontime, offtime;
uint8_t i,num_codes, Loop;
uint8_t region;
uint8_t startOver;

#define FALSE 0
#define TRUE 1

//end tv-b-gone



void setup () 
{
    tiltServo.attach(tiltServoPin);
    tiltServo.write(90);
    Serial.begin(57600);
    Serial.println("Go");
    pinMode(ledPin, OUTPUT);
    setupTVBGone();
}

void setupTVBGone(){
    TCCR2A = 0;
    TCCR2B = 0;
    
    digitalWrite(LED, LOW);
    digitalWrite(IRLED, LOW);
    pinMode(LED, OUTPUT);
    pinMode(IRLED, OUTPUT);

   //region = NA;
   //DEBUGP(putstring_nl("NA"));

    region = EU;
    DEBUGP(putstring_nl("EU"));

    DEBUGP(putstring("\n\rNA Codesize: ");
    putnum_ud(num_NAcodes);
    );
    DEBUGP(putstring("\n\rEU Codesize: ");
    putnum_ud(num_EUcodes);
    );
}

byte inByte = 0;
char code[4]; 
int bytesread = 0;
void loop () 
{
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
               startTVB(code[3]); 
             
            Serial.flush();   
            } 
            digitalWrite(ledPin, LOW);
            bytesread = 0;
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

void startTVB(byte b){
  if(b == 255)
    sendAllCodes();
}


void sendAllCodes() {
  startOver = FALSE;
  num_codes = num_EUcodes;
 

  // for every POWER code in our collection
  for (i=0 ; i < num_codes; i++) {
    PGM_P data_ptr;

    // print out the code # we are about to transmit
    DEBUGP(putstring("\n\r\n\rCode #: ");
    putnum_ud(i));

    // point to next POWER code, from the right database
    if (region == NA) {
      data_ptr = (PGM_P)pgm_read_word(NApowerCodes+i);
    }
    else {
      data_ptr = (PGM_P)pgm_read_word(EUpowerCodes+i);
    }

    // print out the address in ROM memory we're reading
    DEBUGP(putstring("\n\rAddr: ");
    putnum_uh((uint16_t)data_ptr));

    // Read the carrier frequency from the first byte of code structure
    const uint8_t freq = pgm_read_byte(data_ptr++);
    // set OCR for Timer1 to output this POWER code's carrier frequency
    OCR2A = freq;
    OCR2B = freq / 3; // 33% duty cycle

    // Print out the frequency of the carrier and the PWM settings
    DEBUGP(putstring("\n\rOCR1: ");
    putnum_ud(freq);
    );
    DEBUGP(putstring("\n\rOCR2: ");
    putnum_ud(OCR2B);
    );
    DEBUGP(putstring("\n\rF_CPU: ");
    putnum_ud(F_CPU);
    );
     DEBUGP(putstring("\n\rx: ");
    putnum_ud((freq+1) * 2);
    );
    DEBUGP(uint16_t x = (freq+1) * 2;
    putstring("\n\rFreq: ");
    putnum_ud(F_CPU/x);
    );

    // Get the number of pairs, the second byte from the code struct
    const uint8_t numpairs = pgm_read_byte(data_ptr++);
    DEBUGP(putstring("\n\rOn/off pairs: ");
    putnum_ud(numpairs));

    // Get the number of bits we use to index into the timer table
    // This is the third byte of the structure
    const uint8_t bitcompression = pgm_read_byte(data_ptr++);
    DEBUGP(putstring("\n\rCompression: ");
    putnum_ud(bitcompression);
    putstring("\n\r"));

    // Get pointer (address in memory) to pulse-times table
    // The address is 16-bits (2 byte, 1 word)
    PGM_P time_ptr = (PGM_P)pgm_read_word(data_ptr);
    data_ptr+=2;
    code_ptr = (PGM_P)pgm_read_word(data_ptr);

    // Transmit all codeElements for this POWER code
    // (a codeElement is an onTime and an offTime)
    // transmitting onTime means pulsing the IR emitters at the carrier
    // frequency for the length of time specified in onTime
    // transmitting offTime means no output from the IR emitters for the
    // length of time specified in offTime

#if 0

    // print out all of the pulse pairs
    for (uint8_t k=0; k<numpairs; k++) {
      uint8_t ti;
      ti = (read_bits(bitcompression)) * 4;
      // read the onTime and offTime from the program memory
      ontime = pgm_read_word(time_ptr+ti);
      offtime = pgm_read_word(time_ptr+ti+2);
      DEBUGP(putstring("\n\rti = ");
      putnum_ud(ti>>2);
      putstring("\tPair = ");
      putnum_ud(ontime));
      DEBUGP(putstring("\t");
      putnum_ud(offtime));
    }
    continue;
#endif

    // For EACH pair in this code....
    cli();
    for (uint8_t k=0; k<numpairs; k++) {
      uint16_t ti;

      // Read the next 'n' bits as indicated by the compression variable
      // The multiply by 4 because there are 2 timing numbers per pair
      // and each timing number is one word long, so 4 bytes total!
      ti = (read_bits(bitcompression)) * 4;

      // read the onTime and offTime from the program memory
      ontime = pgm_read_word(time_ptr+ti);  // read word 1 - ontime
      offtime = pgm_read_word(time_ptr+ti+2);  // read word 2 - offtime
      // transmit this codeElement (ontime and offtime)
      xmitCodeElement(ontime, offtime, (freq!=0));
    }
    sei();

    //Flush remaining bits, so that next code starts
    //with a fresh set of 8 bits.
    bitsleft_r=0;

    // delay 205 milliseconds before transmitting next POWER code
    delay_ten_us(20500);

    // visible indication that a code has been output.
    quickflashLED();
  }

  // flash the visible LED on PB0  8 times to indicate that we're done
  delay_ten_us(65500); // wait maxtime
  delay_ten_us(65500); // wait maxtime
  quickflashLEDx(8);

}

/****************************** LED AND DELAY FUNCTIONS ********/


// This function delays the specified number of 10 microseconds
// it is 'hardcoded' and is calibrated by adjusting DELAY_CNT
// in main.h Unless you are changing the crystal from 8mhz, dont
// mess with this.
void delay_ten_us(uint16_t us) {
  uint8_t timer;
  while (us != 0) {
    // for 8MHz we want to delay 80 cycles per 10 microseconds
    // this code is tweaked to give about that amount.
    for (timer=0; timer <= DELAY_CNT; timer++) {
      NOP;
      NOP;
    }
    NOP;
    us--;
  }
}


// This function quickly pulses the visible LED (connected to PB0, pin 5)
// This will indicate to the user that a code is being transmitted
void quickflashLED( void ) {
  digitalWrite(LED, HIGH);
  delay_ten_us(3000);   // 30 millisec delay
  digitalWrite(LED, LOW);
}

// This function just flashes the visible LED a couple times, used to
// tell the user what region is selected
void quickflashLEDx( uint8_t x ) {
  quickflashLED();
  while(--x) {
    delay_ten_us(15000);     // 150 millisec delay between flahes
    quickflashLED();
  }
}
