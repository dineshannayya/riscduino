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
////  MBIST Address Repair                                        ////
////                                                              ////
////  This file is part of the mbist_ctrl cores project           ////
////  https://github.com/dineshannayya/mbist_ctrl.git             ////
////                                                              ////
////  Description                                                 ////
////      This block integrate mbist address repair               ////
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


// BIST address Repair Logic

`include "mbist_def.svh"

module mbist_repair_addr 
     #(  parameter BIST_ADDR_WD           = 9,
	 parameter BIST_DATA_WD           = 32,
	 parameter BIST_ADDR_START        = 9'h000,
	 parameter BIST_ADDR_END          = 9'h1F8,
	 parameter BIST_REPAIR_ADDR_START = 9'h1FC,
	 parameter BIST_RAD_WD_I          = BIST_ADDR_WD,
	 parameter BIST_RAD_WD_O          = BIST_ADDR_WD) (
	
    output logic [BIST_RAD_WD_O-1:0] AddressOut,
    output logic                     Correct,
    output  logic                    sdo,         //  scan data output

    input logic [BIST_RAD_WD_I-1:0]  AddressIn,
    input logic                      clk,
    input logic                      rst_n,
    input logic                      Error,
    input logic [BIST_RAD_WD_I-1:0]  ErrorAddr,
    input logic                      scan_shift,  //  shift scan input
    input logic                      sdi          //  scan data input 


);

logic [3:0]   ErrorCnt; // Assumed Maximum Error correction is less than 16
logic [15:0]  shift_reg;
logic [15:0]  shift_load;
logic [7:0]   shift_cnt;
logic         scan_shift_d;
logic         shift_pos_edge;

logic [BIST_RAD_WD_I-1:0] RepairMem [0:BIST_ERR_LIMIT-1];
integer i;


always@(posedge clk or negedge rst_n)
begin
   if(!rst_n) begin
     ErrorCnt    <= '0;
     Correct <= '0;
     // Initialize the Repair RAM for SCAN purpose
     for(i =0; i < BIST_ERR_LIMIT; i = i+1) begin
        RepairMem[i] = 'h0;
     end
   end else if(Error) begin
      if(ErrorCnt <= BIST_ERR_LIMIT) begin
          ErrorCnt            <= ErrorCnt+1;
          RepairMem[ErrorCnt] <= ErrorAddr;
          Correct         <= 1'b1;
      end else begin
          Correct         <= 1'b0;
      end
   end
end

integer index;

always_comb
begin
   AddressOut = AddressIn;
   for(index=0; index < BIST_ERR_LIMIT; index=index+1) begin
      if(ErrorCnt > index && AddressIn == RepairMem[index]) AddressOut = BIST_REPAIR_ADDR_START+index;
   end
end

/********************************************
* Serial shifting the Repair address
* *******************************************/

always@(posedge clk or negedge rst_n)
begin
   if(!rst_n) begin
     shift_reg   <= '0;
     shift_cnt   <= '0;
     scan_shift_d <= 1'b0;
   end else begin
      if(scan_shift && (shift_cnt[7:4] < BIST_ERR_LIMIT)) begin
         shift_cnt <= shift_cnt+1;
      end
      scan_shift_d <= scan_shift;
      shift_reg <= shift_load;
   end
end

// Detect scan_shift pos edge
assign shift_pos_edge = (scan_shift_d ==0) && (scan_shift);

always_comb 
begin
  shift_load = shift_reg;
  // Block the data reloading every pos edge of shift
  if(scan_shift && ((shift_cnt[7:4]+1) < BIST_ERR_LIMIT) && (shift_cnt[3:0] == 4'b1111))
     shift_load = {RepairMem[shift_cnt[7:4]+1]};
  else if(scan_shift)
     shift_load = {sdi,shift_reg[15:1]};
  else
     shift_load = {RepairMem[shift_cnt[7:4]]};
  
end

assign sdo   = shift_reg[0];
endmodule






