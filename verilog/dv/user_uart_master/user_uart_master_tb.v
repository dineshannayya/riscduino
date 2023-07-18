////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText:  2021 , Dinesh Annayya
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
// SPDX-FileContributor: Modified by Dinesh Annayya <dinesha@opencores.org>
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Standalone User validation Test bench                       ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  https://github.com/dineshannayya/yifive_r0.git              ////
////  http://www.opencores.org/cores/yifive/                      ////
////                                                              ////
////  Description                                                 ////
////   This is a standalone test bench to validate the            ////
////   Digital core using uart master i/f.                        ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 16th Feb 2021, Dinesh A                             ////
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

`default_nettype wire

`timescale 1 ns / 1 ps

`include "sram_macros/sky130_sram_2kbyte_1rw1r_32x512_8.v"
`include "uart_agent.v"
`include "user_params.svh"

`define TB_TOP  user_uart_master_tb

module `TB_TOP;

parameter real CLK1_PERIOD  = 25;
parameter real CLK2_PERIOD = 2.5;
parameter real IPLL_PERIOD = 5.008;
parameter real XTAL_PERIOD = 6;

`include "user_tasks.sv"

//----------------------------------
// Uart Configuration
// ---------------------------------
reg [1:0]      uart_data_bit        ;
reg	           uart_stop_bits       ; // 0: 1 stop bit; 1: 2 stop bit;
reg	           uart_stick_parity    ; // 1: force even parity
reg	           uart_parity_en       ; // parity enable
reg	           uart_even_odd_parity ; // 0: odd parity; 1: even parity

reg [7:0]      uart_data            ;
reg [15:0]     uart_divisor         ;	// divided by n * 16
reg [15:0]     uart_timeout         ;// wait time limit

reg [15:0]     uart_rx_nu           ;
reg [15:0]     uart_tx_nu           ;
reg [7:0]      uart_write_data [0:39];
reg 	       uart_fifo_enable     ;	// fifo mode disable

reg            flag;
reg  [15:0]    strap_in;


integer i,j;


`ifdef WFDUMP
initial begin
   $dumpfile("risc_boot.vcd");
   $dumpvars(1, `TB_TOP);
   $dumpvars(1, `TB_TOP.u_top.u_wb_host);
   $dumpvars(1, `TB_TOP.u_top.u_intercon);
   $dumpvars(1, `TB_TOP.u_top.u_pinmux);
end
`endif

initial
begin
   strap_in = 0;
   strap_in[`PSTRAP_UARTM_CFG] = 2'b00; // uart master config control - load from LA
   apply_strap(strap_in);

   uart_data_bit           = 2'b11;
   uart_stop_bits          = 1; // 0: 1 stop bit; 1: 2 stop bit;
   uart_stick_parity       = 0; // 1: force even parity
   uart_parity_en          = 0; // parity enable
   uart_even_odd_parity    = 1; // 0: odd parity; 1: even parity
   uart_divisor            = 15;// divided by n * 16
   uart_timeout            = 600;// wait time limit
   uart_fifo_enable        = 0;	// fifo mode disable

   // UPDATE the RTL UART MASTER
   la_data_in[1] = 1; //  Enable Transmit Path
   la_data_in[2] = 1; //  Enable Received Path
   la_data_in[3] = 1; //  Enable Received Path
   la_data_in[15:4] = ((uart_divisor+1)/16)-1; //  Divisor value
   la_data_in[17:16] = 2'b00; //  priority mode, 0 -> nop, 1 -> Even, 2 -> Odd

   #100;

   $display("Monitor: Standalone User Uart master Test Started");

   tb_master_uart.debug_mode = 0; // disable debug display
   tb_master_uart.uart_init;
   tb_master_uart.control_setup (uart_data_bit, uart_stop_bits, uart_parity_en, uart_even_odd_parity, 
	                          uart_stick_parity, uart_timeout, uart_divisor);


    tb_master_uart.write_char(8'h0A); // for uart baud auto detect purpose - New Line Character \n
   //$write ("\n(%t)Response:\n",$time);
   flag = 0;
   while(flag == 0)
   begin
        tb_master_uart.read_char(read_data,flag);
        $write ("%c",read_data);
   end


   // Remove Wb Reset
   //uartm_reg_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,'h1);

   repeat (2) @(posedge clock);
   #1;

   $display("Monitor: Writing  expected value");
   
   test_fail = 0;
   uartm_reg_write(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_0,32'h11223344);
   uartm_reg_write(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_1,32'h22334455);
   uartm_reg_write(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_2,32'h33445566);
   uartm_reg_write(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_3,32'h44556677);
   uartm_reg_write(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_4,32'h55667788);
   uartm_reg_write(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_5,32'h66778899);

   uartm_reg_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_0,32'h11223344);
   uartm_reg_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_1,32'h22334455);
   uartm_reg_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_2,32'h33445566);
   uartm_reg_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_3,32'h44556677);
   uartm_reg_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_4,32'h55667788);
   uartm_reg_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_5,32'h66778899);
   
   
   
   $display("###################################################");
   if(test_fail == 0) begin
      `ifdef GL
          $display("Monitor: %m (GL) Passed");
      `else
          $display("Monitor: %m (RTL) Passed");
      `endif
   end else begin
       `ifdef GL
           $display("Monitor: %m (GL) Failed");
       `else
           $display("Monitor: %m (RTL) Failed");
       `endif
    end
   $display("###################################################");
   #100
   $finish;
end


// SSPI Slave I/F
assign io_in[5]  = 1'b1; // RESET
assign io_in[21] = 1'b0; // CLOCK


//---------------------------
//  UART Agent integration
// --------------------------
wire uart_txd,uart_rxd;

assign uart_txd   = (io_oeb[7] == 1'b0) ? io_out[7] : 1'b0;
assign io_in[6]   = (io_oeb[6] == 1'b1) ? uart_rxd  : 1'b0;
 
uart_agent tb_master_uart(
	.mclk                (clock              ),
	.txd                 (uart_rxd           ),
	.rxd                 (uart_txd           )
	);



`include "uart_master_tasks.sv"
endmodule
`default_nettype wire
