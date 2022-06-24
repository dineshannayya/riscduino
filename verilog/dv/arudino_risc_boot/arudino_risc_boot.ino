#define uint32_t  long

#define reg_mprj_globl_reg0  (*(volatile uint32_t*)0x10020000)
#define reg_mprj_globl_reg1  (*(volatile uint32_t*)0x10020004)
#define reg_mprj_globl_reg2  (*(volatile uint32_t*)0x10020008)
#define reg_mprj_globl_reg3  (*(volatile uint32_t*)0x1002000C)
#define reg_mprj_globl_reg4  (*(volatile uint32_t*)0x10020010)
#define reg_mprj_globl_reg5  (*(volatile uint32_t*)0x10020014)
#define reg_mprj_globl_reg6  (*(volatile uint32_t*)0x10020018)
#define reg_mprj_globl_reg7  (*(volatile uint32_t*)0x1002001C)
#define reg_mprj_globl_reg8  (*(volatile uint32_t*)0x10020020)
#define reg_mprj_globl_reg9  (*(volatile uint32_t*)0x10020024)
#define reg_mprj_globl_reg10 (*(volatile uint32_t*)0x10020028)
#define reg_mprj_globl_reg11 (*(volatile uint32_t*)0x1002002C)
#define reg_mprj_globl_reg12 (*(volatile uint32_t*)0x10020030)
#define reg_mprj_globl_reg13 (*(volatile uint32_t*)0x10020034)
#define reg_mprj_globl_reg14 (*(volatile uint32_t*)0x10020038)
#define reg_mprj_globl_reg15 (*(volatile uint32_t*)0x1002003C)
#define reg_mprj_globl_reg16 (*(volatile uint32_t*)0x10020040)
#define reg_mprj_globl_reg17 (*(volatile uint32_t*)0x10020044)
#define reg_mprj_globl_reg18 (*(volatile uint32_t*)0x10020048)
#define reg_mprj_globl_reg19 (*(volatile uint32_t*)0x1002004C)
#define reg_mprj_globl_reg20 (*(volatile uint32_t*)0x10020050)
#define reg_mprj_globl_reg21 (*(volatile uint32_t*)0x10020054)
#define reg_mprj_globl_reg22 (*(volatile uint32_t*)0x10020058)
#define reg_mprj_globl_reg23 (*(volatile uint32_t*)0x1002005C)
#define reg_mprj_globl_reg24 (*(volatile uint32_t*)0x10020060)
#define reg_mprj_globl_reg25 (*(volatile uint32_t*)0x10020064)
#define reg_mprj_globl_reg26 (*(volatile uint32_t*)0x10020068)
#define reg_mprj_globl_reg27 (*(volatile uint32_t*)0x1002006C)



void setup() {
  // put your setup code here, to run once:
    reg_mprj_globl_reg22  = 0x11223344; 
    reg_mprj_globl_reg23  = 0x22334455; 
    reg_mprj_globl_reg24  = 0x33445566; 
    reg_mprj_globl_reg25  = 0x44556677; 
    reg_mprj_globl_reg26 = 0x55667788; 
    reg_mprj_globl_reg27 = 0x66778899; 

}

void loop() {
  // put your main code here, to run repeatedly:

}
