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
////  UART2WB  Top Module                                         ////
////                                                              ////
////  Description                                                 ////
////    1. uart_core                                              ////
////    2. uart_msg_handler                                       ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 12th Sep 2022, Dinesh A                             ////
////          baud config auto detect for unknow system clock case////
////          implemented specific to unknown caravel system clk  ////
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

module uart2wb (  
        input wire                  arst_n          , //  sync reset
        input wire                  app_clk         , //  sys clock    

	// configuration control
       input wire                  cfg_auto_det     , // Auto Baud Config detect mode
       input wire                  cfg_tx_enable    , // Enable Transmit Path
       input wire                  cfg_rx_enable    , // Enable Received Path
       input wire                  cfg_stop_bit     , // 0 -> 1 Start , 1 -> 2 Stop Bits
       input wire [1:0]            cfg_pri_mod      , // priority mode, 0 -> nop, 1 -> Even, 2 -> Odd
       input wire [11:0]	    cfg_baud_16x     , // 16x Baud clock generation

    // Master Port
       output   wire                wbm_cyc_o        ,  // strobe/request
       output   wire                wbm_stb_o        ,  // strobe/request
       output   wire [31:0]         wbm_adr_o        ,  // address
       output   wire                wbm_we_o         ,  // write
       output   wire [31:0]         wbm_dat_o        ,  // data output
       output   wire [3:0]          wbm_sel_o        ,  // byte enable
       input    wire [31:0]         wbm_dat_i        ,  // data input
       input    wire                wbm_ack_i        ,  // acknowlegement
       input    wire                wbm_err_i        ,  // error

       // Status information
       output   wire               frm_error        , // framing error
       output   wire       	    par_error        , // par error

       output   wire               baud_clk_16x     , // 16x Baud clock

       // Line Interface
       input    wire              rxd               , // uart rxd
       output   wire              txd                 // uart txd

     );






//-------------------------------------
//---------------------------------------
// Control Unit interface
// --------------------------------------

wire  [31:0]       reg_addr        ; // Register Address
wire  [31:0]       reg_wdata       ; // Register Wdata
wire               reg_req         ; // Register Request
wire               reg_wr          ; // 1 -> write; 0 -> read
wire               reg_ack         ; // Register Ack
wire   [31:0]      reg_rdata       ;
//--------------------------------------
// TXD Path
// -------------------------------------
wire              tx_data_avail    ; // Indicate valid TXD Data 
wire [7:0]        tx_data          ; // TXD Data to be transmited
wire              tx_rd            ; // Indicate TXD Data Been Read


//--------------------------------------
// RXD Path
// -------------------------------------
wire         rx_ready              ; // Indicate Ready to accept the Read Data
wire [7:0]  rx_data                ; // RXD Data 
wire        rx_wr                  ; // Valid RXD Data

wire        line_reset_n           ;
wire        arst_ssn               ;
wire [11:0] auto_baud_16x          ;
wire        auto_tx_enb            ;
wire        auto_rx_enb            ;


wire        cfg_tx_enable_i = (cfg_auto_det) ?  auto_tx_enb: cfg_tx_enable;
wire        cfg_rx_enable_i = (cfg_auto_det) ?  auto_rx_enb: cfg_rx_enable;
wire [11:0] cfg_baud_16x_i  = (cfg_auto_det) ?  auto_baud_16x: cfg_baud_16x;


assign wbm_cyc_o  = wbm_stb_o;

reset_sync  u_arst_sync (
	      .scan_mode  (1'b0         ),
              .dclk       (app_clk      ), // Destination clock domain
	      .arst_n     (arst_n       ), // active low async reset
              .srst_n     (arst_ssn     )
          );


// Async App clock to Uart clock handling

async_reg_bus #(.AW(32), .DW(32),.BEW(4))
          u_async_reg_bus (
    // Initiator declartion
          .in_clk                    (baud_clk_16x),
          .in_reset_n                (line_reset_n),
       // Reg Bus Master
          // outputs
          .in_reg_rdata               (reg_rdata),
          .in_reg_ack                 (reg_ack),
          .in_reg_timeout             (),

          // Inputs
          .in_reg_cs                  (reg_req),
          .in_reg_addr                (reg_addr),
          .in_reg_wdata               (reg_wdata),
          .in_reg_wr                  (reg_wr),
          .in_reg_be                  (4'hF), // No byte enable based support

    // Target Declaration
          .out_clk                    (app_clk),
          .out_reset_n                (arst_ssn),
      // Reg Bus Slave
          // output
          .out_reg_cs                 (wbm_stb_o),
          .out_reg_addr               (wbm_adr_o),
          .out_reg_wdata              (wbm_dat_o),
          .out_reg_wr                 (wbm_we_o),
          .out_reg_be                 (wbm_sel_o),

          // Inputs
          .out_reg_rdata              (wbm_dat_i),
          .out_reg_ack                (wbm_ack_i)
   );



uart_auto_det u_aut_det (
         .mclk              (app_clk        ),
         .reset_n           (arst_ssn       ),
         .cfg_auto_det      (cfg_auto_det   ),
         .rxd               (rxd            ),

         .auto_baud_16x     (auto_baud_16x  ),
         .auto_tx_enb       (auto_tx_enb    ),
         .auto_rx_enb       (auto_rx_enb    )

        );


uart2_core u_core (  
          .arst_n            (arst_n) ,
          .app_clk           (app_clk) ,

	// configuration control
          .cfg_tx_enable      (cfg_tx_enable_i) , 
          .cfg_rx_enable      (cfg_rx_enable_i) , 
          .cfg_stop_bit       (cfg_stop_bit)  , 
          .cfg_pri_mod        (cfg_pri_mod)   , 
	  .cfg_baud_16x           (cfg_baud_16x_i)  ,

    // TXD Information
          .tx_data_avail      (tx_data_avail) ,
          .tx_rd              (tx_rd)         ,
          .tx_data            (tx_data)       ,
         

    // RXD Information
          .rx_ready           (rx_ready)      ,
          .rx_wr              (rx_wr)         ,
          .rx_data            (rx_data)       ,

       // Status information
          .frm_error          (frm_error) ,
	  .par_error          (par_error) ,

	  .baud_clk_16x       (baud_clk_16x) ,
	  .line_reset_n       (line_reset_n),

       // Line Interface
          .rxd                (rxd) ,
          .txd                (txd) 

     );



uart_msg_handler u_msg (  
          .reset_n            (line_reset_n ) ,
          .sys_clk            (baud_clk_16x ) ,
          .cfg_uart_enb       (cfg_tx_enable_i),


    // UART-TX Information
          .tx_data_avail      (tx_data_avail) ,
          .tx_rd              (tx_rd) ,
          .tx_data            (tx_data) ,
         

    // UART-RX Information
          .rx_ready           (rx_ready) ,
          .rx_wr              (rx_wr) ,
          .rx_data            (rx_data) ,

      // Towards Control Unit
          .reg_addr          (reg_addr),
          .reg_wr            (reg_wr),
          .reg_wdata         (reg_wdata),
          .reg_req           (reg_req),
          .reg_ack           (reg_ack),
	  .reg_rdata         (reg_rdata) 

     );

endmodule
