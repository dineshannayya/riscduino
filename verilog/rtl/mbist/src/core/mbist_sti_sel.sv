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
////  MBIST Stimulus Selection                                    ////
////                                                              ////
////  This file is part of the mbist_ctrl cores project           ////
////  https://github.com/dineshannayya/mbist_ctrl.git             ////
////                                                              ////
////  Description                                                 ////
////      This block integrate stimulus slectiion                 ////
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

module mbist_sti_sel 
     #(  parameter BIST_ADDR_WD           = 9,
	 parameter BIST_DATA_WD           = 32,
	 parameter BIST_ADDR_START        = 9'h000,
	 parameter BIST_ADDR_END          = 9'h1F8,
	 parameter BIST_REPAIR_ADDR_START = 9'h1FC,
	 parameter BIST_RAD_WD_I          = BIST_ADDR_WD,
	 parameter BIST_RAD_WD_O          = BIST_ADDR_WD) (

	output logic                         sdo           ,  // Scan Data Out
	output logic                         last_stimulus ,  // last stimulus
        output logic  [BIST_STI_WD-1:0]      stimulus      ,

	input  logic                          clk           ,  // Clock
	input  logic                          rst_n         ,  // Reset 
	input  logic                          scan_shift    ,  // Scan Shift
	input  logic                          sdi           ,  // Scan data in
	input  logic                          run              // Run 

);

logic  [BIST_STI_SIZE-1:0]    sti_sel      ; // Stimulation Selection
logic  [7:0]                  tmp_sti      ; // Warning: Max Stimulus assmed is 8



/* Pattern Selection */

always @(posedge clk or negedge rst_n) begin
  if(!rst_n)           sti_sel <= {1'b1,{(BIST_STI_SIZE-1){1'b0}}};
  else if(scan_shift)  sti_sel <= {sdi, sti_sel[BIST_STI_SIZE-1:1]};
  else if(run)         sti_sel <= {sti_sel[0],sti_sel[BIST_STI_SIZE-1:1]};
end


/* Pattern Selection */
always_comb
begin
   tmp_sti = 8'b00000000;
   tmp_sti[7:8-BIST_STI_SIZE] = sti_sel;
   case(tmp_sti)
     8'b10000000: stimulus = BIST_STIMULUS_TYPE1;
     8'b01000000: stimulus = BIST_STIMULUS_TYPE2;
     8'b00100000: stimulus = BIST_STIMULUS_TYPE3;
     8'b00010000: stimulus = BIST_STIMULUS_TYPE4;
     8'b00001000: stimulus = BIST_STIMULUS_TYPE5;
     8'b00000100: stimulus = BIST_STIMULUS_TYPE6;
     8'b00000010: stimulus = BIST_STIMULUS_TYPE7;
     8'b00000001: stimulus = BIST_STIMULUS_TYPE8;
     default:     stimulus = BIST_STIMULUS_TYPE1;
   endcase
end


/* Assign output  */

assign sdo           = sti_sel[0];
assign last_stimulus = sti_sel[0];



endmodule
