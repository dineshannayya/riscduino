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
////  MBIST Operation Selection                                   ////
////                                                              ////
////  This file is part of the mbist_ctrl cores project           ////
////  https://github.com/dineshannayya/mbist_ctrl.git             ////
////                                                              ////
////  Description                                                 ////
////      This block integrate Operation Selection                ////
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
// bist stimulus selection

module mbist_op_sel 
     #(  parameter BIST_ADDR_WD           = 9,
	 parameter BIST_DATA_WD           = 32,
	 parameter BIST_ADDR_START        = 9'h000,
	 parameter BIST_ADDR_END          = 9'h1F8,
	 parameter BIST_REPAIR_ADDR_START = 9'h1FC,
	 parameter BIST_RAD_WD_I          = BIST_ADDR_WD,
	 parameter BIST_RAD_WD_O          = BIST_ADDR_WD) (

        output logic                        op_read       ,  // Opertion Read
	output logic                        op_write      ,  // Operation Write
	output logic                        op_invert     ,  // Opertaion Data Invert
	output logic                        op_updown     ,  // Operation Address Up Down
	output logic                        op_reverse    ,  // Operation Reverse
	output logic                        op_repeatflag ,  // Operation Repeat flag
	output logic                        sdo           ,  // Scan Data Out
	output logic                        last_op       ,  // last operation

	input  logic                        clk           ,  // Clock
	input  logic                        rst_n         ,  // Reset 
	input  logic                        scan_shift    ,  // Scan Shift
	input  logic                        sdi           ,  // Scan data in
	input  logic                        re_init       ,  // Re-init when there is error correction
	input  logic                        run           ,  // Run 
        input  logic  [BIST_STI_WD-1:0]     stimulus     

);


logic [BIST_OP_SIZE-1:0] op_sel       ;// Actual Operation
logic      [7:0]         tmp_op       ;// Warning : Assming Max opertion is 8
logic      [7:0]         tmpinvert    ;// read control 
logic      [7:0]         tmpread      ;// write control 
logic      [7:0]         tmpwrite     ;// invertor control 
integer                  index        ;// output index */
integer                  loop         ;// bit count


/* Operation Selection Selection */

always @(posedge clk or negedge rst_n) begin
  if(!rst_n)           op_sel <= {1'b1,{(BIST_OP_SIZE-1){1'b0}}};
  else if(scan_shift)  op_sel <= {sdi, op_sel[BIST_OP_SIZE-1:1]};
  else if(re_init)     op_sel <= {1'b1,{(BIST_OP_SIZE-1){1'b0}}}; // need fix for pmbist moode
  else if(run)         op_sel <= {op_sel[0],op_sel[BIST_OP_SIZE-1:1]};
end

assign op_updown     = stimulus[BIST_STI_WD-1];
assign op_reverse    = stimulus[BIST_STI_WD-2];
assign op_repeatflag = stimulus[BIST_STI_WD-3];
// Re-wind the operation, when the is error correct
assign last_op       = (re_init) ? 1'b0 : op_sel[0];



always_comb
begin
   loop=0;
   tmpinvert = 8'h0;
   tmpread   = 8'h0;
   tmpwrite  = 8'h0;
   for(index = 0 ; index < BIST_OP_SIZE ; index = index+1)begin
      tmpinvert[index] = stimulus[loop];
      tmpread[index]   = stimulus[loop+1];
      tmpwrite[index]  = stimulus[loop+2];
      loop             = loop + 3;
   end
end


always_comb
begin
   tmp_op = 8'b00000000;
   tmp_op[BIST_OP_SIZE-1:0] = op_sel;
   case(tmp_op)
     8'b10000000: {op_read,op_write,op_invert} = {tmpread[7],tmpwrite[7],tmpinvert[7]};
     8'b01000000: {op_read,op_write,op_invert} = {tmpread[6],tmpwrite[6],tmpinvert[6]};
     8'b00100000: {op_read,op_write,op_invert} = {tmpread[5],tmpwrite[5],tmpinvert[5]};
     8'b00010000: {op_read,op_write,op_invert} = {tmpread[4],tmpwrite[4],tmpinvert[4]};
     8'b00001000: {op_read,op_write,op_invert} = {tmpread[3],tmpwrite[3],tmpinvert[3]};
     8'b00000100: {op_read,op_write,op_invert} = {tmpread[2],tmpwrite[2],tmpinvert[2]};
     8'b00000010: {op_read,op_write,op_invert} = {tmpread[1],tmpwrite[1],tmpinvert[1]};
     8'b00000001: {op_read,op_write,op_invert} = {tmpread[0],tmpwrite[0],tmpinvert[0]};
     default:     {op_read,op_write,op_invert} = {tmpread[0],tmpwrite[0],tmpinvert[0]};
   endcase
end


endmodule
