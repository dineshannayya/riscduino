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
////                                                              ////
////  Description                                                 ////
////   This is a standalone test bench to validate the            ////
////   pwm interfaface through External WB i/F.                  ////
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

`timescale 1 ns / 1 ps


`define TB_GLBL    user_pwm_tb

`include "sram_macros/sky130_sram_2kbyte_1rw1r_32x512_8.v"


module user_pwm_tb;
parameter real CLK1_PERIOD  = 25;
parameter real CLK2_PERIOD = 2.5;
parameter real IPLL_PERIOD = 5.008;
parameter real XTAL_PERIOD = 6;

`include "user_tasks.sv"



	reg [31:0] OneMsPeriod;
    integer    test_step;
    wire       clock_mon;


	initial begin
		OneMsPeriod = 1000;
	end

	`ifdef WFDUMP
	   initial begin
	   	$dumpfile("simx.vcd");
	   	$dumpvars(1, `TB_GLBL);
	   	$dumpvars(0, `TB_GLBL.u_top.u_wb_host);
	   	$dumpvars(0, `TB_GLBL.u_top.u_pinmux);
	   	$dumpvars(0, `TB_GLBL.u_top.u_intercon);
	   end
       `endif

	initial begin
		$dumpon;
        init();

		#200; // Wait for reset removal
	        repeat (10) @(posedge clock);
		$display("Monitor: Standalone User Risc Boot Test Started");

		// Remove Wb Reset
		//wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,'h1);

        // Enable PWM Multi Functional Ports
        wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_MUTI_FUNC,'h03F);

	    repeat (2) @(posedge clock);
		#1;

        // Remove the reset
		// Remove WB and SPI/UART Reset, Keep CORE under Reset
        //wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG0,'h01F);

		// config 1us based on system clock - 1000/25ns = 40 
        wb_user_core_write(`ADDR_SPACE_TIMER+`TIMER_CFG_GLBL,39);

		test_fail = 0;
	    repeat (200) @(posedge clock);
        wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 1000

	    $display("Step-1, PWM-0: 1ms/2 = 500Hz; PWM-1: 1ms/3; PWM-2: 1ms/4, PWM-3: 1ms/5, PWM-4: 1ms/6, PWM-5: 1ms/7");
	    test_step = 1;
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_CFG_PWM_0,'h0000_0000);
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_CFG_PWM_1,'h0000_0001);
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_CFG_PWM_2,'h0001_0001);
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_CFG_PWM_3,'h0001_0002);
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_CFG_PWM_4,'h0002_0002);
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_CFG_PWM_5,'h0002_0003);
	    pwm_monitor(OneMsPeriod*2,OneMsPeriod*3,OneMsPeriod*4,OneMsPeriod*5,OneMsPeriod*6,OneMsPeriod*7);

		repeat (100) @(posedge clock);
			// $display("+1000 cycles");

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


wire pwm0 = io_out[9];
wire pwm1 = io_out[13];
wire pwm2 = io_out[14];
wire pwm3 = io_out[17];
wire pwm4 = io_out[18];
wire pwm5 = io_out[19];


task pwm_monitor;
input [31:0] pwm0_period;
input [31:0] pwm1_period;
input [31:0] pwm2_period;
input [31:0] pwm3_period;
input [31:0] pwm4_period;
input [31:0] pwm5_period;
begin
   force clock_mon = pwm0;
   check_clock_period("PWM0 Clock",pwm0_period);
   release clock_mon;

   force clock_mon = pwm1;
   check_clock_period("PWM1 Clock",pwm1_period);
   release clock_mon;

   force clock_mon = pwm2;
   check_clock_period("PWM2 Clock",pwm2_period);
   release clock_mon;

   force clock_mon = pwm3;
   check_clock_period("PWM3 Clock",pwm3_period);
   release clock_mon;

   force clock_mon = pwm4;
   check_clock_period("PWM4 Clock",pwm4_period);
   release clock_mon;

   force clock_mon = pwm5;
   check_clock_period("PWM5 Clock",pwm5_period);
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
       $display("STATUS: FAIL => %s Exp Period: %d ms Rxd: %d ms",clk_name,clk_period,periodd);
       test_fail = 1;
   end else begin
       $display("STATUS: PASS => %s  Period: %d ms ",clk_name,clk_period);
   end
end
endtask

// SSPI Slave I/F
assign io_in[5]  = 1'b1; // RESET




//----------------------------------------------------
//  Task
// --------------------------------------------------
task test_err;
begin
     test_fail = 1;
end
endtask

endmodule
`default_nettype wire
