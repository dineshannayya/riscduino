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

module user_uart_master_tb;

reg            clock         ;
reg            wb_rst_i      ;
reg            power1, power2;
reg            power3, power4;

reg            wbd_ext_cyc_i;  // strobe/request
reg            wbd_ext_stb_i;  // strobe/request
reg [31:0]     wbd_ext_adr_i;  // address
reg            wbd_ext_we_i;  // write
reg [31:0]     wbd_ext_dat_i;  // data output
reg [3:0]      wbd_ext_sel_i;  // byte enable

wire [31:0]    wbd_ext_dat_o;  // data input
wire           wbd_ext_ack_o;  // acknowlegement
wire           wbd_ext_err_o;  // error

// User I/O
wire [37:0]    io_oeb        ;
wire [37:0]    io_out        ;
wire [37:0]    io_in         ;

wire [37:0]    mprj_io       ;
wire [7:0]     mprj_io_0     ;
reg            test_fail     ;
reg [31:0]     read_data     ;
//----------------------------------
// Uart Configuration
// ---------------------------------
reg [1:0]      uart_data_bit        ;
reg	       uart_stop_bits       ; // 0: 1 stop bit; 1: 2 stop bit;
reg	       uart_stick_parity    ; // 1: force even parity
reg	       uart_parity_en       ; // parity enable
reg	       uart_even_odd_parity ; // 0: odd parity; 1: even parity

reg [7:0]      uart_data            ;
reg [15:0]     uart_divisor         ;	// divided by n * 16
reg [15:0]     uart_timeout         ;// wait time limit

reg [15:0]     uart_rx_nu           ;
reg [15:0]     uart_tx_nu           ;
reg [7:0]      uart_write_data [0:39];
reg 	       uart_fifo_enable     ;	// fifo mode disable

reg  [127:0]   la_data_in;
reg       flag;


integer i,j;

	// External clock is used by default.  Make this artificially fast for the
	// simulation.  Normally this would be a slow clock and the digital PLL
	// would be the fast clock.

	always #12.5 clock <= (clock === 1'b0);

	initial begin
		clock = 0;
		la_data_in = 1;
	end

	`ifdef WFDUMP
	   initial begin
	   	$dumpfile("risc_boot.vcd");
	   	$dumpvars(0, user_uart_master_tb);
	   end
       `endif

	initial begin
		clock = 0;
                wbd_ext_cyc_i ='h0;  // strobe/request
                wbd_ext_stb_i ='h0;  // strobe/request
                wbd_ext_adr_i ='h0;  // address
                wbd_ext_we_i  ='h0;  // write
                wbd_ext_dat_i ='h0;  // data output
                wbd_ext_sel_i ='h0;  // byte enable
	end
initial
begin
   wb_rst_i <= 1'b1;
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
   wb_rst_i <= 1'b0;	    	// Release reset

   $display("Monitor: Standalone User Uart master Test Started");

   tb_master_uart.debug_mode = 0; // disable debug display
   tb_master_uart.uart_init;
   tb_master_uart.control_setup (uart_data_bit, uart_stop_bits, uart_parity_en, uart_even_odd_parity, 
	                          uart_stick_parity, uart_timeout, uart_divisor);

   //$write ("\n(%t)Response:\n",$time);
   flag = 0;
   while(flag == 0)
   begin
        tb_master_uart.read_char(read_data,flag);
        $write ("%c",read_data);
   end



   // Remove Wb Reset
   uartm_reg_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,'h1);

   repeat (2) @(posedge clock);
   #1;

   $display("Monitor: Writing  expected value");
   
   test_fail = 0;
   uartm_reg_write(`ADDR_SPACE_PINMUX+`PINMUX_SOFT_REG_1,32'h11223344);
   uartm_reg_write(`ADDR_SPACE_PINMUX+`PINMUX_SOFT_REG_2,32'h22334455);
   uartm_reg_write(`ADDR_SPACE_PINMUX+`PINMUX_SOFT_REG_3,32'h33445566);
   uartm_reg_write(`ADDR_SPACE_PINMUX+`PINMUX_SOFT_REG_4,32'h44556677);
   uartm_reg_write(`ADDR_SPACE_PINMUX+`PINMUX_SOFT_REG_5,32'h55667788);
   uartm_reg_write(`ADDR_SPACE_PINMUX+`PINMUX_SOFT_REG_6,32'h66778899);

   uartm_reg_read_check(`ADDR_SPACE_PINMUX+`PINMUX_SOFT_REG_1,32'h11223344);
   uartm_reg_read_check(`ADDR_SPACE_PINMUX+`PINMUX_SOFT_REG_2,32'h22334455);
   uartm_reg_read_check(`ADDR_SPACE_PINMUX+`PINMUX_SOFT_REG_3,32'h33445566);
   uartm_reg_read_check(`ADDR_SPACE_PINMUX+`PINMUX_SOFT_REG_4,32'h44556677);
   uartm_reg_read_check(`ADDR_SPACE_PINMUX+`PINMUX_SOFT_REG_5,32'h55667788);
   uartm_reg_read_check(`ADDR_SPACE_PINMUX+`PINMUX_SOFT_REG_6,32'h66778899);
   
   
   
   $display("###################################################");
   if(test_fail == 0) begin
      `ifdef GL
          $display("Monitor: Standalone User UART Master (GL) Passed");
      `else
          $display("Monitor: Standalone User Uart Master (RTL) Passed");
      `endif
   end else begin
       `ifdef GL
           $display("Monitor: Standalone User Uart Master (GL) Failed");
       `else
           $display("Monitor: Standalone User Uart Master (RTL) Failed");
       `endif
    end
   $display("###################################################");
   #100
   $finish;
end


wire USER_VDD1V8 = 1'b1;
wire VSS = 1'b0;


user_project_wrapper u_top(
`ifdef USE_POWER_PINS
    .vccd1(USER_VDD1V8),	// User area 1 1.8V supply
    .vssd1(VSS),	// User area 1 digital ground
`endif
    .wb_clk_i        (clock),  // System clock
    .user_clock2     (1'b1),  // Real-time clock
    .wb_rst_i        (wb_rst_i),  // Regular Reset signal

    .wbs_cyc_i   (wbd_ext_cyc_i),  // strobe/request
    .wbs_stb_i   (wbd_ext_stb_i),  // strobe/request
    .wbs_adr_i   (wbd_ext_adr_i),  // address
    .wbs_we_i    (wbd_ext_we_i),  // write
    .wbs_dat_i   (wbd_ext_dat_i),  // data output
    .wbs_sel_i   (wbd_ext_sel_i),  // byte enable

    .wbs_dat_o   (wbd_ext_dat_o),  // data input
    .wbs_ack_o   (wbd_ext_ack_o),  // acknowlegement

 
    // Logic Analyzer Signals
    .la_data_in      (la_data_in) ,
    .la_data_out     (),
    .la_oenb         ('0),
 

    // IOs
    .io_in          (io_in)  ,
    .io_out         (io_out) ,
    .io_oeb         (io_oeb) ,

    .user_irq       () 

);

`ifndef GL // Drive Power for Hold Fix Buf
    // All standard cell need power hook-up for functionality work
    initial begin
    end
`endif    


//---------------------------
//  UART Agent integration
// --------------------------
wire uart_txd,uart_rxd;

assign uart_txd   = io_out[35];
assign io_in[34]  = uart_rxd ;
 
uart_agent tb_master_uart(
	.mclk                (clock              ),
	.txd                 (uart_rxd           ),
	.rxd                 (uart_txd           )
	);



`include "uart_master_tasks.sv"
endmodule
`default_nettype wire
