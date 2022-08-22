
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


int pwmValue =0;
void setup() {

  // initialize serial communications at 9600 bps:
  Serial.begin(9600);

}

void loop() {

  attachInterrupt(digitalPinToInterrupt(but1),increase,LOW);  
  attachInterrupt(digitalPinToInterrupt(but2),reset_pwm,FALLING);  

 

  delay(1);
}


void increase()  
 {  
  pwmValue = pwmValue + 10;
  if(pwmValue > 255) pwmValue = 0;;   
  
  Serial.print("String length is: ");
  Serial.println(pwmValue);


  }  
 void reset_pwm(){  
   pwmValue =0;  // 0V
 }  