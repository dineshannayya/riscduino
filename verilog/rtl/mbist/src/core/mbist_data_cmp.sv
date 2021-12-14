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
////  MBIST Data Comparator                                       ////
////                                                              ////
////  This file is part of the mbist_ctrl cores project           ////
////  https://github.com/dineshannayya/mbist_ctrl.git             ////
////                                                              ////
////  Description                                                 ////
////      This block integrate mbist data comparator              ////
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


module mbist_data_cmp
     #(  parameter BIST_ADDR_WD           = 9,
	 parameter BIST_DATA_WD           = 32,
	 parameter BIST_ADDR_START        = 9'h000,
	 parameter BIST_ADDR_END          = 9'h1F8,
	 parameter BIST_REPAIR_ADDR_START = 9'h1FC,
	 parameter BIST_RAD_WD_I          = BIST_ADDR_WD,
	 parameter BIST_RAD_WD_O          = BIST_ADDR_WD) (

          output  logic                      error,
	  output  logic                      error_correct,
	  output  logic                      correct,
	  output  logic [BIST_ADDR_WD-1:0]   error_addr,
          output  logic  [3:0]               error_cnt,
          input   logic                      clk,
          input   logic                      rst_n,
          input   logic                      compare, 
	  input   logic                      addr_inc_phase,
	  input   logic                      read_invert,
          input   logic  [BIST_DATA_WD-1:0]  comp_data,
          input   logic  [BIST_DATA_WD-1:0]  rxd_data,
	  input   logic [BIST_ADDR_WD-1:0]   addr
	     
	);

logic                      mask_compare;
logic  [BIST_DATA_WD-1:0]  exp_data;
logic                      comp_status;

assign exp_data = (read_invert) ? ~comp_data: comp_data;
  
/* Comparison register */

always @(posedge clk or negedge rst_n) begin
   if(!rst_n)         begin
      comp_status <= 1'b0;
      error_addr  <= 'b0;
   end else if(compare && !mask_compare)   begin
      comp_status <= |(exp_data ^ rxd_data);
      error_addr  <= addr;
   end else begin 
     comp_status <= 1'b0;
   end
end

// Due to cycle diference between compare and write opperation
// There is chance two error reported for same address
// To avoid this, once error is detected, comparision is masked
// unit the next address phase
always @(posedge clk or negedge rst_n) begin
   if(!rst_n) begin             
      error_cnt    <= 'b0;
      correct      <='b0;
      mask_compare <= 'b0;
      error        <= '0;
   end else if(mask_compare && addr_inc_phase) begin 
      mask_compare <= 1'b0;
   end else if(comp_status && (error_cnt < BIST_ERR_LIMIT) )   begin
      error_cnt    <= error_cnt+1;
      mask_compare <= 1'b1;
      correct      <='b1;
   end else if(comp_status && (error_cnt == BIST_ERR_LIMIT) )   begin
      error        <= '1;
   end 
end

assign error_correct = (error_cnt < BIST_ERR_LIMIT) ? comp_status : 1'b0;

endmodule






