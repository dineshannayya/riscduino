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
////   Digital core.                                              ////
////   1. User Risc core is booted using  compiled code of        ////
////      user_risc_boot.c                                        ////
////   2. User Risc core uses Serial Flash and SDRAM to boot      ////
////   3. After successful boot, Risc core will check the UART    ////
////      RX Data, If it's available then it loop back the same   ////
////      data in uart tx                                         ////
////   4. Test bench send random 40 character towards User uart   ////
////      and expect same data to return back                     ////
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

`timescale 1 ns/1 ps

`include "sram_macros/sky130_sram_2kbyte_1rw1r_32x512_8.v"
`include "uart_agent.v"
`include "user_params.svh"
`include "qspis/qspis_if.sv"
`include "qspis/qspis_wb.sv"
`include "qspis/qspis_top.sv"


`define TB_HEX "user_qspis.hex"
`define TB_TOP  user_qspis_tb
module `TB_TOP;
parameter real CLK1_PERIOD  = 20; // 50Mhz
parameter real SYS_PERIOD  = 2;  // 500Mhz
parameter real CLK2_PERIOD = 2.5;
parameter real IPLL_PERIOD = 5.008;
parameter real XTAL_PERIOD = 6;

`include "user_tasks.sv"


reg      sys_clk;

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


integer i,j;


always #(SYS_PERIOD/2) sys_clk  <= (sys_clk === 1'b0);

	`ifdef WFDUMP
	   initial begin
	   	$dumpfile("simx.vcd");
	   	$dumpvars(0, `TB_TOP);
	   	$dumpvars(0, `TB_TOP.u_top);
	   	$dumpvars(0, `TB_TOP.u_top.u_wb_host);
	   	$dumpvars(2, `TB_TOP.u_top.u_riscv_top);
	   	$dumpvars(0, `TB_TOP.u_top.u_pinmux);
	   end
       `endif


initial
begin

 $value$plusargs("risc_core_id=%d", d_risc_id);

   init();

   uart_data_bit           = 2'b11;
   uart_stop_bits          = 0; // 0: 1 stop bit; 1: 2 stop bit;
   uart_stick_parity       = 0; // 1: force even parity
   uart_parity_en          = 0; // parity enable
   uart_even_odd_parity    = 1; // 0: odd parity; 1: even parity
   uart_divisor            = 15;// divided by n * 16
   uart_timeout            = 500;// wait time limit
   uart_fifo_enable        = 0;	// fifo mode disable

   $value$plusargs("risc_core_id=%d", d_risc_id);

   #200; // Wait for reset removal
   repeat (10) @(posedge clock);
   $display("Monitor: Standalone User Uart Test Started");
   
   // Remove Wb Reset
   //wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,'h1);

   // Enable UART Multi Functional Ports
   //wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_MUTI_FUNC,'h100);
   
   repeat (2) @(posedge clock);
   #1;
   // Remove all the reset
   if(d_risc_id == 0) begin
	$display("STATUS: Working with Risc core 0");
	//wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG0,'h11F);
   end else if(d_risc_id == 1) begin
	$display("STATUS: Working with Risc core 1");
	wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG0,'h21F);
   end else if(d_risc_id == 2) begin
	$display("STATUS: Working with Risc core 2");
	wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG0,'h41F);
   end else if(d_risc_id == 3) begin
	$display("STATUS: Working with Risc core 3");
	wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG0,'h81F);
   end


   repeat (100) @(posedge clock);  // wait for Processor Get Ready

   tb_uart.uart_init;
   //wb_user_core_write(`ADDR_SPACE_UART0+`UART_CTRL,{3'h0,2'b00,1'b1,1'b1,1'b1});  
   tb_uart.control_setup (uart_data_bit, uart_stop_bits, uart_parity_en, uart_even_odd_parity, 
	                          uart_stick_parity, uart_timeout, uart_divisor);


    wait_riscv_boot();
   
   
   for (i=0; i<40; i=i+1)
   	uart_write_data[i] = $random;
   
   
   
   fork
      begin
         for (i=0; i<40; i=i+1)
         begin
           $display ("\n... UART Agent Writing char %x ...", uart_write_data[i]);
            tb_uart.write_char (uart_write_data[i]);
         end
      end
   
      begin
         for (j=0; j<40; j=j+1)
         begin
           tb_uart.read_char_chk(uart_write_data[j]);
         end
      end
      join
   
      #100
      tb_uart.report_status(uart_rx_nu, uart_tx_nu);
   
      test_fail = 0;

      // Check 
      // if all the 40 byte transmitted
      // if all the 40 byte received
      // if no error 
      if(uart_tx_nu != 40) test_fail = 1;
      if(uart_rx_nu != 40) test_fail = 1;
      if(tb_uart.err_cnt != 0) test_fail = 1;

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


//------------------------------------------------------
//  Integrate the Serial flash with qurd support to
//  user core using the gpio pads
//  ----------------------------------------------------
tri [3:0]  flash_sdin;
wire [3:0]  flash_sdout;
wire        flash_oen;

   wire flash_clk = (io_oeb[28] == 1'b0) ? io_out[28]: 1'b0;
   wire flash_csb = (io_oeb[29] == 1'b0) ? io_out[29]: 1'b0;
   // Creating Pad Delay
   wire #1 io_oeb_33 = io_oeb[33];
   wire #1 io_oeb_34 = io_oeb[34];
   wire #1 io_oeb_35 = io_oeb[35];
   wire #1 io_oeb_36 = io_oeb[36];

   assign  flash_sdin[0] = (io_oeb_33== 1'b0 && flash_oen == 1'b1) ? io_out[33] : 1'bz;
   assign  flash_sdin[1] = (io_oeb_34== 1'b0 && flash_oen == 1'b1) ? io_out[34] : 1'bz;
   assign  flash_sdin[2] = (io_oeb_35== 1'b0 && flash_oen == 1'b1) ? io_out[35] : 1'bz;
   assign  flash_sdin[3] = (io_oeb_36== 1'b0 && flash_oen == 1'b1) ? io_out[36] : 1'bz;

   assign io_in[33] = (io_oeb[33] == 1'b1 && flash_oen == 1'b0) ? flash_sdout[0]: 1'b0;
   assign io_in[34] = (io_oeb[34] == 1'b1 && flash_oen == 1'b0) ? flash_sdout[1]: 1'b0;
   assign io_in[35] = (io_oeb[35] == 1'b1 && flash_oen == 1'b0) ? flash_sdout[2]: 1'b0;
   assign io_in[36] = (io_oeb[36] == 1'b1 && flash_oen == 1'b0) ? flash_sdout[3]: 1'b0;

/***
   // Quard flash
     s25fl256s #(.mem_file_name(`TB_HEX),
	         .otp_file_name("none"), 
                 .TimingModel("S25FL512SAGMFI010_F_30pF")) 
		 u_spi_flash_256mb
       (
           // Data Inputs/Outputs
       .SI      (flash_io0),
       .SO      (flash_io1),
       // Controls
       .SCK     (flash_clk),
       .CSNeg   (flash_csb),
       .WPNeg   (flash_io2),
       .HOLDNeg (flash_io3),
       .RSTNeg  (!wb_rst_i)

       );
***/


/*************************************
  Quad SPI Slave Intergartion
*************************************/

wire        wbm_qspis_cyc_o;
wire        wbm_qspis_stb_o;
wire [31:0] wbm_qspis_adr_o;
wire        wbm_qspis_we_o ;
wire [31:0] wbm_qspis_dat_o;
wire [3:0]  wbm_qspis_sel_o;
reg  [31:0] wbm_qspis_dat_i;
reg         wbm_qspis_ack_i;
wire        wbm_qspis_err_i;



qspis_top u_qspis (

	     .sys_clk         (sys_clk),
	     .rst_n           (!wb_rst_i),

         .sclk            (flash_clk),
         .ssn             (flash_csb),
         .sdin            (flash_sdin),
         .sdout           (flash_sdout),
         .sdout_oen       (flash_oen),

         // WB Master Port
         .wbm_cyc_o       (wbm_qspis_cyc_o ),  // strobe/request
         .wbm_stb_o       (wbm_qspis_stb_o ),  // strobe/request
         .wbm_adr_o       (wbm_qspis_adr_o ),  // address
         .wbm_we_o        (wbm_qspis_we_o  ),  // write
         .wbm_dat_o       (wbm_qspis_dat_o ),  // data output
         .wbm_sel_o       (wbm_qspis_sel_o ),  // byte enable
         .wbm_dat_i       (wbm_qspis_dat_i ),  // data input
         .wbm_ack_i       (wbm_qspis_ack_i ),  // acknowlegement
         .wbm_err_i       (wbm_qspis_err_i )   // error
    );


/******************************
  Program Memory Space
********************************/
reg [7:0] ProgamMem[0:16'hFFFF];

initial begin
    $readmemh(`TB_HEX,ProgamMem);
end

always @(posedge wb_rst_i or posedge sys_clk)
begin
   if(wb_rst_i == 1'b1) begin
      wbm_qspis_ack_i <= 1'b0;
   end else begin
      if(wbm_qspis_stb_o && wbm_qspis_we_o == 1'b0 && wbm_qspis_ack_i == 1'b0) begin
          wbm_qspis_dat_i =  {ProgamMem[wbm_qspis_adr_o+0], ProgamMem[wbm_qspis_adr_o+1],ProgamMem[wbm_qspis_adr_o+2],ProgamMem[wbm_qspis_adr_o+3]};
          wbm_qspis_ack_i <= 1'b1;
      end else begin
          wbm_qspis_ack_i <= 1'b0;
      end
   end
end



//---------------------------
//  UART Agent integration
// --------------------------
wire uart_txd,uart_rxd;

assign uart_txd   = (io_oeb[7] == 1'b0) ? io_out[7] : 1'b0;
assign io_in[6]   = (io_oeb[6] == 1'b1) ? uart_rxd  : 1'b0;
 
uart_agent tb_uart(
	.mclk                (clock              ),
	.txd                 (uart_rxd           ),
	.rxd                 (uart_txd           )
	);


endmodule
`default_nettype wire
