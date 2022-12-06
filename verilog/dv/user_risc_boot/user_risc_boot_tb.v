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
////      in to  user register from 0x1003_0058 to 0x1003_006C    ////
////   4. Through the External Wishbone Interface we read back    ////
////       from 0x3003_0058 to 0x3003_006C                        ////
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

`timescale 1 ns / 10 ps

`include "sram_macros/sky130_sram_2kbyte_1rw1r_32x512_8.v"

`define TB_HEX "user_risc_boot.hex"
`define TB_TOP  user_risc_boot_tb
module `TB_TOP;

parameter real CLK1_PERIOD  = 20; // %0Mhz
parameter real CLK2_PERIOD = 2.5;
parameter real IPLL_PERIOD = 5.008;
parameter real XTAL_PERIOD = 6;

`include "user_tasks.sv"



	`ifdef WFDUMP
	   initial begin
	   	$dumpfile("simx.vcd");
	   	$dumpvars(1, `TB_TOP);
	   	$dumpvars(1, `TB_TOP.u_top.u_wb_host);
	   	$dumpvars(1, `TB_TOP.u_top.u_pinmux);
	   	$dumpvars(1, `TB_TOP.u_top);
	   end
       `endif

	initial begin
		$value$plusargs("risc_core_id=%d", d_risc_id);
        init();


		#200; // Wait for reset removal
	        repeat (10) @(posedge clock);
		$display("Monitor: Standalone User Risc Boot Test Started");

		// Remove Wb Reset
		//wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,'h1);

	        repeat (2) @(posedge clock);
		#1;
		// Remove all the reset
		if(d_risc_id == 0) begin
		     $display("STATUS: Working with Risc core 0");
             //wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG0,'h11F);
		end else begin
		     $display("STATUS: Working with Risc core 1");
                     wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG0,'h21F);
		end

        wait_riscv_boot();

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
		wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_0,read_data,32'h11223344);
		wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_1,read_data,32'h22334455);
		wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_2,read_data,32'h33445566);
		wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_3,read_data,32'h44556677);
		wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_4,read_data,32'h55667788);
		wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_5,read_data,32'h66778899);


	   
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
	    $finish;
	end

// SSPI Slave I/F
assign io_in[5]  = 1'b1; // RESET
assign io_in[21] = 1'b0; // CLOCK



//------------------------------------------------------
//  Integrate the Serial flash with qurd support to
//  user core using the gpio pads
//  ----------------------------------------------------

   wire flash_clk = io_out[28];
   wire flash_csb = io_out[29];
   // Creating Pad Delay
   wire #1 io_oeb_29 = io_oeb[33];
   wire #1 io_oeb_30 = io_oeb[34];
   wire #1 io_oeb_31 = io_oeb[35];
   wire #1 io_oeb_32 = io_oeb[36];
   tri  #1 flash_io0 = (io_oeb_29== 1'b0) ? io_out[33] : 1'bz;
   tri  #1 flash_io1 = (io_oeb_30== 1'b0) ? io_out[34] : 1'bz;
   tri  #1 flash_io2 = (io_oeb_31== 1'b0) ? io_out[35] : 1'bz;
   tri  #1 flash_io3 = (io_oeb_32== 1'b0) ? io_out[36] : 1'bz;

   assign io_in[33] = flash_io0;
   assign io_in[34] = flash_io1;
   assign io_in[35] = flash_io2;
   assign io_in[36] = flash_io3;


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



endmodule
`include "s25fl256s.sv"
`default_nettype wire
