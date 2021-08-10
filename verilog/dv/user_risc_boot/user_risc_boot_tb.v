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
////   3. After successful boot, Risc core will  write signature  ////
////      in to  user register from 0x3000_0018 to 0x3000_002C    ////
////   4. Through the External Wishbone Interface we read back    ////
////       and validate the user register to declared pass fail   ////
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

`timescale 1 ns / 1 ns

`include "s25fl256s.sv"
`include "uprj_netlists.v"
`include "mt48lc8m8a2.v"

module user_risc_boot_tb;
	reg clock;
	reg wb_rst_i;
	reg power1, power2;
	reg power3, power4;

        reg        wbd_ext_cyc_i;  // strobe/request
        reg        wbd_ext_stb_i;  // strobe/request
        reg [31:0] wbd_ext_adr_i;  // address
        reg        wbd_ext_we_i;  // write
        reg [31:0] wbd_ext_dat_i;  // data output
        reg [3:0]  wbd_ext_sel_i;  // byte enable

        wire [31:0] wbd_ext_dat_o;  // data input
        wire        wbd_ext_ack_o;  // acknowlegement
        wire        wbd_ext_err_o;  // error

	// User I/O
	wire [37:0] io_oeb;
	wire [37:0] io_out;
	wire [37:0] io_in;

	wire gpio;
	wire [37:0] mprj_io;
	wire [7:0] mprj_io_0;
	reg         test_fail;
	reg [31:0] read_data;



	// External clock is used by default.  Make this artificially fast for the
	// simulation.  Normally this would be a slow clock and the digital PLL
	// would be the fast clock.

	always #12.5 clock <= (clock === 1'b0);

	initial begin
		clock = 0;
                wbd_ext_cyc_i ='h0;  // strobe/request
                wbd_ext_stb_i ='h0;  // strobe/request
                wbd_ext_adr_i ='h0;  // address
                wbd_ext_we_i  ='h0;  // write
                wbd_ext_dat_i ='h0;  // data output
                wbd_ext_sel_i ='h0;  // byte enable
	end

	`ifdef WFDUMP
	   initial begin
	   	$dumpfile("risc_boot.vcd");
	   	$dumpvars(2, user_risc_boot_tb);
	   end
       `endif

	initial begin

		#200; // Wait for reset removal
	        repeat (10) @(posedge clock);
		$display("Monitor: Standalone User Risc Boot Test Started");

		   // Remove Wb Reset
		   wb_user_core_write('h3080_0000,'h1);

		#1;
		//------------ SDRAM Config - 2
                wb_user_core_write('h3000_0014,'h100_019E);

	        repeat (2) @(posedge clock);
		#1;
		//------------ SDRAM Config - 1
                wb_user_core_write('h3000_0010,'h2F17_2242);

	        repeat (2) @(posedge clock);
		#1;
		// Remove all the reset
                wb_user_core_write('h3080_0000,'hF);


		// Repeat cycles of 1000 clock edges as needed to complete testbench
		repeat (30) begin
			repeat (1000) @(posedge clock);
			// $display("+1000 cycles");
		end


		$display("Monitor: Reading Back the expected value");
		// User RISC core expect to write these value in global
		// register, read back and decide on pass fail
		// 0x30000018  = 0x11223344; 
                // 0x3000001C  = 0x22334455; 
                // 0x30000020  = 0x33445566; 
                // 0x30000024  = 0x44556677; 
                // 0x30000028 = 0x55667788; 
                // 0x3000002C = 0x66778899; 

                test_fail = 0;
		wb_user_core_read(32'h30000018,read_data);
		if(read_data != 32'h11223344) test_fail = 1;

		wb_user_core_read(32'h3000001C,read_data);
		if(read_data != 32'h22334455) test_fail = 1;

		wb_user_core_read(32'h30000020,read_data);
	        if(read_data != 32'h33445566) test_fail = 1;

		wb_user_core_read(32'h30000024,read_data);
                if(read_data!= 32'h44556677) test_fail = 1;

		wb_user_core_read(32'h30000028,read_data);
                if(read_data!= 32'h55667788) test_fail = 1;

		wb_user_core_read(32'h3000002C,read_data) ;
	        if(read_data != 32'h66778899) test_fail = 1;

	   
	    	$display("###################################################");
          	if(test_fail == 0) begin
		   `ifdef GL
	    	       $display("Monitor: Standalone User Risc Boot (GL) Passed");
		   `else
		       $display("Monitor: Standalone User Risc Boot (RTL) Passed");
		   `endif
	        end else begin
		    `ifdef GL
	    	        $display("Monitor: Standalone User Risc Boot (GL) Failed");
		    `else
		        $display("Monitor: Standalone User Risc Boot (RTL) Failed");
		    `endif
		 end
	    	$display("###################################################");
	    $finish;
	end

	initial begin
		wb_rst_i <= 1'b1;
		#100;
		wb_rst_i <= 1'b0;	    	// Release reset
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
    .la_data_in      ('0) ,
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
	force u_top.u_spi_master.u_delay1_sdio0.VPWR =USER_VDD1V8;
	force u_top.u_spi_master.u_delay1_sdio0.VPB  =USER_VDD1V8;
	force u_top.u_spi_master.u_delay1_sdio0.VGND =VSS;
	force u_top.u_spi_master.u_delay1_sdio0.VNB = VSS;
	force u_top.u_spi_master.u_delay2_sdio0.VPWR =USER_VDD1V8;
	force u_top.u_spi_master.u_delay2_sdio0.VPB  =USER_VDD1V8;
	force u_top.u_spi_master.u_delay2_sdio0.VGND =VSS;
	force u_top.u_spi_master.u_delay2_sdio0.VNB = VSS;
	force u_top.u_spi_master.u_buf_sdio0.VPWR   =USER_VDD1V8;
	force u_top.u_spi_master.u_buf_sdio0.VPB    =USER_VDD1V8;
	force u_top.u_spi_master.u_buf_sdio0.VGND   =VSS;
	force u_top.u_spi_master.u_buf_sdio0.VNB    =VSS;

	force u_top.u_spi_master.u_delay1_sdio1.VPWR =USER_VDD1V8;
	force u_top.u_spi_master.u_delay1_sdio1.VPB  =USER_VDD1V8;
	force u_top.u_spi_master.u_delay1_sdio1.VGND =VSS;
	force u_top.u_spi_master.u_delay1_sdio1.VNB = VSS;
	force u_top.u_spi_master.u_delay2_sdio1.VPWR =USER_VDD1V8;
	force u_top.u_spi_master.u_delay2_sdio1.VPB  =USER_VDD1V8;
	force u_top.u_spi_master.u_delay2_sdio1.VGND =VSS;
	force u_top.u_spi_master.u_delay2_sdio1.VNB = VSS;
	force u_top.u_spi_master.u_buf_sdio1.VPWR   =USER_VDD1V8;
	force u_top.u_spi_master.u_buf_sdio1.VPB    =USER_VDD1V8;
	force u_top.u_spi_master.u_buf_sdio1.VGND   =VSS;
	force u_top.u_spi_master.u_buf_sdio1.VNB    =VSS;

	force u_top.u_spi_master.u_delay1_sdio2.VPWR =USER_VDD1V8;
	force u_top.u_spi_master.u_delay1_sdio2.VPB  =USER_VDD1V8;
	force u_top.u_spi_master.u_delay1_sdio2.VGND =VSS;
	force u_top.u_spi_master.u_delay1_sdio2.VNB = VSS;
	force u_top.u_spi_master.u_delay2_sdio2.VPWR =USER_VDD1V8;
	force u_top.u_spi_master.u_delay2_sdio2.VPB  =USER_VDD1V8;
	force u_top.u_spi_master.u_delay2_sdio2.VGND =VSS;
	force u_top.u_spi_master.u_delay2_sdio2.VNB = VSS;
	force u_top.u_spi_master.u_buf_sdio2.VPWR   =USER_VDD1V8;
	force u_top.u_spi_master.u_buf_sdio2.VPB    =USER_VDD1V8;
	force u_top.u_spi_master.u_buf_sdio2.VGND   =VSS;
	force u_top.u_spi_master.u_buf_sdio2.VNB    =VSS;

	force u_top.u_spi_master.u_delay1_sdio3.VPWR =USER_VDD1V8;
	force u_top.u_spi_master.u_delay1_sdio3.VPB  =USER_VDD1V8;
	force u_top.u_spi_master.u_delay1_sdio3.VGND =VSS;
	force u_top.u_spi_master.u_delay1_sdio3.VNB = VSS;
	force u_top.u_spi_master.u_delay2_sdio3.VPWR =USER_VDD1V8;
	force u_top.u_spi_master.u_delay2_sdio3.VPB  =USER_VDD1V8;
	force u_top.u_spi_master.u_delay2_sdio3.VGND =VSS;
	force u_top.u_spi_master.u_delay2_sdio3.VNB = VSS;
	force u_top.u_spi_master.u_buf_sdio3.VPWR   =USER_VDD1V8;
	force u_top.u_spi_master.u_buf_sdio3.VPB    =USER_VDD1V8;
	force u_top.u_spi_master.u_buf_sdio3.VGND   =VSS;
	force u_top.u_spi_master.u_buf_sdio3.VNB    =VSS;
          
	force u_top.u_uart_i2c_usb.u_uart_core.u_lineclk_buf.VPWR =USER_VDD1V8;
	force u_top.u_uart_i2c_usb.u_uart_core.u_lineclk_buf.VPB  =USER_VDD1V8;
	force u_top.u_uart_i2c_usb.u_uart_core.u_lineclk_buf.VGND =VSS;
	force u_top.u_uart_i2c_usb.u_uart_core.u_lineclk_buf.VNB = VSS;

	force u_top.u_wb_host.u_buf_wb_rst.VPWR =USER_VDD1V8;
	force u_top.u_wb_host.u_buf_wb_rst.VPB  =USER_VDD1V8;
	force u_top.u_wb_host.u_buf_wb_rst.VGND =VSS;
	force u_top.u_wb_host.u_buf_wb_rst.VNB = VSS;

	force u_top.u_wb_host.u_buf_cpu_rst.VPWR =USER_VDD1V8;
	force u_top.u_wb_host.u_buf_cpu_rst.VPB  =USER_VDD1V8;
	force u_top.u_wb_host.u_buf_cpu_rst.VGND =VSS;
	force u_top.u_wb_host.u_buf_cpu_rst.VNB = VSS;

	force u_top.u_wb_host.u_buf_spi_rst.VPWR =USER_VDD1V8;
	force u_top.u_wb_host.u_buf_spi_rst.VPB  =USER_VDD1V8;
	force u_top.u_wb_host.u_buf_spi_rst.VGND =VSS;
	force u_top.u_wb_host.u_buf_spi_rst.VNB = VSS;

	force u_top.u_wb_host.u_buf_sdram_rst.VPWR =USER_VDD1V8;
	force u_top.u_wb_host.u_buf_sdram_rst.VPB  =USER_VDD1V8;
	force u_top.u_wb_host.u_buf_sdram_rst.VGND =VSS;
	force u_top.u_wb_host.u_buf_sdram_rst.VNB = VSS;

	force u_top.u_wb_host.u_buf_uart_rst.VPWR =USER_VDD1V8;
	force u_top.u_wb_host.u_buf_uart_rst.VPB  =USER_VDD1V8;
	force u_top.u_wb_host.u_buf_uart_rst.VGND =VSS;
	force u_top.u_wb_host.u_buf_uart_rst.VNB = VSS;

	force u_top.u_wb_host.u_buf_i2cm_rst.VPWR =USER_VDD1V8;
	force u_top.u_wb_host.u_buf_i2cm_rst.VPB  =USER_VDD1V8;
	force u_top.u_wb_host.u_buf_i2cm_rst.VGND =VSS;
	force u_top.u_wb_host.u_buf_i2cm_rst.VNB = VSS;

	force u_top.u_wb_host.u_buf_usb_rst.VPWR =USER_VDD1V8;
	force u_top.u_wb_host.u_buf_usb_rst.VPB  =USER_VDD1V8;
	force u_top.u_wb_host.u_buf_usb_rst.VGND =VSS;
	force u_top.u_wb_host.u_buf_usb_rst.VNB = VSS;

	force u_top.u_wb_host.u_clkbuf_sdram.VPWR =USER_VDD1V8;
	force u_top.u_wb_host.u_clkbuf_sdram.VPB  =USER_VDD1V8;
	force u_top.u_wb_host.u_clkbuf_sdram.VGND =VSS;
	force u_top.u_wb_host.u_clkbuf_sdram.VNB = VSS;

	force u_top.u_wb_host.u_clkbuf_cpu.VPWR =USER_VDD1V8;
	force u_top.u_wb_host.u_clkbuf_cpu.VPB  =USER_VDD1V8;
	force u_top.u_wb_host.u_clkbuf_cpu.VGND =VSS;
	force u_top.u_wb_host.u_clkbuf_cpu.VNB = VSS;

	force u_top.u_wb_host.u_clkbuf_rtc.VPWR =USER_VDD1V8;
	force u_top.u_wb_host.u_clkbuf_rtc.VPB  =USER_VDD1V8;
	force u_top.u_wb_host.u_clkbuf_rtc.VGND =VSS;
	force u_top.u_wb_host.u_clkbuf_rtc.VNB = VSS;

	force u_top.u_wb_host.u_clkbuf_usb.VPWR =USER_VDD1V8;
	force u_top.u_wb_host.u_clkbuf_usb.VPB  =USER_VDD1V8;
	force u_top.u_wb_host.u_clkbuf_usb.VGND =VSS;
	force u_top.u_wb_host.u_clkbuf_usb.VNB = VSS;
    end
`endif    

//------------------------------------------------------
//  Integrate the Serial flash with qurd support to
//  user core using the gpio pads
//  ----------------------------------------------------

   wire flash_clk = io_out[30];
   wire flash_csb = io_out[31];
   // Creating Pad Delay
   wire #1 io_oeb_32 = io_oeb[32];
   wire #1 io_oeb_33 = io_oeb[33];
   wire #1 io_oeb_34 = io_oeb[34];
   wire #1 io_oeb_35 = io_oeb[35];
   tri  flash_io0 = (io_oeb_32== 1'b0) ? io_out[32] : 1'bz;
   tri  flash_io1 = (io_oeb_33== 1'b0) ? io_out[33] : 1'bz;
   tri  flash_io2 = (io_oeb_34== 1'b0) ? io_out[34] : 1'bz;
   tri  flash_io3 = (io_oeb_35== 1'b0) ? io_out[35] : 1'bz;

   assign io_in[32] = flash_io0;
   assign io_in[33] = flash_io1;
   assign io_in[34] = flash_io2;
   assign io_in[35] = flash_io3;


   // Quard flash
     s25fl256s #(.mem_file_name("user_risc_boot.hex"),
	         .otp_file_name("none"),
                 .TimingModel("S25FL512SAGMFI010_F_30pF")) 
		 u_spi_flash_256mb (
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



//------------------------------------------------
// Integrate the SDRAM 8 BIT Memory
// -----------------------------------------------

wire [7:0]    Dq                 ; // SDRAM Read/Write Data Bus
wire [0:0]    sdr_dqm            ; // SDRAM DATA Mask
wire [1:0]    sdr_ba             ; // SDRAM Bank Select
wire [12:0]   sdr_addr           ; // SDRAM ADRESS
wire          sdr_cs_n           ; // chip select
wire          sdr_cke            ; // clock gate
wire          sdr_ras_n          ; // ras
wire          sdr_cas_n          ; // cas
wire          sdr_we_n           ; // write enable        
wire          sdram_clk         ;      

assign  Dq[7:0]           =  (io_oeb[7:0] == 8'h0) ? io_out [7:0] : 8'hZZ;
assign  sdr_addr[12:0]    =    io_out [20:8]     ;
assign  sdr_ba[1:0]       =    io_out [22:21]    ;
assign  sdr_dqm[0]        =    io_out [23]       ;
assign  sdr_we_n          =    io_out [24]       ;
assign  sdr_cas_n         =    io_out [25]       ;
assign  sdr_ras_n         =    io_out [26]       ;
assign  sdr_cs_n          =    io_out [27]       ;
assign  sdr_cke           =    io_out [28]       ;
assign  sdram_clk         =    io_out [29]       ;
assign  io_in[29]         =    sdram_clk;
assign  #(1) io_in[7:0]   =    Dq;

// to fix the sdram interface timing issue
wire #(1) sdram_clk_d   = sdram_clk;

	// SDRAM 8bit
mt48lc8m8a2 #(.data_bits(8)) u_sdram8 (
          .Dq                 (Dq                 ) , 
          .Addr               (sdr_addr[11:0]     ), 
          .Ba                 (sdr_ba             ), 
          .Clk                (sdram_clk_d        ), 
          .Cke                (sdr_cke            ), 
          .Cs_n               (sdr_cs_n           ), 
          .Ras_n              (sdr_ras_n          ), 
          .Cas_n              (sdr_cas_n          ), 
          .We_n               (sdr_we_n           ), 
          .Dqm                (sdr_dqm            )
     );


task wb_user_core_write;
input [31:0] address;
input [31:0] data;
begin
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_adr_i =address;  // address
  wbd_ext_we_i  ='h1;  // write
  wbd_ext_dat_i =data;  // data output
  wbd_ext_sel_i ='hF;  // byte enable
  wbd_ext_cyc_i ='h1;  // strobe/request
  wbd_ext_stb_i ='h1;  // strobe/request
  wait(wbd_ext_ack_o == 1);
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_cyc_i ='h0;  // strobe/request
  wbd_ext_stb_i ='h0;  // strobe/request
  wbd_ext_adr_i ='h0;  // address
  wbd_ext_we_i  ='h0;  // write
  wbd_ext_dat_i ='h0;  // data output
  wbd_ext_sel_i ='h0;  // byte enable
  $display("DEBUG WB USER ACCESS WRITE Address : %x, Data : %x",address,data);
  repeat (2) @(posedge clock);
end
endtask

task  wb_user_core_read;
input [31:0] address;
output [31:0] data;
reg    [31:0] data;
begin
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_adr_i =address;  // address
  wbd_ext_we_i  ='h0;  // write
  wbd_ext_dat_i ='0;  // data output
  wbd_ext_sel_i ='hF;  // byte enable
  wbd_ext_cyc_i ='h1;  // strobe/request
  wbd_ext_stb_i ='h1;  // strobe/request
  wait(wbd_ext_ack_o == 1);
  data  = wbd_ext_dat_o;  
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_cyc_i ='h0;  // strobe/request
  wbd_ext_stb_i ='h0;  // strobe/request
  wbd_ext_adr_i ='h0;  // address
  wbd_ext_we_i  ='h0;  // write
  wbd_ext_dat_i ='h0;  // data output
  wbd_ext_sel_i ='h0;  // byte enable
  $display("DEBUG WB USER ACCESS READ Address : %x, Data : %x",address,data);
  repeat (2) @(posedge clock);
end
endtask

`ifdef GL

wire        wbd_spi_stb_i   = u_top.u_spi_master.wbd_stb_i;
wire        wbd_spi_ack_o   = u_top.u_spi_master.wbd_ack_o;
wire        wbd_spi_we_i    = u_top.u_spi_master.wbd_we_i;
wire [31:0] wbd_spi_adr_i   = u_top.u_spi_master.wbd_adr_i;
wire [31:0] wbd_spi_dat_i   = u_top.u_spi_master.wbd_dat_i;
wire [31:0] wbd_spi_dat_o   = u_top.u_spi_master.wbd_dat_o;
wire [3:0]  wbd_spi_sel_i   = u_top.u_spi_master.wbd_sel_i;

wire        wbd_sdram_stb_i = u_top.u_sdram_ctrl.wb_stb_i;
wire        wbd_sdram_ack_o = u_top.u_sdram_ctrl.wb_ack_o;
wire        wbd_sdram_we_i  = u_top.u_sdram_ctrl.wb_we_i;
wire [31:0] wbd_sdram_adr_i = u_top.u_sdram_ctrl.wb_addr_i;
wire [31:0] wbd_sdram_dat_i = u_top.u_sdram_ctrl.wb_dat_i;
wire [31:0] wbd_sdram_dat_o = u_top.u_sdram_ctrl.wb_dat_o;
wire [3:0]  wbd_sdram_sel_i = u_top.u_sdram_ctrl.wb_sel_i;

wire        wbd_uart_stb_i  = u_top.u_uart_i2c_usb.reg_cs;
wire        wbd_uart_ack_o  = u_top.u_uart_i2c_usb.reg_ack;
wire        wbd_uart_we_i   = u_top.u_uart_i2c_usb.reg_wr;
wire [7:0]  wbd_uart_adr_i  = u_top.u_uart_i2c_usb.reg_addr;
wire [7:0]  wbd_uart_dat_i  = u_top.u_uart_i2c_usb.reg_wdata;
wire [7:0]  wbd_uart_dat_o  = u_top.u_uart_i2c_usb.reg_rdata;
wire        wbd_uart_sel_i  = u_top.u_uart_i2c_usb.reg_be;

`endif

/**
`ifdef GL
//-----------------------------------------------------------------------------
// RISC IMEM amd DMEM Monitoring TASK
//-----------------------------------------------------------------------------

`define RISC_CORE  user_uart_tb.u_top.u_core.u_riscv_top

always@(posedge `RISC_CORE.wb_clk) begin
    if(`RISC_CORE.wbd_imem_ack_i)
          $display("RISCV-DEBUG => IMEM ADDRESS: %x Read Data : %x", `RISC_CORE.wbd_imem_adr_o,`RISC_CORE.wbd_imem_dat_i);
    if(`RISC_CORE.wbd_dmem_ack_i && `RISC_CORE.wbd_dmem_we_o)
          $display("RISCV-DEBUG => DMEM ADDRESS: %x Write Data: %x Resonse: %x", `RISC_CORE.wbd_dmem_adr_o,`RISC_CORE.wbd_dmem_dat_o);
    if(`RISC_CORE.wbd_dmem_ack_i && !`RISC_CORE.wbd_dmem_we_o)
          $display("RISCV-DEBUG => DMEM ADDRESS: %x READ Data : %x Resonse: %x", `RISC_CORE.wbd_dmem_adr_o,`RISC_CORE.wbd_dmem_dat_i);
end

`endif
**/
endmodule
`default_nettype wire
