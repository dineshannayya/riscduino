
/*

  Analog input, analog output, serial output

  Reads an analog input pin, maps the result to a range from 0 to 255 and uses

  the result to set the pulse width modulation (PWM) of an output pin.

  Also prints the results to the Serial Monitor.

  The circuit:

  - potentiometer connected to analog pin 0.

    Center pin of the potentiometer goes to the analog pin.

    side pins of the potentiometer go to +5V and ground

  - LED connected from digital pin 9 to ground

  created 29 Dec. 2008

  modified 9 Apr 2012

  by Tom Igoe

  This example code is in the public domain.

  http://www.arduino.cc/en/Tutorial/AnalogInOutSerial

*/

#include"Arduino.h"
// These constants won't change. They're used to give names to the pins used:


int but1=2;  
int but2=3;  


int Timer_us =0;
int Timer_ms =0;
void setup() {

  Timer.begin();  
  Timer.enable(0, TIMER_MICRO_STEP, 10); // 10 Micro Second
  Timer.enable(1, TIMER_MILLI_STEP, 1); // 1 Milli Second
  // initialize serial communications at 9600 bps:
  Serial.begin(9600);
  attachInterrupt(timerToInterrupt(0),timer_us_intr,RISING);  
  attachInterrupt(timerToInterrupt(1),timer_ms_intr,RISING);  

}

void loop() {

  delay(1);
}


void timer_us_intr()  
 {  
  Timer_us = Timer_us + 1;
  if(Timer_us > 255) Timer_us = 0;;   
  
  Serial.print("Micro Second: ");
  Serial.println(Timer_us);


  }  
void timer_ms_intr()  
 {  
  Timer_ms = Timer_ms + 1;
  if(Timer_ms > 255) Timer_ms = 0;;   
  
  Serial.print("Milli Second: ");
  Serial.println(Timer_ms);


  }   
