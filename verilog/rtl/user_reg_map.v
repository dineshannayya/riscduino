
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
`define ADDR_SPACE_GPIO    32'h3002_0040
`define ADDR_SPACE_PWM     32'h3002_0080
`define ADDR_SPACE_TIMER   32'h3002_00C0
`define ADDR_SPACE_SEMA    32'h3002_0100
`define ADDR_SPACE_WBHOST  32'h3008_0000

//--------------------------------------------------
//  WB Host Register
//--------------------------------------------------
`define WBHOST_GLBL_CFG           8'h00  // reg_0  - Global Config
`define WBHOST_BANK_SEL           8'h04  // reg_1  - Bank Select
`define WBHOST_CLK_CTRL1          8'h08  // reg_2  - Clock Control-1
`define WBHOST_CLK_CTRL2          8'h0C  // reg_3  - Clock Control-2
`define WBHOST_PLL_CTRL           8'h10  // reg_4  - PLL Control

//--------------------------------------------------
// GLOBAL Register
// -------------------------------------------------
`define GLBL_CFG_CHIP_ID       8'h00  // reg_0  - Chip ID
`define GLBL_CFG_CFG0          8'h04  // reg_1  - Global Config-0
`define GLBL_CFG_CFG1          8'h08  // reg_2  - Global Config-1
`define GLBL_CFG_INTR_MSK      8'h0C  // reg_3  - Global Interrupt Mask
`define GLBL_CFG_INTR_STAT     8'h10  // reg_4  - Global Interrupt
`define GLBL_CFG_MUTI_FUNC     8'h14  // reg_5  - Multi functional sel
`define GLBL_CFG_SOFT_REG_0    8'h18  // reg_6 - Sof Register
`define GLBL_CFG_SOFT_REG_1    8'h1C  // reg_7 - Sof Register
`define GLBL_CFG_SOFT_REG_2    8'h20  // reg_8 - Sof Register
`define GLBL_CFG_SOFT_REG_3    8'h24  // reg_9 - Sof Register
`define GLBL_CFG_SOFT_REG_4    8'h28  // reg_10 - Sof Register
`define GLBL_CFG_SOFT_REG_5    8'h2C  // reg_11 - Sof Register

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
`define PWM_GLBL_CFG          8'h00  // reg_0 - PWM Global Config
`define PWM_CFG_PWM_0         8'h04  // reg_1 - PWM Reg-0
`define PWM_CFG_PWM_1         8'h08  // reg_2 - PWM Reg-1
`define PWM_CFG_PWM_2         8'h0C  // reg_3 - PWM Reg-2
`define PWM_CFG_PWM_3         8'h10  // reg_4 - PWM Reg-3
`define PWM_CFG_PWM_4         8'h14  // reg_5 - PWM Reg-4
`define PWM_CFG_PWM_5         8'h18  // reg_6 - PWM Reg-5

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
