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
////  Hardware Semaphore validation Test bench                    ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  https://github.com/dineshannayya/yifive_r0.git              ////
////                                                              ////
////  Description                                                 ////
////   This is a standalone test bench to validate the            ////
////   Digital core.                                              ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 17th Aug 2022, Dinesh A                             ////
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

`include "sram_macros/sky130_sram_2kbyte_1rw1r_32x512_8.v"

`define TOP  user_sema_tb

module `TOP;
parameter real CLK1_PERIOD  = 25;
parameter real CLK2_PERIOD = 2.5;
parameter real IPLL_PERIOD = 5.008;
parameter real XTAL_PERIOD = 6;

`include "user_tasks.sv"


reg [31:0]     exp_data     ;
//----------------------------------
// Uart Configuration
// ---------------------------------
integer        test_step;

integer i,j;


	initial begin
		test_step = 0;
	end

	`ifdef WFDUMP
	   initial begin
	   	$dumpfile("simx.vcd");
	   	$dumpvars(1, `TOP);
	   	//$dumpvars(1, `TOP.u_top);
	   	//$dumpvars(0, `TOP.u_top.u_pll);
	   	$dumpvars(0, `TOP.u_top.u_wb_host);
	   	//$dumpvars(1, `TOP.u_top.u_intercon);
	   	//$dumpvars(1, `TOP.u_top.u_intercon);
	   	$dumpvars(0, `TOP.u_top.u_pinmux);
	   end
       `endif


initial
begin

   init();
   #200; // Wait for reset removal
   repeat (10) @(posedge clock);
   $display("Monitor: Standalone User Basic Test Started");
   
   repeat (2) @(posedge clock);

   test_fail=0;
   fork
      begin

         // Setting Lock Bit Individually and clearing it imediatly
         for(i=0; i < 15; i = i+1) begin
            read_data = 'h0;
            // Step-1: Wait for Semaphore lock bit to '1'
            while(read_data[0] == 0) begin
               @(posedge clock) ;
                  wb_user_core_read(`ADDR_SPACE_SEMA+ (i*4),read_data);
             end 
            // Step-2: Check is Really Lock Bit it Set the corresponding lock status
             wb_user_core_read_check(`ADDR_SPACE_SEMA+`SEMA_CFG_STATUS,read_data, 1<< i);
            // Step-3: Clear the Lock Bit
             wb_user_core_write(`ADDR_SPACE_SEMA+(i*4),1);
            // Step-4: Check is Really Lock Bit it Cleared the corresponding lock status
             wb_user_core_read_check(`ADDR_SPACE_SEMA+`SEMA_CFG_STATUS,read_data, 0);
            
         end
         // Setting all Lock Bit  and clearing it end
         exp_data  = 'h0;
         for(i=0; i < 15; i = i+1) begin
            read_data = 'h0;
            // Step-1: Wait for Semaphore lock bit to '1'
            while(read_data[0] == 0) begin
               @(posedge clock) ;
                  wb_user_core_read(`ADDR_SPACE_SEMA+(i*4),read_data);
             end 
            exp_data  = exp_data | (1<< i);
            wb_user_core_read_check(`ADDR_SPACE_SEMA+`SEMA_CFG_STATUS,read_data, exp_data);
         end
         // Step-2: Check all 15 Sema bit set
         wb_user_core_read_check(`ADDR_SPACE_SEMA+`SEMA_CFG_STATUS,read_data, 32'h7FFF);
         exp_data  = 32'h7FFF;
         for(i=0; i < 15; i = i+1) begin
            // Step-3: clear the Sema Bit
            wb_user_core_write(`ADDR_SPACE_SEMA+(i*4),32'h1);
            exp_data  = exp_data ^ (1<< i);
            wb_user_core_read_check(`ADDR_SPACE_SEMA+`SEMA_CFG_STATUS,read_data, exp_data);
         end
         // Step-3: All hardware lock bit is cleared
         wb_user_core_read_check(`ADDR_SPACE_SEMA+`SEMA_CFG_STATUS,read_data, 32'h0);
      end
   
      begin
      repeat (30000) @(posedge clock);
   		// $display("+1000 cycles");
      test_fail = 1;
      end
      join_any
      disable fork; //disable pending fork activity

   
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
assign io_in[21] = 1'b0 ; // SPIS SCK 

endmodule
`default_nettype wire
