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
////  Pinmux                                                     ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
////      PinMux Manages all the pin multiplexing                 ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 16th Feb 2021, Dinesh A                             ////
////          initial version                                     ////
//////////////////////////////////////////////////////////////////////

module pinmux (
                    `ifdef USE_POWER_PINS
                       input logic         vccd1,// User area 1 1.8V supply
                       input logic         vssd1,// User area 1 digital ground
                    `endif
                        // clock skew adjust
                       input logic [3:0]        cfg_cska_pinmux,
                       input logic	        wbd_clk_int,
                       output logic	        wbd_clk_pinmux,
                       // System Signals
                       // Inputs
		       input logic             mclk,
                       input logic             h_reset_n,

		       // Reg Bus Interface Signal
                       input logic             reg_cs,
                       input logic             reg_wr,
                       input logic [7:0]       reg_addr,
                       input logic [31:0]      reg_wdata,
                       input logic [3:0]       reg_be,

                       // Outputs
                       output logic [31:0]     reg_rdata,
                       output logic            reg_ack,

		      // Risc configuration
                       output logic [31:0]     fuse_mhartid,
                       output logic [15:0]     irq_lines,
                       output logic            soft_irq,
                       output logic [2:0]      user_irq,
		       input  logic            usb_intr,
		       input  logic            i2cm_intr,

                       // Digital IO
                       output logic [37:0]     digital_io_out,
                       output logic [37:0]     digital_io_oen,
                       input  logic [37:0]     digital_io_in,

		       // SFLASH I/F
		       input  logic            sflash_sck,
		       input  logic [3:0]      sflash_ss,
		       input  logic [3:0]      sflash_oen,
		       input  logic [3:0]      sflash_do,
		       output logic [3:0]      sflash_di,

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
		       input   logic           uart_txd,
		       output  logic           uart_rxd,

		       // I2CM I/F
		       input   logic           i2cm_clk_o,
		       output  logic           i2cm_clk_i,
		       input   logic           i2cm_clk_oen,
		       input   logic           i2cm_data_oen,
		       input   logic           i2cm_data_o,
		       output  logic           i2cm_data_i,

		       // SPI MASTER
		       input   logic           spim_sck,
		       input   logic           spim_ss,
		       input   logic           spim_miso,
		       output  logic           spim_mosi,

                       // UART MASTER I/F
                       output  logic            uartm_rxd ,
                       input logic              uartm_txd  ,       

		       output  logic           pulse1m_mclk,
	               output  logic [31:0]    pinmux_debug

   ); 



   
/* clock pulse */
//********************************************************
logic           pulse1u_mclk            ;// 1 UsSecond Pulse for waveform Generator
logic           pulse1s_mclk            ;// 1Second Pulse for waveform Generator
logic [9:0]     cfg_pulse_1us           ;// 1us pulse generation config
                
//---------------------------------------------------
// 6 PWM variabled
//---------------------------------------------------

logic [5:0]     pwm_wfm                 ;
logic [5:0]     cfg_pwm_enb             ;
logic [15:0]    cfg_pwm0_high           ;
logic [15:0]    cfg_pwm0_low            ;
logic [15:0]    cfg_pwm1_high           ;
logic [15:0]    cfg_pwm1_low            ;
logic [15:0]    cfg_pwm2_high           ;
logic [15:0]    cfg_pwm2_low            ;
logic [15:0]    cfg_pwm3_high           ;
logic [15:0]    cfg_pwm3_low            ;
logic [15:0]    cfg_pwm4_high           ;
logic [15:0]    cfg_pwm4_low            ;
logic [15:0]    cfg_pwm5_high           ;
logic [15:0]    cfg_pwm5_low            ;


wire  [31:0]  gpio_prev_indata         ;// previously captured GPIO I/P pins data
wire  [31:0]  cfg_gpio_out_data        ;// GPIO statuc O/P data from config reg
wire  [31:0]  cfg_gpio_dir_sel         ;// decides on GPIO pin is I/P or O/P at pad level, 0 -> Input, 1 -> Output
wire  [31:0]  cfg_gpio_out_type        ;// GPIO Type, Unused
wire  [31:0]  cfg_multi_func_sel       ;// GPIO Multi function type
wire  [31:0]  cfg_gpio_posedge_int_sel ;// select posedge interrupt
wire  [31:0]  cfg_gpio_negedge_int_sel ;// select negedge interrupt
wire  [31:00] cfg_gpio_data_in         ;


reg [7:0]     port_a_in;      // PORT A Data In
reg [7:0]     port_b_in;      // PORT B Data In
reg [7:0]     port_c_in;      // PORT C Data In
reg [7:0]     port_d_in;      // PORT D Data In

wire [7:0]    port_a_out;     // PORT A Data Out
wire [7:0]    port_b_out;     // PORT B Data Out
wire [7:0]    port_c_out;     // PORT C Data Out
wire [7:0]    port_d_out;     // PORT D Data Out
wire [31:0]   pad_gpio_in;    // GPIO data input from PAD
wire [31:0]   pad_gpio_out;   // GPIO Data out towards PAD
wire [31:0]   gpio_int_event; // GPIO Interrupt indication
reg [1:0]     ext_intr_in;    // External PAD level interrupt

// GPIO to PORT Mapping
assign      pad_gpio_in[7:0]     = port_a_in;
assign      pad_gpio_in[15:8]    = port_b_in;
assign      pad_gpio_in[23:16]   = port_c_in;
assign      pad_gpio_in[31:24]   = port_d_in;

assign      port_a_out           = pad_gpio_out[7:0];
assign      port_b_out           = pad_gpio_out[15:8];
assign      port_c_out           = pad_gpio_out[23:16];
assign      port_d_out           = pad_gpio_out[31:24];

assign      pinmux_debug = '0; // Todo: Need to fix

// SSRAM I/F - Temp masked
//input  logic            ssram_sck,
//input  logic            ssram_ss,
//input  logic [3:0]      ssram_oen,
//input  logic [3:0]      ssram_do,
//output logic [3:0]      ssram_di,

// pinmux clock skew control
clk_skew_adjust u_skew_pinmux
       (
`ifdef USE_POWER_PINS
               .vccd1      (vccd1                      ),// User area 1 1.8V supply
               .vssd1      (vssd1                      ),// User area 1 digital ground
`endif
	       .clk_in     (wbd_clk_int                 ), 
	       .sel        (cfg_cska_pinmux             ), 
	       .clk_out    (wbd_clk_pinmux              ) 
       );

gpio_intr u_gpio_intr (
   // System Signals
   // Inputs
          .mclk                    (mclk                    ),
          .h_reset_n               (h_reset_n               ),

   // GPIO cfg input pins
          .gpio_prev_indata        (gpio_prev_indata        ),
          .cfg_gpio_data_in        (cfg_gpio_data_in        ),
          .cfg_gpio_dir_sel        (cfg_gpio_dir_sel        ),
          .cfg_gpio_out_data       (cfg_gpio_out_data       ),
          .cfg_gpio_posedge_int_sel(cfg_gpio_posedge_int_sel),
          .cfg_gpio_negedge_int_sel(cfg_gpio_negedge_int_sel),


   // GPIO output pins
          .pad_gpio_out            (pad_gpio_out            ),
          .gpio_int_event          (gpio_int_event          )  
  );


// 1us pulse
pulse_gen_type2  #(.WD(10)) u_pulse_1us (

	.clk_pulse                 (pulse1u_mclk),
	.clk                       (mclk        ),
        .reset_n                   (h_reset_n   ),
	.cfg_max_cnt               (cfg_pulse_1us)

     );

// 1millisecond pulse
pulse_gen_type1 u_pulse_1ms (

	.clk_pulse   (pulse1m_mclk),
	.clk         (mclk        ),
        .reset_n     (h_reset_n   ),
	.trigger     (pulse1u_mclk)

      );

// 1 second pulse
pulse_gen_type2 u_pulse_1s (

	.clk_pulse   (pulse1s_mclk),
	.clk         (mclk        ),
        .reset_n     (h_reset_n   ),
	.cfg_max_cnt (cfg_pulse_1us)

       );

pinmux_reg u_pinmux_reg(
      // System Signals
      // Inputs
          .mclk                         (mclk                    ),
          .h_reset_n                    (h_reset_n               ),


      // Reg read/write Interface Inputs
          .reg_cs                       (reg_cs                  ),
          .reg_wr                       (reg_wr                  ),
          .reg_addr                     (reg_addr                ),
          .reg_wdata                    (reg_wdata               ),
          .reg_be                       (reg_be                  ),

          .reg_rdata                    (reg_rdata               ),
          .reg_ack                      (reg_ack                 ),

	  .ext_intr_in                  (ext_intr_in             ),

	  .fuse_mhartid                 (fuse_mhartid            ),
	  .irq_lines                    (irq_lines               ),
	  .soft_irq                     (soft_irq                ),
	  .user_irq                     (user_irq                ),
          .usb_intr                     (usb_intr                ),
          .i2cm_intr                    (i2cm_intr               ),

	  .cfg_pulse_1us                (cfg_pulse_1us           ),


          .cfg_pwm0_high                (cfg_pwm0_high           ),
          .cfg_pwm0_low                 (cfg_pwm0_low            ),
          .cfg_pwm1_high                (cfg_pwm1_high           ),
          .cfg_pwm1_low                 (cfg_pwm1_low            ),
          .cfg_pwm2_high                (cfg_pwm2_high           ),
          .cfg_pwm2_low                 (cfg_pwm2_low            ),
          .cfg_pwm3_high                (cfg_pwm3_high           ),
          .cfg_pwm3_low                 (cfg_pwm3_low            ),
          .cfg_pwm4_high                (cfg_pwm4_high           ),
          .cfg_pwm4_low                 (cfg_pwm4_low            ),
          .cfg_pwm5_high                (cfg_pwm5_high           ),
          .cfg_pwm5_low                 (cfg_pwm5_low            ),

      // GPIO input pins
          .gpio_in_data                 (pad_gpio_in             ),
          .gpio_int_event               (gpio_int_event          ),

      // GPIO config pins
          .cfg_gpio_out_data            (cfg_gpio_out_data       ),
          .cfg_gpio_dir_sel             (cfg_gpio_dir_sel        ),
          .cfg_gpio_out_type            (cfg_gpio_out_type       ),
          .cfg_gpio_posedge_int_sel     (cfg_gpio_posedge_int_sel),
          .cfg_gpio_negedge_int_sel     (cfg_gpio_negedge_int_sel),
          .cfg_multi_func_sel           (cfg_multi_func_sel      ),
	  .cfg_gpio_data_in             (cfg_gpio_data_in        ),


       // Outputs
          .gpio_prev_indata             (gpio_prev_indata        ) ,

       // BIST I/F
          .bist_en                      (                        ),
          .bist_run                     (                        ),
          .bist_load                    (                        ),
          
          .bist_sdi                     (                        ),
          .bist_shift                   (                        ),
          .bist_sdo                     ('b0                     ),
          
          .bist_done                    ('b0                     ),
          .bist_error                   ('h0                     ),
          .bist_correct                 ('h0                     ),
          .bist_error_cnt0              ('h0                     ),
          .bist_error_cnt1              ('h0                     ),
          .bist_error_cnt2              ('h0                     ),
          .bist_error_cnt3              ('h0                     )

   ); 


// 6 PWM Waveform Generator
pwm  u_pwm_0 (
	  .waveform                    (pwm_wfm[0]         ), 
	  .h_reset_n                   (h_reset_n          ),
	  .mclk                        (mclk               ),
	  .pulse1m_mclk                (pulse1m_mclk       ),
	  .cfg_pwm_enb                 (cfg_pwm_enb[0]     ),
	  .cfg_pwm_high                (cfg_pwm0_high      ),
	  .cfg_pwm_low                 (cfg_pwm0_low       )
     );

pwm  u_pwm_1 (
	  .waveform                    (pwm_wfm[1]         ), 
	  .h_reset_n                   (h_reset_n          ),
	  .mclk                        (mclk               ),
	  .pulse1m_mclk                (pulse1m_mclk       ),
	  .cfg_pwm_enb                 (cfg_pwm_enb[1]     ),
	  .cfg_pwm_high                (cfg_pwm1_high      ),
	  .cfg_pwm_low                 (cfg_pwm1_low       )
     );
   
pwm  u_pwm_2 (
	  .waveform                    (pwm_wfm[2]         ), 
	  .h_reset_n                   (h_reset_n          ),
	  .mclk                        (mclk               ),
	  .pulse1m_mclk                (pulse1m_mclk       ),
	  .cfg_pwm_enb                 (cfg_pwm_enb[2]     ),
	  .cfg_pwm_high                (cfg_pwm2_high      ),
	  .cfg_pwm_low                 (cfg_pwm2_low       )
     );

pwm  u_pwm_3 (
	  .waveform                    (pwm_wfm[3]         ), 
	  .h_reset_n                   (h_reset_n          ),
	  .mclk                        (mclk               ),
	  .pulse1m_mclk                (pulse1m_mclk       ),
	  .cfg_pwm_enb                 (cfg_pwm_enb[3]     ),
	  .cfg_pwm_high                (cfg_pwm3_high      ),
	  .cfg_pwm_low                 (cfg_pwm3_low       )
     );
pwm  u_pwm_4 (
	  .waveform                    (pwm_wfm[4]         ), 
	  .h_reset_n                   (h_reset_n          ),
	  .mclk                        (mclk               ),
	  .pulse1m_mclk                (pulse1m_mclk       ),
	  .cfg_pwm_enb                 (cfg_pwm_enb[4]     ),
	  .cfg_pwm_high                (cfg_pwm4_high      ),
	  .cfg_pwm_low                 (cfg_pwm4_low       )
     );
pwm  u_pwm_5 (
	  .waveform                    (pwm_wfm[5]         ), 
	  .h_reset_n                   (h_reset_n          ),
	  .mclk                        (mclk               ),
	  .pulse1m_mclk                (pulse1m_mclk       ),
	  .cfg_pwm_enb                 (cfg_pwm_enb[5]     ),
	  .cfg_pwm_high                (cfg_pwm5_high      ),
	  .cfg_pwm_low                 (cfg_pwm5_low       )
     );

/************************************************
* Pin Mapping    ATMGE CONFIG
*   ATMEGA328                        caravel Pin Mapping
*   Pin-1        PC6/RESET*          digital_io[0]
*   Pin-2        PD0/RXD             digital_io[1]
*   Pin-3        PD1/TXD             digital_io[2]
*   Pin-4        PD2/INT0            digital_io[3]
*   Pin-5        PD3/INT1/OC2B(PWM0) digital_io[4]
*   Pin-6        PD4                 digital_io[5]
*   Pin-7        VCC                  -
*   Pin-8        GND                  -
*   Pin-9        PB6/XTAL1/TOSC1     digital_io[6]
*   Pin-10       PB7/XTAL2/TOSC2     digital_io[7]
*   Pin-11       PD5/OC0B(PWM1)/T1   digital_io[8]
*   Pin-12       PD6/OC0A(PWM2)/AIN0 digital_io[9] /analog_io[2]
*   Pin-13       PD7/A1N1            digital_io[10]/analog_io[3]
*   Pin-14       PB0/CLKO/ICP1       digital_io[11]
*   Pin-15       PB1/OC1A(PWM3)      digital_io[12]
*   Pin-16       PB2/SS/OC1B(PWM4)   digital_io[13]
*   Pin-17       PB3/MOSI/OC2A(PWM5) digital_io[14]
*   Pin-18       PB4/MISO            digital_io[15]
*   Pin-19       PB5/SCK             digital_io[16]
*   Pin-20       AVCC                -
*   Pin-21       AREF                analog_io[10]
*   Pin-22       GND                 -
*   Pin-23       PC0/ADC0            digital_io[18]/analog_io[11]
*   Pin-24       PC1/ADC1            digital_io[19]/analog_io[12]
*   Pin-25       PC2/ADC2            digital_io[20]/analog_io[13]
*   Pin-26       PC3/ADC3            digital_io[21]/analog_io[14]
*   Pin-27       PC4/ADC4/SDA        digital_io[22]/analog_io[15]
*   Pin-28       PC5/ADC5/SCL        digital_io[23]/analog_io[16]
*
*  Additional Pad used for Externam ROM/RAM
*                sflash_sck          digital_io[24]
*                sflash_ss[3]        digital_io[25]
*                sflash_ss[2]        digital_io[26]
*                sflash_ss[1]        digital_io[27]
*                sflash_ss[0]        digital_io[28]
*                sflash_io0          digital_io[29]
*                sflash_io1          digital_io[30]
*                sflash_io2          digital_io[31]
*                sflash_io3          digital_io[32]
*                reserved            digital_io[33]
*                uartm_rxd           digital_io[34]
*                uartm_txd           digital_io[35]
*                usb_dp              digital_io[36]
*                usb_dn              digital_io[37]
****************************************************************
* Pin-1 RESET is not supported as there is no suppport for fuse config
**************/

assign      cfg_pwm_enb          = cfg_multi_func_sel[5:0];
wire [1:0]  cfg_int_enb          = cfg_multi_func_sel[7:6];
wire        cfg_uart_enb         = cfg_multi_func_sel[8];
wire        cfg_i2cm_enb         = cfg_multi_func_sel[9];
wire        cfg_spim_enb         = cfg_multi_func_sel[10];

wire [7:0]  cfg_port_a_dir_sel   = cfg_gpio_dir_sel[7:0];
wire [7:0]  cfg_port_b_dir_sel   = cfg_gpio_dir_sel[15:8];
wire [7:0]  cfg_port_c_dir_sel   = cfg_gpio_dir_sel[23:16];
wire [7:0]  cfg_port_d_dir_sel   = cfg_gpio_dir_sel[31:24];


// datain selection
always_comb begin
     port_a_in = 'h0;
     port_b_in = 'h0;
     port_c_in = 'h0;
     port_d_in = 'h0;
     uart_rxd   = 'h0;
     ext_intr_in= 'h0;
     spim_mosi  = 'h0;
     i2cm_data_i= 'h0;
     i2cm_clk_i = 'h0;

     //Pin-1        PC6/RESET*          digital_io[0]
     port_c_in[6] = digital_io_in[0];

     //Pin-2        PD0/RXD             digital_io[1]
     port_d_in[0] = digital_io_in[1];
     if(cfg_uart_enb)  uart_rxd      = digital_io_in[1];
  
     //Pin-3        PD1/TXD             digital_io[2]
     port_d_in[1] = digital_io_in[2];


     //Pin-4        PD2/INT0            digital_io[3]
     port_d_in[2] = digital_io_in[3];
     if(cfg_int_enb[0]) ext_intr_in[0] = digital_io_in[3];

     //Pin-5        PD3/INT1/OC2B(PWM0)  digital_io[4]
     port_d_in[3] = digital_io_in[4];
     if(cfg_int_enb[1]) ext_intr_in[1] = digital_io_in[4];

     //Pin-6        PD4                 digital_io[5]
     port_d_in[4] = digital_io_in[5];

     //Pin-9        PB6/XTAL1/TOSC1     digital_io[6]
     port_b_in[6] = digital_io_in[6];

     // Pin-10       PB7/XTAL2/TOSC2     digital_io[7]
     port_b_in[7] = digital_io_in[7];

     //Pin-11       PD5/OC0B(PWM1)/T1   digital_io[8]
     port_d_in[5] = digital_io_in[8];

     //Pin-12       PD6/OC0A(PWM2)/AIN0 digital_io[9] /analog_io[2]
     port_d_in[6] = digital_io_in[9];

     //Pin-13       PD7/A1N1            digital_io[10]/analog_io[3]
     port_d_in[7] = digital_io_in[10];
     
     //Pin-14       PB0/CLKO/ICP1       digital_io[11]
     port_b_in[0] =  digital_io_in[11];

     //Pin-15       PB1/OC1A(PWM3)      digital_io[12]
     port_b_in[1] = digital_io_in[12];

     //Pin-16       PB2/SS/OC1B(PWM4)   digital_io[13]
     port_b_in[2] = digital_io_in[13];

     //Pin-17       PB3/MOSI/OC2A(PWM5) digital_io[14]
     port_b_in[3] = digital_io_in[14];
     if(cfg_spim_enb) spim_mosi = digital_io_in[14];

     //Pin-18       PB4/MISO            digital_io[15]
     port_b_in[4] = digital_io_in[15];

     //Pin-19       PB5/SCK             digital_io[16]
     port_b_in[5]= digital_io_in[16];
     
     //Pin-23       PC0/ADC0            digital_io[18]/analog_io[11]
     port_c_in[0] = digital_io_in[18];

     //Pin-24       PC1/ADC1            digital_io[19]/analog_io[12]
     port_c_in[1] = digital_io_in[19];

     //Pin-25       PC2/ADC2            digital_io[20]/analog_io[13]
     port_c_in[2] = digital_io_in[20];

     //Pin-26       PC3/ADC3            digital_io[21]/analog_io[14]
     port_c_in[3] = digital_io_in[21];

     //Pin-27       PC4/ADC4/SDA        digital_io[22]/analog_io[15]
     port_c_in[4] = digital_io_in[22];
     if(cfg_i2cm_enb)  i2cm_data_i = digital_io_in[22];

     //Pin-28       PC5/ADC5/SCL        digital_io[23]/analog_io[16]
     port_c_in[5] = digital_io_in[23];
     if(cfg_i2cm_enb)  i2cm_clk_i = digital_io_in[23];

     sflash_di[0] = digital_io_in[29];
     sflash_di[1] = digital_io_in[30];
     sflash_di[2] = digital_io_in[31];
     sflash_di[3] = digital_io_in[32];

     // UAR MASTER I/F
     uartm_rxd    = digital_io_in[34];

     usb_dp_i    = digital_io_in[36];
     usb_dn_i    = digital_io_in[37];
end

// dataout selection
always_comb begin
     digital_io_out = 'h0;
     //Pin-1        PC6/RESET*          digital_io[0]
     if(cfg_port_c_dir_sel[6])       digital_io_out[0]   = port_c_out[6];

     //Pin-2        PD0/RXD             digital_io[1]
     if(cfg_port_d_dir_sel[0])       digital_io_out[1]   = port_d_out[0];
  
     //Pin-3        PD1/TXD             digital_io[2]
     if     (cfg_uart_enb)           digital_io_out[2]   = uart_txd;
     else if(cfg_port_d_dir_sel[1])  digital_io_out[2]   = port_d_out[1];


     //Pin-4        PD2/INT0            digital_io[3]
     if(cfg_port_d_dir_sel[2])       digital_io_out[3]   = port_d_out[2];

     //Pin-5        PD3/INT1/OC2B(PWM0)  digital_io[4]
     if(cfg_pwm_enb[0])              digital_io_out[4]   = pwm_wfm[0];
     if(cfg_port_d_dir_sel[3])       digital_io_out[4]   = port_d_out[3];

     //Pin-6        PD4                 digital_io[5]
     if(cfg_port_d_dir_sel[4])       digital_io_out[5]   = port_d_out[4];

     //Pin-9        PB6/XTAL1/TOSC1     digital_io[6]
     if(cfg_port_b_dir_sel[6])       digital_io_out[6]   = port_b_out[6];


     // Pin-10       PB7/XTAL2/TOSC2     digital_io[7]
     if(cfg_port_b_dir_sel[7])       digital_io_out[7]   = port_b_out[7];

     //Pin-11       PD5/OC0B(PWM1)/T1   digital_io[8]
     if(cfg_pwm_enb[1])              digital_io_out[8]   = pwm_wfm[1];
     else if(cfg_port_d_dir_sel[5])  digital_io_out[8]   = port_d_out[5];

     //Pin-12       PD6/OC0A(PWM2)/AIN0 digital_io[9] /analog_io[2]
     if(cfg_pwm_enb[2])              digital_io_out[9]   = pwm_wfm[2];
     else if(cfg_port_d_dir_sel[6])  digital_io_out[9]   = port_d_out[6];


     //Pin-13       PD7/A1N1            digital_io[10]/analog_io[3]
     if(cfg_port_d_dir_sel[7])       digital_io_out[10]  = port_d_out[7];
     
     //Pin-14       PB0/CLKO/ICP1       digital_io[11]
     if(cfg_port_b_dir_sel[0])       digital_io_out[11]  = port_b_out[0];

     //Pin-15       PB1/OC1A(PWM3)      digital_io[12]
     if(cfg_pwm_enb[3])              digital_io_out[12]  = pwm_wfm[3];
     else if(cfg_port_b_dir_sel[1])  digital_io_out[12]  = port_b_out[1];

     //Pin-16       PB2/SS/OC1B(PWM4)   digital_io[13]
     if(cfg_pwm_enb[4])              digital_io_out[13]  = pwm_wfm[4];
     else if(cfg_spim_enb)           digital_io_out[13]  = spim_ss;
     else if(cfg_port_b_dir_sel[2])  digital_io_out[13]  = port_b_out[2];

     //Pin-17       PB3/MOSI/OC2A(PWM5) digital_io[14]
     if(cfg_pwm_enb[5])              digital_io_out[14]  = pwm_wfm[5];
     else if(cfg_port_b_dir_sel[3])  digital_io_out[14]  = port_b_out[3];

     //Pin-18       PB4/MISO            digital_io[15]
     if(cfg_spim_enb)                digital_io_out[15]  = spim_miso;
     else if(cfg_port_b_dir_sel[4])  digital_io_out[15]  = port_b_out[4];

     //Pin-19       PB5/SCK             digital_io[16]
     if(cfg_spim_enb)                digital_io_out[16]  = spim_sck;
     else if(cfg_port_b_dir_sel[5])  digital_io_out[16]  = port_b_out[5];
     
     //Pin-23       PC0/ADC0            digital_io[18]/analog_io[11]
     if(cfg_port_c_dir_sel[0])       digital_io_out[18]  = port_c_out[0];

     //Pin-24       PC1/ADC1            digital_io[19]/analog_io[12]
     if(cfg_port_c_dir_sel[1])       digital_io_out[19]  = port_c_out[1];

     //Pin-25       PC2/ADC2            digital_io[20]/analog_io[13]
     if(cfg_port_c_dir_sel[2])       digital_io_out[20]  = port_c_out[2];

     //Pin-26       PC3/ADC3            digital_io[21]/analog_io[14]
     if(cfg_port_c_dir_sel[3])       digital_io_out[21]  = port_c_out[3];

     //Pin-27       PC4/ADC4/SDA        digital_io[22]/analog_io[15]
     if(cfg_i2cm_enb)                digital_io_out[22]  = i2cm_data_o;
     else if(cfg_port_c_dir_sel[4])  digital_io_out[22]  = port_c_out[4];

     //Pin-28       PC5/ADC5/SCL        digital_io[23]/analog_io[16]
     if(cfg_i2cm_enb)                digital_io_out[23]  = i2cm_clk_o;
     else if(cfg_port_c_dir_sel[5])  digital_io_out[23]  = port_c_out[5];

     // Serial Flash
     digital_io_out[24] = sflash_sck   ;
     digital_io_out[25] = sflash_ss[3] ;
     digital_io_out[26] = sflash_ss[2] ;
     digital_io_out[27] = sflash_ss[1] ;
     digital_io_out[28] = sflash_ss[0] ;
     digital_io_out[29] = sflash_do[0] ;
     digital_io_out[30] = sflash_do[1] ;
     digital_io_out[31] = sflash_do[2] ;
     digital_io_out[32] = sflash_do[3] ;
                       
     // Reserved
     digital_io_out[33] = 1'b0;

     // UART MASTER I/f
     digital_io_out[34] = 1'b0         ; // RXD
     digital_io_out[35] = uartm_txd    ; // TXD
                  
     // USB 1.1     
     digital_io_out[36] = usb_dp_o     ;
     digital_io_out[37] = usb_dn_o     ;
end

// dataoen selection
always_comb begin
     digital_io_oen = 38'h3F_FFFF_FFFF;
     //Pin-1        PC6/RESET*          digital_io[0]
     if(cfg_port_c_dir_sel[6])       digital_io_oen[0]   = 1'b0;

     //Pin-2        PD0/RXD             digital_io[1]
     if     (cfg_uart_enb)           digital_io_oen[1]   = 1'b1;
     else if(cfg_port_d_dir_sel[0])  digital_io_oen[1]   = 1'b0;

     //Pin-3        PD1/TXD             digital_io[2]
     if     (cfg_uart_enb)           digital_io_oen[2]   = 1'b0;
     else if(cfg_port_d_dir_sel[1])  digital_io_oen[2]   = 1'b0;

    //Pin-4        PD2/INT0            digital_io[3]
     if(cfg_int_enb[0])              digital_io_oen[3]   = 1'b1;
     else if(cfg_port_d_dir_sel[2])  digital_io_oen[3]   = 1'b0;

     //Pin-5        PD3/INT1/OC2B(PWM0)  digital_io[4]
     if(cfg_pwm_enb[0])              digital_io_oen[4]   = 1'b0;
     else if(cfg_int_enb[1])         digital_io_oen[4]   = 1'b1;
     else if(cfg_port_d_dir_sel[3])  digital_io_oen[4]   = 1'b0;

     //Pin-6        PD4                 digital_io[5]
     if(cfg_port_d_dir_sel[4])       digital_io_oen[5]   = 1'b0;

     //Pin-9        PB6/XTAL1/TOSC1     digital_io[6]
     if(cfg_port_b_dir_sel[6])       digital_io_oen[6]   = 1'b0;

     // Pin-10       PB7/XTAL2/TOSC2     digital_io[7]
     if(cfg_port_b_dir_sel[7])       digital_io_oen[7]   = 1'b0;

     //Pin-11       PD5/OC0B(PWM1)/T1   digital_io[8]
     if(cfg_pwm_enb[1])              digital_io_oen[8]   = 1'b0;
     else if(cfg_port_d_dir_sel[5])  digital_io_oen[8]   = 1'b0;

     //Pin-12       PD6/OC0A(PWM2)/AIN0 digital_io[9] /analog_io[2]
     if(cfg_pwm_enb[2])              digital_io_oen[9]   = 1'b0;
     else if(cfg_port_d_dir_sel[6])  digital_io_oen[9]   = 1'b0;

     //Pin-13       PD7/A1N1            digital_io[10]/analog_io[3]
     if(cfg_port_d_dir_sel[7])       digital_io_oen[10]  = 1'b0;
     
     //Pin-14       PB0/CLKO/ICP1       digital_io[11]
     if(cfg_port_b_dir_sel[0])       digital_io_oen[11]  = 1'b0;

     //Pin-15       PB1/OC1A(PWM3)      digital_io[12]
     if(cfg_pwm_enb[3])              digital_io_oen[12]  = 1'b0;
     else if(cfg_port_b_dir_sel[1])  digital_io_oen[12]  = 1'b0;

     //Pin-16       PB2/SS/OC1B(PWM4)   digital_io[13]
     if(cfg_pwm_enb[4])              digital_io_oen[13]  = 1'b0;
     else if(cfg_spim_enb)           digital_io_oen[13]  = 1'b0;
     else if(cfg_port_b_dir_sel[2])  digital_io_oen[13]  = 1'b0;

     //Pin-17       PB3/MOSI/OC2A(PWM5) digital_io[14]
     if(cfg_spim_enb)                digital_io_oen[14]  = 1'b1;
     else if(cfg_pwm_enb[5])         digital_io_oen[14]  = 1'b0;
     else if(cfg_port_b_dir_sel[3])  digital_io_oen[14]  = 1'b0;

     //Pin-18       PB4/MISO            digital_io[15]
     if(cfg_spim_enb)                digital_io_oen[15]  = 1'b0;
     else if(cfg_port_b_dir_sel[4])  digital_io_oen[15]  = 1'b0;

     //Pin-19       PB5/SCK             digital_io[16]
     if(cfg_spim_enb)                digital_io_oen[16]  = 1'b0;
     else if(cfg_port_b_dir_sel[5])  digital_io_oen[16]  = 1'b0;
     
     //Pin-23       PC0/ADC0            digital_io[18]/analog_io[11]
     if(cfg_port_c_dir_sel[0])       digital_io_oen[18]  = 1'b0;

     //Pin-24       PC1/ADC1            digital_io[19]/analog_io[12]
     if(cfg_port_c_dir_sel[1])       digital_io_oen[19]  = 1'b0;

     //Pin-25       PC2/ADC2            digital_io[20]/analog_io[13]
     if(cfg_port_c_dir_sel[2])       digital_io_oen[20]  = 1'b0;

     //Pin-26       PC3/ADC3            digital_io[21]/analog_io[14]
     if(cfg_port_c_dir_sel[3])       digital_io_oen[21]  = 1'b0;

     //Pin-27       PC4/ADC4/SDA        digital_io[22]/analog_io[15]
     if(cfg_i2cm_enb)                digital_io_oen[22]  = i2cm_data_oen;
     else if(cfg_port_c_dir_sel[4])  digital_io_oen[22]  = 1'b0;

     //Pin-28       PC5/ADC5/SCL        digital_io[23]/analog_io[16]
     if(cfg_i2cm_enb)                digital_io_oen[23]  = i2cm_clk_oen;
     else if(cfg_port_c_dir_sel[5])  digital_io_oen[23]  = 1'b0;

     // Serial Flash
     digital_io_oen[24] = 1'b0   ;
     digital_io_oen[25] = 1'b0   ;
     digital_io_oen[26] = 1'b0   ;
     digital_io_oen[27] = 1'b0   ;
     digital_io_oen[28] = 1'b0   ;
     digital_io_oen[29] = sflash_oen[0];
     digital_io_oen[30] = sflash_oen[1];
     digital_io_oen[31] = sflash_oen[2];
     digital_io_oen[32] = sflash_oen[3];
                       
     // Reserved
     digital_io_oen[33] = 1'b0  ;
     // UART MASTER
     digital_io_oen[34] = 1'b1; // RXD
     digital_io_oen[35] = 1'b0; // TXD
                  
     // USB 1.1     
     digital_io_oen[36] = usb_oen;
     digital_io_oen[37] = usb_oen;
end


endmodule 


