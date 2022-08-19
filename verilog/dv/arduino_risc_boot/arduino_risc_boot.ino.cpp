#include <Arduino.h>
#define uint32_t  long

#define reg_mprj_globl_reg0   (*(volatile uint32_t*)0x10020000) // Chip ID
#define reg_mprj_globl_reg1   (*(volatile uint32_t*)0x10020004) // Global Config-0
#define reg_mprj_globl_reg2   (*(volatile uint32_t*)0x10020008) // Global Config-1
#define reg_mprj_globl_reg3   (*(volatile uint32_t*)0x1002000C) // Global Interrupt Mask
#define reg_mprj_globl_reg4   (*(volatile uint32_t*)0x10020010) // Global Interrupt
#define reg_mprj_globl_reg5   (*(volatile uint32_t*)0x10020014) // Multi functional sel
#define reg_mprj_globl_soft0  (*(volatile uint32_t*)0x10020018) // Sof Register-0
#define reg_mprj_globl_soft1  (*(volatile uint32_t*)0x1002001C) // Sof Register-1
#define reg_mprj_globl_soft2  (*(volatile uint32_t*)0x10020020) // Sof Register-2
#define reg_mprj_globl_soft3  (*(volatile uint32_t*)0x10020024) // Sof Register-3
#define reg_mprj_globl_soft4  (*(volatile uint32_t*)0x10020028) // Sof Register-4
#define reg_mprj_globl_soft5  (*(volatile uint32_t*)0x1002002C) // Sof Register-5



void setup();
void loop();
void setup() {
  // put your setup code here, to run once:
    reg_mprj_globl_soft0  = 0x11223344; 
    reg_mprj_globl_soft1  = 0x22334455; 
    reg_mprj_globl_soft2  = 0x33445566; 
    reg_mprj_globl_soft3  = 0x44556677; 
    reg_mprj_globl_soft4  = 0x55667788; 
    reg_mprj_globl_soft5  = 0x66778899; 

}

void loop() {
  // put your main code here, to run repeatedly:

}

