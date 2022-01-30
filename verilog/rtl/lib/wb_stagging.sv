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
//----------------------------------------------------------------------
// This logic create a holding register for Wishbone interface.
// This is usefull to break timing issue at interconnect
//
// Limitation: Due to stagging FF, Continous Burst of Wishbone will have one
// cycle break between each transaction
//----------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Wishbone Stagging FF                                        ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  https://github.com/dineshannayya/yifive_r0.git              ////
////  http://www.opencores.org/cores/yifive/                      ////
////                                                              ////
////  Description                                                 ////
////    This logic create a holding FF for Wishbone interface.    ////
////    This is usefull to break timing issue at interconnect     ////
////                                                              ////
////  Limitation: Due to stagging FF, Continous Burst of          ////
////  Wishbone will have one cycle break between each transaction ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 12th June 2021, Dinesh A                            ////
////                                                              ////
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


module wb_stagging (
         input logic		clk_i, 
         input logic            rst_n,
         // WishBone Input master I/P
         input   logic	[31:0]	m_wbd_dat_i,
         input   logic  [31:0]	m_wbd_adr_i,
         input   logic  [3:0]	m_wbd_sel_i,
         input   logic  [9:0]	m_wbd_bl_i,
         input   logic  	m_wbd_bry_i,
         input   logic  	m_wbd_we_i,
         input   logic  	m_wbd_cyc_i,
         input   logic  	m_wbd_stb_i,
         input   logic  [3:0]	m_wbd_tid_i,
         output  logic	[31:0]	m_wbd_dat_o,
         output  logic		m_wbd_ack_o,
         output  logic		m_wbd_lack_o,
         output  logic		m_wbd_err_o,

         // Slave Interface
         input	logic [31:0]	s_wbd_dat_i,
         input	logic 	        s_wbd_ack_i,
         input	logic 	        s_wbd_lack_i,
         input	logic 	        s_wbd_err_i,
         output	logic [31:0]	s_wbd_dat_o,
         output	logic [31:0]	s_wbd_adr_o,
         output	logic [3:0]	s_wbd_sel_o,
         output	logic [9:0]	s_wbd_bl_o,
         output	logic    	s_wbd_bry_o,
         output	logic 	        s_wbd_we_o,
         output	logic 	        s_wbd_cyc_o,
         output	logic 	        s_wbd_stb_o,
         output	logic [3:0]	s_wbd_tid_o

);

logic [31:0] m_wbd_dat_i_ff ; // Flopped vesion of m_wbd_dat_i
logic [31:0] m_wbd_adr_i_ff ; // Flopped vesion of m_wbd_adr_i
logic [3:0]  m_wbd_sel_i_ff ; // Flopped vesion of m_wbd_sel_i
logic [9:0]  m_wbd_bl_i_ff ;  // Flopped vesion of m_wbd_bl_i
logic        m_wbd_bry_i_ff ; // Flopped vesion of m_wbd_bry_i
logic        m_wbd_we_i_ff  ; // Flopped vesion of m_wbd_we_i
logic        m_wbd_cyc_i_ff ; // Flopped vesion of m_wbd_cyc_i
logic        m_wbd_stb_i_ff ; // Flopped vesion of m_wbd_stb_i
logic [3:0]  m_wbd_tid_i_ff ; // Flopped vesion of m_wbd_tid_i
logic [31:0] s_wbd_dat_i_ff ; // Flopped vesion of s_wbd_dat_i
logic        s_wbd_ack_i_ff ; // Flopped vesion of s_wbd_ack_i
logic        s_wbd_lack_i_ff ; // Flopped vesion of s_wbd_ack_i
logic        s_wbd_err_i_ff ; // Flopped vesion of s_wbd_err_i


assign s_wbd_dat_o = m_wbd_dat_i_ff;
assign s_wbd_adr_o = m_wbd_adr_i_ff;
assign s_wbd_sel_o = m_wbd_sel_i_ff;
assign s_wbd_bl_o  = m_wbd_bl_i_ff;
assign s_wbd_bry_o = m_wbd_bry_i_ff;
assign s_wbd_we_o  = m_wbd_we_i_ff;
assign s_wbd_cyc_o = m_wbd_cyc_i_ff;
assign s_wbd_stb_o = m_wbd_stb_i_ff;
assign s_wbd_tid_o = m_wbd_tid_i_ff;

assign m_wbd_dat_o = s_wbd_dat_i_ff;
assign m_wbd_ack_o = s_wbd_ack_i_ff;
assign m_wbd_lack_o = s_wbd_lack_i_ff;
assign m_wbd_err_o = s_wbd_err_i_ff;

always @(negedge rst_n or posedge clk_i)
begin
   if(rst_n == 1'b0) begin
       m_wbd_dat_i_ff <= 'h0;
       m_wbd_adr_i_ff <= 'h0;
       m_wbd_sel_i_ff <= 'h0;
       m_wbd_bl_i_ff  <= 'h0;
       m_wbd_bry_i_ff <= 'b0;
       m_wbd_we_i_ff  <= 'h0;
       m_wbd_cyc_i_ff <= 'h0;
       m_wbd_stb_i_ff <= 'h0;
       m_wbd_tid_i_ff <= 'h0;
       s_wbd_dat_i_ff <= 'h0;
       s_wbd_ack_i_ff <= 'h0;
       s_wbd_lack_i_ff <= 'h0;
       s_wbd_err_i_ff <= 'h0;
   end else begin
       s_wbd_dat_i_ff  <= s_wbd_dat_i;
       s_wbd_ack_i_ff  <= s_wbd_ack_i;
       s_wbd_lack_i_ff <= s_wbd_lack_i;
       s_wbd_err_i_ff <= s_wbd_err_i;
       if((m_wbd_stb_i && m_wbd_bry_i && s_wbd_ack_i == 0 && m_wbd_lack_o == 0) ||
          (m_wbd_stb_i && m_wbd_bry_i && s_wbd_ack_i == 1 && s_wbd_lack_i == 0)) begin
          m_wbd_dat_i_ff <= m_wbd_dat_i;
          m_wbd_adr_i_ff <= m_wbd_adr_i;
          m_wbd_sel_i_ff <= m_wbd_sel_i;
          m_wbd_we_i_ff  <= m_wbd_we_i;
          m_wbd_cyc_i_ff <= m_wbd_cyc_i;
          m_wbd_stb_i_ff <= m_wbd_stb_i;
          m_wbd_tid_i_ff <= m_wbd_tid_i;
          m_wbd_bl_i_ff  <= m_wbd_bl_i;
          m_wbd_bry_i_ff <= 'b1;
       end else  if ((m_wbd_stb_i && !m_wbd_bry_i && s_wbd_ack_i == 1 && s_wbd_lack_i == 0)) begin // De-Assert burst ready
          m_wbd_bry_i_ff <= 'b0;
       end else if (s_wbd_lack_i) begin
          m_wbd_dat_i_ff <= 'h0;
          m_wbd_adr_i_ff <= 'h0;
          m_wbd_sel_i_ff <= 'h0;
          m_wbd_we_i_ff  <= 'h0;
          m_wbd_cyc_i_ff <= 'h0;
          m_wbd_stb_i_ff <= 'h0;
          m_wbd_tid_i_ff <= 'h0;
          m_wbd_bl_i_ff  <= 'h0;
          m_wbd_bry_i_ff <= 'b0;
       end
   end
end


endmodule

