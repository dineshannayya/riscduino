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
////    0.5  Aug 5 2022, Dinesh A                                 ////
////         changes in sspim                                     ////
////           A. SPI Mode 0 to 3 support added,                  ////
////           B. SPI Duplex mode TX-RX Mode added                ////
////    0.6  Aug 15 2022, Dinesh A                                ////
////          A. 15 Hardware Semahore added                       ////
////    0.7 - 24 Aug 2022, Dinesh A                               ////
////          A. GPIO interrupt generation changed from 1 to 32   ////
////          B. uart_master disable option added                 ////
////          C. Timer interrupt related clean-up                 ////
////          D. 4x ws281x driver logic added                     ////
////          E. 4x ws281x driver are mux with 16x gpio           ////
////          F. gpio type select the normal gpio vs ws281x       ////
////    0.7 - 26th Aug 2022, Dinesh A                             ////
////          As digitial-io[0-4] reserved at power up.           ////
////          A. to keep at least one uart access,                ////
////              we have moved UART_RXD[1] from io[3] to io[6]   ////
////          B. SPI Slave SSN move from io[0] to [7]             ////
////          C. Additional Mail Box Register added at addr 0xF   ////
////          D. Due to power on digitalio[0-4] access issue,we   ////
////             have moved arduino pin mapping from io 5 onward  ////
////    0.8 - 1 Sept 2022, Dinesh A                               ////
////          A. System strap implementation                      ////
////          B. glbl address space increased from 16 to 32       ////
////          C. software register address moved, 4 register will ////
////             reset under power-on reset, 4 register will reset////
////             system reset                                     ////
////    0.9 - 5 Jan 2023, Dinesh A                                ////
////          A. Stepper Motor Integration                        ////
////    1.0 - 5 Mar 2023, Dinesh A                                ////
////          A. Riscv Tap access integration                     ////
//////////////////////////////////////////////////////////////////////
`include "user_params.svh"
module pinmux_top (
                    `ifdef USE_POWER_PINS
                       input logic             vccd1,// User area 1 1.8V supply
                       input logic             vssd1,// User area 1 digital ground
                    `endif
                        // clock skew adjust
                       input logic [3:0]       cfg_cska_pinmux,
                       input logic	           wbd_clk_int,
                       output logic	           wbd_clk_pinmux,
                       // System Signals
                       // Inputs
		               input logic             mclk,
	                   input logic             e_reset_n              ,  // external reset
	                   input logic             p_reset_n              ,  // power-on reset
                       input logic             s_reset_n              ,  // soft reset

                       `ifdef YCR_DBG_EN
                           // -- JTAG I/F
                        output   logic         riscv_trst_n,
                        output   logic         riscv_tck,
                        output   logic         riscv_tms,
                        output   logic         riscv_tdi,
                        input    logic         riscv_tdo,
                        input    logic         riscv_tdo_en,
                       `endif // YCR_DBG_EN

                       // to/from Global Reset FSM
                        input  logic           cfg_strap_pad_ctrl     ,
	                    input  logic [31:0]    system_strap           ,
	                    output logic [31:0]    strap_sticky           ,
                        output logic [1:0]     strap_uartm            ,

                        input logic            user_clock1            ,
                        input logic            user_clock2            ,
                        input logic            int_pll_clock          ,
                        input logic            cpu_clk                ,
                        output logic           xtal_clk               ,

                        output logic           usb_clk                ,
                        output logic           rtc_clk                ,

                       // Global Reset control
                       output logic  [3:0]     cpu_core_rst_n   ,
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
                       input logic [10:0]      reg_addr,
                       input logic [31:0]      reg_wdata,
                       input logic [3:0]       reg_be,

                       // Outputs
                       output logic [31:0]     reg_rdata,
                       output logic            reg_ack,

		      // Risc configuration
                       output logic [31:0]     irq_lines,
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

               // Digital PLL I/F
               output logic            cfg_pll_enb        , // Enable PLL
               output logic[4:0]       cfg_pll_fed_div    , // PLL feedback division ratio
               output logic            cfg_dco_mode       , // Run PLL in DCO mode
               output logic[25:0]      cfg_dc_trim        , // External trim for DCO mode
               output logic            pll_ref_clk        , // Input oscillator to match

		       // Peripheral Reg Bus Interface Signal
               output logic             reg_peri_cs,
               output logic             reg_peri_wr,
               output logic [10:0]      reg_peri_addr,
               output logic [31:0]      reg_peri_wdata,
               output logic [3:0]       reg_peri_be,

               // Input
               input logic [31:0]       reg_peri_rdata,
               input logic              reg_peri_ack,

               input logic              rtc_intr,

               // IR Receiver I/F
               output logic             ir_rx,
               input  logic             ir_tx,
               input  logic             ir_intr,

               //------------------------------
               // Stepper Motor Variable
               //------------------------------
               input logic              sm_a1,  
               input logic              sm_a2,  
               input logic              sm_b1,  
               input logic              sm_b2  


               
   ); 



logic         s_reset_ssn;  // Sync Reset
logic         p_reset_ssn;  // Sync Reset
logic [15:0]  pad_strap_in;
logic         dbg_clk_mon;
logic         cfg_gpio_dgmode; // gpio de-glitch mode
logic         pwm_intr;   
/* clock pulse */
//********************************************************
logic           pulse_1ms               ; // 1 Milli Second Pulse for waveform Generator
logic           pulse_1us               ; // 1 Micro Second Pulse for waveform Generator
logic [5:0]     cfg_pwm_enb             ;


//---------------------------------------------------------
// Timer Register                          
// -------------------------------------------------------
logic [2:0]    timer_intr              ;

//---------------------------------------------------
// 6 PWM variabled
//---------------------------------------------------

logic [5:0]     pwm_wfm                 ;


logic [31:0]  gpio_intr                ;
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

logic [3:0]     ws_txd        ; // ws281x txd port

assign      pinmux_debug = '0; // Todo: Need to fix


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

logic [31:0]  reg_ws_rdata;
logic         reg_ws_ack;

logic [31:0]  reg_d2a_rdata;
logic         reg_d2a_ack;

logic [7:0]   pwm_gpio_in;

logic         reg_glbl_cs ;
logic         reg_gpio_cs ;
logic         reg_pwm_cs  ;
logic         reg_timer_cs;
logic         reg_sema_cs ;
logic         reg_ws_cs   ;




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
	      .scan_mode  (1'b0           ),
          .dclk       (mclk           ), // Destination clock domain
	      .arst_n     (s_reset_n      ), // active low async reset
          .srst_n     (s_reset_ssn    )
          );

reset_sync  u_prst_sync (
	      .scan_mode  (1'b0           ),
          .dclk       (mclk           ), // Destination clock domain
	      .arst_n     (p_reset_n      ), // active low async reset
          .srst_n     (p_reset_ssn    )
          );


//------------------------------------------------------------------
// Global Register
//------------------------------------------------------------------
glbl_reg u_glbl_reg(
      // System Signals
      // Inputs
          .mclk                         (mclk                    ),
	      .e_reset_n                    (e_reset_n               ),  // external reset
	      .p_reset_n                    (p_reset_ssn             ),  // power-on reset
          .s_reset_n                    (s_reset_ssn             ),

          .pad_strap_in                 (pad_strap_in            ),
          .system_strap                 (system_strap            ),
          .strap_sticky                 (strap_sticky            ),
          .strap_uartm                  (strap_uartm             ),

          .user_clock1                  (user_clock1             ),
          .user_clock2                  (user_clock2             ),
          .int_pll_clock                (int_pll_clock           ),
          .cpu_clk                      (cpu_clk                 ),
          .xtal_clk                     (xtal_clk                ),

          .usb_clk                      (usb_clk                 ),
          .rtc_clk                      (rtc_clk                 ),


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
          .reg_addr                     (reg_addr[6:2]           ),
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
          .pwm_intr                     (pwm_intr                ),
          .rtc_intr                     (rtc_intr                ),
          .ir_intr                      (ir_intr                 ),



          .timer_intr                   (timer_intr             ),
          .gpio_intr                    (gpio_intr              ),

         // Digital PLL I/F
         .cfg_pll_enb                   (cfg_pll_enb            ), // Enable PLL
         .cfg_pll_fed_div               (cfg_pll_fed_div        ), // PLL feedback division ratio
         .cfg_dco_mode                  (cfg_dco_mode           ), // Run PLL in DCO mode
         .cfg_dc_trim                   (cfg_dc_trim            ), // External trim for DCO mode
         .pll_ref_clk                   (pll_ref_clk            ), // Input oscillator to match

         .dbg_clk_mon                   (dbg_clk_mon            ),
         .cfg_gpio_dgmode               (cfg_gpio_dgmode        )



   ); 

//-----------------------------------------------------------------------
// GPIO Top
//-----------------------------------------------------------------------
gpio_top  u_gpio(
              // System Signals
              // Inputs
		      .mclk                     ( mclk                      ),
              .h_reset_n                (s_reset_ssn                ),
              .cfg_gpio_dgmode          (cfg_gpio_dgmode            ),
              .pulse_1us                (pulse_1us                  ), 

		      // Reg Bus Interface Signal
              .reg_cs                   (reg_gpio_cs                ),
              .reg_wr                   (reg_wr                     ),
              .reg_addr                 (reg_addr[5:2]             ),
              .reg_wdata                (reg_wdata                  ),
              .reg_be                   (reg_be                     ),

              // Outputs
              .reg_rdata                (reg_gpio_rdata             ),
              .reg_ack                  (reg_gpio_ack               ),


              .cfg_gpio_out_type        (cfg_gpio_out_type           ),
              .cfg_gpio_dir_sel         (cfg_gpio_dir_sel           ),
              .pad_gpio_in              (pad_gpio_in                ),
              .pad_gpio_out             (pad_gpio_out               ),
              .pwm_gpio_in              (pwm_gpio_in                ),

              .gpio_intr                (gpio_intr                  )          


                ); 

//-----------------------------------------------------------------------
// PWM Top
//-----------------------------------------------------------------------
pwm_top  u_pwm(
              // System Signals
              // Inputs
		      .mclk                     ( mclk                      ),
              .h_reset_n                (s_reset_ssn                ),

		      // Reg Bus Interface Signal
              .reg_cs                   (reg_pwm_cs                 ),
              .reg_wr                   (reg_wr                     ),
              .reg_addr                 (reg_addr[6:2]              ),
              .reg_wdata                (reg_wdata                  ),
              .reg_be                   (reg_be                     ),

              // Outputs
              .reg_rdata                (reg_pwm_rdata              ),
              .reg_ack                  (reg_pwm_ack                ),

              .pad_gpio                 (pwm_gpio_in                ),
              .pwm_wfm                  (pwm_wfm                    ),
              .pwm_intr                 (pwm_intr                   ) 
           );

//-----------------------------------------------------------------------
// Timer Top
//-----------------------------------------------------------------------
timer_top  u_timer(
              // System Signals
              // Inputs
		      .mclk                     (mclk                     ),
              .h_reset_n                (s_reset_ssn              ),

		      // Reg Bus Interface Signal
              .reg_cs                   (reg_timer_cs               ),
              .reg_wr                   (reg_wr                     ),
              .reg_addr                 (reg_addr[3:2]              ),
              .reg_wdata                (reg_wdata                  ),
              .reg_be                   (reg_be                     ),

              // Outputs
              .reg_rdata                (reg_timer_rdata            ),
              .reg_ack                  (reg_timer_ack              ),

              .pulse_1us                (pulse_1us                  ), 
              .pulse_1ms                (pulse1m_mclk               ), 
              .timer_intr               (timer_intr                 ) 
           );

//-----------------------------------------------------------------------
// Semaphore Register
//-----------------------------------------------------------------------
semaphore_reg  u_semaphore(
              // System Signals
              // Inputs
		      .mclk                     ( mclk                      ),
              .h_reset_n                (s_reset_ssn                ),

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

//-----------------------------------------------------------------------
// 4 Port ws281x driver 
//----------------------------------------------------------------------

ws281x_top  u_ws281x(
		                .mclk           (mclk             ),
                        .h_reset_n      (s_reset_ssn      ),
                                                          
                        .reg_cs         (reg_ws_cs        ),
                        .reg_wr         (reg_wr           ),
                        .reg_addr       (reg_addr[5:2]    ),
                        .reg_wdata      (reg_wdata        ),
                        .reg_be         (reg_be           ),

                        .reg_rdata      (reg_ws_rdata     ),
                        .reg_ack        (reg_ws_ack       ),

                        .txd            (ws_txd           )

                ); 



//----------------------------------------------------------------------
// Pinmux 
//----------------------------------------------------------------------

pinmux u_pinmux (
       `ifdef YCR_DBG_EN
           // -- JTAG I/F
              .riscv_trst_n             (riscv_trst_n        ),
              .riscv_tck                (riscv_tck           ),
              .riscv_tms                (riscv_tms           ),
              .riscv_tdi                (riscv_tdi           ),
              .riscv_tdo                (riscv_tdo           ),
              .riscv_tdo_en             (riscv_tdo_en        ),
       `endif // YCR_DBG_EN

               .cfg_strap_pad_ctrl      (cfg_strap_pad_ctrl  ),
               .pad_strap_in            (pad_strap_in        ),
               // Digital IO
               .digital_io_out          (digital_io_out      ),
               .digital_io_oen          (digital_io_oen      ),
               .digital_io_in           (digital_io_in       ),

               .xtal_clk                (xtal_clk            ),

               // Config
               .cfg_gpio_out_type       (cfg_gpio_out_type   ),
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

               .ws_txd                  (ws_txd              ),       
                                                   
		       .dbg_clk_mon             (dbg_clk_mon         ),

               .ir_rx                   (ir_rx               ),
               .ir_tx                   (ir_tx               ),

               //-------------------------------------
               // Stpper Motor outputs
               //-------------------------------------
               .sm_a1                   (sm_a1               ),  
               .sm_a2                   (sm_a2               ),  
               .sm_b1                   (sm_b1               ),  
               .sm_b2                   (sm_b2               )   

   ); 


//-------------------------------------------------
// Register Block Selection Logic
//-------------------------------------------------
reg [3:0] reg_blk_sel;

always @(posedge mclk or negedge s_reset_ssn)
begin
   if(s_reset_ssn == 1'b0) begin
     reg_blk_sel <= 'h0;
   end
   else begin
      if(reg_cs) reg_blk_sel <= reg_addr[10:7];
   end
end

assign reg_rdata = (reg_blk_sel    == `SEL_GLBL)  ? {reg_glbl_rdata} : 
	               (reg_blk_sel    == `SEL_GPIO)  ? {reg_gpio_rdata} :
	               (reg_blk_sel    == `SEL_PWM)   ? {reg_pwm_rdata}  :
	               (reg_blk_sel    == `SEL_TIMER) ? reg_timer_rdata  : 
	               (reg_blk_sel    == `SEL_SEMA)  ? {16'h0,reg_sema_rdata} : 
	               (reg_blk_sel    == `SEL_WS)    ? reg_ws_rdata     : 
	               (reg_blk_sel[3] == `SEL_PERI)  ? reg_peri_rdata   : 'h0;

assign reg_ack   = (reg_blk_sel    == `SEL_GLBL)  ? reg_glbl_ack   : 
	               (reg_blk_sel    == `SEL_GPIO)  ? reg_gpio_ack   : 
	               (reg_blk_sel    == `SEL_PWM)   ? reg_pwm_ack    : 
	               (reg_blk_sel    == `SEL_TIMER) ? reg_timer_ack  : 
	               (reg_blk_sel    == `SEL_SEMA)  ? reg_sema_ack   : 
	               (reg_blk_sel    == `SEL_WS)    ? reg_ws_ack     : 
	               (reg_blk_sel[3] == `SEL_PERI)  ? reg_peri_ack   : 1'b0;

assign reg_glbl_cs  = (reg_addr[10:7] == `SEL_GLBL) ? reg_cs : 1'b0;
assign reg_gpio_cs  = (reg_addr[10:7] == `SEL_GPIO) ? reg_cs : 1'b0;
assign reg_pwm_cs   = (reg_addr[10:7] == `SEL_PWM)  ? reg_cs : 1'b0;
assign reg_timer_cs = (reg_addr[10:7] == `SEL_TIMER)? reg_cs : 1'b0;
assign reg_sema_cs  = (reg_addr[10:7] == `SEL_SEMA) ? reg_cs : 1'b0;
assign reg_ws_cs    = (reg_addr[10:7] == `SEL_WS)   ? reg_cs : 1'b0;
assign reg_peri_cs  = (reg_addr[10]   == `SEL_PERI) ? reg_cs : 1'b0;

assign  reg_peri_wr    = reg_wr;
assign  reg_peri_addr  = reg_addr;
assign  reg_peri_wdata = reg_wdata;
assign  reg_peri_be    = reg_be;








endmodule 


