
/*
Testing the GPIO Interrupt 

*/

#include"Arduino.h"
// These constants won't change. They're used to give names to the pins used:




int pwmValue =0;
void setup();
void loop();
void increase_2();
void decrease_1();
void setup() {

  // initialize serial communications at 9600 bps:
  Serial.begin(1152000);
  //attachInterrupt(digitalPinToInterrupt(0),increase_2,RISING);  // Exclude UART
  //attachInterrupt(digitalPinToInterrupt(1),decrease_1,FALLING);  // Exclude UART
  attachInterrupt(digitalPinToInterrupt(2),increase_2,RISING);  
  attachInterrupt(digitalPinToInterrupt(3),decrease_1,FALLING);  
  attachInterrupt(digitalPinToInterrupt(4),increase_2,RISING);  
  attachInterrupt(digitalPinToInterrupt(5),decrease_1,FALLING);  
  attachInterrupt(digitalPinToInterrupt(6),increase_2,RISING);  
  attachInterrupt(digitalPinToInterrupt(7),decrease_1,FALLING);  
  attachInterrupt(digitalPinToInterrupt(8),increase_2,RISING);  
  attachInterrupt(digitalPinToInterrupt(9),decrease_1,FALLING);  

  attachInterrupt(digitalPinToInterrupt(10),increase_2,RISING);  
  attachInterrupt(digitalPinToInterrupt(11),decrease_1,FALLING);  
  attachInterrupt(digitalPinToInterrupt(12),increase_2,RISING);  
  attachInterrupt(digitalPinToInterrupt(13),decrease_1,FALLING);  
  attachInterrupt(digitalPinToInterrupt(14),increase_2,RISING);  
  attachInterrupt(digitalPinToInterrupt(15),decrease_1,FALLING);  
  attachInterrupt(digitalPinToInterrupt(16),increase_2,RISING);  
  attachInterrupt(digitalPinToInterrupt(17),decrease_1,FALLING);  
  attachInterrupt(digitalPinToInterrupt(18),increase_2,RISING);  
  attachInterrupt(digitalPinToInterrupt(19),decrease_1,FALLING);  

  attachInterrupt(digitalPinToInterrupt(20),increase_2,RISING);  
  attachInterrupt(digitalPinToInterrupt(21),decrease_1,FALLING);  
  attachInterrupt(digitalPinToInterrupt(22),increase_2,RISING);  
}

void loop() {

  delay(1);
}


void decrease_1()  {  
  pwmValue = pwmValue - 1;
  
  Serial.print("PWM Value Decrease to: ");
  Serial.println(pwmValue);
  }  

void increase_2()  {  
  pwmValue = pwmValue + 2;
  
  Serial.print("PWM Value Increase to: ");
  Serial.println(pwmValue);
  }  
