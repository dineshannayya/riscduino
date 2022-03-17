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
////   timer interfaface through External WB i/F.                 ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 01 Oct 2021, Dinesh A                               ////
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

`define TB_GLBL    user_timer_tb

`include "uprj_netlists.v"
`include "user_reg_map.v"


module user_timer_tb;
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


	reg [1:0] spi_chip_no;

	wire gpio;
	wire [37:0] mprj_io;
	wire [7:0] mprj_io_0;
	reg        test_fail;
	reg [31:0] read_data;
	reg [31:0] OneUsPeriod;
        integer    test_step;
        wire       clock_mon;


	// External clock is used by default.  Make this artificially fast for the
	// simulation.  Normally this would be a slow clock and the digital PLL
	// would be the fast clock.

	always #12.5 clock <= (clock === 1'b0);

	initial begin
		OneUsPeriod = 1;
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
	   	$dumpfile("simx.vcd");
	   	$dumpvars(1, `TB_GLBL);
	   	$dumpvars(0, `TB_GLBL.u_top.u_pinmux);
	   end
       `endif

	initial begin
		$dumpon;

		#200; // Wait for reset removal
	        repeat (10) @(posedge clock);
		$display("Monitor: Standalone User Risc Boot Test Started");

		// Remove Wb Reset
		wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,'h1);

	        repeat (2) @(posedge clock);
		#1;

                // Remove the reset
		// Remove WB and SPI/UART Reset, Keep CORE under Reset
                wb_user_core_write(`ADDR_SPACE_PINMUX+`PINMUX_GBL_CFG0,'h01F);

		// config 1us based on system clock - 1000/25ns = 40 
                wb_user_core_write(`ADDR_SPACE_PINMUX+`PINMUX_GBL_CFG1,39);

		// Enable Timer Interrupt
                wb_user_core_write(`ADDR_SPACE_PINMUX+`PINMUX_GBL_INTR_MSK,'h700);

		test_fail = 0;
	        repeat (200) @(posedge clock);
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 10

	        $display("Step-1, Timer-0: 1us * 100 = 100us; Timer-1: 200us; Timer-2: 300us");
	        test_step = 1;
                wb_user_core_write(`ADDR_SPACE_PINMUX+`PINMUX_CFG_TIMER0,'h0001_0063);
                wb_user_core_write(`ADDR_SPACE_PINMUX+`PINMUX_CFG_TIMER1,'h0001_00C7);
                wb_user_core_write(`ADDR_SPACE_PINMUX+`PINMUX_CFG_TIMER2,'h0001_012B);
	        timer_monitor(OneUsPeriod*100,OneUsPeriod*200,OneUsPeriod*300);

		$display("Checking the Timer Interrupt generation and clearing");

		// Disable the Timer - To avoid multiple interrupt generation
		// during status check and interrupt clearing
                wb_user_core_write(`ADDR_SPACE_PINMUX+`PINMUX_CFG_TIMER0,'h0000_0063);
                wb_user_core_write(`ADDR_SPACE_PINMUX+`PINMUX_CFG_TIMER1,'h0000_00C7);
                wb_user_core_write(`ADDR_SPACE_PINMUX+`PINMUX_CFG_TIMER2,'h0000_012B);

                wb_user_core_read(`ADDR_SPACE_PINMUX+`PINMUX_GBL_INTR,read_data);
		if((u_top.u_pinmux.irq_lines[10:8] == 3'b111) && (read_data[10:8] == 3'b111)) begin
		    $display("STATUS: Timer Interrupt detected ");
		    // Clearing the Timer Interrupt
                    wb_user_core_write(`ADDR_SPACE_PINMUX+`PINMUX_GBL_INTR,'h700);
                    wb_user_core_read(`ADDR_SPACE_PINMUX+`PINMUX_GBL_INTR,read_data);
		    if((u_top.u_pinmux.irq_lines[10:8] == 3'b111) && (read_data[10:8] == 3'b000)) begin
		       $display("ERROR: Timer Interrupt not cleared ");
		       test_fail = 1;
		    end else begin
		       $display("STATUS: Timer Interrupt cleared ");
		    end
	        end else begin
		    $display("ERROR: Timer interrupt not detected ");
		    test_fail = 1;
	        end

	        $display("Step-2, Timer-0: 1us * 200 = 200us; Timer-1: 300us; Timer-2: 400us");
	        test_step = 2;
                wb_user_core_write(`ADDR_SPACE_PINMUX+`PINMUX_CFG_TIMER0,'h0001_00C7);
                wb_user_core_write(`ADDR_SPACE_PINMUX+`PINMUX_CFG_TIMER1,'h0001_012B);
                wb_user_core_write(`ADDR_SPACE_PINMUX+`PINMUX_CFG_TIMER2,'h0001_018F);
	        timer_monitor(OneUsPeriod*200,OneUsPeriod*300,OneUsPeriod*400);

		$display("Checking the Timer Interrupt generation and clearing");

		// Disable the Timer - To avoid multiple interrupt generation
		// during status check and interrupt clearing
                wb_user_core_write(`ADDR_SPACE_PINMUX+`PINMUX_CFG_TIMER0,'h0000_0063);
                wb_user_core_write(`ADDR_SPACE_PINMUX+`PINMUX_CFG_TIMER1,'h0000_00C7);
                wb_user_core_write(`ADDR_SPACE_PINMUX+`PINMUX_CFG_TIMER2,'h0000_012B);

                wb_user_core_read(`ADDR_SPACE_PINMUX+`PINMUX_GBL_INTR,read_data);
		if((u_top.u_pinmux.irq_lines[10:8] == 3'b111) && (read_data[10:8] == 3'b111)) begin
		    $display("STATUS: Timer Interrupt detected ");
		    // Clearing the Timer Interrupt
                    wb_user_core_write(`ADDR_SPACE_PINMUX+`PINMUX_GBL_INTR,'h700);
                    wb_user_core_read(`ADDR_SPACE_PINMUX+`PINMUX_GBL_INTR,read_data);
		    if((u_top.u_pinmux.irq_lines[10:8] == 3'b111) && (read_data[10:8] == 3'b000)) begin
		       $display("ERROR: Timer Interrupt not cleared ");
		       test_fail = 1;
		    end else begin
		       $display("STATUS: Timer Interrupt cleared ");
		    end
	        end else begin
		    $display("ERROR: Timer interrupt not detected ");
		    test_fail = 1;
	        end

		repeat (100) @(posedge clock);
			// $display("+1000 cycles");

          	if(test_fail == 0) begin
		   `ifdef GL
	    	       $display("Monitor: Timer Mode (GL) Passed");
		   `else
		       $display("Monitor: Timer Mode (RTL) Passed");
		   `endif
	        end else begin
		    `ifdef GL
	    	        $display("Monitor: Timer Mode (GL) Failed");
		    `else
		        $display("Monitor: Timer Mode (RTL) Failed");
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

wire timer_intr0 = u_top.u_pinmux.timer_intr[0];
wire timer_intr1 = u_top.u_pinmux.timer_intr[1];
wire timer_intr2 = u_top.u_pinmux.timer_intr[2];

// Monitor the Timer interrupt interval
task timer_monitor;
input [31:0] timer0_period;
input [31:0] timer1_period;
input [31:0] timer2_period;
begin
   force clock_mon = timer_intr0;
   check_clock_period("Timer0",timer0_period);
   release clock_mon;

   force clock_mon = timer_intr1;
   check_clock_period("Timer1",timer1_period);
   release clock_mon;

   force clock_mon = timer_intr2;
   check_clock_period("Timer1",timer2_period);
   release clock_mon;

end
endtask


//----------------------------------
// Check the clock period
//----------------------------------
task check_clock_period;
input [127:0] clk_name;
input [31:0] clk_period; // in NS
time prev_t, next_t, periodd;
begin
    $timeformat(-12,3,"ns",10);
   repeat(1) @(posedge clock_mon);
   repeat(1) @(posedge clock_mon);
   prev_t  = $realtime;
   repeat(2) @(posedge clock_mon);
   next_t  = $realtime;
   periodd = (next_t-prev_t)/2;
   periodd = (periodd)/1e3;
   if(clk_period != periodd) begin
       $display("STATUS: FAIL => %s Exp Period: %d us Rxd: %d us",clk_name,clk_period,periodd);
       test_fail = 1;
   end else begin
       $display("STATUS: PASS => %s  Period: %d us ",clk_name,clk_period);
   end
end
endtask

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

`ifndef GL // Drive Power for Hold Fix Buf
    // All standard cell need power hook-up for functionality work
    initial begin

    end
`endif    



//----------------------------------------------------
//  Task
// --------------------------------------------------
task test_err;
begin
     test_fail = 1;
end
endtask

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
  $display("STATUS: WB USER ACCESS WRITE Address : 0x%x, Data : 0x%x",address,data);
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
  //$display("STATUS: WB USER ACCESS READ  Address : 0x%x, Data : 0x%x",address,data);
  repeat (2) @(posedge clock);
end
endtask

task  wb_user_core_read_check;
input [31:0] address;
output [31:0] data;
input [31:0] cmp_data;
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
  if(data !== cmp_data) begin
     $display("ERROR : WB USER ACCESS READ  Address : 0x%x, Exd: 0x%x Rxd: 0x%x ",address,cmp_data,data);
     `TB_GLBL.test_fail = 1;
  end else begin
     $display("STATUS: WB USER ACCESS READ  Address : 0x%x, Data : 0x%x",address,data);
  end
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
