
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
////  integrated UART/I2C Master & USB1.1 Host                    ////
////                                                              ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  https://github.com/dineshannayya/yifive_r0.git              ////
////                                                              ////
////  Description: This module integarte Uart and I2C Master      ////
////   and USB 1.1 Host. Both these block share common two pins,  ////
////   effectly only one block active at time. This is due to     ////
////   top-level pin restriction.                                 ////
////                                                              ////
////    Pin  Maping    UART       I2C       USB                   ////
////    IO[1] -        TXD        SDA       DP                    ////
////    IO[0] -        RXD        SCL       DN                    ////
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

module uart_i2c_usb_top 

     (  

   input logic         uart_rstn  , // async reset
   input logic         i2c_rstn  , // async reset
   input logic         usb_rstn  , // async reset
   input logic         app_clk ,
   input logic         usb_clk ,   // 48Mhz usb clock
   input logic [1:0]   uart_i2c_usb_sel, // Uart Or I2C Or USB Interface Select

        // Reg Bus Interface Signal
   input logic         reg_cs,
   input logic         reg_wr,
   input logic [3:0]   reg_addr,
   input logic [31:0]  reg_wdata,
   input logic         reg_be,

        // Outputs
   output logic [31:0]  reg_rdata,
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

/////////////////////////////////////////////////////////
// usb interface
///////////////////////////////////////////////////////
logic             usb_in_dp                ;
logic             usb_in_dn                ;
             
logic             usb_out_dp               ;
logic             usb_out_dn               ;
logic             usb_out_tx_oen           ;

`define SEL_UART 2'b00
`define SEL_I2C  2'b01
`define SEL_USB  2'b10

assign  io_oeb[0]  =  (uart_i2c_usb_sel == `SEL_UART) ? 1'b1 : 
	              (uart_i2c_usb_sel == `SEL_I2C) ? scl_pad_oen_o : usb_out_tx_oen ; 
assign  uart_rxd   =  (uart_i2c_usb_sel == `SEL_UART) ? io_in[0]: 1'b0;
assign  scl_pad_i  =  (uart_i2c_usb_sel == `SEL_I2C) ? io_in[0]: 1'b0;
assign  usb_in_dn  =  (uart_i2c_usb_sel == `SEL_USB) ? io_in[0]: 1'b0;
assign  io_out[0]  =  (uart_i2c_usb_sel == `SEL_UART) ? 1'b0 : 
	              (uart_i2c_usb_sel == `SEL_I2C) ?  scl_pad_o :  usb_out_dn;


assign  io_oeb[1] =  (uart_i2c_usb_sel == `SEL_UART) ? 1'b0 : 
	             (uart_i2c_usb_sel == `SEL_I2C) ? sda_padoen_o : usb_out_tx_oen ; 
assign  io_out[1]  = (uart_i2c_usb_sel == `SEL_UART) ? uart_txd: 
	             (uart_i2c_usb_sel == `SEL_I2C) ? sda_pad_o : usb_out_dp;
assign  sda_pad_i =  (uart_i2c_usb_sel == `SEL_I2C) ? io_in[1] : 1'b0;
assign  usb_in_dp =  (uart_i2c_usb_sel == `SEL_USB) ? io_in[1] : 1'b0;


//----------------------------------------
//  Register Response Path Mux
//  --------------------------------------
logic [7:0]   reg_uart_rdata;
logic [7:0]   reg_i2c_rdata;
logic [31:0]   reg_usb_rdata;
logic         reg_uart_ack;
logic         reg_i2c_ack;
logic         reg_usb_ack;


assign reg_rdata = (uart_i2c_usb_sel == `SEL_UART) ? {24'h0,reg_uart_rdata} : 
	           (uart_i2c_usb_sel == `SEL_I2C) ? {24'h0,reg_i2c_rdata} : reg_usb_rdata;
assign reg_ack   = (uart_i2c_usb_sel == `SEL_UART) ? reg_uart_ack   : 
	           (uart_i2c_usb_sel == `SEL_I2C) ? reg_i2c_ack   : reg_usb_ack;

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
	.wb_dat_i      (reg_wdata[7:0] ), // databus input
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


usb1_host u_usb_host (
    .usb_clk_i      (usb_clk       ),
    .usb_rstn_i     (usb_rstn      ),

    // USB D+/D-
    .in_dp          (usb_in_dp     ),
    .in_dn          (usb_in_dn     ),

    .out_dp         (usb_out_dp    ),
    .out_dn         (usb_out_dn    ),
    .out_tx_oen     (usb_out_tx_oen),

    // Master Port
    .wbm_rst_n      (usb_rstn      ),  // Regular Reset signal
    .wbm_clk_i      (app_clk       ),  // System clock
    .wbm_stb_i      (reg_cs        ),  // strobe/request
    .wbm_adr_i      ({reg_addr[3:0],
                      2'b0}        ),  // address
    .wbm_we_i       (reg_wr        ),  // write
    .wbm_dat_i      (reg_wdata     ),  // data output
    .wbm_sel_i      (reg_be        ),  // byte enable
    .wbm_dat_o      (reg_usb_rdata ),  // data input
    .wbm_ack_o      (reg_usb_ack   ),  // acknowlegement
    .wbm_err_o      (              ),  // error

    // Outputs
    .usb_intr_o    (               )


    );


endmodule
