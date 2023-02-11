
// Note in caravel, 0x300X_XXXX only come to user interface
// So, using wb_host bank select we have changing MSB address [31:16] = 0x1000
//
`define ADDR_SPACE_QSPI    32'h3000_0000
`define ADDR_SPACE_UART0   32'h3001_0000
`define ADDR_SPACE_I2CM    32'h3001_0040
`define ADDR_SPACE_USB     32'h3001_0080
`define ADDR_SPACE_SSPI    32'h3001_00C0
`define ADDR_SPACE_UART1   32'h3001_0100
`define ADDR_SPACE_PINMUX  32'h3002_0000
`define ADDR_SPACE_GLBL    32'h3002_0000
`define ADDR_SPACE_GPIO    32'h3002_0080
`define ADDR_SPACE_PWM     32'h3002_0100
`define ADDR_SPACE_TIMER   32'h3002_0180
`define ADDR_SPACE_SEMA    32'h3002_0200
`define ADDR_SPACE_WS281X  32'h3002_0280
`define ADDR_SPACE_ANALOG  32'h3002_0400
`define ADDR_SPACE_RTC     32'h3002_0480
`define ADDR_SPACE_IR      32'h3002_0500
`define ADDR_SPACE_SM      32'h3002_0580
`define ADDR_SPACE_WBI     32'h3003_0000
`define ADDR_SPACE_WBHOST  32'h3008_0000

//--------------------------------------------------
//  WB Host Register
//--------------------------------------------------
`define WBHOST_GLBL_CFG           8'h00  // reg_0  - Global Config
`define WBHOST_BANK_SEL           8'h04  // reg_1  - Bank Select
`define WBHOST_CLK_CTRL1          8'h08  // reg_2  - Clock Control-1
`define WBHOST_CLK_CTRL2          8'h0C  // reg_3  - Clock Control-2

//--------------------------------------------------
// GLOBAL Register
// -------------------------------------------------
`define GLBL_CFG_CHIP_ID       8'h00  // reg_0  - Chip ID
`define GLBL_CFG_CFG0          8'h04  // reg_1  - Global Config-0
`define GLBL_CFG_CFG1          8'h08  // reg_2  - Global Config-1
`define GLBL_CFG_INTR_MSK      8'h0C  // reg_3  - Global Interrupt Mask
`define GLBL_CFG_INTR_STAT     8'h10  // reg_4  - Global Interrupt
`define GLBL_CFG_MUTI_FUNC     8'h14  // reg_5  - Multi functional sel
`define GLBL_CFG_CLK_CTRL      8'h18  // reg_6  - RTC/USB CLK CTRL
`define GLBL_CFG_PLL_CTRL1     8'h1C  // reg_7  - PLL Control-1
`define GLBL_CFG_PLL_CTRL2     8'h20  // reg_8  - PLL Control-2
`define GLBL_CFG_RANDOM_NO     8'h24  // reg_9  - Random Number
`define GLBL_CFG_PAD_STRAP     8'h30  // Strap as seen in Pad
`define GLBL_CFG_STRAP_STICKY  8'h34  // Sticky Strap used in next soft boot
`define GLBL_CFG_SYSTEM_STRAP  8'h38  // Current System Strap
`define GLBL_CFG_MAIL_BOX      8'h3C  // reg_15 - Mail Box
`define GLBL_CFG_SOFT_REG_0    8'h40  // reg_16 - Sof Register
`define GLBL_CFG_SOFT_REG_1    8'h44  // reg_17 - Sof Register
`define GLBL_CFG_SOFT_REG_2    8'h48  // reg_18 - Sof Register
`define GLBL_CFG_SOFT_REG_3    8'h4C  // reg_19 - Sof Register
`define GLBL_CFG_SOFT_REG_4    8'h50  // reg_20 - Sof Register
`define GLBL_CFG_SOFT_REG_5    8'h54  // reg_21 - Sof Register
`define GLBL_CFG_SOFT_REG_6    8'h58  // reg_22 - Sof Register
`define GLBL_CFG_SOFT_REG_7    8'h5C  // reg_23 - Sof Register

//--------------------------------------------------
// GPIO Register
// -------------------------------------------------
`define GPIO_CFG_DSEL         8'h00  // reg_0  - GPIO Direction Select
`define GPIO_CFG_TYPE         8'h04  // reg_1  - GPIO TYPE - Static/Waveform
`define GPIO_CFG_IDATA        8'h08  // reg_2  - GPIO Data In
`define GPIO_CFG_ODATA        8'h0C  // reg_3  - GPIO Data Out
`define GPIO_CFG_INTR_STAT    8'h10  // reg_4  - GPIO Interrupt status
`define GPIO_CFG_INTR_CLR     8'h10  // reg_4  - GPIO Interrupt Clear
`define GPIO_CFG_INTR_SET     8'h14  // reg_5  - GPIO Interrupt Set
`define GPIO_CFG_INTR_MASK    8'h18  // reg_6  - GPIO Interrupt Mask
`define GPIO_CFG_POS_INTR_SEL 8'h1C  // reg_7  - GPIO Posedge Interrupt
`define GPIO_CFG_NEG_INTR_SEL 8'h20  // reg_8  - GPIO Neg Interrupt


//--------------------------------------------------
// PWM Register
// -------------------------------------------------
`define PWM_GLBL_CFG0         8'h00  // reg_0 - PWM Global Config-0
`define PWM_GLBL_CFG1         8'h04  // reg_1 - PWM Global Config-1
`define PWM_GLBL_INTR_MASK    8'h08  // reg_2 - PWM Global Interrupt Status
`define PWM_GLBL_INTR_STAT    8'h0C  // reg_3 - PWM Global Interrupt Mask
`define PWM_BLK0_CFG0         8'h10  // reg_0 - PWM BLK-0 Reg-0
`define PWM_BLK0_CFG1         8'h14  // reg_1 - PWM BLK-0 Reg-1
`define PWM_BLK0_CFG2         8'h18  // reg_2 - PWM BLK-0 Reg-2
`define PWM_BLK0_CFG3         8'h1C  // reg_3 - PWM BLK-0 Reg-3
`define PWM_BLK1_CFG0         8'h20  // reg_0 - PWM BLK-1 Reg-0
`define PWM_BLK1_CFG1         8'h24  // reg_1 - PWM BLK-1 Reg-1
`define PWM_BLK1_CFG2         8'h28  // reg_2 - PWM BLK-1 Reg-2
`define PWM_BLK1_CFG3         8'h2C  // reg_3 - PWM BLK-1 Reg-3
`define PWM_BLK2_CFG0         8'h30  // reg_0 - PWM BLK-2 Reg-0
`define PWM_BLK2_CFG1         8'h34  // reg_1 - PWM BLK-2 Reg-1
`define PWM_BLK2_CFG2         8'h38  // reg_2 - PWM BLK-2 Reg-2
`define PWM_BLK2_CFG3         8'h3C  // reg_3 - PWM BLK-2 Reg-3
`define PWM_BLK3_CFG0         8'h40  // reg_0 - PWM BLK-3 Reg-0
`define PWM_BLK3_CFG1         8'h44  // reg_1 - PWM BLK-3 Reg-1
`define PWM_BLK3_CFG2         8'h48  // reg_2 - PWM BLK-3 Reg-2
`define PWM_BLK3_CFG3         8'h4C  // reg_3 - PWM BLK-3 Reg-3
`define PWM_BLK4_CFG0         8'h50  // reg_0 - PWM BLK-4 Reg-0
`define PWM_BLK4_CFG1         8'h54  // reg_1 - PWM BLK-4 Reg-1
`define PWM_BLK4_CFG2         8'h58  // reg_2 - PWM BLK-4 Reg-2
`define PWM_BLK4_CFG3         8'h5C  // reg_3 - PWM BLK-4 Reg-3
`define PWM_BLK5_CFG0         8'h60  // reg_0 - PWM BLK-5 Reg-0
`define PWM_BLK5_CFG1         8'h64  // reg_1 - PWM BLK-5 Reg-1
`define PWM_BLK5_CFG2         8'h68  // reg_2 - PWM BLK-5 Reg-2
`define PWM_BLK5_CFG3         8'h6C  // reg_3 - PWM BLK-5 Reg-3

//--------------------------------------------------
// TIMER Register
// -------------------------------------------------
`define TIMER_CFG_GLBL        8'h00  // reg_0 - Global Config
`define TIMER_CFG_TIMER_0     8'h04  // reg_1 - Timer-0
`define TIMER_CFG_TIMER_1     8'h08  // reg_2 - Timer-1
`define TIMER_CFG_TIMER_2     8'h0C  // reg_3 - Timer-2

//--------------------------------------------------
// SEMAPHORE Register
// -------------------------------------------------
`define SEMA_CFG_LOCK_0       8'h00  // reg_0  - Semaphore Lock Bit-0
`define SEMA_CFG_LOCK_1       8'h04  // reg_1  - Semaphore Lock Bit-1
`define SEMA_CFG_LOCK_2       8'h08  // reg_2  - Semaphore Lock Bit-2
`define SEMA_CFG_LOCK_3       8'h0C  // reg_3  - Semaphore Lock Bit-3
`define SEMA_CFG_LOCK_4       8'h10  // reg_4  - Semaphore Lock Bit-4
`define SEMA_CFG_LOCK_5       8'h14  // reg_5  - Semaphore Lock Bit-5
`define SEMA_CFG_LOCK_6       8'h18  // reg_6  - Semaphore Lock Bit-6
`define SEMA_CFG_LOCK_7       8'h1C  // reg_7  - Semaphore Lock Bit-7
`define SEMA_CFG_LOCK_8       8'h20  // reg_8  - Semaphore Lock Bit-8
`define SEMA_CFG_LOCK_9       8'h24  // reg_9  - Semaphore Lock Bit-9
`define SEMA_CFG_LOCK_10      8'h28  // reg_10 - Semaphore Lock Bit-10
`define SEMA_CFG_LOCK_11      8'h2C  // reg_11 - Semaphore Lock Bit-11
`define SEMA_CFG_LOCK_12      8'h30  // reg_12 - Semaphore Lock Bit-12
`define SEMA_CFG_LOCK_13      8'h34  // reg_13 - Semaphore Lock Bit-13
`define SEMA_CFG_LOCK_14      8'h38  // reg_14 - Semaphore Lock Bit-14
`define SEMA_CFG_STATUS       8'h3C  // reg_15 - Semaphore Lock Status


//----------------------------------------------------
// Analog Configuration
//----------------------------------------------------
`define ANALOG_CFG_DAC0          8'h00
`define ANALOG_CFG_DAC1          8'h04
`define ANALOG_CFG_DAC2          8'h08
`define ANALOG_CFG_DAC3          8'h0C

//----------------------------------------------------------
// QSPI Register Map
//----------------------------------------------------------
`define QSPIM_GLBL_CTRL          8'h00
`define QSPIM_DMEM_G0_RD_CTRL    8'h04
`define QSPIM_DMEM_G0_WR_CTRL    8'h08
`define QSPIM_DMEM_G1_RD_CTRL    8'h0C
`define QSPIM_DMEM_G1_WR_CTRL    8'h10

`define QSPIM_DMEM_CS_AMAP       8'h14
`define QSPIM_DMEM_CA_AMASK      8'h18

`define QSPIM_IMEM_CTRL1         8'h1C
`define QSPIM_IMEM_CTRL2         8'h20
`define QSPIM_IMEM_ADDR          8'h24
`define QSPIM_IMEM_WDATA         8'h28
`define QSPIM_IMEM_RDATA         8'h2C
`define QSPIM_SPI_STATUS         8'h30

//----------------------------------------------------------
// UART Register Map
//----------------------------------------------------------
`define UART_CTRL         8'h00  // Reg-0
`define UART_INTR_STAT    8'h04  // Reg-1
`define UART_BAUD_CTRL1   8'h08  // Reg-2
`define UART_BAUD_CTRL2   8'h0C  // Reg-3
`define UART_STATUS       8'h10  // Reg-4
`define UART_TDATA        8'h14  // Reg-5
`define UART_RDATA        8'h18  // Reg-6
`define UART_TFIFO_STAT   8'h1C  // Reg-7
`define UART_RFIFO_STAT   8'h20  // Reg-8

//--------------------------------------------------------
// RTC Register Map
//--------------------------------------------------------
`define  RTC_CMD          8'h0
`define  RTC_TIME         8'h4
`define  RTC_DATE         8'h8
`define  RTC_ALRM1        8'hC
`define  RTC_ALRM2        8'h10
`define  RTC_CTRL         8'h14

//--------------------------------------------------------
// IR RECEIVER Register Map
//--------------------------------------------------------
`define IR_CFG_CMD          8'h00 
`define IR_CFG_MULTIPLIER   8'h04 
`define IR_CFG_DIVIDER      8'h08 
`define IR_CFG_RX_DATA      8'h0C 
`define IR_CFG_TX_DATA      8'h10 

//--------------------------------------------------------
// STEPPER Register Map
//--------------------------------------------------------
`define SM_CFG_CMD          8'h00
`define SM_CFG_MUL          8'h04
`define SM_CFG_DIV          8'h08
`define SM_CFG_PER          8'h0C
`define SM_CFG_CTRL         8'h10

//--------------------------------------------------------
// WB INTER-CONNECT Register Map
//--------------------------------------------------------
`define WBI_CFG_STAT        8'h00
`define WBI_CFG_DCG         8'h04
