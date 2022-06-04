
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
// Pinmux Register
// -------------------------------------------------

`define PINMUX_CHIP_ID           8'h00  // reg_0  - Chip ID
`define PINMUX_GBL_CFG0          8'h04  // reg_1  - Global Config-2
`define PINMUX_GBL_CFG1          8'h08  // reg_2  - Global Config-1
`define PINMUX_GBL_INTR_MSK      8'h0C  // reg_3  - Global Interrupt Mask
`define PINMUX_GBL_INTR          8'h10  // reg_4  - Global Interrupt
`define PINMUX_GPIO_IDATA        8'h14  // reg_5  - GPIO Data In
`define PINMUX_GPIO_ODATA        8'h18  // reg_6  - GPIO Data Out
`define PINMUX_GPIO_DSEL         8'h1C  // reg_7  - GPIO Direction Select
`define PINMUX_GPIO_TYPE         8'h20  // reg_8  - GPIO TYPE - Static/Waveform
`define PINMUX_GPIO_INTR_STAT    8'h24  // reg_9  - GPIO Interrupt status
`define PINMUX_GPIO_INTR_CLR     8'h24  // reg_9  - GPIO Interrupt Clear
`define PINMUX_GPIO_INTR_SET     8'h28  // reg_10 - GPIO Interrupt Set
`define PINMUX_GPIO_INTR_MASK    8'h2C  // reg_11 - GPIO Interrupt Mask
`define PINMUX_GPIO_POS_INTR     8'h30  // reg_12 - GPIO Posedge Interrupt
`define PINMUX_GPIO_NEG_INTR     8'h34  // reg_13 - GPIO Neg Interrupt
`define PINMUX_GPIO_MULTI_FUNC   8'h38  // reg_14 - GPIO Multi Function
`define PINMUX_SOFT_REG_0        8'h3C  // reg_15 - Soft Register
`define PINMUX_CFG_PWM0          8'h40  // reg_16 - PWM Reg-0
`define PINMUX_CFG_PWM1          8'h44  // reg_17 - PWM Reg-1
`define PINMUX_CFG_PWM2          8'h48  // reg_18 - PWM Reg-2
`define PINMUX_CFG_PWM3          8'h4C  // reg_19 - PWM Reg-3
`define PINMUX_CFG_PWM4          8'h50  // reg_20 - PWM Reg-4
`define PINMUX_CFG_PWM5          8'h54  // reg_21 - PWM Reg-5
`define PINMUX_SOFT_REG_1        8'h58  // reg_22 - Sof Register
`define PINMUX_SOFT_REG_2        8'h5C  // reg_23 - Sof Register
`define PINMUX_SOFT_REG_3        8'h60  // reg_24 - Sof Register
`define PINMUX_SOFT_REG_4        8'h64  // reg_25 - Sof Register
`define PINMUX_SOFT_REG_5        8'h68  // reg_26 - Sof Register
`define PINMUX_SOFT_REG_6        8'h6C  // reg_27 - Sof Register
`define PINMUX_CFG_TIMER0        8'h70  // reg_28 - Timer-0
`define PINMUX_CFG_TIMER1        8'h74  // reg_28 - Timer-1
`define PINMUX_CFG_TIMER2        8'h78  // reg_28 - Timer-2

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

