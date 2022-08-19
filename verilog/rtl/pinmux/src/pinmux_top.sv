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
////    0.2 - 6 April 2021, Dinesh A                              ////
////          1. SSPI CS# increased from 1 to 4                   ////
//            2. UART I/F increase from 1 to 2                    ////
////    0.3 - 8 July 2022, Dinesh A                               ////
////          In ardunio, SPI chip select are control through     ////
////          GPIO, So we have moved the Auto generated SPI CS    ////
////          different config bit. I2C config position moved from////
////          bit[14] to bit [15]                                 ////
////    0.4 - 20 July 2022, Dinesh A                              ////
////         On Power On, If RESET* = 0, then system will enter   ////
////         in to SPIS slave mode to support boot                ////
//////////////////////////////////////////////////////////////////////

module pinmux_top (
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

                       // Global Reset control
                       output logic  [1:0]     cpu_core_rst_n   ,
                       output logic            cpu_intf_rst_n   ,
                       output logic            qspim_rst_n      ,
                       output logic            sspim_rst_n      ,
                       output logic [1:0]      uart_rst_n       ,
                       output logic            i2cm_rst_n       ,
                       output logic            usb_rst_n        ,

		       output logic [15:0]     cfg_riscv_ctrl,

		       // Reg Bus Interface Signal
                       input logic             reg_cs,
                       input logic             reg_wr,
                       input logic [8:0]       reg_addr,
                       input logic [31:0]      reg_wdata,
                       input logic [3:0]       reg_be,

                       // Outputs
                       output logic [31:0]     reg_rdata,
                       output logic            reg_ack,

		      // Risc configuration
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
                       input logic              uartm_txd  ,       

		       output  logic           pulse1m_mclk,
	               output  logic [31:0]    pinmux_debug,

		       input   logic           dbg_clk_mon

   ); 



logic sreset_n;  // Sync Reset
   
/* clock pulse */
//********************************************************
logic           pulse_1ms               ; // 1 Milli Second Pulse for waveform Generator
logic [5:0]     cfg_pwm_enb             ;


//---------------------------------------------------------
// Timer Register                          
// -------------------------------------------------------
logic [2:0]    timer_intr              ;

//---------------------------------------------------
// 6 PWM variabled
//---------------------------------------------------

logic [5:0]     pwm_wfm                 ;


wire  [31:0]  cfg_gpio_dir_sel         ;// decides on GPIO pin is I/P or O/P at pad level, 0 -> Input, 1 -> Output
wire  [31:0]  cfg_gpio_out_type        ;// GPIO Type, Unused
wire  [31:0]  cfg_multi_func_sel       ;// GPIO Multi function type


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


assign      pinmux_debug = '0; // Todo: Need to fix

//------------------------------------------------------
// Register Map Decoding

`define SEL_GLBL  3'b000   // GLOBAL REGISTER
`define SEL_GPIO  3'b001   // GPIO REGISTER
`define SEL_PWM   3'b010   // PWM REGISTER
`define SEL_TIMER 3'b011   // TIMER REGISTER
`define SEL_SEMA  3'b100   // SEMAPHORE REGISTER


//----------------------------------------
//  Register Response Path Mux
//  --------------------------------------
logic [31:0]  reg_glbl_rdata;
logic         reg_glbl_ack;

logic [31:0]  reg_gpio_rdata;
logic         reg_gpio_ack;

logic [31:0]  reg_pwm_rdata;
logic         reg_pwm_ack;

logic [31:0]  reg_timer_rdata;
logic         reg_timer_ack;

logic [15:0]  reg_sema_rdata;
logic         reg_sema_ack;


assign reg_rdata = (reg_addr[8:6] == `SEL_GLBL)  ? {reg_glbl_rdata} : 
	               (reg_addr[8:6] == `SEL_GPIO)  ? {reg_gpio_rdata} :
	               (reg_addr[8:6] == `SEL_PWM)   ? {reg_pwm_rdata}  :
	               (reg_addr[8:6] == `SEL_TIMER) ? reg_timer_rdata  : 
	               (reg_addr[8:6] == `SEL_SEMA)  ? {16'h0,reg_sema_rdata} : 'h0;

assign reg_ack   = (reg_addr[8:6] == `SEL_GLBL)  ? reg_glbl_ack   : 
	               (reg_addr[8:6] == `SEL_GPIO)  ? reg_gpio_ack   : 
	               (reg_addr[8:6] == `SEL_PWM)   ? reg_pwm_ack    : 
	               (reg_addr[8:6] == `SEL_TIMER) ? reg_timer_ack  : 
	               (reg_addr[8:6] == `SEL_SEMA)  ? reg_sema_ack   : 1'b0;

wire reg_glbl_cs  = (reg_addr[8:6] == `SEL_GLBL) ? reg_cs : 1'b0;
wire reg_gpio_cs  = (reg_addr[8:6] == `SEL_GPIO) ? reg_cs : 1'b0;
wire reg_pwm_cs   = (reg_addr[8:6] == `SEL_PWM)  ? reg_cs : 1'b0;
wire reg_timer_cs = (reg_addr[8:6] == `SEL_TIMER)? reg_cs : 1'b0;
wire reg_sema_cs  = (reg_addr[8:6] == `SEL_SEMA) ? reg_cs : 1'b0;

//---------------------------------------------------------------------

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

reset_sync  u_rst_sync (
	      .scan_mode  (1'b0        ),
              .dclk       (mclk        ), // Destination clock domain
	      .arst_n     (h_reset_n   ), // active low async reset
              .srst_n     (sreset_n    )
          );

//------------------------------------------------------------------
// Global Register
//------------------------------------------------------------------
glbl_reg u_glbl_reg(
      // System Signals
      // Inputs
          .mclk                         (mclk                    ),
          .h_reset_n                    (sreset_n                ),

          .cpu_core_rst_n               (cpu_core_rst_n          ),
          .cpu_intf_rst_n               (cpu_intf_rst_n          ),
          .qspim_rst_n                  (qspim_rst_n             ),
          .sspim_rst_n                  (sspim_rst_n             ),
          .uart_rst_n                   (uart_rst_n              ),
          .i2cm_rst_n                   (i2cm_rst_n              ),
          .usb_rst_n                    (usb_rst_n               ),

	      .cfg_riscv_ctrl               (cfg_riscv_ctrl          ),
          .cfg_multi_func_sel           (cfg_multi_func_sel      ),


      // Reg read/write Interface Inputs
          .reg_cs                       (reg_glbl_cs             ),
          .reg_wr                       (reg_wr                  ),
          .reg_addr                     (reg_addr[5:2]           ),
          .reg_wdata                    (reg_wdata               ),
          .reg_be                       (reg_be                  ),

          .reg_rdata                    (reg_glbl_rdata          ),
          .reg_ack                      (reg_glbl_ack            ),

	      .ext_intr_in                  (ext_intr_in             ),

	      .irq_lines                    (irq_lines               ),
	      .soft_irq                     (soft_irq                ),
	      .user_irq                     (user_irq                ),
          .usb_intr                     (usb_intr                ),
          .i2cm_intr                    (i2cm_intr               ),



          .timer_intr                   (timer_intr             ),
          .gpio_intr                    (gpio_intr              )


   ); 

//-----------------------------------------------------------------------
// GPIO Top
//-----------------------------------------------------------------------
gpio_top  u_gpio(
              // System Signals
              // Inputs
		      .mclk                     ( mclk                      ),
              .h_reset_n                (h_reset_n                  ),

		      // Reg Bus Interface Signal
              .reg_cs                   (reg_gpio_cs                ),
              .reg_wr                   (reg_wr                     ),
              .reg_addr                 (reg_addr[5:2]             ),
              .reg_wdata                (reg_wdata                  ),
              .reg_be                   (reg_be                     ),

              // Outputs
              .reg_rdata                (reg_gpio_rdata             ),
              .reg_ack                  (reg_gpio_ack               ),


              .cfg_gpio_dir_sel         (cfg_gpio_dir_sel           ),
              .pad_gpio_in              (pad_gpio_in                ),
              .pad_gpio_out             (pad_gpio_out               ),

              .gpio_intr                (gpio_intr                  )          


                ); 

//-----------------------------------------------------------------------
// PWM Top
//-----------------------------------------------------------------------
pwm_top  u_pwm(
              // System Signals
              // Inputs
		      .mclk                     ( mclk                      ),
              .h_reset_n                (h_reset_n                  ),

		      // Reg Bus Interface Signal
              .reg_cs                   (reg_pwm_cs                 ),
              .reg_wr                   (reg_wr                     ),
              .reg_addr                 (reg_addr[4:2]              ),
              .reg_wdata                (reg_wdata                  ),
              .reg_be                   (reg_be                     ),

              // Outputs
              .reg_rdata                (reg_pwm_rdata              ),
              .reg_ack                  (reg_pwm_ack                ),

              .pulse_1ms                (pulse_1ms                  ), 
              .cfg_pwm_enb              (cfg_pwm_enb                ),
              .pwm_wfm                  (pwm_wfm                    ) 
           );

//-----------------------------------------------------------------------
// Timer Top
//-----------------------------------------------------------------------
timer_top  u_timer(
              // System Signals
              // Inputs
		      .mclk                     ( mclk                      ),
              .h_reset_n                (h_reset_n                  ),

		      // Reg Bus Interface Signal
              .reg_cs                   (reg_timer_cs               ),
              .reg_wr                   (reg_wr                     ),
              .reg_addr                 (reg_addr[3:2]              ),
              .reg_wdata                (reg_wdata                  ),
              .reg_be                   (reg_be                     ),

              // Outputs
              .reg_rdata                (reg_timer_rdata            ),
              .reg_ack                  (reg_timer_ack              ),

              .pulse_1ms                (pulse_1ms                  ), 
              .timer_intr               (timer_intr                 ) 
           );

//-----------------------------------------------------------------------
// Semaphore Register
//-----------------------------------------------------------------------
semaphore_reg  u_semaphore(
              // System Signals
              // Inputs
		      .mclk                     ( mclk                      ),
              .h_reset_n                (h_reset_n                  ),

		      // Reg Bus Interface Signal
              .reg_cs                   (reg_sema_cs                ),
              .reg_wr                   (reg_wr                     ),
              .reg_addr                 (reg_addr[5:2]              ),
              .reg_wdata                (reg_wdata[15:0]            ),
              .reg_be                   (reg_be[1:0]                ),

              // Outputs
              .reg_rdata                (reg_sema_rdata             ),
              .reg_ack                  (reg_sema_ack               )
         );


pinmux u_pinmux (
               // Digital IO
               .digital_io_out          (digital_io_out      ),
               .digital_io_oen          (digital_io_oen      ),
               .digital_io_in           (digital_io_in       ),

               // Config
               .cfg_gpio_dir_sel        (cfg_gpio_dir_sel    ),
               .cfg_multi_func_sel      (cfg_multi_func_sel  ),

               .cfg_pwm_enb             (cfg_pwm_enb         ),                                                          
               .pwm_wfm                 (pwm_wfm             ),
               .ext_intr_in             (ext_intr_in         ),  // External PAD level interrupt
               .pad_gpio_in             (pad_gpio_in         ),  // GPIO data input from PAD
               .pad_gpio_out            (pad_gpio_out        ),  // GPIO Data out towards PAD

		       // SFLASH I/F
		       .sflash_sck              (sflash_sck          ),
		       .sflash_ss               (sflash_ss           ),
		       .sflash_oen              (sflash_oen          ),
		       .sflash_do               (sflash_do           ),
		       .sflash_di               (sflash_di           ),

		       // USB I/F
		       .usb_dp_o                (usb_dp_o            ),
		       .usb_dn_o                (usb_dn_o            ),
		       .usb_oen                 (usb_oen             ),
		       .usb_dp_i                (usb_dp_i            ),
		       .usb_dn_i                (usb_dn_i            ),

		       // UART I/F
		       .uart_txd                (uart_txd            ),
		       .uart_rxd                (uart_rxd            ),

		       // I2CM I/F
		       .i2cm_clk_o              (i2cm_clk_o          ),
		       .i2cm_clk_i              (i2cm_clk_i          ),
		       .i2cm_clk_oen            (i2cm_clk_oen        ),
		       .i2cm_data_oen           (i2cm_data_oen       ),
		       .i2cm_data_o             (i2cm_data_o         ),
		       .i2cm_data_i             (i2cm_data_i         ),

		       // SPI MASTER
		       .spim_sck                (spim_sck            ),
		       .spim_ssn                (spim_ssn            ),
		       .spim_miso               (spim_miso           ),
		       .spim_mosi               (spim_mosi           ),
		       
		       // SPI SLAVE
		       .spis_sck                (spis_sck            ),
		       .spis_ssn                (spis_ssn            ),
		       .spis_miso               (spis_miso           ),
		       .spis_mosi               (spis_mosi           ),

               // UART MASTER I/F
               .uartm_rxd               (uartm_rxd           ),
               .uartm_txd               (uartm_txd           ),       
                                                   
		       .dbg_clk_mon             (dbg_clk_mon         )

   ); 

endmodule 


