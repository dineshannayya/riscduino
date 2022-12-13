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
/********************************************************************
  Standalone Random Generator validation Test bench           
PseudoRandom generator Test:
    - Read 32 randoms values
	- Check that each value is non-equal to 0x00000000
	- Check that each value is non-equal to 0xFFFFFFFF
	- Check that each value is non-equal to the previous value

     Author(s):                                                  
        - Dinesh Annayya, dinesh.annayya@gmail.com                
     Revision :                                                  
        - 0.1 - 16th Feb 2021, Dinesh A                           
*********************************************************************/

`default_nettype wire

`timescale 1 ns/1 ps

`include "sram_macros/sky130_sram_2kbyte_1rw1r_32x512_8.v"
`include "uart_agent.v"
`include "user_params.svh"

`define TB_TOP user_random_tb

module `TB_TOP;
parameter real CLK1_PERIOD  = 20; // 50Mhz
parameter real CLK2_PERIOD = 2.5;
parameter real IPLL_PERIOD = 5.008;
parameter real XTAL_PERIOD = 6;

integer  i;
reg [31:0] pre_random;

`include "user_tasks.sv"



	`ifdef WFDUMP
	   initial begin
	   	$dumpfile("simx.vcd");
	   	$dumpvars(1, `TB_TOP);
	   	$dumpvars(1, `TB_TOP.u_top);
	   	//$dumpvars(0, `TB_TOP.u_top.u_pll);
	   	$dumpvars(0, `TB_TOP.u_top.u_wb_host);
	   	//$dumpvars(0, `TB_TOP.u_top.u_intercon);
	   	//$dumpvars(1, `TB_TOP.u_top.u_intercon);
	   	$dumpvars(0, `TB_TOP.u_top.u_pinmux);
	   	$dumpvars(0, `TB_TOP.u_top.u_rp_south);
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
   pre_random = 0;
   fork
   begin
       for(i =0; i < 100; i = i+1) begin
          wb_user_core_read(`ADDR_SPACE_GLBL+`GLBL_CFG_RANDOM_NO,read_data);
          if(read_data == 32'h0) begin
             test_fail = 1;
             $display("ERROR: RANDOM Number Is Zero");
          end else if(read_data == 32'hFFFF_FFFF) begin
             test_fail = 1;
             $display("ERROR: RANDOM Number Is All One");
          end else if(read_data == pre_random) begin
             test_fail = 1;
             $display("ERROR: RANDOM Number is same as previous one");
          end
          pre_random = read_data;
       end
   end
   begin
      repeat (50000) @(posedge clock);
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
endmodule
`default_nettype wire
