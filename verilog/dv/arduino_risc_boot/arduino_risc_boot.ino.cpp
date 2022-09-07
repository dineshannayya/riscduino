#include <Arduino.h>
#define uint32_t  long

void setup();
void loop();
void setup() {
  // put your setup code here, to run once:
    GLBL_REG(GLBL_SOFT_REG0)  = 0x11223344; 
    GLBL_REG(GLBL_SOFT_REG1)  = 0x22334455; 
    GLBL_REG(GLBL_SOFT_REG2)  = 0x33445566; 
    GLBL_REG(GLBL_SOFT_REG3)  = 0x44556677; 
    GLBL_REG(GLBL_SOFT_REG4)  = 0x55667788; 
    GLBL_REG(GLBL_SOFT_REG5)  = 0x66778899; 

}

void loop() {
  // put your main code here, to run repeatedly:

}

