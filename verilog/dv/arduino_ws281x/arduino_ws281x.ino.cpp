#line 1 "/home/dinesha/Arduino/ws281x_example1/ws281x_example1.ino"

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
#include"WS281X.h"
// These constants won't change. They're used to give names to the pins used:


int port0 = 2;
int port1 = 3;
int port2 = 5;
int port3 = 9;


void setup();
void loop();
void setup() {

  ws281x.begin(WS2811_HIGH_SPEED);  

  // Enable WS_281X PORT-0
  ws281x.enable(port0);
  ws281x.write(port0, 0x112233);
  ws281x.write(port0, 0x223344);
  ws281x.write(port0, 0x334455);
  ws281x.write(port0, 0x445566);
  ws281x.write(port0, 0x556677);
  ws281x.write(port0, 0x667788);
  ws281x.write(port0, 0x778899);
  ws281x.write(port0, 0x8899AA);
  ws281x.write(port0, 0x99AABB);
  ws281x.write(port0, 0xAABBCC);
  ws281x.write(port0, 0xBBCCDD);
  ws281x.write(port0, 0xCCDDEE);
  ws281x.write(port0, 0xDDEEFF);
  ws281x.write(port0, 0xEEFF00);
  ws281x.write(port0, 0xFF0011);
  ws281x.write(port0, 0x001122);
  
// Enable WS_281X PORT-1
  ws281x.enable(port1);
  ws281x.write(port1, 0x010203);
  ws281x.write(port1, 0x020304);
  ws281x.write(port1, 0x030405);
  ws281x.write(port1, 0x040506);
  ws281x.write(port1, 0x050607);
  ws281x.write(port1, 0x060708);
  ws281x.write(port1, 0x070809);
  ws281x.write(port1, 0x08090A);
  ws281x.write(port1, 0x090A0B);
  ws281x.write(port1, 0x0A0B0C);
  ws281x.write(port1, 0x0B0C0D);
  ws281x.write(port1, 0x0C0D0E);
  ws281x.write(port1, 0x0D0E0F);
  ws281x.write(port1, 0x0E0F00);
  ws281x.write(port1, 0x0F0001);
  ws281x.write(port1, 0x000102);

// Enable WS_281X PORT-2
  ws281x.enable(port2);
  ws281x.write(port2, 0x102030);
  ws281x.write(port2, 0x203040);
  ws281x.write(port2, 0x304050);
  ws281x.write(port2, 0x405060);
  ws281x.write(port2, 0x506070);
  ws281x.write(port2, 0x607080);
  ws281x.write(port2, 0x708090);
  ws281x.write(port2, 0x8090A0);
  ws281x.write(port2, 0x90A0B0);
  ws281x.write(port2, 0xA0B0C0);
  ws281x.write(port2, 0xB0C0D0);
  ws281x.write(port2, 0xC0D0E0);
  ws281x.write(port2, 0xD0E0F0);
  ws281x.write(port2, 0xE0F000);
  ws281x.write(port2, 0xF00010);
  ws281x.write(port2, 0x001020);
  
// Enable WS_281X PORT-3
  ws281x.enable(port3);
  ws281x.write(port3, 0x012345);
  ws281x.write(port3, 0x123456);
  ws281x.write(port3, 0x234567);
  ws281x.write(port3, 0x345678);
  ws281x.write(port3, 0x456789);
  ws281x.write(port3, 0x56789A);
  ws281x.write(port3, 0x6789AB);
  ws281x.write(port3, 0x789ABC);
  ws281x.write(port3, 0x89ABCD);
  ws281x.write(port3, 0x9ABCDE);
  ws281x.write(port3, 0xABCDEF);
  ws281x.write(port3, 0xBCDEF0);
  ws281x.write(port3, 0xCDEF01);
  ws281x.write(port3, 0xDEF012);
  ws281x.write(port3, 0xEF0123);
  ws281x.write(port3, 0xF01234);
}

void loop() {

  delay(1);
}



