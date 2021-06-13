
#define SC_SIM_OUTPORT (0xf0000000)
#define uint32_t  long

#define reg_mprj_globl_reg0  (*(volatile uint32_t*)0x30000000)
#define reg_mprj_globl_reg1  (*(volatile uint32_t*)0x30000004)
#define reg_mprj_globl_reg2  (*(volatile uint32_t*)0x30000008)
#define reg_mprj_globl_reg3  (*(volatile uint32_t*)0x3000000C)
#define reg_mprj_globl_reg4  (*(volatile uint32_t*)0x30000010)
#define reg_mprj_globl_reg5  (*(volatile uint32_t*)0x30000014)
#define reg_mprj_globl_reg6  (*(volatile uint32_t*)0x30000018)
#define reg_mprj_globl_reg7  (*(volatile uint32_t*)0x3000001C)
#define reg_mprj_globl_reg8  (*(volatile uint32_t*)0x30000020)
#define reg_mprj_globl_reg9  (*(volatile uint32_t*)0x30000024)
#define reg_mprj_globl_reg10 (*(volatile uint32_t*)0x30000028)
#define reg_mprj_globl_reg11 (*(volatile uint32_t*)0x3000002C)
#define reg_mprj_globl_reg12 (*(volatile uint32_t*)0x30000030)
#define reg_mprj_globl_reg13 (*(volatile uint32_t*)0x30000034)
#define reg_mprj_globl_reg14 (*(volatile uint32_t*)0x30000038)
#define reg_mprj_globl_reg15 (*(volatile uint32_t*)0x3000003C)

int main()
{

    //volatile long *out_ptr = (volatile long*)SC_SIM_OUTPORT;
    //*out_ptr = 0xAABBCCDD;
    //*out_ptr = 0xBBCCDDEE;
    //*out_ptr = 0xCCDDEEFF;
    //*out_ptr = 0xDDEEFF00;

    // Write software Write & Read Register
    reg_mprj_globl_reg6  = 0x11223344; 
    reg_mprj_globl_reg7  = 0x22334455; 
    reg_mprj_globl_reg8  = 0x33445566; 
    reg_mprj_globl_reg9  = 0x44556677; 
    reg_mprj_globl_reg10 = 0x55667788; 
    reg_mprj_globl_reg11 = 0x66778899; 
    //reg_mprj_globl_reg12 = 0x778899AA; 
    //reg_mprj_globl_reg13 = 0x8899AABB; 
    //reg_mprj_globl_reg14 = 0x99AABBCC; 
    //reg_mprj_globl_reg15 = 0xAABBCCDD; 

    while(1) {}
    return 0;
}
