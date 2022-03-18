

//-------------------------------------
// PinMux Register
// ------------------------------------
#define reg_pinmux_chip_id           (*(volatile uint32_t*)0x30020000)  // reg_0  - Chip ID
#define reg_pinmux_gbl_cfg0          (*(volatile uint32_t*)0x30020004)  // reg_1  - Global Config-2
#define reg_pinmux_gbl_cfg1          (*(volatile uint32_t*)0x30020008)  // reg_2  - Global Config-1
#define reg_pinmux_gbl_intr_msk      (*(volatile uint32_t*)0x3002000C)  // reg_3  - Global Interrupt Mask
#define reg_pinmux_gbl_intr          (*(volatile uint32_t*)0x30020010)  // reg_4  - Global Interrupt
#define reg_pinmux_gpio_idata        (*(volatile uint32_t*)0x30020014)  // reg_5  - GPIO Data In
#define reg_pinmux_gpio_odata        (*(volatile uint32_t*)0x30020018)  // reg_6  - GPIO Data Out
#define reg_pinmux_gpio_dsel         (*(volatile uint32_t*)0x3002001C)  // reg_7  - GPIO Direction Select
#define reg_pinmux_gpio_type         (*(volatile uint32_t*)0x30020020)  // reg_8  - GPIO TYPE - Static/Waveform
#define reg_pinmux_gpio_intr_stat    (*(volatile uint32_t*)0x30020024)  // reg_9  - GPIO Interrupt status
#define reg_pinmux_gpio_intr_clr     (*(volatile uint32_t*)0x30020024)  // reg_9  - GPIO Interrupt Clear
#define reg_pinmux_gpio_intr_set     (*(volatile uint32_t*)0x30020028)  // reg_10 - GPIO Interrupt Set
#define reg_pinmux_gpio_intr_mask    (*(volatile uint32_t*)0x3002002C)  // reg_11 - GPIO Interrupt Mask
#define reg_pinmux_gpio_pos_intr     (*(volatile uint32_t*)0x30020030)  // reg_12 - GPIO Posedge Interrupt
#define reg_pinmux_gpio_neg_intr     (*(volatile uint32_t*)0x30020034)  // reg_13 - GPIO Neg Interrupt
#define reg_pinmux_gpio_multi_func   (*(volatile uint32_t*)0x30020038)  // reg_14 - GPIO Multi Function
#define reg_pinmux_soft_reg_0        (*(volatile uint32_t*)0x3002003C)  // reg_15 - Soft Register
#define reg_pinmux_cfg_pwm0          (*(volatile uint32_t*)0x30020040)  // reg_16 - PWM Reg-0
#define reg_pinmux_cfg_pwm1          (*(volatile uint32_t*)0x30020044)  // reg_17 - PWM Reg-1
#define reg_pinmux_cfg_pwm2          (*(volatile uint32_t*)0x30020048)  // reg_18 - PWM Reg-2
#define reg_pinmux_cfg_pwm3          (*(volatile uint32_t*)0x3002004C)  // reg_19 - PWM Reg-3
#define reg_pinmux_cfg_pwm4          (*(volatile uint32_t*)0x30020050)  // reg_20 - PWM Reg-4
#define reg_pinmux_cfg_pwm5          (*(volatile uint32_t*)0x30020054)  // reg_21 - PWM Reg-5
#define reg_pinmux_soft_reg_1        (*(volatile uint32_t*)0x30020058)  // reg_22 - Sof Register
#define reg_pinmux_soft_reg_2        (*(volatile uint32_t*)0x3002005C)  // reg_23 - Sof Register
#define reg_pinmux_soft_reg_3        (*(volatile uint32_t*)0x30020060)  // reg_24 - Sof Register
#define reg_pinmux_soft_reg_4        (*(volatile uint32_t*)0x30020064)  // reg_25 - Sof Register
#define reg_pinmux_soft_reg_5        (*(volatile uint32_t*)0x30020068)  // reg_26 - Sof Register
#define reg_pinmux_soft_reg_6        (*(volatile uint32_t*)0x3002006C)  // reg_27 - Sof Register
#define reg_pinmux_cfg_timer0        (*(volatile uint32_t*)0x30020070)  // reg_28 - Timer-0
#define reg_pinmux_cfg_timer1        (*(volatile uint32_t*)0x30020074)  // reg_28 - Timer-1
#define reg_pinmux_cfg_timer2        (*(volatile uint32_t*)0x30020078)  // reg_28 - Timer-2

