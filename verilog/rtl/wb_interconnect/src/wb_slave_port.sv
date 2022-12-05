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
////  Wishbone interconnect for slave port                        ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
////	1. This block implement simple round robine request       ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - Mar 2, 2022, Dinesh A                               ////
//////////////////////////////////////////////////////////////////////



module wb_slave_port  (
         input logic		clk_i, 
         input logic            rst_n,

         input logic [3:0]      cfg_slave_id,

         
         // Master 0 Interface
         input   logic	[31:0]	m0_wbd_dat_i,
         input   logic  [31:0]	m0_wbd_adr_i,
         input   logic  [3:0]	m0_wbd_sel_i,
         input   logic  	m0_wbd_we_i,
         input   logic  	m0_wbd_cyc_i,
         input   logic  	m0_wbd_stb_i,
         input   logic  [3:0]   m0_wbd_tid_i,
         output  logic	[31:0]	m0_wbd_dat_o,
         output  logic		m0_wbd_ack_o,
         output  logic		m0_wbd_lack_o,
         output  logic		m0_wbd_err_o,
         
         // Master 1 Interface
         input	logic [31:0]	m1_wbd_dat_i,
         input	logic [31:0]	m1_wbd_adr_i,
         input	logic [3:0]	m1_wbd_sel_i,
         input	logic [2:0]	m1_wbd_bl_i,
         input	logic    	m1_wbd_bry_i,
         input	logic 	        m1_wbd_we_i,
         input	logic 	        m1_wbd_cyc_i,
         input	logic 	        m1_wbd_stb_i,
         input  logic [3:0]     m1_wbd_tid_i,
         output	logic [31:0]	m1_wbd_dat_o,
         output	logic 	        m1_wbd_ack_o,
         output	logic 	        m1_wbd_lack_o,
         output	logic 	        m1_wbd_err_o,
         
         // Master 2 Interface
         input	logic [31:0]	m2_wbd_dat_i,
         input	logic [31:0]	m2_wbd_adr_i,
         input	logic [3:0]	m2_wbd_sel_i,
         input	logic [9:0]	m2_wbd_bl_i,
         input	logic    	m2_wbd_bry_i,
         input	logic 	        m2_wbd_we_i,
         input	logic 	        m2_wbd_cyc_i,
         input	logic 	        m2_wbd_stb_i,
         input  logic [3:0]     m2_wbd_tid_i,
         output	logic [31:0]	m2_wbd_dat_o,
         output	logic 	        m2_wbd_ack_o,
         output	logic 	        m2_wbd_lack_o,
         output	logic 	        m2_wbd_err_o,
         
         // Master 3 Interface
         input	logic [31:0]	m3_wbd_adr_i,
         input	logic [3:0]	m3_wbd_sel_i,
         input	logic [9:0]	m3_wbd_bl_i,
         input	logic    	m3_wbd_bry_i,
         input	logic 	        m3_wbd_we_i,
         input	logic 	        m3_wbd_cyc_i,
         input	logic 	        m3_wbd_stb_i,
         input  logic [3:0]     m3_wbd_tid_i,
         output	logic [31:0]	m3_wbd_dat_o,
         output	logic 	        m3_wbd_ack_o,
         output	logic 	        m3_wbd_lack_o,
         output	logic 	        m3_wbd_err_o,
         
         // Slave 0 Interface
         input	logic [31:0]	s_wbd_dat_i,
         input	logic 	        s_wbd_ack_i,
         input	logic 	        s_wbd_lack_i,
         output	logic [31:0]	s_wbd_dat_o,
         output	logic [31:0]	s_wbd_adr_o,
         output	logic [3:0]	s_wbd_sel_o,
         output	logic [9:0]	s_wbd_bl_o,
         output	logic 	        s_wbd_bry_o,
         output	logic 	        s_wbd_we_o,
         output	logic 	        s_wbd_cyc_o,
         output	logic 	        s_wbd_stb_o

	);

// WishBone Wr Interface
typedef struct packed { 
  logic	[31:0]	wbd_dat;
  logic  [31:0]	wbd_adr;
  logic  [3:0]	wbd_sel;
  logic  [9:0]	wbd_bl;
  logic  	wbd_bry;
  logic  	wbd_we;
  logic  	wbd_cyc;
  logic  	wbd_stb;
  logic [3:0] 	wbd_tid; // target id
} type_wb_wr_intf;

// WishBone Rd Interface
typedef struct packed { 
  logic	[31:0]	wbd_dat;
  logic  	wbd_ack;
  logic  	wbd_lack;
  logic  	wbd_err;
} type_wb_rd_intf;


// Master Write Interface
type_wb_wr_intf  m0_wb_wr;
type_wb_wr_intf  m1_wb_wr;
type_wb_wr_intf  m2_wb_wr;
type_wb_wr_intf  m3_wb_wr;

// Master Read Interface
type_wb_rd_intf  m0_wb_rd;
type_wb_rd_intf  m1_wb_rd;
type_wb_rd_intf  m2_wb_rd;
type_wb_rd_intf  m3_wb_rd;

wire m0_stb_i = (m0_wbd_stb_i & (m0_wbd_tid_i== cfg_slave_id));
wire m1_stb_i = (m1_wbd_stb_i & (m1_wbd_tid_i== cfg_slave_id));
wire m2_stb_i = (m2_wbd_stb_i & (m2_wbd_tid_i== cfg_slave_id));
wire m3_stb_i = (m3_wbd_stb_i & (m3_wbd_tid_i== cfg_slave_id));

type_wb_wr_intf  m_bus_wr;  // Multiplexed Master I/F
type_wb_rd_intf  m_bus_rd;  // Multiplexed Slave I/F

//----------------------------------------
// Master Mapping
// -------------------------------------
assign m0_wb_wr.wbd_dat = m0_wbd_dat_i;
assign m0_wb_wr.wbd_adr = {m0_wbd_adr_i[31:2],2'b00};
assign m0_wb_wr.wbd_sel = m0_wbd_sel_i;
assign m0_wb_wr.wbd_bl  = 'h1;
assign m0_wb_wr.wbd_bry = 'b1;
assign m0_wb_wr.wbd_we  = m0_wbd_we_i;
assign m0_wb_wr.wbd_cyc = m0_wbd_cyc_i;
assign m0_wb_wr.wbd_stb = m0_stb_i;
assign m0_wb_wr.wbd_tid = m0_wbd_tid_i;

assign m1_wb_wr.wbd_dat = m1_wbd_dat_i;
assign m1_wb_wr.wbd_adr = {m1_wbd_adr_i[31:2],2'b00};
assign m1_wb_wr.wbd_sel = m1_wbd_sel_i;
assign m1_wb_wr.wbd_bl  = {7'b0,m1_wbd_bl_i};
assign m1_wb_wr.wbd_bry = m1_wbd_bry_i;
assign m1_wb_wr.wbd_we  = m1_wbd_we_i;
assign m1_wb_wr.wbd_cyc = m1_wbd_cyc_i;
assign m1_wb_wr.wbd_stb = m1_stb_i;
assign m1_wb_wr.wbd_tid = m1_wbd_tid_i;

assign m2_wb_wr.wbd_dat = m2_wbd_dat_i;
assign m2_wb_wr.wbd_adr = {m2_wbd_adr_i[31:2],2'b00};
assign m2_wb_wr.wbd_sel = m2_wbd_sel_i;
assign m2_wb_wr.wbd_bl  = m2_wbd_bl_i;
assign m2_wb_wr.wbd_bry = m2_wbd_bry_i;
assign m2_wb_wr.wbd_we  = m2_wbd_we_i;
assign m2_wb_wr.wbd_cyc = m2_wbd_cyc_i;
assign m2_wb_wr.wbd_stb = m2_stb_i;
assign m2_wb_wr.wbd_tid = m2_wbd_tid_i;

assign m3_wb_wr.wbd_dat = 'h0;
assign m3_wb_wr.wbd_adr = {m3_wbd_adr_i[31:2],2'b00};
assign m3_wb_wr.wbd_sel = m3_wbd_sel_i;
assign m3_wb_wr.wbd_bl  = m3_wbd_bl_i;
assign m3_wb_wr.wbd_bry = m3_wbd_bry_i;
assign m3_wb_wr.wbd_we  = m3_wbd_we_i;
assign m3_wb_wr.wbd_cyc = m3_wbd_cyc_i;
assign m3_wb_wr.wbd_stb = m3_stb_i;
assign m3_wb_wr.wbd_tid = m3_wbd_tid_i;

assign m0_wbd_dat_o  =  m0_wb_rd.wbd_dat;
assign m0_wbd_ack_o  =  m0_wb_rd.wbd_ack;
assign m0_wbd_lack_o =  m0_wb_rd.wbd_lack;
assign m0_wbd_err_o  =  m0_wb_rd.wbd_err;

assign m1_wbd_dat_o  =  m1_wb_rd.wbd_dat;
assign m1_wbd_ack_o  =  m1_wb_rd.wbd_ack;
assign m1_wbd_lack_o =  m1_wb_rd.wbd_lack;
assign m1_wbd_err_o  =  m1_wb_rd.wbd_err;

assign m2_wbd_dat_o  =  m2_wb_rd.wbd_dat;
assign m2_wbd_ack_o  =  m2_wb_rd.wbd_ack;
assign m2_wbd_lack_o =  m2_wb_rd.wbd_lack;
assign m2_wbd_err_o  =  m2_wb_rd.wbd_err;

assign m3_wbd_dat_o  =  m3_wb_rd.wbd_dat;
assign m3_wbd_ack_o  =  m3_wb_rd.wbd_ack;
assign m3_wbd_lack_o =  m3_wb_rd.wbd_lack;
assign m3_wbd_err_o  =  m3_wb_rd.wbd_err;

//
// arbitor 
//
logic [1:0]  gnt;
wb_arb	u_wb_arb(
	.clk(clk_i), 
	.rstn(rst_n),
	.req({	m3_stb_i & !m3_wbd_lack_o,
	        m2_stb_i & !m2_wbd_lack_o,
		m1_stb_i & !m1_wbd_lack_o,
		m0_stb_i & !m0_wbd_lack_o}),
	.gnt(gnt)
);

// Generate Multiplexed Master Interface based on grant
always_comb begin
     case(gnt)
        2'h0:	   m_bus_wr = m0_wb_wr;
        2'h1:	   m_bus_wr = m1_wb_wr;
        2'h2:	   m_bus_wr = m2_wb_wr;
        2'h3:	   m_bus_wr = m3_wb_wr;
        default:   m_bus_wr = m0_wb_wr;
     endcase			
end

// Stagging FF to break write and read timing path
sync_wbb u_sync_wbb(
         .clk_i            (clk_i               ), 
         .rst_n            (rst_n               ),
         // WishBone Input master I/P
         .wbm_dat_i      (m_bus_wr.wbd_dat    ),
         .wbm_adr_i      (m_bus_wr.wbd_adr    ),
         .wbm_sel_i      (m_bus_wr.wbd_sel    ),
         .wbm_bl_i       (m_bus_wr.wbd_bl     ),
         .wbm_bry_i      (m_bus_wr.wbd_bry    ),
         .wbm_we_i       (m_bus_wr.wbd_we     ),
         .wbm_cyc_i      (m_bus_wr.wbd_cyc    ),
         .wbm_stb_i      (m_bus_wr.wbd_stb    ),
         .wbm_tid_i      (m_bus_wr.wbd_tid    ),
         .wbm_dat_o      (m_bus_rd.wbd_dat    ),
         .wbm_ack_o      (m_bus_rd.wbd_ack    ),
         .wbm_lack_o     (m_bus_rd.wbd_lack   ),
         .wbm_err_o      (m_bus_rd.wbd_err    ),

         // Slave Interface
         .wbs_dat_i      (s_wbd_dat_i    ),
         .wbs_ack_i      (s_wbd_ack_i    ),
         .wbs_lack_i     (s_wbd_lack_i   ),
         .wbs_err_i      (1'b0           ),
         .wbs_dat_o      (s_wbd_dat_o    ),
         .wbs_adr_o      (s_wbd_adr_o    ),
         .wbs_sel_o      (s_wbd_sel_o    ),
         .wbs_bl_o       (s_wbd_bl_o     ),
         .wbs_bry_o      (s_wbd_bry_o    ),
         .wbs_we_o       (s_wbd_we_o     ),
         .wbs_cyc_o      (s_wbd_cyc_o    ),
         .wbs_stb_o      (s_wbd_stb_o    ),
         .wbs_tid_o      (               )

);

// Connect Slave to Master
assign  m0_wb_rd = (gnt == 2'b00) ? m_bus_rd : 'h0;
assign  m1_wb_rd = (gnt == 2'b01) ? m_bus_rd : 'h0;
assign  m2_wb_rd = (gnt == 2'b10) ? m_bus_rd : 'h0;
assign  m3_wb_rd = (gnt == 2'b11) ? m_bus_rd : 'h0;

endmodule
