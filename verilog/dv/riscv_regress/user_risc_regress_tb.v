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

 `define QSPIM_GLBL_CTRL          32'h10000000
 `define QSPIM_DMEM_G0_RD_CTRL    32'h10000004
 `define QSPIM_DMEM_G0_WR_CTRL    32'h10000008
 `define QSPIM_DMEM_G1_RD_CTRL    32'h1000000C
 `define QSPIM_DMEM_G1_WR_CTRL    32'h10000010

 `define QSPIM_DMEM_CS_AMAP        32'h10000014
 `define QSPIM_DMEM_CA_AMASK       32'h10000018

 `define QSPIM_IMEM_CTRL1          32'h1000001C
 `define QSPIM_IMEM_CTRL2          32'h10000020
 `define QSPIM_IMEM_ADDR           32'h10000024
 `define QSPIM_IMEM_WDATA          32'h10000028
 `define QSPIM_IMEM_RDATA          32'h1000002C
 `define QSPIM_SPI_STATUS          32'h10000030

module user_risc_regress_tb;
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
	wire        clk;

	// User I/O
	wire [37:0] io_oeb;
	wire [37:0] io_out;
	wire [37:0] io_in;

	wire gpio;
	wire [37:0] mprj_io;
	wire [7:0] mprj_io_0;
	reg         test_fail;
	reg [31:0] read_data;


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


        event	               reinit_event;
	bit                    test_running;
        int unsigned           tests_passed;
        int unsigned           tests_total;

	logic  [7:0]           tem_mem[0:4095];
	logic  [31:0]          mem_data;
	integer    d_risc_id;


parameter P_FSM_C      = 4'b0000; // Command Phase Only
parameter P_FSM_CW     = 4'b0001; // Command + Write DATA Phase Only
parameter P_FSM_CA     = 4'b0010; // Command -> Address Phase Only

parameter P_FSM_CAR    = 4'b0011; // Command -> Address -> Read Data
parameter P_FSM_CADR   = 4'b0100; // Command -> Address -> Dummy -> Read Data
parameter P_FSM_CAMR   = 4'b0101; // Command -> Address -> Mode -> Read Data
parameter P_FSM_CAMDR  = 4'b0110; // Command -> Address -> Mode -> Dummy -> Read Data

parameter P_FSM_CAW    = 4'b0111; // Command -> Address ->Write Data
parameter P_FSM_CADW   = 4'b1000; // Command -> Address -> DUMMY + Write Data
parameter P_FSM_CAMW   = 4'b1001; // Command -> Address -> MODE + Write Data

parameter P_FSM_CDR    = 4'b1010; // COMMAND -> DUMMY -> READ
parameter P_FSM_CDW    = 4'b1011; // COMMAND -> DUMMY -> WRITE
parameter P_FSM_CR     = 4'b1100;  // COMMAND -> READ

parameter P_MODE_SWITCH_IDLE     = 2'b00;
parameter P_MODE_SWITCH_AT_ADDR  = 2'b01;
parameter P_MODE_SWITCH_AT_DATA  = 2'b10;

parameter P_SINGLE = 2'b00;
parameter P_DOUBLE = 2'b01;
parameter P_QUAD   = 2'b10;
parameter P_QDDR   = 2'b11;
	//-----------------------------------------------------------------
	// Since this is regression, reset will be applied multiple time
	// Reset logic
	// ----------------------------------------------------------------
	bit [1:0]     rst_cnt;
        bit           rst_init;
	wire          rst_n;


        assign rst_n = &rst_cnt;
	assign wb_rst_i    =  !rst_n;
        
        always_ff @(posedge clk) begin
	if (rst_init)   begin
	     rst_cnt <= '0;
	     -> reinit_event;
	end
            else if (~&rst_cnt) rst_cnt <= rst_cnt + 1'b1;
        end

	// External clock is used by default.  Make this artificially fast for the
	// simulation.  Normally this would be a slow clock and the digital PLL
	// would be the fast clock.

	always #12.5 clock <= (clock === 1'b0);

	assign clk = clock;

	initial begin
		clock = 0;
                wbd_ext_cyc_i ='h0;  // strobe/request
                wbd_ext_stb_i ='h0;  // strobe/request
                wbd_ext_adr_i ='h0;  // address
                wbd_ext_we_i  ='h0;  // write
                wbd_ext_dat_i ='h0;  // data output
                wbd_ext_sel_i ='h0;  // byte enable
   
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
		wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,'h1);
	        repeat (2) @(posedge clock);
		#1;
		//------------ fuse_mhartid= 0x00
                //wb_user_core_write('h3002_0004,'h0);


	        repeat (2) @(posedge clock);
		#1;
		// Remove WB and SPI Reset, Keep SDARM and CORE under Reset
                wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG0,'h01F);

		// CS#2 Switch to QSPI Mode
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 1000
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0000,P_MODE_SWITCH_IDLE,P_SINGLE,P_SINGLE,4'b0100});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'h0,2'b00,2'b00,P_FSM_C,8'h00,8'h38});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h0);

		// Enable the DCACHE Remap to SRAM region
		//wb_user_core_write('h3080_000C,{4'b0000,4'b1111, 24'h0});
		//
		// Remove all the reset
               if(d_risc_id == 0) begin
                    $display("STATUS: Working with Risc core 0");
                    wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG0,'h11F);
               end else begin
                    $display("STATUS: Working with Risc core 1");
                    wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG0,'h21F);
               end

	end

wire USER_VDD1V8 = 1'b1;
wire VSS = 1'b0;

//-------------------------------------------------------------------------------
// Run tests
//-------------------------------------------------------------------------------

`include "riscv_runtests.sv"


//-------------------------------------------------------------------------------
// Core instance
//-------------------------------------------------------------------------------

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
    .la_data_in      ('1) ,
    .la_data_out     (),
    .la_oenb         ('0),
 

    // IOs
    .io_in          (io_in)  ,
    .io_out         (io_out) ,
    .io_oeb         (io_oeb) ,

    .user_irq       () 

);
// SSPI Slave I/F
assign io_in[0]  = 1'b1; // RESET
assign io_in[16] = 1'b0 ; // SPIS SCK 


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

   wire flash_clk = io_out[24];
   wire flash_csb = io_out[25];
   // Creating Pad Delay
   wire #1 io_oeb_29 = io_oeb[29];
   wire #1 io_oeb_30 = io_oeb[30];
   wire #1 io_oeb_31 = io_oeb[31];
   wire #1 io_oeb_32 = io_oeb[32];
   tri  #1 flash_io0 = (io_oeb_29== 1'b0) ? io_out[29] : 1'bz;
   tri  #1 flash_io1 = (io_oeb_30== 1'b0) ? io_out[30] : 1'bz;
   tri  #1 flash_io2 = (io_oeb_31== 1'b0) ? io_out[31] : 1'bz;
   tri  #1 flash_io3 = (io_oeb_32== 1'b0) ? io_out[32] : 1'bz;

   assign io_in[29] = flash_io0;
   assign io_in[30] = flash_io1;
   assign io_in[31] = flash_io2;
   assign io_in[32] = flash_io3;


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


   wire spiram_csb = io_out[27];

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
  repeat (1) @(negedge clock);
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
`include "s25fl256s.sv"
`default_nettype wire
