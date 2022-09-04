
/*
Testing the Timer Interrupt 

*/

#include"Arduino.h"
// These constants won't change. They're used to give names to the pins used:




uint8_t Timer_us =0;
uint8_t Timer_ms =0;
void setup();
void loop();
void timer_us_intr();
void timer_ms_intr();
void setup() {

  Timer.begin();  
  Timer.enable(0, TIMER_MICRO_STEP, 400); // 1000 Micro Second
  Timer.enable(1, TIMER_MILLI_STEP, 2); // 2 Milli Second
  // initialize serial communications at 9600 bps:
  Serial.begin(1152000);
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
  
  Serial.print("Timer-0 Step: ");
  Serial.println(Timer_us);
  if(Timer_us > 19) {
    Timer.disable(0);
  }



  }  
void timer_ms_intr()  
 {  
  Timer_ms = Timer_ms + 1;
  if(Timer_ms > 255) Timer_ms = 0;;   
  
  Serial.print("Timer-1 Step: ");
  Serial.println(Timer_ms);

  if(Timer_ms > 4) {
    Timer.disable(1);
  }

  }   
