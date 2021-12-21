//////////////////////////////////////////////////////////////////////////////
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
////  MBIST and MEMORY Mux Control Selection                      ////
////                                                              ////
////  This file is part of the mbist_ctrl cores project           ////
////  https://github.com/dineshannayya/mbist_ctrl.git             ////
////                                                              ////
////  Description                                                 ////
////      This block integrate MBIST and Memory control selection ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.0 - 11th Oct 2021, Dinesh A                             ////
////          Initial integration 
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "mbist_def.svh"
module   mbist_mux
     #(  parameter BIST_ADDR_WD           = 9,
	 parameter BIST_DATA_WD           = 32,
	 parameter BIST_ADDR_START        = 9'h000,
	 parameter BIST_ADDR_END          = 9'h1F8,
	 parameter BIST_REPAIR_ADDR_START = 9'h1FC,
	 parameter BIST_RAD_WD_I          = BIST_ADDR_WD,
	 parameter BIST_RAD_WD_O          = BIST_ADDR_WD) (

      input   logic                      scan_mode,

      input   logic                      rst_n,
      // MBIST CTRL SIGNAL
      input   logic                      bist_en,
      input   logic  [BIST_ADDR_WD-1:0]  bist_addr,
      input   logic  [BIST_DATA_WD-1:0]  bist_wdata,
      input   logic                      bist_clk,
      input   logic                      bist_wr,
      input   logic                      bist_rd,
      input   logic                      bist_error,
      input   logic  [BIST_ADDR_WD-1:0]  bist_error_addr,
      output  logic                      bist_correct,
      input   logic                      bist_sdi,
      input   logic                      bist_load,
      input   logic                      bist_shift,
      output  logic                      bist_sdo,

      input   logic                      func_clk,
      input   logic                      func_cen,
      input   logic                      func_web,
      input   logic [BIST_DATA_WD/8-1:0] func_mask,
      input   logic  [BIST_ADDR_WD-1:0]  func_addr,
      input   logic  [BIST_DATA_WD-1:0]  func_din,
      output  logic  [BIST_DATA_WD-1:0]  func_dout,


     // towards memory

      output logic                       mem_clk,
      output logic                       mem_cen,
      output logic                       mem_web,
      output logic [BIST_DATA_WD/8-1:0]  mem_mask,
      output logic   [BIST_ADDR_WD-1:0]  mem_addr,
      output logic   [BIST_DATA_WD-1:0]  mem_din,
      input  logic   [BIST_DATA_WD-1:0]  mem_dout
    );


parameter BIST_MASK_WD = BIST_DATA_WD/8;

wire   [BIST_ADDR_WD-1:0]      addr;



assign addr   = (bist_en) ? bist_addr   : func_addr;

assign mem_cen    = (bist_en) ? !(bist_rd | bist_wr)   : func_cen;
assign mem_web    = (bist_en) ? !bist_wr   : func_web;
assign mem_mask   = (bist_en) ? {{BIST_MASK_WD}{1'b1}} : func_mask;

//assign mem_clk_a    = (bist_en) ? bist_clk   : func_clk_a;
//assign mem_clk_b    = (bist_en) ? bist_clk   : func_clk_b;

ctech_mux2x1 u_mem_clk_sel (.A0 (func_clk),.A1 (bist_clk),.S  (bist_en),     .X  (mem_clk));

//ctech_clk_buf u_mem_clk (.A (mem_clk_cts), . X(mem_clk));

assign mem_din    = (bist_en) ? bist_wdata   : func_din;



// During scan, SRAM data is unknown, feed data in back to avoid unknow
// propagation
assign func_dout   =  (scan_mode) ?  mem_din : mem_dout;

mbist_repair_addr 
      #(.BIST_ADDR_WD           (BIST_ADDR_WD),
	.BIST_DATA_WD           (BIST_DATA_WD),
	.BIST_ADDR_START        (BIST_ADDR_START),
	.BIST_ADDR_END          (BIST_ADDR_END),
	.BIST_REPAIR_ADDR_START (BIST_REPAIR_ADDR_START),
	.BIST_RAD_WD_I          (BIST_RAD_WD_I),
	.BIST_RAD_WD_O          (BIST_RAD_WD_O)) 
     u_repair(
    .AddressOut    (mem_addr         ),
    .Correct       (bist_correct     ),
    .sdo           (bist_sdo         ),

    .AddressIn     (addr             ),
    .clk           (mem_clk          ),
    .rst_n         (rst_n            ),
    .Error         (bist_error       ),
    .ErrorAddr     (bist_error_addr  ),
    .bist_load     (bist_load       ),
    .bist_shift    (bist_shift       ),
    .sdi           (bist_sdi         )
);





endmodule











