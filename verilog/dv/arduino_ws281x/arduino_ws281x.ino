
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


void setup() {

  ws281x.begin(WS2811_LOW_SPEED);  
  ws281x.enable(2);
}

void loop() {

  ws281x.write(2, 0x112233);
  ws281x.write(2, 0x223344);
  ws281x.write(2, 0x334455);
  ws281x.write(2, 0x445566);
  ws281x.write(2, 0x556677);
  ws281x.write(2, 0x667788);
  ws281x.write(2, 0x778899);
  delay(1);
}


