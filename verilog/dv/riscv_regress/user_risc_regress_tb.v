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

`timescale 1 ns/1 ps

`include "sram_macros/sky130_sram_2kbyte_1rw1r_32x512_8.v"
`include "is62wvs1288.v"



localparam [31:0]      YCR1_SIM_EXIT_ADDR      = 32'h0000_00F8;
localparam [31:0]      YCR1_SIM_PRINT_ADDR     = 32'hF000_0000;
localparam [31:0]      YCR1_SIM_EXT_IRQ_ADDR   = 32'hF000_0100;
localparam [31:0]      YCR1_SIM_SOFT_IRQ_ADDR  = 32'hF000_0200;

module user_risc_regress_tb;
parameter real CLK1_PERIOD  = 20; // 50Mhz
parameter real CLK2_PERIOD = 2.5;
parameter real IPLL_PERIOD = 5.008;
parameter real XTAL_PERIOD = 6;

`include "user_tasks.sv"

	int unsigned                f_results;
    int unsigned                f_info;
        
    string                      s_results;
    string                      s_info;
    `ifdef SIGNATURE_OUT
    string                      s_testname;
    bit                         b_single_run_flag;
    `endif  //  SIGNATURE_OUT


	`ifdef VERILATOR
     logic [255:0]          test_file;
	 logic [255:0]          test_ram_file;
     `else // VERILATOR
     string                 test_file;
	 string                 test_ram_file;

     `endif // VERILATOR


	bit                    test_running;
    int unsigned           tests_passed;
    int unsigned           tests_total;

	logic  [7:0]           tem_mem[0:4095];
	logic  [31:0]          mem_data;
    bit                    test_start;

	initial begin
        test_start = 0;
		$value$plusargs("risc_core_id=%d", d_risc_id);
	end

	`ifdef WFDUMP
	   initial begin
	   	$dumpfile("simx.vcd");
	   	$dumpvars(1, user_risc_regress_tb);
	   	$dumpvars(1, user_risc_regress_tb.u_top);
	   	$dumpvars(0, user_risc_regress_tb.u_top.u_riscv_top);
	   	$dumpvars(0, user_risc_regress_tb.u_top.u_qspi_master);
	   	$dumpvars(0, user_risc_regress_tb.u_top.u_intercon);
	   	$dumpvars(0, user_risc_regress_tb.u_top.u_pinmux);
	   end
       `endif

        integer i;

        always @reinit_event
	begin
		// Initialize the SPI memory with hex content
		// Wait for reset removal
		wait (rst_n == 1);


		// Initialize the SPI memory with hex content
         $write("\033[0;34m---Initializing the SPI Memory with Hexfile: %s\033[0m\n", test_file);
         $readmemh(test_file,u_spi_flash_256mb.Mem);

		// some of the RISCV test need SRAM area for specific
		// instruction execution like fence
		$sformat(test_ram_file, "%s.ram",test_file);
        $readmemh(test_ram_file,u_sram.memory);

		/***
		// Split the Temp memory content to two sram file
                $readmemh(test_ram_file,tem_mem);
		// Load the SRAM0/SRAM1 with 2KB data
                $write("\033[0;34m---Initializing the u_sram0_2kb Memory with Hexfile: %s\033[0m\n",test_ram_file);
		// Initializing the SRAM
		for(i = 0 ; i < 2048; i = i +4) begin
		    mem_data = {tem_mem[i+3],tem_mem[i+2],tem_mem[i+1],tem_mem[i+0]};
		    //$display("Filling Mem Location : %x with data : %x",i, mem_data);
		    u_top.u_sram0_2kb.mem[i/4] = mem_data;
		end
		for(i = 2048 ; i < 4096; i = i +4) begin
		  mem_data = {tem_mem[i+3],tem_mem[i+2],tem_mem[i+1],tem_mem[i+0]};
		  //$display("Filling Mem Location : %x with data : %x",i, mem_data);
		  u_top.u_sram1_2kb.mem[(2048-i)/4] = mem_data;
		end
		***/

		//for(i =32'h00; i < 32'h100; i = i+1)
                //    $display("Location: %x, Data: %x", i, u_top.u_tsram0_2kb.mem[i]);


		#200; 
	    repeat (10) @(posedge clock);
		$display("Monitor: Core reset removal");

		// Remove Wb Reset
		//wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,'h1);
	    repeat (2) @(posedge clock);
		#1;
		//------------ fuse_mhartid= 0x00
        //wb_user_core_write('h3002_0004,'h0);


        test_start = 1;
	    repeat (2) @(posedge clock);
		#1;
        // Remove all the reset
        if(d_risc_id == 0) begin
             $display("STATUS: Working with Risc core 0");
             wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG0,'h11F);
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

	end

//-------------------------------------------------------------------------------
// Run tests
//-------------------------------------------------------------------------------

`include "riscv_runtests.sv"


// SSPI Slave I/F
assign io_in[5]  = 1'b1; // RESET
assign io_in[21] = 1'b0 ; // SPIS SCK 


logic [31:0] riscv_dmem_req_cnt; // cnt dmem req
initial 
begin
   riscv_dmem_req_cnt = 0;
end

always @(posedge u_top.wbd_riscv_dmem_stb_i)
begin
    riscv_dmem_req_cnt = riscv_dmem_req_cnt+1;
    if((riscv_dmem_req_cnt %200) == 0)
	$display("STATUS: Total Dmem Req Cnt: %d ",riscv_dmem_req_cnt);
end


`ifndef GL // Drive Power for Hold Fix Buf
    // All standard cell need power hook-up for functionality work
    initial begin
    end
`endif    

//------------------------------------------------------
//  Integrate the Serial flash with qurd support to
//  user core using the gpio pads
//  ----------------------------------------------------

   wire flash_clk = (io_oeb[28] == 1'b0) ? io_out[28]: 1'b0;
   wire flash_csb = (io_oeb[29] == 1'b0) ? io_out[29]: 1'b0;
   // Creating Pad Delay
   wire #1 io_oeb_33 = io_oeb[33];
   wire #1 io_oeb_34 = io_oeb[34];
   wire #1 io_oeb_35 = io_oeb[35];
   wire #1 io_oeb_36 = io_oeb[36];
   tri  #1 flash_io0 = (io_oeb_33== 1'b0) ? io_out[33] : 1'bz;
   tri  #1 flash_io1 = (io_oeb_34== 1'b0) ? io_out[34] : 1'bz;
   tri  #1 flash_io2 = (io_oeb_35== 1'b0) ? io_out[35] : 1'bz;
   tri  #1 flash_io3 = (io_oeb_36== 1'b0) ? io_out[36] : 1'bz;

   assign io_in[33] = (io_oeb[33] == 1'b1) ? flash_io0: 1'b0;
   assign io_in[34] = (io_oeb[34] == 1'b1) ? flash_io1: 1'b0;
   assign io_in[35] = (io_oeb[35] == 1'b1) ? flash_io2: 1'b0;
   assign io_in[36] = (io_oeb[36] == 1'b1) ? flash_io3: 1'b0;


   // Quard flash
     s25fl256s #(.mem_file_name("add.hex"),
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


   wire spiram_csb = (io_oeb[31] == 1'b0) ? io_out[31] : 1'b0;

   is62wvs1288 #(.mem_file_name("none"))
	u_sram (
         // Data Inputs/Outputs
           .io0     (flash_io0),
           .io1     (flash_io1),
           // Controls
           .clk    (flash_clk),
           .csb    (spiram_csb),
           .io2    (flash_io2),
           .io3    (flash_io3)
    );




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
`include "s25fl256s.sv"
`default_nettype wire
