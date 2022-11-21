`ifndef USER_PARMS
`define USER_PARMS

// ASCI Representation of RISC = 32'h8273_8343
parameter CHIP_SIGNATURE = 32'h8273_8343;
// Software Reg-1, Release date: <DAY><MONTH><YEAR>
parameter CHIP_RELEASE_DATE = 32'h2011_2022;
// Software Reg-2: Poject Revison 5.1 = 0005200
parameter CHIP_REVISION   = 32'h0005_8000;

parameter CLK_SKEW1_RESET_VAL = 32'b0000_0000_1000_1100_1010_1010_1001_0011;
parameter CLK_SKEW2_RESET_VAL = 32'b0000_0000_0000_0000_0000_0000_0000_0111;

parameter PSTRAP_DEFAULT_VALUE = 15'b000_0011_1010_0000;

/*****************************************************
pad_strap_in decoding
     bit[1:0] - System Clock Source Selection for wbs/riscv
                 00 - User clock1 (Default)
                 01 - User clock2 
                 10 - Internal PLL
                 11 - Xtal
     bit[3:2] - Clock Division for wbs/riscv
                 00 - 0 Div       (Default)
                 01 - 2 Div       
                 10 - 4 Div
                 11 - 8 Div
     bit [4]   - Reserved
     bit [5]   - QSPI SRAM Mode Selection
                 1'b0 - Single    
                 1'b1 - Quad      (Default)
     bit [7:6] - QSPI Fash Mode Selection
                 2'b00 - Single   
                 2'b01 - Double
                 2'b10 - Quad     (Default
                 2'b11 - QDDR
     bit [8]   - Riscv Reset control
                 0 - Keep Riscv on Reset
                 1 - Removed Riscv on Power On Reset (Default)
     bit [9]   - Riscv Cache Bypass
                 0 - Cache Enable
                 1 - Bypass cache  (Default)
     bit [10]  - Riscv SRAM clock edge selection
                 0 - Normal      (Default)
                 1 - Invert        
     bit [12:11] - Skew selection
                 2'b00 - Default value  (Default)
                 2'b01 - Default value + 2               
                 2'b10 - Default value + 4               
                 2'b11 - Default value - 4 
     bit [4:13]   - uart master config control
                 2'b00   - Auto Detect (Default)
                 2'b01   - constant value based on system clock-50Mhz
                 2'b10   - constant value based on system clock-4Mhz 
                 2'b11   - load from LA

     bit[15]   - Strap Mode
                0 - [14:0] loaded from pad
                1 - Default reset value loaded
                    PSTRAP_DEFAULT_VALUE
****************************************************/

`define PSTRAP_CLK_SRC             1:0
`define PSTRAP_CLK_DIV             3:2
`define PSTRAP_UARTM_CFG           4
`define PSTRAP_QSPI_SRAM           5
`define PSTRAP_QSPI_FLASH          7:6
`define PSTRAP_RISCV_RESET_MODE    8
`define PSTRAP_RISCV_CACHE_BYPASS  9
`define PSTRAP_RISCV_SRAM_CLK_EDGE 10
`define PSTRAP_CLK_SKEW            12:11
`define PSTRAP_UARTM_CFG           14:13

`define PSTRAP_DEFAULT_VALUE       15

/************************************************************
system strap decoding
     bit[1:0] - System Clock Source Selection for wbs
                 00 - User clock1 
                 01 - User clock2 
                 10 - Internal PLL
                 11 - Xtal
     bit[3:2] - Clock Division for wbs
                 00 - 0 Div
                 01 - 2 Div
                 10 - 4 Div
                 11 - 8 Div
     bit[5:4] - System Clock Source Selection for riscv
                 00 - User clock1 
                 01 - User clock2 
                 10 - Internal PLL
                 11 - Xtal
     bit[7:6] - Clock Division for riscv
                 00 - 0 Div
                 01 - 2 Div
                 10 - 4 Div
                 11 - 8 Div
     bit [8]   - uart master config control
                 0   - load from LA
                 1   - constant value based on system clock selection
     bit [9]   - QSPI SRAM Mode Selection CS#2
                 1'b0 - Single
                 1'b1 - Quad
     bit [11:10] - QSPI FLASH Mode Selection CS#0
                 2'b00 - Single
                 2'b01 - Double
                 2'b10 - Quad
                 2'b11 - QDDR
     bit [12]  - Riscv Reset control
                 0 - Keep Riscv on Reset
                 1 - Removed Riscv on Power On Reset
     bit [13]   - Riscv Cache Bypass
                 1 - Cache Enable
                 0 - Bypass cache
     bit [14]  - Riscv SRAM clock edge selection
                 0 - Normal
                 1 - Invert

     bit [15]    -  Soft Reboot Request
     bit [17:16] -  cfg_cska_wi Skew selection      
     bit [19:18] -  cfg_cska_wh Skew selection        
     bit [21:20] -  cfg_cska_riscv Skew selection      
     bit [23:22] -  cfg_cska_qspi  Skew selection      
     bit [25:24] -  cfg_cska_uart  Skew selection       
     bit [27:26] -  cfg_cska_pinmux Skew selection     
     bit [29:28] -  cfg_cska_qspi_co Skew selection    


********************************************************/
// Stikcy Strap
`define STRAP_WB_CLK_SRC           1:0
`define STRAP_WB_CLK_DIV           3:2
`define STRAP_RISCV_CLK_SRC        5:4
`define STRAP_RISCV_CLK_DIV        7:6
`define STRAP_UARTM_CFG            8
`define STRAP_QSPI_SRAM            9
`define STRAP_QSPI_FLASH           11:10
`define STRAP_RISCV_RESET_MODE     12
`define STRAP_RISCV_CACHE_BYPASS   13
`define STRAP_RISCV_SRAM_CLK_EDGE  14
`define STRAP_QSPI_PRE_SRAM        15      // Previous SRAM Strap Status
`define STRAP_SCLK_SKEW_WI          17:16
`define STRAP_SCLK_SKEW_WH          19:18
`define STRAP_SCLK_SKEW_RISCV       21:20
`define STRAP_SCLK_SKEW_QSPI        23:22
`define STRAP_SCLK_SKEW_UART        25:24
`define STRAP_SCLK_SKEW_PINMUX      27:26
`define STRAP_SCLK_SKEW_QSPI_CO     29:28
`define STRAP_QSPI_INIT_BYPASS     30
`define STRAP_SOFT_REBOOT_REQ      31


`endif // USER_PARMS

