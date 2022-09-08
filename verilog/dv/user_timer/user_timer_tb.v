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

`timescale 1 ns / 1 ps

`define TB_GLBL    user_timer_tb

`include "sram_macros/sky130_sram_2kbyte_1rw1r_32x512_8.v"


module user_timer_tb;
parameter real CLK1_PERIOD  = 25;
parameter real CLK2_PERIOD = 2.5;
parameter real IPLL_PERIOD = 5.008;
parameter real XTAL_PERIOD = 6;

`include "user_tasks.sv"


	reg [31:0] OneUsPeriod;
    integer    test_step;
    wire       clock_mon;



	initial begin
		OneUsPeriod = 1;
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
        init();

		#200; // Wait for reset removal
	        repeat (10) @(posedge clock);
		$display("Monitor: Standalone User Risc Boot Test Started");

		// Remove Wb Reset
		//wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,'h1);

	        repeat (2) @(posedge clock);
		#1;

        // Remove the reset
		// Remove WB and SPI/UART Reset, Keep CORE under Reset
        //wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG0,'h01F);

		// config 1us based on system clock - 1000/25ns = 40 
        wb_user_core_write(`ADDR_SPACE_TIMER+`TIMER_CFG_GLBL,39);

		// Enable Timer Interrupt
        wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_MSK,'h007);

		test_fail = 0;
	    repeat (200) @(posedge clock);
        wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 10

	    $display("Step-1, Timer-0: 1us * 100 = 100us; Timer-1: 200us; Timer-2: 300us");
	    test_step = 1;
        wb_user_core_write(`ADDR_SPACE_TIMER+`TIMER_CFG_TIMER_0,'h0001_0063);
        wb_user_core_write(`ADDR_SPACE_TIMER+`TIMER_CFG_TIMER_1,'h0001_00C7);
        wb_user_core_write(`ADDR_SPACE_TIMER+`TIMER_CFG_TIMER_2,'h0001_012B);
	    timer_monitor(OneUsPeriod*100,OneUsPeriod*200,OneUsPeriod*300);

		$display("Checking the Timer Interrupt generation and clearing");

		// Disable the Timer - To avoid multiple interrupt generation
		// during status check and interrupt clearing
        wb_user_core_write(`ADDR_SPACE_TIMER+`TIMER_CFG_TIMER_0,'h0000_0063);
        wb_user_core_write(`ADDR_SPACE_TIMER+`TIMER_CFG_TIMER_1,'h0000_00C7);
        wb_user_core_write(`ADDR_SPACE_TIMER+`TIMER_CFG_TIMER_2,'h0000_012B);

        wb_user_core_read(`ADDR_SPACE_GLBL+`GPIO_CFG_INTR_STAT,read_data);
		if((u_top.u_pinmux.irq_lines[2:0] == 3'b111) && (read_data[2:0] == 3'b111)) begin
		    $display("STATUS: Timer Interrupt detected ");
		    // Clearing the Timer Interrupt
                    wb_user_core_write(`ADDR_SPACE_GLBL+`GPIO_CFG_INTR_CLR,'h007);
                    wb_user_core_read(`ADDR_SPACE_GLBL+`GPIO_CFG_INTR_STAT,read_data);
		    if((u_top.u_pinmux.irq_lines[2:0] == 3'b111) && (read_data[2:0] == 3'b000)) begin
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
                wb_user_core_write(`ADDR_SPACE_TIMER+`TIMER_CFG_TIMER_0,'h0001_00C7);
                wb_user_core_write(`ADDR_SPACE_TIMER+`TIMER_CFG_TIMER_1,'h0001_012B);
                wb_user_core_write(`ADDR_SPACE_TIMER+`TIMER_CFG_TIMER_2,'h0001_018F);
	        timer_monitor(OneUsPeriod*200,OneUsPeriod*300,OneUsPeriod*400);

		$display("Checking the Timer Interrupt generation and clearing");

		// Disable the Timer - To avoid multiple interrupt generation
		// during status check and interrupt clearing
                wb_user_core_write(`ADDR_SPACE_TIMER+`TIMER_CFG_TIMER_0,'h0000_0063);
                wb_user_core_write(`ADDR_SPACE_TIMER+`TIMER_CFG_TIMER_1,'h0000_00C7);
                wb_user_core_write(`ADDR_SPACE_TIMER+`TIMER_CFG_TIMER_2,'h0000_012B);

                wb_user_core_read(`ADDR_SPACE_GLBL+`GPIO_CFG_INTR_STAT,read_data);
		if((u_top.u_pinmux.irq_lines[2:0] == 3'b111) && (read_data[2:0] == 3'b111)) begin
		    $display("STATUS: Timer Interrupt detected ");
		    // Clearing the Timer Interrupt
                    wb_user_core_write(`ADDR_SPACE_GLBL+`GPIO_CFG_INTR_CLR,'h007);
                    wb_user_core_read(`ADDR_SPACE_GLBL+`GPIO_CFG_INTR_STAT,read_data);
		    if((u_top.u_pinmux.irq_lines[2:0] == 3'b111) && (read_data[2:0] == 3'b000)) begin
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
