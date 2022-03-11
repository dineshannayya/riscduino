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

`timescale 1 ns/10 ps

`include "uprj_netlists.v"


module user_basic_tb;
parameter CLK1_PERIOD = 10;
parameter CLK2_PERIOD = 2;

reg            clock         ;
reg            clock2        ;
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

wire           clock_mon;
integer        test_step;

integer i,j;

	// External clock is used by default.  Make this artificially fast for the
	// simulation.  Normally this would be a slow clock and the digital PLL
	// would be the fast clock.

	always #(CLK1_PERIOD/2) clock  <= (clock === 1'b0);
	always #(CLK2_PERIOD/2) clock2 <= (clock2 === 1'b0);

	initial begin
		test_step = 0;
		clock = 0;
		clock2 = 0;
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
	   	$dumpvars(4, user_basic_tb);
	   end
       `endif

	initial begin
		wb_rst_i <= 1'b1;
		#100;
		wb_rst_i <= 1'b0;	    	// Release reset
	end
initial
begin

   #200; // Wait for reset removal
   repeat (10) @(posedge clock);
   $display("Monitor: Standalone User Basic Test Started");
   
   repeat (2) @(posedge clock);

   test_fail=0;
   fork
      begin
	  // Default Value Check
          // cfg_glb_ctrl         = reg_0[6:0];
          // uart_i2c_usb_sel     = reg_0[8:7];
          // cfg_wb_clk_ctrl      = reg_0[11:9];
          // cfg_rtc_clk_ctrl     = reg_0[19:12];
          // cfg_cpu_clk_ctrl     = reg_0[23:20];
          // cfg_usb_clk_ctrl     = reg_0[31:24];
	  $display("Step-1, CPU: CLOCK1, RTC: CLOCK2 *2, USB: CLOCK2, WBS:CLOCK1");
	  test_step = 1;
          wb_user_core_write('h3080_0000,{8'h0,4'h0,8'h0,4'h0,8'h00});
	  clock_monitor(CLK1_PERIOD,CLK2_PERIOD*2,CLK2_PERIOD,CLK1_PERIOD);

	  $display("Step-2, CPU: CLOCK2, RTC: CLOCK2/(2+1), USB: CLOCK2/2, WBS:CLOCK2");
	  test_step = 2;
          wb_user_core_write('h3080_0000,{8'h80,4'h8,8'h1,4'h8,8'h00});
	  clock_monitor(CLK2_PERIOD,(3)*CLK2_PERIOD,2*CLK2_PERIOD,CLK2_PERIOD);

	  $display("Step-3, CPU: CLOCK1/2, RTC: CLOCK2/(2+2), USB: CLOCK2/(2+1), WBS:CLOCK1/2");
	  test_step = 3;
          wb_user_core_write('h3080_0000,{8'h81,4'h4,8'h2,4'h4,8'h00});
	  clock_monitor(2*CLK1_PERIOD,(4)*CLK2_PERIOD,3*CLK2_PERIOD,2*CLK1_PERIOD);

	  $display("Step-4, CPU: CLOCK1/3, RTC: CLOCK2/(2+3), USB: CLOCK2/(2+2), WBS:CLOCK1/3");
	  test_step = 4;
          wb_user_core_write('h3080_0000,{8'h82,4'h5,8'h3,4'h5,8'h00});
	  clock_monitor(3*CLK1_PERIOD,5*CLK2_PERIOD,4*CLK2_PERIOD,3*CLK1_PERIOD);

	  $display("Step-5, CPU: CLOCK1/4, RTC: CLOCK2/(2+4), USB: CLOCK2/(2+3), WBS:CLOCK1/4");
	  test_step = 5;
          wb_user_core_write('h3080_0000,{8'h83,4'h6,8'h4,4'h6,8'h00});
	  clock_monitor(4*CLK1_PERIOD,6*CLK2_PERIOD,5*CLK2_PERIOD,4*CLK1_PERIOD);

	  $display("Step-6, CPU: CLOCK1/(2+3), RTC: CLOCK2/(2+5), USB: CLOCK2/(2+4), WBS:CLOCK1/(2+3)");
	  test_step = 6;
          wb_user_core_write('h3080_0000,{8'h84,4'h7,8'h5,4'h7,8'h00});
	  clock_monitor(5*CLK1_PERIOD,7*CLK2_PERIOD,6*CLK2_PERIOD,5*CLK1_PERIOD);

	  $display("Step-7, CPU: CLOCK2/(2), RTC: CLOCK2/(2+6), USB: CLOCK2/(2+5), WBS:CLOCK2/(2)");
	  test_step = 7;
          wb_user_core_write('h3080_0000,{8'h85,4'hC,8'h6,4'hC,8'h00});
	  clock_monitor(2*CLK2_PERIOD,8*CLK2_PERIOD,7*CLK2_PERIOD,2*CLK2_PERIOD);

	  $display("Step-8, CPU: CLOCK2/3, RTC: CLOCK2/(2+7), USB: CLOCK2/(2+6), WBS:CLOCK2/3");
	  test_step = 8;
          wb_user_core_write('h3080_0000,{8'h86,4'hD,8'h7,4'hD,8'h00});
	  clock_monitor(3*CLK2_PERIOD,9*CLK2_PERIOD,8*CLK2_PERIOD,3*CLK2_PERIOD);

	  $display("Step-9, CPU: CLOCK2/4, RTC: CLOCK2/(2+8), USB: CLOCK2/(2+7), WBS:CLOCK2/4");
	  test_step = 9;
          wb_user_core_write('h3080_0000,{8'h87,4'hE,8'h8,4'hE,8'h00});
	  clock_monitor(4*CLK2_PERIOD,10*CLK2_PERIOD,9*CLK2_PERIOD,4*CLK2_PERIOD);

	  $display("Step-10, CPU: CLOCK2/(2+3), RTC: CLOCK2/(2+128), USB: CLOCK2/(2+8), WBS:CLOCK1/(2+3)");
	  test_step = 10;
          wb_user_core_write('h3080_0000,{8'h88,4'hF,8'h80,4'hF,8'h00});
	  clock_monitor(5*CLK2_PERIOD,130*CLK2_PERIOD,10*CLK2_PERIOD,5*CLK2_PERIOD);

	  $display("Step-10, CPU: CLOCK2/(2+3), RTC: CLOCK2/(2+255), USB: CLOCK2/(2+9), WBS:CLOCK2/(2+3)");
	  test_step = 10;
          wb_user_core_write('h3080_0000,{8'h89,4'hF,8'hFF,4'hF,8'h00});
	  clock_monitor(5*CLK2_PERIOD,257*CLK2_PERIOD,11*CLK2_PERIOD,5*CLK2_PERIOD);

         $display("###################################################");
         $display("Monitor: Checking the chip signature :");
         // Remove Wb/PinMux Reset
         wb_user_core_write('h3080_0000,'h1);

	 wb_user_core_read_check(32'h30020058,read_data,32'h8273_8343);
	 wb_user_core_read_check(32'h3002005C,read_data,32'h1003_2022);
	 wb_user_core_read_check(32'h30020060,read_data,32'h0003_8000);

      end
   
      begin
      repeat (20000) @(posedge clock);
   		// $display("+1000 cycles");
      test_fail = 1;
      end
      join_any
      disable fork; //disable pending fork activity

   
      $display("###################################################");
      if(test_fail == 0) begin
         `ifdef GL
             $display("Monitor: Standalone User UART Test (GL) Passed");
         `else
             $display("Monitor: Standalone User UART Test (RTL) Passed");
         `endif
      end else begin
          `ifdef GL
              $display("Monitor: Standalone User UART Test (GL) Failed");
          `else
              $display("Monitor: Standalone User UART Test (RTL) Failed");
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
    .user_clock2     (clock2),  // Real-time clock
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


task clock_monitor;
input [15:0] exp_cpu_period;
input [15:0] exp_rtc_period;
input [15:0] exp_usb_period;
input [15:0] exp_wbs_period;
begin
   force clock_mon = u_top.u_wb_host.cpu_clk;
   check_clock_period("CPU CLock",exp_cpu_period);
   release clock_mon;

   force clock_mon = u_top.u_wb_host.rtc_clk;
   check_clock_period("RTC Clock",exp_rtc_period);
   release clock_mon;

   force clock_mon = u_top.u_wb_host.usb_clk;
   check_clock_period("USB Clock",exp_usb_period);
   release clock_mon;

   force clock_mon = u_top.u_wb_host.wbs_clk_out;
   check_clock_period("WBS Clock",exp_wbs_period);
   release clock_mon;
end
endtask

//----------------------------------
// Check the clock period
//----------------------------------
task check_clock_period;
input [127:0] clk_name;
input [15:0] clk_period; // in NS
time prev_t, next_t, periodd;
begin
	$timeformat(-12,3,"ns",10);
   repeat(1) @(posedge clock_mon);
   repeat(1) @(posedge clock_mon);
   prev_t  = $realtime;
   repeat(100) @(posedge clock_mon);
   next_t  = $realtime;
   periodd = (next_t-prev_t)/100;
   //periodd = (periodd)/1e9;
   if(clk_period != periodd) begin
       $display("STATUS: FAIL => %s Exp Period: %d Rxd: %d",clk_name,clk_period,periodd);
       test_fail = 1;
   end else begin
       $display("STATUS: PASS => %s  Period: %d ",clk_name,clk_period);
   end
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
     test_fail = 1;
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
