//////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2021 , Dinesh Annayya                          
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0
// SPDX-FileContributor: Created by Dinesh Annayya <dinesha@opencores.org>
//
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Pinmux                                                      ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
////      Manages all the pin multiplexing                        ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 16th Aug 2022, Dinesh A                             ////
////          Seperated the pinmux from pinmux_top module         ////
////    0.2 - 21th Aug 2022, Dinesh A                             ////
////          uart_master disable option added                    ////
////    0.3 - 28th Aug 2022, Dinesh A                             ////
////          Due to caravel io[4:0] reserved on power up, we have////
////          re-arrange the arduino pins from 5 onward           ////
////    0.4 - 5 Jan 2023, Dinesh A                                ////
////          A. Stepper Motor Integration                        ////
////          B. Riscv Tap Integration                            ////
//////////////////////////////////////////////////////////////////////
/************************************************
* Pin Mapping    Arduino              ATMGE CONFIG
*   ATMEGA328     Port                                                      caravel Pin Mapping
*   Pin-1         22            PC6/WS[0]/RESET*                            digital_io[5]
*   Pin-2         0             PD0/WS[0]/MRXD/RXD[0]                       digital_io[6]
*   Pin-3         1             PD1/WS[0]/MRXD/TXD[0]                       digital_io[7]
*   Pin-4         2             PD2/WS[0]/RXD[1]/INT0                       digital_io[8]
*   Pin-5         3             PD3/WS[1]INT1/OC2B(PWM0)                    digital_io[9]
*   Pin-6         4             PD4/WS[1]TXD[1]                             digital_io[10]
*   Pin-7                       VCC                  -
*   Pin-8                       GND                  -
*   Pin-9         20            PB6/WS[1]/XTAL1/TOSC1                       digital_io[11]
*   Pin-10        21            PB7/WS[1]/XTAL2/TOSC2/IR-RX                 digital_io[12]
*   Pin-11        5             PD5/WS[2]/SS[3]/OC0B(PWM1)/T1   strap[0]    digital_io[13]
*   Pin-12        6             PD6/WS[2]/SS[2]/OC0A(PWM2)/AIN0 strap[1]    digital_io[14]/analog_io[2]
*   Pin-13        7             PD7/WS[2]/A1N1/IR-TX            strap[2]    digital_io[15]/analog_io[3]
*   Pin-14        8             PB0/WS[2]/CLKO/ICP1             strap[3]    digital_io[16]
*   Pin-15        9             PB1/WS[3]/SS[1]/OC1A(PWM3)      strap[4]    digital_io[17]
*   Pin-16        10            PB2/WS[3]/SS[0]/OC1B(PWM4)      strap[5]    digital_io[18]
*   Pin-17        11            PB3/WS[3]/MOSI/OC2A(PWM5)       strap[6]    digital_io[19]
*   Pin-18        12            PB4/WS[3]/MISO                  strap[7]    digital_io[20]
*   Pin-19        13            PB5/SCK                                     digital_io[21]
*   Pin-20                      AVCC                -
*   Pin-21                      AREF                                        analog_io[10]
*   Pin-22                      GND                 -
*   Pin-23        14            PC0/ADC0                                    digital_io[22]/analog_io[11]
*   Pin-24        15            PC1/ADC1                                    digital_io[23]/analog_io[12]
*   Pin-25        16            PC2/usb_dp/ADC2                             digital_io[24]/analog_io[13]
*   Pin-26        17            PC3/usb_dn/ADC3                             digital_io[25]/analog_io[14]
*   Pin-27        18            PC4/ADC4/SDA                                digital_io[26]/analog_io[15]
*   Pin-28        19            PC5/ADC5/SCL                                digital_io[27]/analog_io[16]
*
*  Additional Pad used for Externam ROM/RAM
*                               sflash_sck                                 digital_io[28]
*                               sflash_ss[0]                  strap[8]     digital_io[29]
*                               sflash_ss[1]                  strap[9]     digital_io[30]
*                               sflash_ss[2]                  strap[10]    digital_io[31]
*                               sflash_ss[3]                  strap[11]    digital_io[32]
*                               sflash_io0                    strap[12]    digital_io[33]
*                               sflash_io1                    strap[13]    digital_io[34]
*                               sflash_io2                    strap[14]    digital_io[35]
*                               sflash_io3                    strap[15]    digital_io[36]
*                               dbg_clk_mon                                digital_io[37]
*   These port are not available at power up
*                               PA0/trst_n/sm_a1                           digital_io[0]
*                               PA1/tck/sm_a2                              digital_io[1]
*                               PA2/tms/sm_b1                              digital_io[2]
*                               PA3/tdi/sm_b2                              digital_io[3]
*                               PA4/tdo                                    digital_io[4]
****************************************************************
* Pin-1 RESET is not supported as there is no suppport for fuse config


**************/

module pinmux (
               `ifdef YCR_DBG_EN
                   // -- JTAG I/F
                output   logic         riscv_trst_n,
                output   logic         riscv_tck,
                output   logic         riscv_tms,
                output   logic         riscv_tdi,
                input    logic         riscv_tdo,
                input    logic         riscv_tdo_en,
               `endif // YCR_DBG_EN


               input logic             cfg_strap_pad_ctrl      , // 1 - Keep the Pad in input direction
               output logic [15:0]     pad_strap_in            , // Strap value
               // Digital IO
               output logic [37:0]     digital_io_out          ,
               output logic [37:0]     digital_io_oen          ,
               input  logic [37:0]     digital_io_in           ,

               output logic            xtal_clk                ,

               // Config
               input logic  [31:0]    cfg_gpio_out_type        ,// GPIO Type, 1 - WS_281X port
               input logic  [31:0]    cfg_gpio_dir_sel         ,
               input logic  [31:0]    cfg_multi_func_sel       ,

               output logic[5:0]       cfg_pwm_enb             ,
               input logic [5:0]       pwm_wfm                 ,
               output logic [1:0]      ext_intr_in             ,  // External PAD level interrupt
               output  logic [31:0]    pad_gpio_in             ,  // GPIO data input from PAD
               input  logic [31:0]     pad_gpio_out            ,  // GPIO Data out towards PAD

		       // SFLASH I/F
		       input  logic            sflash_sck              ,
		       input  logic [3:0]      sflash_ss               ,
		       input  logic [3:0]      sflash_oen              ,
		       input  logic [3:0]      sflash_do               ,
		       output logic [3:0]      sflash_di               ,

		       // SSRAM I/F - Temp Masked
		       //input  logic            ssram_sck,
		       //input  logic            ssram_ss,
		       //input  logic [3:0]      ssram_oen,
		       //input  logic [3:0]      ssram_do,
		       //output logic [3:0]      ssram_di,

		       // USB I/F
		       input   logic           usb_dp_o,
		       input   logic           usb_dn_o,
		       input   logic           usb_oen,
		       output   logic          usb_dp_i,
		       output   logic          usb_dn_i,

		       // UART I/F
		       input   logic  [1:0]    uart_txd,
		       output  logic  [1:0]    uart_rxd,

		       // I2CM I/F
		       input   logic           i2cm_clk_o,
		       output  logic           i2cm_clk_i,
		       input   logic           i2cm_clk_oen,
		       input   logic           i2cm_data_oen,
		       input   logic           i2cm_data_o,
		       output  logic           i2cm_data_i,

		       // SPI MASTER
		       input   logic           spim_sck,
		       input   logic [3:0]     spim_ssn,
		       input   logic           spim_miso,
		       output  logic           spim_mosi,
		       
		       // SPI SLAVE
		       output   logic           spis_sck,
		       output   logic           spis_ssn,
		       input    logic           spis_miso,
		       output   logic           spis_mosi,

               // UART MASTER I/F
               output  logic            uartm_rxd ,
               input logic              uartm_txd ,       

               // WS_281X TXD Port
               input logic [3:0]        ws_txd,

		       input   logic           dbg_clk_mon,
             
               // IR Receiver
               output  logic           ir_rx,
               input   logic           ir_tx,

               //------------------------------
               // Stepper Motor Variable
               //------------------------------
               input logic              sm_a1,  
               input logic              sm_a2,  
               input logic              sm_b1,  
               input logic              sm_b2  


   ); 



reg [7:0]     port_a_in;      // PORT A Data In
reg [7:0]     port_b_in;      // PORT B Data In
reg [7:0]     port_c_in;      // PORT C Data In
reg [7:0]     port_d_in;      // PORT D Data In

wire [7:0]    port_a_out;     // PORT A Data Out
wire [7:0]    port_b_out;     // PORT B Data Out
wire [7:0]    port_c_out;     // PORT C Data Out
wire [7:0]    port_d_out;     // PORT D Data Out

//--------------------------------------------------
// Strap Pin Mapping
//--------------------------------------------------
assign pad_strap_in = {digital_io_in[36:29],digital_io_in[20:13] };


// GPIO to PORT Mapping
assign      pad_gpio_in[7:0]     = port_a_in;
assign      pad_gpio_in[15:8]    = port_b_in;
assign      pad_gpio_in[23:16]   = port_c_in;
assign      pad_gpio_in[31:24]   = port_d_in;

assign      port_a_out           = pad_gpio_out[7:0];
assign      port_b_out           = pad_gpio_out[15:8];
assign      port_c_out           = pad_gpio_out[23:16];
assign      port_d_out           = pad_gpio_out[31:24];


assign      cfg_pwm_enb          = cfg_multi_func_sel[5:0];
wire [1:0]  cfg_int_enb          = cfg_multi_func_sel[7:6];
wire [1:0]  cfg_uart_enb         = cfg_multi_func_sel[9:8];
wire        cfg_spim_enb         = cfg_multi_func_sel[10];
wire [3:0]  cfg_spim_cs_enb      = cfg_multi_func_sel[14:11];
wire        cfg_i2cm_enb         = cfg_multi_func_sel[15];
wire        cfg_usb_enb          = cfg_multi_func_sel[16];
wire        cfg_ir_tx_enb        = cfg_multi_func_sel[17]; // NEC IR TX Enable
wire        cfg_sm_enb           = cfg_multi_func_sel[18]; // Stepper Motor Enable
wire        cfg_tap_enb          = cfg_multi_func_sel[30]; // 1 - Riscv Tap Enable
wire        cfg_muart_enb        = cfg_multi_func_sel[31]; // 1 - uart master enable, 

wire [7:0]  cfg_port_a_dir_sel   = cfg_gpio_dir_sel[7:0];
wire [7:0]  cfg_port_b_dir_sel   = cfg_gpio_dir_sel[15:8];
wire [7:0]  cfg_port_c_dir_sel   = cfg_gpio_dir_sel[23:16];
wire [7:0]  cfg_port_d_dir_sel   = cfg_gpio_dir_sel[31:24];

wire [7:0]  cfg_port_a_port_type   = cfg_gpio_out_type[7:0];
wire [7:0]  cfg_port_b_port_type   = cfg_gpio_out_type[15:8];
wire [7:0]  cfg_port_c_port_type   = cfg_gpio_out_type[23:16];
wire [7:0]  cfg_port_d_port_type   = cfg_gpio_out_type[31:24];

// This logic to create spi slave interface
logic        pin_resetn,spis_boot;

// On Reset internal SPI Master is disabled, If cfg_spim_enb = 0, then we are in
// SPIS Boot Mode
assign      spis_boot = (cfg_spim_enb ) ? 1'b0: !pin_resetn; 
assign      spis_ssn  = (spis_boot    ) ? pin_resetn : 1'b1;

// datain selection
always_comb begin
     port_a_in = 'h0;
     port_b_in = 'h0;
     port_c_in = 'h0;
     port_d_in = 'h0;
     uart_rxd   = 'b1;
     ext_intr_in= 'h0;
     spim_mosi  = 'h0;
     i2cm_data_i= 'h0;
     i2cm_clk_i = 'h0;
     uartm_rxd  = 'b1;
     xtal_clk   = 'b0;
     ir_rx      = 'b0;

     //Pin-1        PC6/RESET*          digital_io[5]
     port_c_in[6] = digital_io_in[5];
     pin_resetn   = digital_io_in[5];

     //Pin-2        PD0/MRXD/RXD[0]             digital_io[6]
     port_d_in[0] = digital_io_in[6];
     if (cfg_muart_enb)        uartm_rxd     = digital_io_in[6];
     else if(cfg_uart_enb[0])  uart_rxd[0]   = digital_io_in[6];
  
     //Pin-3        PD1/MTXD/TXD[0]             digital_io[7]
     port_d_in[1] = digital_io_in[7];


     //Pin-4        PD2/RXD[1]/INT0      digital_io[8]
     port_d_in[2] = digital_io_in[8];
     if(cfg_uart_enb[1])     uart_rxd[1]    = digital_io_in[8];
     else if(cfg_int_enb[0]) ext_intr_in[0] = digital_io_in[8];

     //Pin-5        PD3/INT1/OC2B(PWM0)  digital_io[9]
     port_d_in[3] = digital_io_in[9];
     if(cfg_int_enb[1]) ext_intr_in[1] = digital_io_in[9];

     //Pin-6        PD4/TXD[1]          digital_io[10]
     port_d_in[4] = digital_io_in[10];

     //Pin-9        PB6/XTAL1/TOSC1     digital_io[11]
     port_b_in[6] = digital_io_in[11];
     xtal_clk     = digital_io_in[11];

     // Pin-10       PB7/XTAL2/TOSC2/IR-RX  digital_io[12]
     port_b_in[7] = digital_io_in[12];
     ir_rx        = digital_io_in[12];

     //Pin-11       PD5/OC0B(PWM1)/T1   digital_io[13]
     port_d_in[5] = digital_io_in[13];

     //Pin-12       PD6/OC0A(PWM2)/AIN0 digital_io[14] /analog_io[2]
     port_d_in[6] = digital_io_in[14];

     //Pin-13       PD7/A1N1/IR-RX      digital_io[15]/analog_io[3]
     port_d_in[7] = digital_io_in[15];
     
     //Pin-14       PB0/CLKO/ICP1       digital_io[16]
     port_b_in[0] =  digital_io_in[16];

     //Pin-15       PB1/OC1A(PWM3)      digital_io[17]
     port_b_in[1] = digital_io_in[17];

     //Pin-16       PB2/SS/OC1B(PWM4)   digital_io[18]
     port_b_in[2] = digital_io_in[18];

     //Pin-17       PB3/MOSI/OC2A(PWM5) digital_io[19]
     port_b_in[3] = digital_io_in[19];
     if(cfg_spim_enb) spim_mosi = digital_io_in[19];        // SPIM MOSI (Input) = SPIS MISO (Output)

     //Pin-18       PB4/MISO            digital_io[20]
     port_b_in[4] = digital_io_in[20];
     spis_mosi    = (spis_boot) ? digital_io_in[20] : 1'b0;  // SPIM MISO (Output) = SPIS MOSI (Input)

     //Pin-19       PB5/SCK             digital_io[21]
     port_b_in[5]= digital_io_in[21];
     spis_sck    = (spis_boot) ? digital_io_in[21] : 1'b1;   // SPIM SCK (Output) = SPIS SCK (Input)
     
     //Pin-23       PC0/ADC0            digital_io[22]/analog_io[11]
     port_c_in[0] = digital_io_in[22];

     //Pin-24       PC1/ADC1            digital_io[23]/analog_io[12]
     port_c_in[1] = digital_io_in[23];

     //Pin-25       PC2/ADC2            digital_io[24]/usb_dp/analog_io[13]
     usb_dp_i     = (cfg_usb_enb) ? digital_io_in[24] : 1'b1;
     port_c_in[2] = digital_io_in[24];

     //Pin-26       PC3/ADC3            digital_io[25]/usb_dn/analog_io[14]
     usb_dn_i     = (cfg_usb_enb) ? digital_io_in[25] : 1'b1;
     port_c_in[3] = digital_io_in[25];

     //Pin-27       PC4/ADC4/SDA        digital_io[26]/analog_io[15]
     port_c_in[4] = digital_io_in[26];
     if(cfg_i2cm_enb)  i2cm_data_i = digital_io_in[26];

     //Pin-28       PC5/ADC5/SCL        digital_io[27]/analog_io[16]
     port_c_in[5] = digital_io_in[27];
     if(cfg_i2cm_enb)  i2cm_clk_i = digital_io_in[27];

     sflash_di[0] = digital_io_in[33];
     sflash_di[1] = digital_io_in[34];
     sflash_di[2] = digital_io_in[35];
     sflash_di[3] = digital_io_in[36];
     
     port_a_in[0] = digital_io_in[0];
     port_a_in[1] = digital_io_in[1];
     port_a_in[2] = digital_io_in[2];
     port_a_in[3] = digital_io_in[3];
     port_a_in[4] = digital_io_in[4];

    riscv_trst_n  = (cfg_tap_enb) ? digital_io_in[0] : 1'b1;
    riscv_tck     = (cfg_tap_enb) ? digital_io_in[1] : 1'b0;
    riscv_tms     = (cfg_tap_enb) ? digital_io_in[2] : 1'b0;
    riscv_tdi     = (cfg_tap_enb) ? digital_io_in[3] : 1'b0;

end

// dataout selection
always_comb begin
     digital_io_out = 'h0;
     //Pin-1        PC6/WS[0]/RESET*       digital_io[5]
     if(cfg_port_c_port_type[6])       digital_io_out[5]   = ws_txd[0];
     else if(cfg_port_c_dir_sel[6])    digital_io_out[5]   = port_c_out[6];

     //Pin-2        PD0/WS[0]/MRXD/RXD[0]       digital_io[6]
     if(cfg_port_d_port_type[0])       digital_io_out[6]   = ws_txd[0];
     else if(cfg_port_d_dir_sel[0])    digital_io_out[6]   = port_d_out[0];
  
     //Pin-3        PD1/WS[0]/MTXD/TXD[0]       digital_io[7]
     if     (cfg_muart_enb)           digital_io_out[7]  = uartm_txd;
     else if(cfg_uart_enb[0])         digital_io_out[7]  = uart_txd[0];
     else if(cfg_port_d_port_type[1]) digital_io_out[7]  = ws_txd[0];
     else if(cfg_port_d_dir_sel[1])   digital_io_out[7]  = port_d_out[1];


     //Pin-4        PD2/WS[0]/RXD[1]/INT0  digital_io[8]
     if(cfg_port_d_port_type[2])      digital_io_out[8]   = ws_txd[0];
     else if(cfg_port_d_dir_sel[2])   digital_io_out[8]   = port_d_out[2];

     //Pin-5        PD3/WS[1]INT1/OC2B(PWM0)  digital_io[9]
     if(cfg_pwm_enb[0])              digital_io_out[9]   = pwm_wfm[0];
     else if(cfg_port_d_port_type[3])digital_io_out[9]   = ws_txd[1];
     else if(cfg_port_d_dir_sel[3])  digital_io_out[9]   = port_d_out[3];

     //Pin-6        PD4/WS[1]/TXD[1]         digital_io[10]
     if   (cfg_uart_enb[1])               digital_io_out[10]   = uart_txd[1];
     else if(cfg_port_d_port_type[4])     digital_io_out[10]   = ws_txd[1];
     else if(cfg_port_d_dir_sel[4])       digital_io_out[10]   = port_d_out[4];

     //Pin-9        PB6/XTAL1/WS[1]/TOSC1     digital_io[11]
     if(cfg_port_b_port_type[6])       digital_io_out[11]   = ws_txd[1];
     else if(cfg_port_b_dir_sel[6])    digital_io_out[11]   = port_b_out[6];


     // Pin-10       PB7/XTAL2/WS[1]/TOSC2     digital_io[12]
     if(cfg_port_b_port_type[7])       digital_io_out[12]   = ws_txd[1];
     else if(cfg_port_b_dir_sel[7])    digital_io_out[12]   = port_b_out[7];

     //Pin-11       PD5/SS[3]/WS[2]/OC0B(PWM1)/T1   digital_io[13]
     if(cfg_pwm_enb[1])              digital_io_out[13]   = pwm_wfm[1];
     else if(cfg_spim_cs_enb[3])     digital_io_out[13]  = spim_ssn[3];
     else if(cfg_port_d_port_type[5])digital_io_out[13]   = ws_txd[2];
     else if(cfg_port_d_dir_sel[5])  digital_io_out[13]   = port_d_out[5];

     //Pin-12       PD6/SS[2]/WS[2]/OC0A(PWM2)/AIN0 digital_io[14] /analog_io[2]
     if(cfg_pwm_enb[2])              digital_io_out[14]   = pwm_wfm[2];
     else if(cfg_spim_cs_enb[2])     digital_io_out[14]   = spim_ssn[2];
     else if(cfg_port_d_port_type[6])digital_io_out[14]   = ws_txd[2];
     else if(cfg_port_d_dir_sel[6])  digital_io_out[14]   = port_d_out[6];


     //Pin-13       PD7/A1N1/WS[2]/IR-TX    digital_io[15]/analog_io[3]
     if(cfg_ir_tx_enb)               digital_io_out[15]  = ir_tx;
     else if(cfg_port_d_port_type[7])digital_io_out[15]  = ws_txd[2];
     else if(cfg_port_d_dir_sel[7])  digital_io_out[15]  = port_d_out[7];
     
     //Pin-14       PB0/CLKO/WS[2]/ICP1       digital_io[16]
     if(cfg_port_b_port_type[0])     digital_io_out[16]  = ws_txd[2];
     else if(cfg_port_b_dir_sel[0])  digital_io_out[16]  = port_b_out[0];

     //Pin-15       PB1/SS[1]/WS[3]/OC1A(PWM3)      digital_io[17]
     if(cfg_pwm_enb[3])              digital_io_out[17]    = pwm_wfm[3];
     else if(cfg_spim_cs_enb[1])     digital_io_out[17]    = spim_ssn[1];
     else if(cfg_port_b_port_type[1])digital_io_out[17]    = ws_txd[3];
     else if(cfg_port_b_dir_sel[1])  digital_io_out[17]    = port_b_out[1];

     //Pin-16       PB2/SS[0]/WS[3]/OC1B(PWM4)   digital_io[18]
     if(cfg_pwm_enb[4])              digital_io_out[18]  = pwm_wfm[4];
     else if(cfg_spim_cs_enb[0])     digital_io_out[18]  = spim_ssn[0];
     else if(cfg_port_b_port_type[2])digital_io_out[18]  = ws_txd[3];
     else if(cfg_port_b_dir_sel[2])  digital_io_out[18]  = port_b_out[2];

     //Pin-17       PB3/MOSI/WS[3]/OC2A(PWM5) digital_io[19]
     if(cfg_pwm_enb[5])              digital_io_out[19]  = pwm_wfm[5];
     else if(cfg_port_b_port_type[3])  digital_io_out[19]  = ws_txd[3];
     else if(cfg_port_b_dir_sel[3])  digital_io_out[19]  = port_b_out[3];
     else if(spis_boot)              digital_io_out[19]  = spis_miso;   // SPIM MOSI (Input) = SPIS MISO (Output)

     //Pin-18       PB4/WS[3]/MISO            digital_io[20]
     if(cfg_spim_enb)                digital_io_out[20]  = spim_miso;   // SPIM MISO (Output) = SPIS MOSI (Input)
     else if(cfg_port_b_port_type[4])digital_io_out[20]  = ws_txd[3];
     else if(cfg_port_b_dir_sel[4])  digital_io_out[20]  = port_b_out[4];

     //Pin-19       PB5/SCK             digital_io[21]
     if(cfg_spim_enb)             digital_io_out[21]  = spim_sck;      // SPIM SCK (Output) = SPIS SCK (Input)
     else if(cfg_port_b_dir_sel[5])  digital_io_out[21]  = port_b_out[5];
     
     //Pin-23       PC0/ADC0    digital_io[22]/analog_io[11]
     if(cfg_port_c_dir_sel[0])  digital_io_out[22]  = port_c_out[0];

     //Pin-24       PC1/ADC1    digital_io[23]/analog_io[12]
     if(cfg_port_c_dir_sel[1])  digital_io_out[23]  = port_c_out[1];

     //Pin-25       PC2/USB_DP/ADC2  digital_io[24]/analog_io[13]
     if(cfg_usb_enb)                 digital_io_out[24]  = usb_dp_o;
     else if(cfg_port_c_dir_sel[2])  digital_io_out[24]  = port_c_out[2];

     //Pin-26       PC3/USB_DN/ADC3  digital_io[25]/analog_io[14]
     if(cfg_usb_enb)                 digital_io_out[25]  = usb_dn_o;
     if(cfg_port_c_dir_sel[3])       digital_io_out[25]  = port_c_out[3];

     //Pin-27       PC4/ADC4/SDA        digital_io[26]/analog_io[15]
     if(cfg_i2cm_enb)                digital_io_out[26]  = i2cm_data_o;
     else if(cfg_port_c_dir_sel[4])  digital_io_out[26]  = port_c_out[4];

     //Pin-28       PC5/ADC5/SCL        digital_io[27]/analog_io[16]
     if(cfg_i2cm_enb)                digital_io_out[27]  = i2cm_clk_o;
     else if(cfg_port_c_dir_sel[5])  digital_io_out[27]  = port_c_out[5];

     // Serial Flash
     digital_io_out[28] = sflash_sck   ;
     digital_io_out[29] = sflash_ss[0] ;
     digital_io_out[30] = sflash_ss[1] ;
     digital_io_out[31] = sflash_ss[2] ;
     digital_io_out[32] = sflash_ss[3] ;
     digital_io_out[33] = sflash_do[0] ;
     digital_io_out[34] = sflash_do[1] ;
     digital_io_out[35] = sflash_do[2] ;
     digital_io_out[36] = sflash_do[3] ;
                       
     // dbg_clk_mon - Pll clock output monitor
     digital_io_out[37] = dbg_clk_mon;

     digital_io_out[0] = (cfg_sm_enb) ? sm_a1 : port_a_out[0] ;
     digital_io_out[1] = (cfg_sm_enb) ? sm_a2 : port_a_out[1] ;
     digital_io_out[2] = (cfg_sm_enb) ? sm_b1 : port_a_out[2] ;
     digital_io_out[3] = (cfg_sm_enb) ? sm_b2 : port_a_out[3] ;
     digital_io_out[4] = (cfg_tap_enb)? riscv_tdo : port_a_out[4] ;
end

// dataoen selection
always_comb begin
     digital_io_oen = 38'h3F_FFFF_FFFF;

     //Pin-1        PC6/WS[0]/RESET*          digital_io[5]
     if(cfg_port_c_port_type[6])       digital_io_oen[5]   = 1'b0;
     else if(cfg_port_c_dir_sel[6])    digital_io_oen[5]   = 1'b0;

     //Pin-2        PD0/WS[0]/MRXD/RXD[0]          digital_io[6]
     if     (cfg_muart_enb)          digital_io_oen[6]   = 1'b1;
     else if(cfg_uart_enb[0])        digital_io_oen[6]   = 1'b1;
     else if(cfg_port_d_port_type[0])digital_io_oen[6]   = 1'b0;
     else if(cfg_port_d_dir_sel[0])  digital_io_oen[6]   = 1'b0;

     //Pin-3        PD1/WS[0]/MTXD/TXD[0]          digital_io[7]
     if     (cfg_muart_enb)          digital_io_oen[7]   = 1'b0;
     else if(cfg_uart_enb[0])        digital_io_oen[7]   = 1'b0;
     else if(cfg_port_d_port_type[1])digital_io_oen[7]   = 1'b0;
     else if(cfg_port_d_dir_sel[1])  digital_io_oen[7]   = 1'b0;

    //Pin-4        PD2/WS[0]/RXD[1]/INT0      digital_io[8]
     if(cfg_int_enb[0])         digital_io_oen[8]   = 1'b1;
     else if(cfg_port_d_port_type[2])digital_io_oen[8]   = 1'b0;
     else if(cfg_port_d_dir_sel[2])  digital_io_oen[8]   = 1'b0;

     //Pin-5        PD3/WS[1]/INT1/OC2B(PWM0)  digital_io[9]
     if(cfg_pwm_enb[0])              digital_io_oen[9]   = 1'b0;
     else if(cfg_int_enb[1])         digital_io_oen[9]   = 1'b1;
     else if(cfg_port_d_port_type[3])digital_io_oen[9]   = 1'b0;
     else if(cfg_port_d_dir_sel[3])  digital_io_oen[9]   = 1'b0;

     //Pin-6        PD4/WS[1]/TXD[1]       digital_io[10]
     if   (cfg_uart_enb[1])          digital_io_oen[10]   = 1'b0;
     else if(cfg_port_d_port_type[4])digital_io_oen[10]   = 1'b0;
     else if(cfg_port_d_dir_sel[4])  digital_io_oen[10]   = 1'b0;

     //Pin-9        PB6/WS[1]/XTAL1/TOSC1     digital_io[11]
     if(cfg_port_b_port_type[6])       digital_io_oen[11]   = 1'b0;
     else if(cfg_port_b_dir_sel[6])    digital_io_oen[11]   = 1'b0;

     // Pin-10       PB7/WS[1]/XTAL2/TOSC2     digital_io[12]
     if(cfg_port_b_port_type[7])       digital_io_oen[12]   = 1'b0;
     else if(cfg_port_b_dir_sel[7])    digital_io_oen[12]   = 1'b0;

     //Pin-11       PD5/WS[2]/SS[3]/OC0B(PWM1)/T1   digital_io[13]
     if(cfg_strap_pad_ctrl)          digital_io_oen[13]   = 1'b1;
     else if(cfg_pwm_enb[1])         digital_io_oen[13]   = 1'b0;
     else if(cfg_spim_cs_enb[3])     digital_io_oen[13]   = 1'b0;
     else if(cfg_port_d_port_type[5])digital_io_oen[13]   = 1'b0;
     else if(cfg_port_d_dir_sel[5])  digital_io_oen[13]   = 1'b0;

     //Pin-12       PD6/SS[2]/OC0A(PWM2)/AIN0 digital_io[14] /analog_io[2]
     if(cfg_strap_pad_ctrl)          digital_io_oen[14]   = 1'b1;
     else if(cfg_pwm_enb[2])         digital_io_oen[14]   = 1'b0;
     else if(cfg_spim_cs_enb[2])     digital_io_oen[14]   = 1'b0;
     else if(cfg_port_d_port_type[6])digital_io_oen[14]   = 1'b0;
     else if(cfg_port_d_dir_sel[6])  digital_io_oen[14]   = 1'b0;

     //Pin-13       PD7/A1N1/WS[2]/IR-TX    digital_io[15]/analog_io[3]
     if(cfg_strap_pad_ctrl)          digital_io_oen[15]   = 1'b1;
     else if(cfg_ir_tx_enb)          digital_io_oen[15]   = 1'b0;
     else if(cfg_port_d_port_type[7])digital_io_oen[15]   = 1'b0;
     else if(cfg_port_d_dir_sel[7])  digital_io_oen[15]  = 1'b0;
     
     //Pin-14       PB0/WS[2]/CLKO/ICP1       digital_io[16]
     if(cfg_strap_pad_ctrl)          digital_io_oen[16]   = 1'b1;
     else if(cfg_port_b_port_type[0])digital_io_oen[16]  = 1'b0;
     else if(cfg_port_b_dir_sel[0])  digital_io_oen[16]  = 1'b0;

     //Pin-15       PB1/WS[3]/SS[1]/OC1A(PWM3)      digital_io[17]
     if(cfg_strap_pad_ctrl)          digital_io_oen[17]   = 1'b1;
     else if(cfg_pwm_enb[3])         digital_io_oen[17]  = 1'b0;
     else if(cfg_spim_cs_enb[1])     digital_io_oen[17]  = 1'b0;
     else if(cfg_port_b_port_type[1])digital_io_oen[17]  = 1'b0;
     else if(cfg_port_b_dir_sel[1])  digital_io_oen[17]  = 1'b0;

     //Pin-16       PB2/WS[3]/SS[0]/OC1B(PWM4)   digital_io[18]
     if(cfg_strap_pad_ctrl)          digital_io_oen[18]   = 1'b1;
     else if(cfg_pwm_enb[4])         digital_io_oen[18]  = 1'b0;
     else if(cfg_spim_cs_enb[0])     digital_io_oen[18]  = 1'b0;
	 else if(cfg_port_b_port_type[2])digital_io_oen[18]  = 1'b0;
     else if(cfg_port_b_dir_sel[2])  digital_io_oen[18]  = 1'b0;

     //Pin-17       PB3/WS[3]/MOSI/OC2A(PWM5) digital_io[19]
     if(cfg_strap_pad_ctrl)          digital_io_oen[19]   = 1'b1;
     else if(cfg_spim_enb)           digital_io_oen[19]  = 1'b1; // SPIM MOSI (Input)
     else if(cfg_pwm_enb[5])         digital_io_oen[19]  = 1'b0;
     else if(cfg_port_b_port_type[3])digital_io_oen[19]  = 1'b0;
     else if(cfg_port_b_dir_sel[3])  digital_io_oen[19]  = 1'b0;
     else if(spis_boot)              digital_io_oen[19]  = 1'b0; // SPIS MISO (Output)

     //Pin-18       PB4/WS[3]/MISO         digital_io[20]
     if(cfg_strap_pad_ctrl)          digital_io_oen[20]  = 1'b1;
     else if(cfg_spim_enb)           digital_io_oen[20]  = 1'b0; // SPIM MISO (Output) 
     else if(cfg_port_b_port_type[4])digital_io_oen[20]  = 1'b0;
     else if(cfg_port_b_dir_sel[4])  digital_io_oen[20]  = 1'b0;
     else if(spis_boot)              digital_io_oen[20]  = 1'b1; // SPIS MOSI (Input)

     //Pin-19       PB5/SCK             digital_io[21]
     if(cfg_spim_enb)                digital_io_oen[21]  = 1'b0; // SPIM SCK (Output)
     else if(cfg_port_b_dir_sel[5])  digital_io_oen[21]  = 1'b0;
     else if(spis_boot)              digital_io_oen[21]  = 1'b1; // SPIS SCK (Input)
     
     //Pin-23       PC0/ADC0    digital_io[22]/analog_io[11]
     if(cfg_port_c_dir_sel[0])       digital_io_oen[22]  = 1'b0;

     //Pin-24       PC1/ADC1    digital_io[23]/analog_io[12]
     if(cfg_port_c_dir_sel[1])       digital_io_oen[23]  = 1'b0;

     //Pin-25       PC2/USB_DP/ADC2  digital_io[24]/analog_io[13]
     if(cfg_usb_enb)                 digital_io_oen[24]  = usb_oen;
     else if(cfg_port_c_dir_sel[2])  digital_io_oen[24]  = 1'b0;

     //Pin-26       PC3/USB_DN/ADC3  digital_io[25]/analog_io[14]
     if(cfg_usb_enb)                 digital_io_oen[25]  = usb_oen;
     else if(cfg_port_c_dir_sel[3])  digital_io_oen[25]  = 1'b0;

     //Pin-27       PC4/ADC4/SDA        digital_io[26]/analog_io[15]
     if(cfg_i2cm_enb)                digital_io_oen[26]  = i2cm_data_oen;
     else if(cfg_port_c_dir_sel[4])  digital_io_oen[26]  = 1'b0;

     //Pin-28       PC5/ADC5/SCL        digital_io[27]/analog_io[16]
     if(cfg_i2cm_enb)                digital_io_oen[27]  = i2cm_clk_oen;
     else if(cfg_port_c_dir_sel[5])  digital_io_oen[27]  = 1'b0;

     // Serial Flash
     if(cfg_strap_pad_ctrl)          digital_io_oen[28]  = 1'b1;
     else                            digital_io_oen[28]  = 1'b0;
     if(cfg_strap_pad_ctrl)          digital_io_oen[29]  = 1'b1;
     else                            digital_io_oen[29]  = 1'b0;
     if(cfg_strap_pad_ctrl)          digital_io_oen[30]  = 1'b1;
     else                            digital_io_oen[30]  = 1'b0;
     if(cfg_strap_pad_ctrl)          digital_io_oen[31]  = 1'b1;
     else                            digital_io_oen[31]  = 1'b0;
     if(cfg_strap_pad_ctrl)          digital_io_oen[32]  = 1'b1;
     else                            digital_io_oen[32]  = 1'b0;
     if(cfg_strap_pad_ctrl)          digital_io_oen[33]  = 1'b1;
     else                            digital_io_oen[33]  = sflash_oen[0];
     if(cfg_strap_pad_ctrl)          digital_io_oen[34]  = 1'b1;
     else                            digital_io_oen[34]  = sflash_oen[1];
     if(cfg_strap_pad_ctrl)          digital_io_oen[35]  = 1'b1;
     else                            digital_io_oen[35]  = sflash_oen[2];
     if(cfg_strap_pad_ctrl)          digital_io_oen[36]  = 1'b1;
     else                            digital_io_oen[36]  = sflash_oen[3];
                       
     // dbg_clk_mon
     if(cfg_strap_pad_ctrl)          digital_io_oen[37] = 1'b1;
     else                            digital_io_oen[37] = 1'b0;

     if(cfg_tap_enb)                 digital_io_oen[0]   = 1'b1; // riscv_trst_n - input
     else if(cfg_sm_enb)             digital_io_oen[0]   = 1'b0;
     else if(cfg_port_a_dir_sel[0])  digital_io_oen[0]   = 1'b0;

     if(cfg_tap_enb)                 digital_io_oen[1]   = 1'b1; // riscv_tck - input
     else if(cfg_sm_enb)             digital_io_oen[1]   = 1'b0;
     else if(cfg_port_a_dir_sel[1])  digital_io_oen[1]   = 1'b0;

     if(cfg_tap_enb)                 digital_io_oen[2]   = 1'b1; // riscv_tms - input
     else if(cfg_sm_enb)             digital_io_oen[2]   = 1'b0;
     else if(cfg_port_a_dir_sel[2])  digital_io_oen[2]   = 1'b0;

     if(cfg_tap_enb)                 digital_io_oen[3]   = 1'b1; // riscv_tdi - input
     else if(cfg_sm_enb)             digital_io_oen[3]   = 1'b0;
     else if(cfg_port_a_dir_sel[3])  digital_io_oen[3]   = 1'b0;

     if(cfg_tap_enb)                 digital_io_oen[4]   = riscv_tdo_en; // riscv_tdo - output
     else if(cfg_port_a_dir_sel[4])  digital_io_oen[4]   = 1'b0;
end


endmodule 


