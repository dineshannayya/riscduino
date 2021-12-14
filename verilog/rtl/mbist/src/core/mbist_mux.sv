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
      input   logic                      bist_shift,
      output  logic                      bist_sdo,

      // FUNCTIONAL CTRL SIGNAL
      input   logic                      func_clk_a,
      input   logic                      func_cen_a,
      input   logic  [BIST_ADDR_WD-1:0]  func_addr_a,
      // Common for func and Mbist i/f
      output  logic  [BIST_DATA_WD-1:0]  func_dout_a,

      input   logic                      func_clk_b,
      input   logic                      func_cen_b,
      input   logic                      func_web_b,
      input   logic [BIST_DATA_WD/8-1:0] func_mask_b,
      input   logic  [BIST_ADDR_WD-1:0]  func_addr_b,
      input   logic  [BIST_DATA_WD-1:0]  func_din_b,


     // towards memory
      output logic                       mem_clk_a,
      output logic                       mem_cen_a,
      output logic   [BIST_ADDR_WD-1:0]  mem_addr_a,
      input  logic   [BIST_DATA_WD-1:0]  mem_dout_a,

      output logic                       mem_clk_b,
      output logic                       mem_cen_b,
      output logic                       mem_web_b,
      output logic [BIST_DATA_WD/8-1:0]  mem_mask_b,
      output logic   [BIST_ADDR_WD-1:0]  mem_addr_b,
      output logic   [BIST_DATA_WD-1:0]  mem_din_b
    );


parameter BIST_MASK_WD = BIST_DATA_WD/8;

wire   [BIST_ADDR_WD-1:0]      addr_a;
wire   [BIST_ADDR_WD-1:0]      addr_b;
wire                           mem_clk_a_cts; // used for internal clock tree
wire                           mem_clk_b_cts; // usef for internal clock tree



assign addr_a   = (bist_en) ? bist_addr   : func_addr_a;
assign addr_b   = (bist_en) ? bist_addr   : func_addr_b;

assign mem_cen_a    = (bist_en) ? !bist_rd   : func_cen_a;
assign mem_cen_b    = (bist_en) ? !bist_wr   : func_cen_b;

assign mem_web_b    = (bist_en) ? !bist_wr   : func_web_b;
assign mem_mask_b   = (bist_en) ? {{BIST_MASK_WD}{1'b1}}       : func_mask_b;

//assign mem_clk_a    = (bist_en) ? bist_clk   : func_clk_a;
//assign mem_clk_b    = (bist_en) ? bist_clk   : func_clk_b;

ctech_mux2x1 u_mem_clk_a_sel (.A0 (func_clk_a),.A1 (bist_clk),.S  (bist_en),     .X  (mem_clk_a));
ctech_mux2x1 u_mem_clk_b_sel (.A0 (func_clk_b),.A1 (bist_clk),.S  (bist_en),     .X  (mem_clk_b));

ctech_clk_buf u_cts_mem_clk_a (.A (mem_clk_a), . X(mem_clk_a_cts));
ctech_clk_buf u_cts_mem_clk_b (.A (mem_clk_b), . X(mem_clk_b_cts));

assign mem_din_b    = (bist_en) ? bist_wdata   : func_din_b;



// During scan, SRAM data is unknown, feed data in back to avoid unknow
// propagation
assign func_dout_a   =  (scan_mode) ?  mem_din_b : mem_dout_a;

mbist_repair_addr 
      #(.BIST_ADDR_WD           (BIST_ADDR_WD),
	.BIST_DATA_WD           (BIST_DATA_WD),
	.BIST_ADDR_START        (BIST_ADDR_START),
	.BIST_ADDR_END          (BIST_ADDR_END),
	.BIST_REPAIR_ADDR_START (BIST_REPAIR_ADDR_START),
	.BIST_RAD_WD_I          (BIST_RAD_WD_I),
	.BIST_RAD_WD_O          (BIST_RAD_WD_O)) 
     u_repair_A(
    .AddressOut    (mem_addr_a       ),
    .Correct       (bist_correct     ),
    .sdo           (bist_sdo         ),

    .AddressIn     (addr_a           ),
    .clk           (mem_clk_a_cts    ),
    .rst_n         (rst_n            ),
    .Error         (bist_error       ),
    .ErrorAddr     (bist_error_addr  ),
    .scan_shift    (bist_shift       ),
    .sdi           (bist_sdi         )
);

mbist_repair_addr 
      #(.BIST_ADDR_WD           (BIST_ADDR_WD),
	.BIST_DATA_WD           (BIST_DATA_WD),
	.BIST_ADDR_START        (BIST_ADDR_START),
	.BIST_ADDR_END          (BIST_ADDR_END),
	.BIST_REPAIR_ADDR_START (BIST_REPAIR_ADDR_START),
	.BIST_RAD_WD_I          (BIST_RAD_WD_I),
	.BIST_RAD_WD_O          (BIST_RAD_WD_O)) 
    u_repair_B(
    .AddressOut    (mem_addr_b      ),
    .Correct       (                ), // Both Bist Correct are same
    .sdo           (                ),

    .AddressIn     (addr_b          ),
    .clk           (mem_clk_b_cts   ),
    .rst_n         (rst_n           ),
    .Error         (bist_error      ),
    .ErrorAddr     (bist_error_addr ),
    .scan_shift    (1'b0            ), // Both Repair hold same address
    .sdi           (1'b0            )
);




endmodule











