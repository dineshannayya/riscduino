//--------------------------------------------------------------------
// Register Address Map As Seen By the Internal RISCV Core
//--------------------------------------------------------------------

//-------------------------------------
// PinMux Register
// ------------------------------------
#define reg_glbl_chip_id       (*(volatile uint32_t*)0x10020000)  // reg_0  - Chip ID
#define reg_glbl_cfg0          (*(volatile uint32_t*)0x10020004)  // reg_1  - Global Config-0
#define reg_glbl_cfg1          (*(volatile uint32_t*)0x10020008)  // reg_2  - Global Config-1
#define reg_glbl_intr_msk      (*(volatile uint32_t*)0x1002000C)  // reg_3  - Global Interrupt Mask
#define reg_glbl_intr          (*(volatile uint32_t*)0x10020010)  // reg_4  - Global Interrupt
#define reg_glbl_multi_func    (*(volatile uint32_t*)0x10020014)  // reg_5 -  GPIO Multi Function
#define reg_glbl_clk_ctrl      (*(volatile uint32_t*)0x10020018)  // reg_6 -  RTC/USB Clock control
#define reg_glbl_pll_ctrl1     (*(volatile uint32_t*)0x1002001C)  // reg_7 -  PLL Control-1
#define reg_glbl_pll_ctrl2     (*(volatile uint32_t*)0x10020020)  // reg_8 -  PLL Control-2
#define reg_glbl_pad_strap     (*(volatile uint32_t*)0x10020030)  // reg_12 - Pad Strap
#define reg_glbl_strap_sticky  (*(volatile uint32_t*)0x10020034)  // reg_13 - Strap Sticky
#define reg_glbl_system_strap  (*(volatile uint32_t*)0x10020038)  // reg_14 - System Strap
#define reg_glbl_mail_box      (*(volatile uint32_t*)0x1002003C)  // reg_15 - Mail Box
#define reg_glbl_soft_reg_0    (*(volatile uint32_t*)0x10020040)  // reg_16 - Soft Register-0
#define reg_glbl_soft_reg_1    (*(volatile uint32_t*)0x10020044)  // reg_17 - Soft Register-1
#define reg_glbl_soft_reg_2    (*(volatile uint32_t*)0x10020048)  // reg_18 - Soft Register-2
#define reg_glbl_soft_reg_3    (*(volatile uint32_t*)0x1002004C)  // reg_19 - Soft Register-3
#define reg_glbl_soft_reg_4    (*(volatile uint32_t*)0x10020050)  // reg_20 - Soft Register-4
#define reg_glbl_soft_reg_5    (*(volatile uint32_t*)0x10020054)  // reg_21 - Soft Register-5
#define reg_glbl_soft_reg_6    (*(volatile uint32_t*)0x10020058)  // reg_22 - Soft Register-6
#define reg_glbl_soft_reg_7    (*(volatile uint32_t*)0x1002005C)  // reg_23 - Soft Register-7

#define reg_gpio_dsel         (*(volatile uint32_t*)0x10020080)  // reg_0  - GPIO Direction Select
#define reg_gpio_type         (*(volatile uint32_t*)0x10020084)  // reg_1  - GPIO TYPE - Static/Waveform
#define reg_gpio_idata        (*(volatile uint32_t*)0x10020088)  // reg_2  - GPIO Data In
#define reg_gpio_odata        (*(volatile uint32_t*)0x1002008C)  // reg_3  - GPIO Data Out
#define reg_gpio_intr_stat    (*(volatile uint32_t*)0x10020090)  // reg_4  - GPIO Interrupt status
#define reg_gpio_intr_clr     (*(volatile uint32_t*)0x10020090)  // reg_5  - GPIO Interrupt Clear
#define reg_gpio_intr_set     (*(volatile uint32_t*)0x10020094)  // reg_6 - GPIO Interrupt Set
#define reg_gpio_intr_mask    (*(volatile uint32_t*)0x10020098)  // reg_7 - GPIO Interrupt Mask
#define reg_gpio_pos_intr     (*(volatile uint32_t*)0x1002009C)  // reg_8 - GPIO Posedge Interrupt
#define reg_gpio_neg_intr     (*(volatile uint32_t*)0x100200A0)  // reg_9 - GPIO Neg Interrupt

#define reg_pwm_glbl_cfg      (*(volatile uint32_t*)0x10020100)  // reg_0 - PWM Reg-0
#define reg_pwm_cfg_pwm0      (*(volatile uint32_t*)0x10020104)  // reg_1 - PWM Reg-0
#define reg_pwm_cfg_pwm1      (*(volatile uint32_t*)0x10020108)  // reg_2 - PWM Reg-1
#define reg_pwm_cfg_pwm2      (*(volatile uint32_t*)0x1002011C)  // reg_3 - PWM Reg-2
#define reg_pwm_cfg_pwm3      (*(volatile uint32_t*)0x10020110)  // reg_4 - PWM Reg-3
#define reg_pwm_cfg_pwm4      (*(volatile uint32_t*)0x10020114)  // reg_5 - PWM Reg-4
#define reg_pwm_cfg_pwm5      (*(volatile uint32_t*)0x10020118)  // reg_6 - PWM Reg-5

#define reg_timer_glbl_cfg    (*(volatile uint32_t*)0x10020180)  // reg_0 - Global config
#define reg_timer_cfg_timer0  (*(volatile uint32_t*)0x10020184)  // reg_1 - Timer-0
#define reg_timer_cfg_timer1  (*(volatile uint32_t*)0x10020188)  // reg_2 - Timer-1
#define reg_timer_cfg_timer2  (*(volatile uint32_t*)0x1002018C)  // reg_3 - Timer-2

#define reg_sema_lock0        (*(volatile uint32_t*)0x10020200)  // reg_0  - Hardware Lock-0
#define reg_sema_lock1        (*(volatile uint32_t*)0x10020204)  // reg_1  - Hardware Lock-1
#define reg_sema_lock2        (*(volatile uint32_t*)0x10020208)  // reg_2  - Hardware Lock-2
#define reg_sema_lock3        (*(volatile uint32_t*)0x1002020C)  // reg_3  - Hardware Lock-3
#define reg_sema_lock4        (*(volatile uint32_t*)0x10020210)  // reg_4  - Hardware Lock-4
#define reg_sema_lock5        (*(volatile uint32_t*)0x10020214)  // reg_5  - Hardware Lock-5
#define reg_sema_lock6        (*(volatile uint32_t*)0x10020218)  // reg_6  - Hardware Lock-6
#define reg_sema_lock7        (*(volatile uint32_t*)0x1002021C)  // reg_7  - Hardware Lock-7
#define reg_sema_lock8        (*(volatile uint32_t*)0x10020220)  // reg_8  - Hardware Lock-8
#define reg_sema_lock9        (*(volatile uint32_t*)0x10020224)  // reg_9  - Hardware Lock-9
#define reg_sema_lock10       (*(volatile uint32_t*)0x10020228)  // reg_10 - Hardware Lock-10
#define reg_sema_lock11       (*(volatile uint32_t*)0x1002022C)  // reg_11 - Hardware Lock-11
#define reg_sema_lock12       (*(volatile uint32_t*)0x10020230)  // reg_12 - Hardware Lock-12
#define reg_sema_lock13       (*(volatile uint32_t*)0x10020234)  // reg_13 - Hardware Lock-13
#define reg_sema_lock14       (*(volatile uint32_t*)0x10020238)  // reg_14 - Hardware Lock-14
#define reg_sema_lock_cfg     (*(volatile uint32_t*)0x1002023C)  // reg_15 - Hardware Lock config
#define reg_sema_lock_stat    (*(volatile uint32_t*)0x1002023C)  // reg_15 - Hardware Lock Status


#define reg_uart0_ctrl         (*(volatile uint32_t*)0x10010000)  // Reg-0
#define reg_uart0_intr_stat    (*(volatile uint32_t*)0x10010004)  // Reg-1
#define reg_uart0_baud_ctrl1   (*(volatile uint32_t*)0x10010008)  // Reg-2
#define reg_uart0_baud_ctrl2   (*(volatile uint32_t*)0x1001000C)  // Reg-3
#define reg_uart0_status       (*(volatile uint32_t*)0x10010010)  // Reg-4
#define reg_uart0_txdata       (*(volatile uint32_t*)0x10010014)  // Reg-5
#define reg_uart0_rxdata       (*(volatile uint32_t*)0x10010018)  // Reg-6
#define reg_uart0_txfifo_stat  (*(volatile uint32_t*)0x1001001C)  // Reg-7
#define reg_uart0_rxfifo_stat  (*(volatile uint32_t*)0x10010020)  // Reg-8

#define reg_uart1_ctrl         (*(volatile uint32_t*)0x10010100)  // Reg-0
#define reg_uart1_intr_stat    (*(volatile uint32_t*)0x10010104)  // Reg-1
#define reg_uart1_baud_ctrl1   (*(volatile uint32_t*)0x10010108)  // Reg-2
#define reg_uart1_baud_ctrl2   (*(volatile uint32_t*)0x1001010C)  // Reg-3
#define reg_uart1_status       (*(volatile uint32_t*)0x10010110)  // Reg-4
#define reg_uart1_txdata       (*(volatile uint32_t*)0x10010114)  // Reg-5
#define reg_uart1_rxdata       (*(volatile uint32_t*)0x10010118)  // Reg-6
#define reg_uart1_txfifo_stat  (*(volatile uint32_t*)0x1001011C)  // Reg-7
#define reg_uart1_rxfifo_stat  (*(volatile uint32_t*)0x10010120)  // Reg-8

// AES Encription Register
#define reg_aes_enc_ctrl           (*(volatile uint32_t*)0x0C490080)  // Reg-0

#define reg_aes_enc_key_dw0        (*(volatile uint32_t*)0x0C490084)  // Reg-1
#define reg_aes_enc_key_dw1        (*(volatile uint32_t*)0x0C490088)  // Reg-2
#define reg_aes_enc_key_dw2        (*(volatile uint32_t*)0x0C49008C)  // Reg-3
#define reg_aes_enc_key_dw3        (*(volatile uint32_t*)0x0C490090)  // Reg-4
#define reg_aes_enc_key_bptr       (*(volatile uint8_t*)0x0C490093)  // Last Addr Location

#define reg_aes_enc_text_in_dw0    (*(volatile uint32_t*)0x0C490094) // Reg-5
#define reg_aes_enc_text_in_dw1    (*(volatile uint32_t*)0x0C490098) // Reg-6
#define reg_aes_enc_text_in_dw2    (*(volatile uint32_t*)0x0C49009C) // Reg-7
#define reg_aes_enc_text_in_dw3    (*(volatile uint32_t*)0x0C4900A0) // Reg-8
#define reg_aes_enc_text_in_bptr   (*(volatile uint8_t*)0x0C4900A3)  // Last Addr Location

#define reg_aes_enc_text_out_dw0   (*(volatile uint32_t*)0x0C4900A4) // Reg-9
#define reg_aes_enc_text_out_dw1   (*(volatile uint32_t*)0x0C4900A8) // Reg-10
#define reg_aes_enc_text_out_dw2   (*(volatile uint32_t*)0x0C4900AC) // Reg-11
#define reg_aes_enc_text_out_dw3   (*(volatile uint32_t*)0x0C4900B0) // Reg-12
#define reg_aes_enc_text_out_bptr  (*(volatile uint8_t*)0x0C4900B3)  // Last Addr Location

// AES Decryption Register
#define reg_aes_dec_ctrl           (*(volatile uint32_t*)0x0C4900C0)  // Reg-0
#define reg_aes_dec_key_dw0        (*(volatile uint32_t*)0x0C4900C4)  // Reg-1
#define reg_aes_dec_key_dw1        (*(volatile uint32_t*)0x0C4900C8)  // Reg-2
#define reg_aes_dec_key_dw2        (*(volatile uint32_t*)0x0C4900CC)  // Reg-3
#define reg_aes_dec_key_dw3        (*(volatile uint32_t*)0x0C4900D0)  // Reg-4
#define reg_aes_dec_key_bptr       (*(volatile uint8_t*)0x0C4900D3)   // Last Addr Location

#define reg_aes_dec_text_in_dw0    (*(volatile uint32_t*)0x0C4900D4)  // Reg-5
#define reg_aes_dec_text_in_dw1    (*(volatile uint32_t*)0x0C4900D8)  // Reg-6
#define reg_aes_dec_text_in_dw2    (*(volatile uint32_t*)0x0C4900DC)  // Reg-7
#define reg_aes_dec_text_in_dw3    (*(volatile uint32_t*)0x0C4900E0)  // Reg-8
#define reg_aes_dec_text_in_bptr   (*(volatile uint8_t*)0x0C4900E3)   // Last Addr Location

#define reg_aes_dec_text_out_dw0   (*(volatile uint32_t*)0x0C4900E4)  // Reg-9
#define reg_aes_dec_text_out_dw1   (*(volatile uint32_t*)0x0C4900E8)  // Reg-10
#define reg_aes_dec_text_out_dw2   (*(volatile uint32_t*)0x0C4900EC)  // Reg-11
#define reg_aes_dec_text_out_dw3   (*(volatile uint32_t*)0x0C4900F0)  // Reg-12
#define reg_aes_dec_text_out_bptr  (*(volatile uint8_t*)0x0C4900F3)   // Last Addr Location

// FPU Core
#define reg_fpu_ctrl (*(volatile uint32_t*)0x0C490100)  // Reg-0
#define reg_fpu_din1 (*(volatile uint32_t*)0x0C490104)  // Reg-1
#define reg_fpu_din2 (*(volatile uint32_t*)0x0C490108)  // Reg-2
#define reg_fpu_res  (*(volatile uint32_t*)0x0C49010C)  // Reg-3

// Wishbone Interconnect
#define reg_wbi_stat         (*(volatile uint32_t*)0x10030000)  // Reg-0
#define reg_wbi_dcg          (*(volatile uint32_t*)0x10030004)  // Reg-1


// CPU Core Specific Register
#define reg_cpu_glbl_cfg (*(volatile uint32_t*)0x0C490018)  // Global config
#define reg_cpu_clk_cfg  (*(volatile uint32_t*)0x0C49001C)  // CPU clock config

