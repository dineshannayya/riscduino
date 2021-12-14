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
////  MBIST Pattern Selection                                     ////
////                                                              ////
////  This file is part of the mbist_ctrl cores project           ////
////  https://github.com/dineshannayya/mbist_ctrl.git             ////
////                                                              ////
////  Description                                                 ////
////      This block integrate mbist pattern selection            ////
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
//-----------------------------------
// MBIST Data Pattern Selection Logic
//-----------------------------------
module mbist_pat_sel 
     #(  parameter BIST_ADDR_WD           = 9,
	 parameter BIST_DATA_WD           = 32,
	 parameter BIST_ADDR_START        = 9'h000,
	 parameter BIST_ADDR_END          = 9'h1F8,
	 parameter BIST_REPAIR_ADDR_START = 9'h1FC,
	 parameter BIST_RAD_WD_I          = BIST_ADDR_WD,
	 parameter BIST_RAD_WD_O          = BIST_ADDR_WD) (

      output  logic                     pat_last,   // Last pattern
      output  logic [BIST_DATA_WD-1:0]  pat_data,   // pattern data
      output  logic                     sdo,        // scan data output
      input   logic                     clk,        // clock 
      input   logic                     rst_n,      // reset 
      input   logic                     run,        // stop or start state machine 
      input   logic                     scan_shift, // scan shift 
      input   logic                     sdi         // scan input

);


logic    [BIST_DATA_PAT_SIZE-1:0] pat_sel     ;/* Pattern Select    */
logic    [63:0]                   pattern; 
                    
integer                           index       ;/* output index */



// last pattern
assign pat_last = pat_sel[0];


/* Pattern Selection */

always @(posedge clk or negedge rst_n) begin
  if(!rst_n)           pat_sel <= {1'b1,{(BIST_DATA_PAT_SIZE-1){1'b0}}};
  else if(scan_shift)  pat_sel <= {sdi, pat_sel[BIST_DATA_PAT_SIZE-1:1]};
  else if(run)         pat_sel <= {pat_sel[0],pat_sel[BIST_DATA_PAT_SIZE-1:1]};
end


/* Pattern Selection */
logic [7:0] tmp_pat;
always_comb
begin
   tmp_pat = 8'b00000000;
   tmp_pat[7:8-BIST_DATA_PAT_SIZE] = pat_sel;
   case(tmp_pat)
     8'b10000000: pattern = BIST_DATA_PAT_TYPE1;
     8'b01000000: pattern = BIST_DATA_PAT_TYPE2;
     8'b00100000: pattern = BIST_DATA_PAT_TYPE3;
     8'b00010000: pattern = BIST_DATA_PAT_TYPE4;
     8'b00001000: pattern = BIST_DATA_PAT_TYPE5;
     8'b00000100: pattern = BIST_DATA_PAT_TYPE6;
     8'b00000010: pattern = BIST_DATA_PAT_TYPE7;
     8'b00000001: pattern = BIST_DATA_PAT_TYPE8;
     default:     pattern = BIST_DATA_PAT_TYPE1;
   endcase
end

/* Data distributor */

always_comb
begin
   for(index = 0 ; index < BIST_DATA_WD ; index = index + 1) begin
       pat_data[index] = pattern[index%64];
   end
end

assign sdo   = pat_sel[0];

endmodule


