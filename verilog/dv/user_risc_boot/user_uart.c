
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

#define reg_mprj_uart_reg0 (*(volatile uint32_t*)0x30010000)
#define reg_mprj_uart_reg1 (*(volatile uint32_t*)0x30010004)
#define reg_mprj_uart_reg2 (*(volatile uint32_t*)0x30010008)
#define reg_mprj_uart_reg3 (*(volatile uint32_t*)0x3001000C)
#define reg_mprj_uart_reg4 (*(volatile uint32_t*)0x30010010)
#define reg_mprj_uart_reg5 (*(volatile uint32_t*)0x30010014)
#define reg_mprj_uart_reg6 (*(volatile uint32_t*)0x30010018)
#define reg_mprj_uart_reg7 (*(volatile uint32_t*)0x3001001C)
#define reg_mprj_uart_reg8 (*(volatile uint32_t*)0x30010020)

int main()
{

    while(1) {
       // Check UART RX fifo has data, if available loop back the data
       if(reg_mprj_uart_reg8 != 0) { 
	   reg_mprj_uart_reg5 = reg_mprj_uart_reg6;
       }
    }

    return 0;
}
