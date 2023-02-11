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
////  Peripheral Top                                              ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
////      Hold the All the Misc IP Integration                    ////
////        A. dig2ang                                            ////
////        B. RTC                                                ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 07 Dec 2022, Dinesh A                               ////
////          initial version                                     ////
////    0.2 - 05 Jan 2023, Dinesh A                               ////
////          Stepper Motor Integration                           ////
//////////////////////////////////////////////////////////////////////

`include "user_params.svh"
module peri_top (
                    `ifdef USE_POWER_PINS
                       input logic             vccd1,// User area 1 1.8V supply
                       input logic             vssd1,// User area 1 digital ground
                    `endif
                        // clock skew adjust
                       input logic [3:0]       cfg_cska_peri,
                       input logic	           wbd_clk_int,
                       output logic	           wbd_clk_peri,

                       // System Signals
                       // Inputs
		               input logic             mclk,
                       input logic             s_reset_n,  // soft reset

		       // Reg Bus Interface Signal
                       input logic             reg_cs,
                       input logic             reg_wr,
                       input logic [10:0]      reg_addr,
                       input logic [31:0]      reg_wdata,
                       input logic [3:0]       reg_be,

                       // Outputs
                       output logic [31:0]     reg_rdata,
                       output logic            reg_ack,

                       // RTC Clock Domain
                       input  logic            rtc_clk,
                       output logic            rtc_intr,

                       output logic            inc_time_s,
                       output logic            inc_date_d,

                       // IR Receiver I/F
                       input  logic            ir_rx,
                       output logic            ir_tx,
                       output logic            ir_intr,
               
                      // DAC Config
                       output logic [7:0]      cfg_dac0_mux_sel,
                       output logic [7:0]      cfg_dac1_mux_sel,
                       output logic [7:0]      cfg_dac2_mux_sel,
                       output logic [7:0]      cfg_dac3_mux_sel,     

                      //------------------------------
                      // Stepper Motor Variable
                      //------------------------------
                      output logic              sm_a1,  
                      output logic              sm_a2,  
                      output logic              sm_b1,  
                      output logic              sm_b2  

   ); 



logic         s_reset_ssn;  // Sync Reset


//----------------------------------------
//  Register Response Path Mux
//  --------------------------------------

logic [31:0]  reg_d2a_rdata;
logic         reg_d2a_ack;
logic         reg_d2a_cs;

logic [31:0]  reg_rtc_rdata;
logic         reg_rtc_ack;
logic         reg_rtc_cs;

logic [31:0]  reg_ir_rdata;
logic         reg_ir_ack;
logic         reg_ir_cs;

logic [31:0]  reg_sm_rdata;
logic         reg_sm_ack;
logic         reg_sm_cs;

assign reg_rdata  = (reg_addr[10:7] == `SEL_D2A) ? reg_d2a_rdata :
                    (reg_addr[10:7] == `SEL_RTC) ? reg_rtc_rdata :
                    (reg_addr[10:7] == `SEL_IR)  ? reg_ir_rdata :
                    (reg_addr[10:7] == `SEL_SM)  ? reg_sm_rdata :
                     'h0;
assign reg_ack    = (reg_addr[10:7] == `SEL_D2A) ? reg_d2a_ack   :
                    (reg_addr[10:7] == `SEL_RTC) ? reg_rtc_ack   :
                    (reg_addr[10:7] == `SEL_IR)  ? reg_ir_ack   :
                    (reg_addr[10:7] == `SEL_SM)  ? reg_sm_ack   :
                    1'b0;
assign reg_d2a_cs = (reg_addr[10:7] == `SEL_D2A)  ? reg_cs : 1'b0;
assign reg_rtc_cs = (reg_addr[10:7] == `SEL_RTC)  ? reg_cs : 1'b0;
assign reg_ir_cs  = (reg_addr[10:7] == `SEL_IR)  ? reg_cs : 1'b0;
assign reg_sm_cs  = (reg_addr[10:7] == `SEL_SM)  ? reg_cs : 1'b0;


// peri clock skew control
clk_skew_adjust u_skew_peri
       (
`ifdef USE_POWER_PINS
               .vccd1      (vccd1                      ),// User area 1 1.8V supply
               .vssd1      (vssd1                      ),// User area 1 digital ground
`endif
	           .clk_in     (wbd_clk_int                ), 
	           .sel        (cfg_cska_peri              ), 
	           .clk_out    (wbd_clk_peri               ) 
       );

reset_sync  u_rst_sync (
	      .scan_mode  (1'b0           ),
          .dclk       (mclk           ), // Destination clock domain
	      .arst_n     (s_reset_n      ), // active low async reset
          .srst_n     (s_reset_ssn    )
          );


//-----------------------------------------------------------------------
// Digital To Analog Register
//-----------------------------------------------------------------------
dig2ana_reg  u_d2a(
              // System Signals
              // Inputs
		      .mclk                     ( mclk                      ),
              .h_reset_n                (s_reset_ssn                ),

		      // Reg Bus Interface Signal
              .reg_cs                   (reg_d2a_cs                 ),
              .reg_wr                   (reg_wr                     ),
              .reg_addr                 (reg_addr[5:2]              ),
              .reg_wdata                (reg_wdata[31:0]            ),
              .reg_be                   (reg_be[3:0]                ),

              // Outputs
              .reg_rdata                (reg_d2a_rdata              ),
              .reg_ack                  (reg_d2a_ack                ),

              .cfg_dac0_mux_sel         (cfg_dac0_mux_sel           ),
              .cfg_dac1_mux_sel         (cfg_dac1_mux_sel           ),
              .cfg_dac2_mux_sel         (cfg_dac2_mux_sel           ),
              .cfg_dac3_mux_sel         (cfg_dac3_mux_sel           )
         );

//-----------------------------------------------------------------------
// RTC
//-----------------------------------------------------------------------
rtc_top  u_rtc(
              // System Signals
              // Inputs
		      .sys_clk                  ( mclk                      ),
              .rst_n                    (s_reset_ssn                ),

		      // Reg Bus Interface Signal
              .reg_cs                   (reg_rtc_cs                 ),
              .reg_wr                   (reg_wr                     ),
              .reg_addr                 (reg_addr[4:0]              ),
              .reg_wdata                (reg_wdata[31:0]            ),
              .reg_be                   (reg_be[3:0]                ),

              // Outputs
              .reg_rdata                (reg_rtc_rdata              ),
              .reg_ack                  (reg_rtc_ack                ),

              .rtc_clk                  (rtc_clk                    ),
              .rtc_intr                 (rtc_intr                   ),

              .inc_date_d               (inc_date_d                 ),
              .inc_time_s               (inc_time_s                 )

         );

//--------------------------------------------------------------------------
// IR Receiver
//--------------------------------------------------------------------------

nec_ir_top i_ir (

              .rst_n                    (s_reset_ssn                ), 
              .clk                      (mclk                       ), 

              // Wishbone bus
              .wbs_cyc_i                (reg_ir_cs                  ), 
              .wbs_stb_i                (reg_ir_cs                  ), 
              .wbs_adr_i                (reg_addr[4:0]              ),
              .wbs_we_i                 (reg_wr                     ),
              .wbs_dat_i                (reg_wdata                  ),
              .wbs_sel_i                (reg_be                     ),
              .wbs_dat_o                (reg_ir_rdata               ),
              .wbs_ack_o                (reg_ir_ack                 ),

              .ir_rx                    (ir_rx                      ),
              .ir_tx                    (ir_tx                      ),

              .irq                      (ir_intr                    )  

);


//-------------------------------------------------------
// Stepper Motor Controller
//-------------------------------------------------------

sm_ctrl u_sm (

          .rst_n              (s_reset_ssn        ),            
          .clk                (mclk               ),            

  // Wishbone bus
          .wbs_cyc_i          (reg_sm_cs          ),            
          .wbs_stb_i          (reg_sm_cs          ),            
          .wbs_adr_i          (reg_addr[4:0]      ), 
          .wbs_we_i           (reg_wr             ), 
          .wbs_dat_i          (reg_wdata          ), 
          .wbs_sel_i          (reg_be             ), 
          .wbs_dat_o          (reg_sm_rdata       ), 
          .wbs_ack_o          (reg_sm_ack         ), 

  // Motor outputs
          .motor_a1           (sm_a1              ),  
          .motor_a2           (sm_a2              ),  
          .motor_b1           (sm_b1              ),  
          .motor_b2           (sm_b2              )   

);


endmodule 


