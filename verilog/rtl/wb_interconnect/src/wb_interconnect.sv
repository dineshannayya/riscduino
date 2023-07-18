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
////  Wishbone Interconnect                                       ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  https://github.com/dineshannayya/yifive_r0.git              ////
////  http://www.opencores.org/cores/yifive/                      ////
////                                                              ////
////  Description                                                 ////
////	1. 3 masters and 3 slaves share bus Wishbone connection   ////
////	2. This block implement simple round robine request       ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 12th June 2021, Dinesh A                            ////
////    0.2 - 17th June 2021, Dinesh A                            ////
////          Stagging FF added at Slave Interface to break       ////
////          path                                                ////
////    0.3 - 21th June 2021, Dinesh A                            ////
////          slave port 3 added for uart                         ////
////    0.4 - 25th June 2021, Dinesh A                            ////
////          External Memory Map changed and made same as        ////
////          internal memory map                                 ////
////    0.4 - 27th June 2021, Dinesh A                            ////
////          unused tie off at digital core level brought inside ////
////          to avoid core level power hook up                   ////
////    0.5 - 28th June 2021, Dinesh A                            ////
////          interchange the Master port for better physical     ////
////          placement                                           ////
////          m0: external host                                   ////
////          m1: risc imem                                       ////
////          m2: risc dmem                                       ////
////   0.6 - 06 Nov 2021, Dinesh A                                ////
////          Push the clock skew logic inside the block due to   ////
////          global power hooking challanges for small block at  ////
////          top level                                           ////
////   0.7 - 07 Dec 2021, Dinesh A                                ////
////         Buffer channel are added insider wb_inter to simply  ////
////         global routing                                       ////
////   0.8  -10 Dec 2021 , Dinesh A                               ////
////         two more slave port added for MBIST and ADC port     ////
////         removed                                              ////
////         Memory remap added to move the RISC Program memory   ////
////         to SRAM Memory                                       ////
////   0.9  - 15 Dec 2021, Dinesh A                               ////
////         Consolidated 4 MBIST port into one 8KB Port          ////
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



module wb_interconnect #(
	parameter CH_CLK_WD = 7,
	parameter CH_DATA_WD = 103
        ) (
`ifdef USE_POWER_PINS
         input logic            vccd1,    // User area 1 1.8V supply
         input logic            vssd1,    // User area 1 digital ground
`endif
	 // Bus repeaters
	     input [CH_CLK_WD-1:0]  ch_clk_in,
	     output [CH_CLK_WD-1:0] ch_clk_out,
	     input [CH_DATA_WD-1:0] ch_data_in,
	     output [CH_DATA_WD-1:0]ch_data_out,

         // Clock Skew Adjust
         input logic [3:0]      cfg_cska_wi,
         input logic            wbd_clk_int,
	     output logic           wbd_clk_wi,


         input logic            mclk_raw,
         input logic		    clk_i, 
         input logic            rst_n,

         output logic           peri_wbclk,
         output logic           riscv_wbclk,

         
         // Master 0 Interface
         input   logic	[31:0]	m0_wbd_dat_i,
         input   logic  [31:0]	m0_wbd_adr_i,
         input   logic  [3:0]	m0_wbd_sel_i,
         input   logic  	    m0_wbd_we_i,
         input   logic  	    m0_wbd_cyc_i,
         input   logic  	    m0_wbd_stb_i,
         output  logic	[31:0]	m0_wbd_dat_o,
         output  logic		    m0_wbd_ack_o,
         output  logic		    m0_wbd_lack_o,
         output  logic		    m0_wbd_err_o,
         
         // Master 1 Interface
         input	logic [31:0]	m1_wbd_dat_i,
         input	logic [31:0]	m1_wbd_adr_i,
         input	logic [3:0]	    m1_wbd_sel_i,
         input	logic [2:0]	    m1_wbd_bl_i,
         input	logic    	    m1_wbd_bry_i,
         input	logic 	        m1_wbd_we_i,
         input	logic 	        m1_wbd_cyc_i,
         input	logic 	        m1_wbd_stb_i,
         output	logic [31:0]	m1_wbd_dat_o,
         output	logic 	        m1_wbd_ack_o,
         output	logic 	        m1_wbd_lack_o,
         output	logic 	        m1_wbd_err_o,
         
         // Master 2 Interface
         input	logic [31:0]	m2_wbd_dat_i,
         input	logic [31:0]	m2_wbd_adr_i,
         input	logic [3:0]	    m2_wbd_sel_i,
         input	logic [9:0]	    m2_wbd_bl_i,
         input	logic    	    m2_wbd_bry_i,
         input	logic 	        m2_wbd_we_i,
         input	logic 	        m2_wbd_cyc_i,
         input	logic 	        m2_wbd_stb_i,
         output	logic [31:0]	m2_wbd_dat_o,
         output	logic 	        m2_wbd_ack_o,
         output	logic 	        m2_wbd_lack_o,
         output	logic 	        m2_wbd_err_o,
         
         // Master 3 Interface
         input	logic [31:0]	m3_wbd_adr_i,
         input	logic [3:0]	    m3_wbd_sel_i,
         input	logic [9:0]	    m3_wbd_bl_i,
         input	logic    	    m3_wbd_bry_i,
         input	logic 	        m3_wbd_we_i,
         input	logic 	        m3_wbd_cyc_i,
         input	logic 	        m3_wbd_stb_i,
         output	logic [31:0]	m3_wbd_dat_o,
         output	logic 	        m3_wbd_ack_o,
         output	logic 	        m3_wbd_lack_o,
         output	logic 	        m3_wbd_err_o,
         
         // Slave 0 Interface
         output logic           s0_mclk,
         input  logic           s0_idle,
         input	logic [31:0]	s0_wbd_dat_i,
         input	logic 	        s0_wbd_ack_i,
         input	logic 	        s0_wbd_lack_i,
         //input	logic 	s0_wbd_err_i, - unused
         output	logic [31:0]	s0_wbd_dat_o,
         output	logic [31:0]	s0_wbd_adr_o,
         output	logic [3:0]	    s0_wbd_sel_o,
         output	logic [9:0]	    s0_wbd_bl_o,
         output	logic 	        s0_wbd_bry_o,
         output	logic 	        s0_wbd_we_o,
         output	logic 	        s0_wbd_cyc_o,
         output	logic 	        s0_wbd_stb_o,
         
         // Slave 1 Interface
         output logic           s1_mclk,
         input	logic [31:0]	s1_wbd_dat_i,
         input	logic 	        s1_wbd_ack_i,
         // input	logic 	s1_wbd_err_i, - unused
         output	logic [31:0]	s1_wbd_dat_o,
         output	logic [8:0]	    s1_wbd_adr_o, // Uart
         output	logic [3:0]	    s1_wbd_sel_o,
         output	logic 	        s1_wbd_we_o,
         output	logic 	        s1_wbd_cyc_o,
         output	logic 	        s1_wbd_stb_o,
         
         // Slave 2 Interface
         output logic           s2_mclk,
         input	logic [31:0]	s2_wbd_dat_i,
         input	logic 	        s2_wbd_ack_i,
         // input	logic 	s2_wbd_err_i, - unused
         output	logic [31:0]	s2_wbd_dat_o,
         output	logic [10:0]	s2_wbd_adr_o, // glbl reg need only 9 bits
         output	logic [3:0]	    s2_wbd_sel_o,
         output	logic 	        s2_wbd_we_o,
         output	logic 	        s2_wbd_cyc_o,
         output	logic 	        s2_wbd_stb_o

	);

////////////////////////////////////////////////////////////////////
//
// Type define
//

parameter TARGET_SPI_MEM  = 4'b0000;
parameter TARGET_SPI_REG  = 4'b0000;
parameter TARGET_UART     = 4'b0001;
parameter TARGET_PINMUX   = 4'b0010;
parameter TARGET_WBI      = 4'b0011;

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
type_wb_wr_intf m0_wb_wr;
type_wb_wr_intf m1_wb_wr;
type_wb_wr_intf m2_wb_wr;
type_wb_wr_intf m3_wb_wr;

// Master Read Interface
type_wb_rd_intf  m0_bus_rd;
type_wb_rd_intf  m1_bus_rd;
type_wb_rd_intf  m2_bus_rd;
type_wb_rd_intf  m3_bus_rd;


type_wb_rd_intf  m0_s0_wb_rd;
type_wb_rd_intf  m1_s0_wb_rd;
type_wb_rd_intf  m2_s0_wb_rd;
type_wb_rd_intf  m3_s0_wb_rd;

type_wb_rd_intf  m0_s1_wb_rd;
type_wb_rd_intf  m1_s1_wb_rd;
type_wb_rd_intf  m2_s1_wb_rd;
type_wb_rd_intf  m3_s1_wb_rd;

type_wb_rd_intf  m0_s2_wb_rd;
type_wb_rd_intf  m1_s2_wb_rd;
type_wb_rd_intf  m2_s2_wb_rd;
type_wb_rd_intf  m3_s2_wb_rd;


// Slave Write Interface
type_wb_wr_intf  s0_wb_wr;
type_wb_wr_intf  s1_wb_wr;
type_wb_wr_intf  s2_wb_wr;
type_wb_wr_intf  wbi_wb_wr;

// Slave Read Interface
type_wb_rd_intf  s0_wb_rd;
type_wb_rd_intf  s1_wb_rd;
type_wb_rd_intf  s2_wb_rd;
type_wb_rd_intf  wbi_wb_rd;

//------------------------------------
// Register I/F
//------------------------------------
logic             reg_wbi_cs;
logic             reg_wbi_wr;
logic  [4:0]      reg_wbi_addr;
logic  [31:0]     reg_wbi_wdata;
logic  [3:0]      reg_wbi_be;

logic  [31:0]     reg_wbi_rdata;
logic             reg_wbi_ack;

//------------------------------------
// Dynamic Clock gate config
//------------------------------------
logic   [31:0]     cfg_dcg_ctrl;

//------------------------------------
// clock gate indication
//------------------------------------
logic   [7:0]     stat_reg_req; 
logic   [7:0]     stat_clk_gate; 
logic   [7:0]     stat_clk_gate_ss; 


//--------------------------------------


// channel repeater
assign ch_clk_out  = ch_clk_in;
assign ch_data_out = ch_data_in;

// Wishbone interconnect clock skew control
clk_skew_adjust u_skew_wi
       (
`ifdef USE_POWER_PINS
               .vccd1      (vccd1                      ),// User area 1 1.8V supply
               .vssd1      (vssd1                      ),// User area 1 digital ground
`endif
	       .clk_in     (wbd_clk_int                 ), 
	       .sel        (cfg_cska_wi                 ), 
	       .clk_out    (wbd_clk_wi                  ) 
       );

//--------------------------------------------------------------------------------------
// Dummy clock gate to balence avoid clk-skew between two branch for simulation handling
//--------------------------------------------------------------------------------------
logic clk_g;
ctech_clk_gate u_wbi_clkgate (.GATE (1'b1), . CLK(clk_i), .GCLK(clk_g));

//----------------------------------------
// Reset Sync
//----------------------------------------
logic rst_ssn;

reset_sync  u_rst_sync (
	      .scan_mode  (1'b0       ),
          .dclk       (clk_g       ), // Destination clock domain
	      .arst_n     (rst_n      ), // active low async reset
          .srst_n     (rst_ssn    )
          );

//-------------------------------------------------------------------
// EXTERNAL MEMORY MAP
// 0x0000_0000 to 0x0FFF_FFFF  - QSPI MEMORY
// 0x1000_0000 to 0x1000_00FF  - QSPIM REG
// 0x1001_0000 to 0x1001_003F  - UART
// 0x1001_0040 to 0x1001_007F  - I2C
// 0x1001_0080 to 0x1001_00BF  - USB
// 0x1001_00C0 to 0x1001_00FF  - SSPIM
// 0x1001_0100 to 0x1001_013F  - UART1
// 0x1002_0000 to 0x1002_00FF  - PINMUX
// 0x1003_0000 to 0x1003_00FF  - WBI
// 0x3080_0000 to 0x3080_00FF  - WB HOST (This decoding happens at wb_host block)
// ---------------------------------------------------------------------------
//
wire [3:0] m0_wbd_tid_i       = (m0_wbd_adr_i[31:28] == 4'b0000   ) ? TARGET_SPI_MEM :   // SPI
                                (m0_wbd_adr_i[31:16] == 16'h1000  ) ? TARGET_SPI_REG :   // SPI REG
                                (m0_wbd_adr_i[31:16] == 16'h1001  ) ? TARGET_UART    :   // UART/I2C/USB/SPI
                                (m0_wbd_adr_i[31:16] == 16'h1002  ) ? TARGET_PINMUX  :   // PINMUX
                                (m0_wbd_adr_i[31:16] == 16'h1003  ) ? TARGET_WBI     :   // WB-INTER
				                TARGET_SPI_MEM; 

//------------------------------
// RISC Data Memory Map
// 0x0000_0000 to 0x0FFF_FFFF  - QSPIM MEMORY
// 0x1000_0000 to 0x1000_00FF  - QSPIM REG
// 0x1001_0000 to 0x1001_003F  - UART0
// 0x1001_0040 to 0x1001_007F  - I2
// 0x1001_0080 to 0x1001_00BF  - USB
// 0x1001_00C0 to 0x1001_00FF  - SSPIM
// 0x1001_0100 to 0x1001_013F  - UART1
// 0x1002_0000 to 0x1002_00FF  - PINMUX
// 0x1003_0000 to 0x1003_00FF  - WBI
//-----------------------------
// 
wire [3:0] m1_wbd_tid_i     = (m1_wbd_adr_i[31:28] ==  4'b0000 ) ? TARGET_SPI_MEM :
                              (m1_wbd_adr_i[31:16] == 16'h1000 ) ? TARGET_SPI_REG :
                              (m1_wbd_adr_i[31:16] == 16'h1001 ) ? TARGET_UART :
                              (m1_wbd_adr_i[31:16] == 16'h1002 ) ? TARGET_PINMUX : 
                              (m1_wbd_adr_i[31:16] == 16'h1003 ) ? TARGET_WBI : 
			                  TARGET_SPI_MEM; 

wire [3:0] m2_wbd_tid_i     = (m2_wbd_adr_i[31:28] ==  4'b0000 ) ? TARGET_SPI_MEM :
                              (m2_wbd_adr_i[31:16] == 16'h1000 ) ? TARGET_SPI_REG :
                              (m2_wbd_adr_i[31:16] == 16'h1001 ) ? TARGET_UART : 
                              (m2_wbd_adr_i[31:16] == 16'h1002 ) ? TARGET_PINMUX : 
                              (m2_wbd_adr_i[31:16] == 16'h1003 ) ? TARGET_WBI : 
			                  TARGET_SPI_MEM; 
wire [3:0] m3_wbd_tid_i     = (m3_wbd_adr_i[31:28] ==  4'b0000 ) ? TARGET_SPI_MEM :
                              (m3_wbd_adr_i[31:16] == 16'h1000 ) ? TARGET_SPI_REG :
                              (m3_wbd_adr_i[31:16] == 16'h1001 ) ? TARGET_UART : 
                              (m3_wbd_adr_i[31:16] == 16'h1002 ) ? TARGET_PINMUX : 
                              (m3_wbd_adr_i[31:16] == 16'h1003 ) ? TARGET_WBI : 
			                  TARGET_SPI_MEM; 


//----------------------------------------
// Target Port -0
//----------------------------------------
wb_slave_port  u_s0 (

          .clk_i                   (clk_g                  ), 
          .rst_n                   (rst_ssn                ),
	  .cfg_slave_id                (TARGET_SPI_MEM         ),

         // Master 0 Interface
          .m0_wbd_dat_i            (m0_wbd_dat_i           ),
          .m0_wbd_adr_i            (m0_wbd_adr_i           ),
          .m0_wbd_sel_i            (m0_wbd_sel_i           ),
          .m0_wbd_we_i             (m0_wbd_we_i            ),
          .m0_wbd_cyc_i            (m0_wbd_cyc_i           ),
          .m0_wbd_stb_i            (m0_wbd_stb_i           ),
	      .m0_wbd_tid_i            (m0_wbd_tid_i           ),
          .m0_wbd_dat_o            (m0_s0_wb_rd.wbd_dat    ),
          .m0_wbd_ack_o            (m0_s0_wb_rd.wbd_ack    ),
          .m0_wbd_lack_o           (m0_s0_wb_rd.wbd_lack   ),
          .m0_wbd_err_o            (m0_s0_wb_rd.wbd_err    ),
         
         // Master 1 Interface
          .m1_wbd_dat_i            (m1_wbd_dat_i           ),
          .m1_wbd_adr_i            (m1_wbd_adr_i           ),
          .m1_wbd_sel_i            (m1_wbd_sel_i           ),
          .m1_wbd_bl_i             (m1_wbd_bl_i            ),
          .m1_wbd_bry_i            (m1_wbd_bry_i           ),
          .m1_wbd_we_i             (m1_wbd_we_i            ),
          .m1_wbd_cyc_i            (m1_wbd_cyc_i           ),
          .m1_wbd_stb_i            (m1_wbd_stb_i           ),
	      .m1_wbd_tid_i            (m1_wbd_tid_i           ),
          .m1_wbd_dat_o            (m1_s0_wb_rd.wbd_dat    ),
          .m1_wbd_ack_o            (m1_s0_wb_rd.wbd_ack    ),
          .m1_wbd_lack_o           (m1_s0_wb_rd.wbd_lack   ),
          .m1_wbd_err_o            (m1_s0_wb_rd.wbd_err    ),
         
         // Master 2 Interface
          .m2_wbd_dat_i            (m2_wbd_dat_i           ),
          .m2_wbd_adr_i            (m2_wbd_adr_i           ),
          .m2_wbd_sel_i            (m2_wbd_sel_i           ),
          .m2_wbd_bl_i             (m2_wbd_bl_i            ),
          .m2_wbd_bry_i            (m2_wbd_bry_i           ),
          .m2_wbd_we_i             (m2_wbd_we_i            ),
          .m2_wbd_cyc_i            (m2_wbd_cyc_i           ),
          .m2_wbd_stb_i            (m2_wbd_stb_i           ),
	      .m2_wbd_tid_i            (m2_wbd_tid_i           ),
          .m2_wbd_dat_o            (m2_s0_wb_rd.wbd_dat    ),
          .m2_wbd_ack_o            (m2_s0_wb_rd.wbd_ack    ),
          .m2_wbd_lack_o           (m2_s0_wb_rd.wbd_lack   ),
          .m2_wbd_err_o            (m2_s0_wb_rd.wbd_err    ),

         // Master 3 Interface
          .m3_wbd_adr_i            (m3_wbd_adr_i           ),
          .m3_wbd_sel_i            (m3_wbd_sel_i           ),
          .m3_wbd_bl_i             (m3_wbd_bl_i            ),
          .m3_wbd_bry_i            (m3_wbd_bry_i           ),
          .m3_wbd_we_i             (m3_wbd_we_i            ),
          .m3_wbd_cyc_i            (m3_wbd_cyc_i           ),
          .m3_wbd_stb_i            (m3_wbd_stb_i           ),
	      .m3_wbd_tid_i            (m3_wbd_tid_i           ),
          .m3_wbd_dat_o            (m3_s0_wb_rd.wbd_dat    ),
          .m3_wbd_ack_o            (m3_s0_wb_rd.wbd_ack    ),
          .m3_wbd_lack_o           (m3_s0_wb_rd.wbd_lack   ),
          .m3_wbd_err_o            (m3_s0_wb_rd.wbd_err    ),
         
         
         // Slave  Interface
          .s_wbd_dat_i            (s0_wb_rd.wbd_dat        ),
          .s_wbd_ack_i            (s0_wb_rd.wbd_ack        ),
          .s_wbd_lack_i           (s0_wb_rd.wbd_lack       ),
          .s_wbd_dat_o            (s0_wb_wr.wbd_dat        ),
          .s_wbd_adr_o            (s0_wb_wr.wbd_adr        ),
          .s_wbd_bry_o            (s0_wb_wr.wbd_bry        ),
          .s_wbd_bl_o             (s0_wb_wr.wbd_bl         ),
          .s_wbd_sel_o            (s0_wb_wr.wbd_sel        ),
          .s_wbd_we_o             (s0_wb_wr.wbd_we         ),  
          .s_wbd_cyc_o            (s0_wb_wr.wbd_cyc        ),
          .s_wbd_stb_o            (s0_wb_wr.wbd_stb        )
         
	);

//----------------------------------------
// Target Port -1
//----------------------------------------
wb_slave_port  u_s1 (

          .clk_i                   (clk_g                  ), 
          .rst_n                   (rst_ssn                ),
	      .cfg_slave_id            (TARGET_UART            ),

         // Master 0 Interface
          .m0_wbd_dat_i            (m0_wbd_dat_i           ),
          .m0_wbd_adr_i            (m0_wbd_adr_i           ),
          .m0_wbd_sel_i            (m0_wbd_sel_i           ),
          .m0_wbd_we_i             (m0_wbd_we_i            ),
          .m0_wbd_cyc_i            (m0_wbd_cyc_i           ),
          .m0_wbd_stb_i            (m0_wbd_stb_i           ),
	  .m0_wbd_tid_i            (m0_wbd_tid_i           ),
          .m0_wbd_dat_o            (m0_s1_wb_rd.wbd_dat    ),
          .m0_wbd_ack_o            (m0_s1_wb_rd.wbd_ack    ),
          .m0_wbd_lack_o           (m0_s1_wb_rd.wbd_lack   ),
          .m0_wbd_err_o            (m0_s1_wb_rd.wbd_err    ),
         
         // Master 1 Interface
          .m1_wbd_dat_i            (m1_wbd_dat_i           ),
          .m1_wbd_adr_i            (m1_wbd_adr_i           ),
          .m1_wbd_sel_i            (m1_wbd_sel_i           ),
          .m1_wbd_bl_i             (m1_wbd_bl_i            ),
          .m1_wbd_bry_i            (m1_wbd_bry_i           ),
          .m1_wbd_we_i             (m1_wbd_we_i            ),
          .m1_wbd_cyc_i            (m1_wbd_cyc_i           ),
          .m1_wbd_stb_i            (m1_wbd_stb_i           ),
	  .m1_wbd_tid_i            (m1_wbd_tid_i           ),
          .m1_wbd_dat_o            (m1_s1_wb_rd.wbd_dat    ),
          .m1_wbd_ack_o            (m1_s1_wb_rd.wbd_ack    ),
          .m1_wbd_lack_o           (m1_s1_wb_rd.wbd_lack   ),
          .m1_wbd_err_o            (m1_s1_wb_rd.wbd_err    ),
         
         // Master 2 Interface
          .m2_wbd_dat_i            (m2_wbd_dat_i           ),
          .m2_wbd_adr_i            (m2_wbd_adr_i           ),
          .m2_wbd_sel_i            (m2_wbd_sel_i           ),
          .m2_wbd_bl_i             (m2_wbd_bl_i            ),
          .m2_wbd_bry_i            (m2_wbd_bry_i           ),
          .m2_wbd_we_i             (m2_wbd_we_i            ),
          .m2_wbd_cyc_i            (m2_wbd_cyc_i           ),
          .m2_wbd_stb_i            (m2_wbd_stb_i           ),
	  .m2_wbd_tid_i            (m2_wbd_tid_i           ),
          .m2_wbd_dat_o            (m2_s1_wb_rd.wbd_dat    ),
          .m2_wbd_ack_o            (m2_s1_wb_rd.wbd_ack    ),
          .m2_wbd_lack_o           (m2_s1_wb_rd.wbd_lack   ),
          .m2_wbd_err_o            (m2_s1_wb_rd.wbd_err    ),

         // Master 3 Interface
          .m3_wbd_adr_i            (m3_wbd_adr_i           ),
          .m3_wbd_sel_i            (m3_wbd_sel_i           ),
          .m3_wbd_bl_i             (m3_wbd_bl_i            ),
          .m3_wbd_bry_i            (m3_wbd_bry_i           ),
          .m3_wbd_we_i             (m3_wbd_we_i            ),
          .m3_wbd_cyc_i            (m3_wbd_cyc_i           ),
          .m3_wbd_stb_i            (m3_wbd_stb_i           ),
	  .m3_wbd_tid_i            (m3_wbd_tid_i           ),
          .m3_wbd_dat_o            (m3_s1_wb_rd.wbd_dat    ),
          .m3_wbd_ack_o            (m3_s1_wb_rd.wbd_ack    ),
          .m3_wbd_lack_o           (m3_s1_wb_rd.wbd_lack   ),
          .m3_wbd_err_o            (m3_s1_wb_rd.wbd_err    ),
         
         
         // Slave  Interface
          .s_wbd_dat_i            (s1_wb_rd.wbd_dat        ),
          .s_wbd_ack_i            (s1_wb_rd.wbd_ack        ),
          .s_wbd_lack_i           (s1_wb_rd.wbd_lack       ),
          .s_wbd_dat_o            (s1_wb_wr.wbd_dat        ),
          .s_wbd_adr_o            (s1_wb_wr.wbd_adr        ),
          .s_wbd_bry_o            (s1_wb_wr.wbd_bry        ),
          .s_wbd_bl_o             (s1_wb_wr.wbd_bl         ),
          .s_wbd_sel_o            (s1_wb_wr.wbd_sel        ),
          .s_wbd_we_o             (s1_wb_wr.wbd_we         ),  
          .s_wbd_cyc_o            (s1_wb_wr.wbd_cyc        ),
          .s_wbd_stb_o            (s1_wb_wr.wbd_stb        )
         
	);

//----------------------------------------
// Target Port -2
//----------------------------------------
wb_slave_port  u_s2 (

          .clk_i                   (clk_g                  ), 
          .rst_n                   (rst_ssn                ),
	      .cfg_slave_id            (TARGET_PINMUX          ),

         // Master 0 Interface
          .m0_wbd_dat_i            (m0_wbd_dat_i           ),
          .m0_wbd_adr_i            (m0_wbd_adr_i           ),
          .m0_wbd_sel_i            (m0_wbd_sel_i           ),
          .m0_wbd_we_i             (m0_wbd_we_i            ),
          .m0_wbd_cyc_i            (m0_wbd_cyc_i           ),
          .m0_wbd_stb_i            (m0_wbd_stb_i           ),
	  .m0_wbd_tid_i            (m0_wbd_tid_i           ),
          .m0_wbd_dat_o            (m0_s2_wb_rd.wbd_dat    ),
          .m0_wbd_ack_o            (m0_s2_wb_rd.wbd_ack    ),
          .m0_wbd_lack_o           (m0_s2_wb_rd.wbd_lack   ),
          .m0_wbd_err_o            (m0_s2_wb_rd.wbd_err    ),
         
         // Master 1 Interface
          .m1_wbd_dat_i            (m1_wbd_dat_i           ),
          .m1_wbd_adr_i            (m1_wbd_adr_i           ),
          .m1_wbd_sel_i            (m1_wbd_sel_i           ),
          .m1_wbd_bl_i             (m1_wbd_bl_i            ),
          .m1_wbd_bry_i            (m1_wbd_bry_i           ),
          .m1_wbd_we_i             (m1_wbd_we_i            ),
          .m1_wbd_cyc_i            (m1_wbd_cyc_i           ),
          .m1_wbd_stb_i            (m1_wbd_stb_i           ),
	  .m1_wbd_tid_i            (m1_wbd_tid_i           ),
          .m1_wbd_dat_o            (m1_s2_wb_rd.wbd_dat    ),
          .m1_wbd_ack_o            (m1_s2_wb_rd.wbd_ack    ),
          .m1_wbd_lack_o           (m1_s2_wb_rd.wbd_lack   ),
          .m1_wbd_err_o            (m1_s2_wb_rd.wbd_err    ),
         
         // Master 2 Interface
          .m2_wbd_dat_i            (m2_wbd_dat_i           ),
          .m2_wbd_adr_i            (m2_wbd_adr_i           ),
          .m2_wbd_sel_i            (m2_wbd_sel_i           ),
          .m2_wbd_bl_i             (m2_wbd_bl_i            ),
          .m2_wbd_bry_i            (m2_wbd_bry_i           ),
          .m2_wbd_we_i             (m2_wbd_we_i            ),
          .m2_wbd_cyc_i            (m2_wbd_cyc_i           ),
          .m2_wbd_stb_i            (m2_wbd_stb_i           ),
	  .m2_wbd_tid_i            (m2_wbd_tid_i           ),
          .m2_wbd_dat_o            (m2_s2_wb_rd.wbd_dat    ),
          .m2_wbd_ack_o            (m2_s2_wb_rd.wbd_ack    ),
          .m2_wbd_lack_o           (m2_s2_wb_rd.wbd_lack   ),
          .m2_wbd_err_o            (m2_s2_wb_rd.wbd_err    ),

         // Master 3 Interface
          .m3_wbd_adr_i            (m3_wbd_adr_i           ),
          .m3_wbd_sel_i            (m3_wbd_sel_i           ),
          .m3_wbd_bl_i             (m3_wbd_bl_i            ),
          .m3_wbd_bry_i            (m3_wbd_bry_i           ),
          .m3_wbd_we_i             (m3_wbd_we_i            ),
          .m3_wbd_cyc_i            (m3_wbd_cyc_i           ),
          .m3_wbd_stb_i            (m3_wbd_stb_i           ),
	  .m3_wbd_tid_i            (m3_wbd_tid_i           ),
          .m3_wbd_dat_o            (m3_s2_wb_rd.wbd_dat    ),
          .m3_wbd_ack_o            (m3_s2_wb_rd.wbd_ack    ),
          .m3_wbd_lack_o           (m3_s2_wb_rd.wbd_lack   ),
          .m3_wbd_err_o            (m3_s2_wb_rd.wbd_err    ),
         
         
         // Slave  Interface
          .s_wbd_dat_i            (s2_wb_rd.wbd_dat        ),
          .s_wbd_ack_i            (s2_wb_rd.wbd_ack        ),
          .s_wbd_lack_i           (s2_wb_rd.wbd_lack       ),
          .s_wbd_dat_o            (s2_wb_wr.wbd_dat        ),
          .s_wbd_adr_o            (s2_wb_wr.wbd_adr        ),
          .s_wbd_bry_o            (s2_wb_wr.wbd_bry        ),
          .s_wbd_bl_o             (s2_wb_wr.wbd_bl         ),
          .s_wbd_sel_o            (s2_wb_wr.wbd_sel        ),
          .s_wbd_we_o             (s2_wb_wr.wbd_we         ),  
          .s_wbd_cyc_o            (s2_wb_wr.wbd_cyc        ),
          .s_wbd_stb_o            (s2_wb_wr.wbd_stb        )
         
	);

/////////////////////////////////////////////////
// Master-0 Mapping
// ---------------------------------------------
assign m0_wb_wr.wbd_dat  = m0_wbd_dat_i;
assign m0_wb_wr.wbd_adr  = m0_wbd_adr_i;
assign m0_wb_wr.wbd_sel  = m0_wbd_sel_i;
assign m0_wb_wr.wbd_bl   = 'h0;
assign m0_wb_wr.wbd_bry  = 1'b1;
assign m0_wb_wr.wbd_we   = m0_wbd_we_i;
assign m0_wb_wr.wbd_cyc  = m0_wbd_cyc_i;
assign m0_wb_wr.wbd_stb  = m0_wbd_stb_i;
assign m0_wb_wr.wbd_tid  = 4'b0; // unused

assign m0_wbd_dat_o  = m0_bus_rd.wbd_dat;
assign m0_wbd_ack_o  = m0_bus_rd.wbd_ack;
assign m0_wbd_lack_o = m0_bus_rd.wbd_lack;
assign m0_wbd_err_o  = m0_bus_rd.wbd_err;

always_comb begin
     case(m0_wbd_tid_i)
        TARGET_SPI_MEM:	   m0_bus_rd = m0_s0_wb_rd;
        TARGET_SPI_REG:	   m0_bus_rd = m0_s0_wb_rd;
        TARGET_UART:	           m0_bus_rd = m0_s1_wb_rd;
        TARGET_PINMUX:	           m0_bus_rd = m0_s2_wb_rd;
        TARGET_WBI:	       m0_bus_rd = wbi_wb_rd;
        default:           m0_bus_rd = m0_s0_wb_rd;
     endcase			
end

/////////////////////////////////////////////////
// Master-1 Mapping
// ---------------------------------------------
assign m1_wb_wr.wbd_dat  = m1_wbd_dat_i;
assign m1_wb_wr.wbd_adr  = m1_wbd_adr_i;
assign m1_wb_wr.wbd_sel  = m1_wbd_sel_i;
assign m1_wb_wr.wbd_bl   = m1_wbd_bl_i;
assign m1_wb_wr.wbd_bry  = m1_wbd_bry_i;
assign m1_wb_wr.wbd_we   = m1_wbd_we_i;
assign m1_wb_wr.wbd_cyc  = m1_wbd_cyc_i;
assign m1_wb_wr.wbd_stb  = m1_wbd_stb_i;
assign m1_wb_wr.wbd_tid  = 4'b0; // unused

assign m1_wbd_dat_o  = m1_bus_rd.wbd_dat;
assign m1_wbd_ack_o  = m1_bus_rd.wbd_ack;
assign m1_wbd_lack_o = m1_bus_rd.wbd_lack;
assign m1_wbd_err_o  = m1_bus_rd.wbd_err;

always_comb begin
     case(m1_wbd_tid_i)
        TARGET_SPI_MEM:	   m1_bus_rd = m1_s0_wb_rd;
        TARGET_SPI_REG:	   m1_bus_rd = m1_s0_wb_rd;
        TARGET_UART:	   m1_bus_rd = m1_s1_wb_rd;
        TARGET_PINMUX:	   m1_bus_rd = m1_s2_wb_rd;
        TARGET_WBI:	       m1_bus_rd = wbi_wb_rd;
        default:           m1_bus_rd = m1_s0_wb_rd;
     endcase			
end

/////////////////////////////////////////////////
// Master-2 Mapping
// ---------------------------------------------
assign m2_wb_wr.wbd_dat  = m2_wbd_dat_i;
assign m2_wb_wr.wbd_adr  = m2_wbd_adr_i;
assign m2_wb_wr.wbd_sel  = m2_wbd_sel_i;
assign m2_wb_wr.wbd_bl   = m2_wbd_bl_i;
assign m2_wb_wr.wbd_bry  = m2_wbd_bry_i;
assign m2_wb_wr.wbd_we   = m2_wbd_we_i;
assign m2_wb_wr.wbd_cyc  = m2_wbd_cyc_i;
assign m2_wb_wr.wbd_stb  = m2_wbd_stb_i;
assign m2_wb_wr.wbd_tid  = 4'b0; // unused

assign m2_wbd_dat_o  = m2_bus_rd.wbd_dat;
assign m2_wbd_ack_o  = m2_bus_rd.wbd_ack;
assign m2_wbd_lack_o = m2_bus_rd.wbd_lack;
assign m2_wbd_err_o  = m2_bus_rd.wbd_err;

always_comb begin
     case(m2_wbd_tid_i)
        TARGET_SPI_MEM:	   m2_bus_rd = m2_s0_wb_rd;
        TARGET_SPI_REG:	   m2_bus_rd = m2_s0_wb_rd;
        TARGET_UART:	   m2_bus_rd = m2_s1_wb_rd;
        TARGET_PINMUX:	   m2_bus_rd = m2_s2_wb_rd;
        TARGET_WBI:	       m2_bus_rd = wbi_wb_rd;
        default:           m2_bus_rd = m2_s0_wb_rd;
     endcase			
end

/////////////////////////////////////////////////
// Master-3 Mapping
// ---------------------------------------------
assign m3_wb_wr.wbd_dat  = 'h0; // icache doesnot had wdata
assign m3_wb_wr.wbd_adr  = m3_wbd_adr_i;
assign m3_wb_wr.wbd_sel  = m3_wbd_sel_i;
assign m3_wb_wr.wbd_bl   = m3_wbd_bl_i;
assign m3_wb_wr.wbd_bry  = m3_wbd_bry_i;
assign m3_wb_wr.wbd_we   = m3_wbd_we_i;
assign m3_wb_wr.wbd_cyc  = m3_wbd_cyc_i;
assign m3_wb_wr.wbd_stb  = m3_wbd_stb_i;
assign m3_wb_wr.wbd_tid  = 4'b0; // unused

assign m3_wbd_dat_o  = m3_bus_rd.wbd_dat;
assign m3_wbd_ack_o  = m3_bus_rd.wbd_ack;
assign m3_wbd_lack_o = m3_bus_rd.wbd_lack;
assign m3_wbd_err_o  = m3_bus_rd.wbd_err;

always_comb begin
     case(m3_wbd_tid_i)
        TARGET_SPI_MEM:	   m3_bus_rd = m3_s0_wb_rd;
        TARGET_SPI_REG:	   m3_bus_rd = m3_s0_wb_rd;
        TARGET_UART:	   m3_bus_rd = m3_s1_wb_rd;
        TARGET_PINMUX:	   m3_bus_rd = m3_s2_wb_rd;
        TARGET_WBI:	       m3_bus_rd = wbi_wb_rd;
        default:           m3_bus_rd = m3_s0_wb_rd;
     endcase			
end

//----------------------------------------
// Slave Mapping
// -------------------------------------
 assign  s0_wbd_dat_o =  s0_wb_wr.wbd_dat ;
 assign  s0_wbd_adr_o =  s0_wb_wr.wbd_adr ;
 assign  s0_wbd_sel_o =  s0_wb_wr.wbd_sel ;
 assign  s0_wbd_bl_o  =  s0_wb_wr.wbd_bl ;
 assign  s0_wbd_bry_o =  s0_wb_wr.wbd_bry ;
 assign  s0_wbd_we_o  =  s0_wb_wr.wbd_we  ;
 assign  s0_wbd_cyc_o =  s0_wb_wr.wbd_cyc ;
 assign  s0_wbd_stb_o =  s0_wb_wr.wbd_stb ;
                      
 assign  s1_wbd_dat_o =  s1_wb_wr.wbd_dat ;
 assign  s1_wbd_adr_o =  s1_wb_wr.wbd_adr[8:0] ;
 assign  s1_wbd_sel_o =  s1_wb_wr.wbd_sel ;
 assign  s1_wbd_we_o  =  s1_wb_wr.wbd_we  ;
 assign  s1_wbd_cyc_o =  s1_wb_wr.wbd_cyc ;
 assign  s1_wbd_stb_o =  s1_wb_wr.wbd_stb ;
                      
 assign  s2_wbd_dat_o =  s2_wb_wr.wbd_dat ;
 assign  s2_wbd_adr_o =  s2_wb_wr.wbd_adr[10:0] ; // Global Reg Need 8 bit
 assign  s2_wbd_sel_o =  s2_wb_wr.wbd_sel ;
 assign  s2_wbd_we_o  =  s2_wb_wr.wbd_we  ;
 assign  s2_wbd_cyc_o =  s2_wb_wr.wbd_cyc ;
 assign  s2_wbd_stb_o =  s2_wb_wr.wbd_stb ;

 
 
 assign s0_wb_rd.wbd_dat   = s0_wbd_dat_i ;
 assign s0_wb_rd.wbd_ack   = s0_wbd_ack_i ;
 assign s0_wb_rd.wbd_lack  = s0_wbd_lack_i ;
 assign s0_wb_rd.wbd_err  = 1'b0; // s0_wbd_err_i ; - unused
 
 assign s1_wb_rd.wbd_dat  = s1_wbd_dat_i ;
 assign s1_wb_rd.wbd_ack  = s1_wbd_ack_i ;
 assign s1_wb_rd.wbd_lack  = s1_wbd_ack_i ;
 assign s1_wb_rd.wbd_err  = 1'b0; // s1_wbd_err_i ; - unused
 
 assign s2_wb_rd.wbd_dat  = s2_wbd_dat_i ;
 assign s2_wb_rd.wbd_ack  = s2_wbd_ack_i ;
 assign s2_wb_rd.wbd_lack = s2_wbd_ack_i ;
 assign s2_wb_rd.wbd_err  = 1'b0; // s2_wbd_err_i ; - unused


//----------------------------
// Register Interface
//----------------------------
wire [1:0] wbi_grnt;
wire m0_wbi_req = m0_wbd_stb_i & (m0_wbd_tid_i == TARGET_WBI);
wire m1_wbi_req = m1_wbd_stb_i & (m1_wbd_tid_i == TARGET_WBI);
wire m2_wbi_req = m2_wbd_stb_i & (m2_wbd_tid_i == TARGET_WBI);
wire m3_wbi_req = m3_wbd_stb_i & (m3_wbd_tid_i == TARGET_WBI);


wb_arb u_wbi_arb(
	.clk      (clk_g ), 
	.rstn     (rst_ssn), 
	.req      ({m3_wbi_req,m2_wbi_req,m1_wbi_req,m0_wbi_req}), 
	.gnt      (wbi_grnt)
        );

always_comb begin
     case(wbi_grnt)
        2'b00:	   wbi_wb_wr = m0_wb_wr;
        2'b01:	   wbi_wb_wr = m1_wb_wr;
        2'b10:	   wbi_wb_wr = m2_wb_wr;
        2'b11:	   wbi_wb_wr = m3_wb_wr;
     endcase			
end

always_comb begin
     case(wbi_grnt)
        2'b00:	   reg_wbi_cs = m0_wbi_req;
        2'b01:	   reg_wbi_cs = m1_wbi_req;
        2'b10:	   reg_wbi_cs = m2_wbi_req;
        2'b11:	   reg_wbi_cs = m3_wbi_req;
     endcase			
end

assign  reg_wbi_wr     = wbi_wb_wr.wbd_we;
assign  reg_wbi_addr   = wbi_wb_wr.wbd_adr[4:0];
assign  reg_wbi_wdata  = wbi_wb_wr.wbd_dat;
assign  reg_wbi_be     = wbi_wb_wr.wbd_sel;

assign wbi_wb_rd.wbd_dat   = reg_wbi_rdata ;
assign wbi_wb_rd.wbd_ack   = reg_wbi_ack ;
assign wbi_wb_rd.wbd_lack  = reg_wbi_ack ;
assign wbi_wb_rd.wbd_err   = 1'b0; 

assign stat_reg_req = {4'b0,m3_wb_wr.wbd_stb,m2_wb_wr.wbd_stb,m1_wb_wr.wbd_stb,m0_wb_wr.wbd_stb};

wbi_reg  u_reg(
                       // System Signals
                       // Inputs
		               .mclk                   (clk_g            ),
	                   .reset_n                (rst_ssn          ),  // external reset


		       // Reg Bus Interface Signal
                       .reg_cs                 (reg_wbi_cs       ),
                       .reg_wr                 (reg_wbi_wr       ),
                       .reg_addr               (reg_wbi_addr     ),
                       .reg_wdata              (reg_wbi_wdata    ),
                       .reg_be                 (reg_wbi_be       ),

                       // Outputs
                       .reg_rdata              (reg_wbi_rdata    ),
                       .reg_ack                (reg_wbi_ack      ),

                       // Dynamic Clock gate config
                       .cfg_dcg_ctrl           (cfg_dcg_ctrl     ),

                       // clock gate indication
                       .stat_reg_req           (stat_reg_req     ), 
                       .stat_clk_gate          (stat_clk_gate_ss )          
   ); 

//----------------------------
// Source Clock Gating for S0
//----------------------------
src_clk_gate  u_dcg_s0(
                        .reset_n               (rst_ssn             ),
                        .clk_in                (mclk_raw            ),
                        .cfg_mode              (cfg_dcg_ctrl[1:0]   ),
                        .dst_idle              (s0_idle             ), // 1 - indicate destination is ideal
                        .src_req               (s0_wbd_stb_o        ), // 1 - Source Request

                        .clk_enb               (stat_clk_gate[0]    ), // clock enable indication
                        .clk_out               (s0_mclk             )  // clock output
     
       );

//---------------------------------------------------------------------------------------
// Special Note: There is hugh clock skew difference between mclk and mclk_raw clock
// for timing closure purpose all the mclk_raw output signal need to double sync to mclk
//----------------------------------------------------------------------------------------

//----------------------------
// Source Clock Gating for S1
//----------------------------
src_clk_gate  u_dcg_s1(
                        .reset_n               (rst_ssn            ),
                        .clk_in                (mclk_raw           ),
                        .cfg_mode              (cfg_dcg_ctrl[3:2]  ),
                        .dst_idle              (1'b0               ), // 1 - indicate destination is ideal
                        .src_req               (s1_wbd_stb_o       ), // 1 - Source Request

                        .clk_enb               (stat_clk_gate[1]   ), // clock enable indication
                        .clk_out               (s1_mclk            )  // clock output
     
       );

//----------------------------
// Source Clock Gating for S2
//----------------------------
src_clk_gate  u_dcg_s2(
                        .reset_n               (rst_ssn            ),
                        .clk_in                (mclk_raw           ),
                        .cfg_mode              (cfg_dcg_ctrl[5:4]  ),
                        .dst_idle              (1'b0               ), // 1 - indicate destination is ideal
                        .src_req               (s2_wbd_stb_o       ), // 1 - Source Request

                        .clk_enb               (stat_clk_gate[2]   ), // clock enable indication
                        .clk_out               (s2_mclk            )  // clock output
     
       );

//----------------------------
// Source Clock Gating for S2
//----------------------------
src_clk_gate  u_dcg_peri(
                        .reset_n               (rst_ssn            ),
                        .clk_in                (mclk_raw           ),
                        .cfg_mode              (cfg_dcg_ctrl[7:6]  ),
                        .dst_idle              (1'b0               ), // 1 - indicate destination is ideal
                        .src_req               (s2_wbd_stb_o       ), // 1 - Source Request

                        .clk_enb               (stat_clk_gate[3]   ), // clock enable indication
                        .clk_out               (peri_wbclk         )  // clock output
     
       );

//----------------------------
// Source Clock Gating for RISCV-WB
//----------------------------
src_clk_gate  u_dcg_riscv(
                        .reset_n               (rst_ssn            ),
                        .clk_in                (mclk_raw           ),
                        .cfg_mode              (cfg_dcg_ctrl[9:8]  ),
                        .dst_idle              (1'b0               ), // 1 - indicate destination is ideal
                        .src_req               (1'b0               ), // 1 - Source Request

                        .clk_enb               (stat_clk_gate[4]   ), // clock enable indication
                        .clk_out               (riscv_wbclk        )  // clock output
     
       );


/**************************************
 As there is hugh clock skey at stat_clk_gate
between mclk_raw & clk_g. We are creating async
path to simply the timing closure
***************************************/

assign stat_clk_gate[7:5] = 3'b0;

ctech_dsync_high  #(.WB(8)) u_dsync(
              .in_data    ( stat_clk_gate     ),
              .out_clk    ( clk_g             ),
              .out_rst_n  ( rst_ssn           ),
              .out_data   ( stat_clk_gate_ss  )
          );
endmodule

