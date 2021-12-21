///////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2021 , Dinesh Annayya                          
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
// SPDX-FileContributor: Created by Dinesh Annayya <dinesha@opencores.org>
//
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  MBIST Address Generator                                     ////
////                                                              ////
////  This file is part of the mbist_ctrl cores project           ////
////  https://github.com/dineshannayya/mbist_ctrl.git             ////
////                                                              ////
////  Description                                                 ////
////      This block integrate mbist address gen                  ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.0 - 11th Oct 2021, Dinesh A                             ////
////          Initial integration                                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "mbist_def.svh"

module mbist_addr_gen
     #(  parameter BIST_ADDR_WD           = 9,
	 parameter BIST_DATA_WD           = 32,
	 parameter BIST_ADDR_START        = 9'h000,
	 parameter BIST_ADDR_END          = 9'h1F8,
	 parameter BIST_REPAIR_ADDR_START = 9'h1FC,
	 parameter BIST_RAD_WD_I          = BIST_ADDR_WD,
	 parameter BIST_RAD_WD_O          = BIST_ADDR_WD) (

   output  logic                    last_addr,   //  Last address access
   output  logic [BIST_ADDR_WD-1:0] bist_addr,   //  Bist Address  
   output  logic                    sdo,         //  scan data output
   input   logic                    clk,         //  clock input
   input   logic                    rst_n,       //  asynchronous reset 
   input   logic                    run,         //  stop or start state machine 
   input   logic                    updown,      //  count up or down 
   input   logic                    bist_shift,  //  shift scan input
   input   logic                    bist_load,   //  load scan input
   input   logic                    sdi          //  scan data input 

);


logic   [BIST_ADDR_WD-1:0] next_addr;  // Next Address
logic   [BIST_ADDR_WD-1:0] start_addr; // Address Start Address
logic   [BIST_ADDR_WD-1:0] end_addr;   // Address Stop Address


assign last_addr = (((updown == 1'b1)&&(bist_addr == end_addr))||((updown == 1'b0)&&(bist_addr == start_addr)))?1'b1:1'b0;


/******************************
     Address register 
     Basic Assumption: Allways counter start with upcounting
*********************************/


always @(posedge clk or negedge rst_n) begin
  if(!rst_n)          bist_addr <= BIST_ADDR_START ;
  else if(bist_load)  bist_addr <= start_addr;
  else                bist_addr <= next_addr;
end

/* Input combinational block */

always_comb  begin
    if(run) begin
       if((bist_addr == end_addr)&&(updown == 1'b1))    
	  next_addr = start_addr ;
       else if((bist_addr == start_addr)&&(updown == 1'b0)) 
	  next_addr = end_addr ;
       else next_addr = (updown)?bist_addr+1'b1:bist_addr-1'b1;
    end
    else next_addr = bist_addr;
end


/* Start register */

always @(posedge clk or negedge rst_n) begin
  if(!rst_n)           start_addr <= BIST_ADDR_START ;
  else if(bist_shift)  start_addr <= {sdi, start_addr[BIST_ADDR_WD-1:1]};
end

/* Start register */
always @(posedge clk or negedge rst_n) begin
  if(!rst_n)           end_addr <= BIST_ADDR_END ;
  else if(bist_shift)  end_addr <= {start_addr[0], end_addr[BIST_ADDR_WD-1:1]};
end


assign sdo   = end_addr[0];

endmodule

