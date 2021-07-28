
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
////  UART CORE with TX/RX 16 Byte Buffer                         ////
////  I2C Master                                                  ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  https://github.com/dineshannayya/yifive_r0.git              ////
////                                                              ////
////  Description: This module integarte Uart and I2C Master      ////
////    Both these block share common two pins, effectly only     ////
////    one block active at time. This is due to top-level pin    ////
////    restriction.                                              ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
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

module uart_i2c_top 

     (  

   input logic         uart_rstn  , // async reset
   input logic         i2c_rstn  , // async reset
   input logic         app_clk ,
   input logic         uart_i2c_sel, // Uart Or I2C Interface Select

        // Reg Bus Interface Signal
   input logic         reg_cs,
   input logic         reg_wr,
   input logic [3:0]   reg_addr,
   input logic [7:0]   reg_wdata,
   input logic         reg_be,

        // Outputs
   output logic [7:0]  reg_rdata,
   output logic        reg_ack,

       // Pad Control
   input  logic [1:0]  io_in,
   output logic [1:0]  io_out,
   output logic [1:0]  io_oeb

     );

/////////////////////////////////////////////////////////
// uart interface
///////////////////////////////////////////////////////

logic             uart_rxd                  ; 
logic             uart_txd                  ;
/////////////////////////////////////////////////////////
// i2c interface
///////////////////////////////////////////////////////
logic             scl_pad_i                 ; // SCL-line input
logic             scl_pad_o                 ; // SCL-line output (always 1'b0)
logic             scl_pad_oen_o             ; // SCL-line output enable (active low)

logic             sda_pad_i                 ; // SDA-line input
logic             sda_pad_o                 ; // SDA-line output (always 1'b0)
logic             sda_padoen_o              ; // SDA-line output enable (active low)



assign  io_oeb[0]  =  (uart_i2c_sel == 0) ? 1'b1 : scl_pad_oen_o ; // Uart RX
assign  uart_rxd   =  (uart_i2c_sel == 0) ? io_in[0]: 1'b0;
assign  scl_pad_i  =  (uart_i2c_sel == 1) ? io_in[0]: 1'b0;
assign  io_out[0]  =  (uart_i2c_sel == 0) ? 1'b0 : scl_pad_o ;

assign  io_oeb[1] =  (uart_i2c_sel == 0) ? 1'b0 : sda_padoen_o ; // Uart TX & I2C Clock
assign  io_out[1]  = (uart_i2c_sel == 0) ? uart_txd: sda_pad_o ;
assign  sda_pad_i =  (uart_i2c_sel == 1) ? io_in[1] : 1'b0;

logic [7:0]   reg_uart_rdata;
logic [7:0]   reg_i2c_rdata;
logic         reg_uart_ack;
logic         reg_i2c_ack;


assign reg_rdata = (uart_i2c_sel == 0) ? reg_uart_rdata : reg_i2c_rdata;
assign reg_ack   = (uart_i2c_sel == 0) ? reg_uart_ack   : reg_i2c_ack;

uart_core  u_uart_core (  

        .arst_n      (uart_rstn        ), // async reset
        .app_clk     (app_clk          ),

        // Reg Bus Interface Signal
        .reg_cs      (reg_cs           ),
        .reg_wr      (reg_wr           ),
        .reg_addr    (reg_addr[3:0]    ),
        .reg_wdata   (reg_wdata[7:0]   ),
        .reg_be      (reg_be           ),

        // Outputs
        .reg_rdata   (reg_uart_rdata[7:0]),
        .reg_ack     (reg_uart_ack     ),

            // Pad Control
        .rxd          (uart_rxd        ),
        .txd          (uart_txd        )
     );

i2cm_top  u_i2cm (
	// wishbone signals
	.wb_clk_i      (app_clk        ), // master clock input
	.sresetn       (1'b1           ), // synchronous reset
	.aresetn       (i2c_rstn       ), // asynchronous reset
	.wb_adr_i      (reg_addr[2:0]  ), // lower address bits
	.wb_dat_i      (reg_wdata      ), // databus input
	.wb_dat_o      (reg_i2c_rdata  ), // databus output
	.wb_we_i       (reg_wr         ), // write enable input
	.wb_stb_i      (reg_cs         ), // stobe/core select signal
	.wb_cyc_i      (reg_cs         ), // valid bus cycle input
	.wb_ack_o      (reg_i2c_ack    ), // bus cycle acknowledge output
	.wb_inta_o     (               ), // interrupt request signal output

	// I2C signals
	// i2c clock line
	.scl_pad_i     (scl_pad_i      ), // SCL-line input
	.scl_pad_o     (scl_pad_o      ), // SCL-line output (always 1'b0)
	.scl_padoen_o  (scl_pad_oen_o  ), // SCL-line output enable (active low)

	// i2c data line
	.sda_pad_i     (sda_pad_i      ), // SDA-line input
	.sda_pad_o     (sda_pad_o      ), // SDA-line output (always 1'b0)
	.sda_padoen_o  (sda_padoen_o   )  // SDA-line output enable (active low)

         );

endmodule
