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
////  Tubo 8051 cores UART Interface Module                       ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
module uart2_core (  
        input wire       arst_n ,     // Async reset
        input wire       app_clk ,    // Application clock
    

	// configuration control
        input wire       cfg_tx_enable  , // Enable Transmit Path
        input wire       cfg_rx_enable  , // Enable Received Path
        input wire       cfg_stop_bit   , // 0 -> 1 Start , 1 -> 2 Stop Bits
        input wire [1:0] cfg_pri_mod    , // priority mode, 0 -> nop, 1 -> Even, 2 -> Odd
	input wire [11:0]cfg_baud_16x   , // 16x baud rate control

    // TX PATH Information
        input  wire      tx_data_avail  ,   // Indicate valid TXD Data
        output wire     tx_rd          ,   // Indicate TXD Data Been Read
        input  wire [7:0]tx_data        ,   // Indicate TXD Data Been 
         

    // RXD Information
        input  wire       rx_ready       ,  // Indicate Ready to accept the Read Data
        output wire      rx_wr          ,  // Valid RXD Data
        output wire [7:0]rx_data        ,  // RXD Data

       // Status information
        output wire      frm_error      ,  // framing error
	output wire      par_error      ,  // par error

	output wire      baud_clk_16x   ,  // 16x Baud clock
	output wire      line_reset_n   ,  // Reset sync to 16x Baud clock

       // Line Interface
        input  wire       rxd            ,  // uart rxd
        output wire      txd               // uart txd

     );



//---------------------------------
// Global Dec
// ---------------------------------

// Wire Declaration

wire [1  : 0]   error_ind          ;
wire            si_ss              ;

// OpenSource CTS tool does not work with buffer as source point
// changed buf to max with select tied=0
//ctech_clk_buf u_lineclk_buf  (.A(line_clk_16x_in),  .X(line_clk_16x));
wire line_clk_16x;
ctech_mux2x1 u_uart_clk  (.A0(line_clk_16x), .A1(1'b0), .S(1'b0), .X(baud_clk_16x));

// 16x Baud clock generation
// Example: to generate 19200 Baud clock from 50Mhz Link clock
//    50 * 1000 * 1000 / (2 + cfg_baud_16x) = 19200 * 16
//    cfg_baud_16x = 0xA0 (160)

clk_ctl #(11) u_clk_ctl (
   // Outputs
       .clk_o          (line_clk_16x),

   // Inputs
       .mclk           (app_clk),
       .reset_n        (arst_n), 
       .clk_div_ratio  (cfg_baud_16x)
   );

   
//###################################
// Line Reset Synchronization
//###################################
reset_sync  u_line_rst (
	      .scan_mode  (1'b0           ),
              .dclk       (baud_clk_16x   ), // Destination clock domain
	      .arst_n     (arst_n         ), // active low async reset
              .srst_n     (line_reset_n   )
          );



uart_txfsm u_txfsm (
               . reset_n           ( line_reset_n      ),
               . baud_clk_16x      ( baud_clk_16x      ),

               . cfg_tx_enable     ( cfg_tx_enable     ),
               . cfg_stop_bit      ( cfg_stop_bit      ),
               . cfg_pri_mod       ( cfg_pri_mod       ),

       // FIFO control signal
               . fifo_empty        ( !tx_data_avail    ),
               . fifo_rd           ( tx_rd             ),
               . fifo_data         ( tx_data           ),

          // Line Interface
               . so                ( txd               )
          );


uart_rxfsm u_rxfsm (
               . reset_n           (  line_reset_n     ),
               . baud_clk_16x      (  baud_clk_16x     ) ,

               . cfg_rx_enable     (  cfg_rx_enable    ),
               . cfg_stop_bit      (  cfg_stop_bit     ),
               . cfg_pri_mod       (  cfg_pri_mod      ),

               . error_ind         (  error_ind        ),

       // FIFO control signal
               .  fifo_aval        ( rx_ready          ),
               .  fifo_wr          ( rx_wr             ),
               .  fifo_data        ( rx_data           ),

          // Line Interface
               .  si               (si_ss              )
          );

// Double Sync RXD
double_sync_low   u_rxd_sync (
               .in_data           (rxd                ),
               .out_clk           (baud_clk_16x       ),
               .out_rst_n         (line_reset_n       ),
               .out_data          (si_ss              ) 
          );


assign   frm_error          = (error_ind == 2'b01);
assign   par_error          = (error_ind == 2'b10);



endmodule
