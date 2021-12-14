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
////  Memory wrapper                                              ////
////                                                              ////
////  This file is part of the mbist_ctrl  project                ////
////  https://github.com/dineshannayya/mbist_ctrl.git             ////
////                                                              ////
////  Description                                                 ////
////      This block does wishbone to SRAM signal mapping         ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 18 Nov 2021, Dinesh A                               ////
////          initial version                                     ////
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
module mbist_mem_wrapper #(
	parameter BIST_ADDR_WD=10,
	parameter BIST_DATA_WD=32) (
	input   logic                          rst_n           ,
          // WB I/F
        input   logic                          wb_clk_i        ,  // System clock
        input   logic                          wb_cyc_i        ,  // strobe/request
        input   logic                          wb_stb_i        ,  // strobe/request
        input   logic [BIST_ADDR_WD-1:0]       wb_adr_i        ,  // address
        input   logic                          wb_we_i         ,  // write
        input   logic [BIST_DATA_WD-1:0]       wb_dat_i        ,  // data output
        input   logic [BIST_DATA_WD/8-1:0]     wb_sel_i        ,  // byte enable
        output  logic [BIST_DATA_WD-1:0]       wb_dat_o        ,  // data input
        output  logic                          wb_ack_o        ,  // acknowlegement
        output  logic                          wb_err_o        ,  // error
      // MEM A PORT 
        output   logic                         func_clk_a      ,
        output   logic                         func_cen_a      ,
        output   logic  [BIST_ADDR_WD-1:0]     func_addr_a     ,
        input    logic  [BIST_DATA_WD-1:0]     func_dout_a     ,

       // Functional B Port
        output   logic                         func_clk_b     ,
        output   logic                         func_cen_b     ,
        output   logic                         func_web_b     ,
        output   logic [BIST_DATA_WD/8-1:0]    func_mask_b    ,
        output   logic  [BIST_ADDR_WD-1:0]     func_addr_b    ,
        output   logic  [BIST_DATA_WD-1:0]     func_din_b     

);


// Memory Write PORT
assign func_clk_b    = wb_clk_i;
assign func_cen_b    = !wb_stb_i;
assign func_web_b    = !wb_we_i;
assign func_mask_b   = wb_sel_i;
assign func_addr_b   = wb_adr_i;
assign func_din_b    = wb_dat_i;

assign func_clk_a    = wb_clk_i;
assign func_cen_a    = (wb_stb_i == 1'b1 && wb_we_i == 1'b0 && wb_ack_o ==0) ? 1'b0 : 1'b1;
assign func_addr_a   = wb_adr_i;
assign wb_dat_o      = func_dout_a;

assign wb_err_o      = 1'b0;

// Generate Once cycle delayed ACK to get the data from SRAM
always_ff @(negedge rst_n or posedge wb_clk_i) begin
    if ( rst_n == 1'b0 ) begin
      wb_ack_o<= 'h0;
   end else begin
      wb_ack_o <= (wb_stb_i == 1'b1) & (wb_ack_o == 0);
   end
end


endmodule
