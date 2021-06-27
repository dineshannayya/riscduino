//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Async Wishbone Interface                                    ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  http://www.opencores.org/cores/yifive/                      ////
////                                                              ////
////  Description                                                 ////
////      This block does async Wishbone from one clock to other  ////
////      clock domain
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 25th Feb 2021, Dinesh A                             ////
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

module async_wb (

    // Master Port
       input   logic               wbm_rst_n   ,  // Regular Reset signal
       input   logic               wbm_clk_i   ,  // System clock
       input   logic               wbm_cyc_i   ,  // strobe/request
       input   logic               wbm_stb_i   ,  // strobe/request
       input   logic [31:0]        wbm_adr_i   ,  // address
       input   logic               wbm_we_i    ,  // write
       input   logic [31:0]        wbm_dat_i   ,  // data output
       input   logic [3:0]         wbm_sel_i   ,  // byte enable
       output  logic [31:0]        wbm_dat_o   ,  // data input
       output  logic               wbm_ack_o   ,  // acknowlegement
       output  logic               wbm_err_o   ,  // error

    // Slave Port
       input   logic               wbs_rst_n   ,  // Regular Reset signal
       input   logic               wbs_clk_i   ,  // System clock
       output  logic               wbs_cyc_o   ,  // strobe/request
       output  logic               wbs_stb_o   ,  // strobe/request
       output  logic [31:0]        wbs_adr_o   ,  // address
       output  logic               wbs_we_o    ,  // write
       output  logic [31:0]        wbs_dat_o   ,  // data output
       output  logic [3:0]         wbs_sel_o   ,  // byte enable
       input   logic [31:0]        wbs_dat_i   ,  // data input
       input   logic               wbs_ack_i   ,  // acknowlegement
       input   logic               wbs_err_i      // error

    );




//-------------------------------------------------
//  Master Interface
// -------------------------------------------------
logic        PendingRd     ; // Pending Read Transaction
logic        m_cmd_wr_en       ;
logic [70:0] m_cmd_wr_data     ;
logic        m_cmd_wr_full     ;
logic        m_cmd_wr_afull    ;

logic        m_resp_rd_empty    ;
logic        m_resp_rd_aempty   ;
logic        m_resp_rd_en       ;
logic [32:0] m_resp_rd_data     ;

// Master Write Interface


assign m_cmd_wr_en = (!PendingRd) && wbm_stb_i && !m_cmd_wr_full && !m_cmd_wr_afull;

assign m_cmd_wr_data = {wbm_cyc_i,wbm_stb_i,wbm_adr_i,wbm_we_i,wbm_dat_i,wbm_sel_i};

always@(negedge wbm_rst_n or posedge wbm_clk_i)
begin
   if(wbm_rst_n == 0) begin
      PendingRd <= 1'b0;
   end else begin
      if((!PendingRd) && wbm_stb_i && (!wbm_we_i)) begin
      PendingRd <= 1'b1;
      end else if(PendingRd && wbm_stb_i && (!wbm_we_i) && wbm_ack_o) begin
         PendingRd <= 1'b0;
      end
   end
end


// Master Read Interface
// For Write is feed through, if there is space in fifo the ack
// For Read, Wait for Response Path FIFO status
assign wbm_ack_o = (wbm_stb_i && wbm_we_i)    ?  m_cmd_wr_en : // Write Logic
	           (wbm_stb_i && (!wbm_we_i)) ? !m_resp_rd_empty : 1'b0; // Read Logic

assign m_resp_rd_en   = !m_resp_rd_empty;
assign wbm_dat_o      = m_resp_rd_data[31:0];
assign wbm_err_o      = m_resp_rd_data[32];


//------------------------------
// Slave Interface
//-------------------------------

logic [70:0] s_cmd_rd_data      ;
logic        s_cmd_rd_empty     ;
logic        s_cmd_rd_aempty    ;
logic        s_cmd_rd_en        ;
logic        s_resp_wr_en        ;
logic [32:0] s_resp_wr_data      ;
logic        s_resp_wr_full      ;
logic        s_resp_wr_afull     ;


// Read Interface
assign {wbs_cyc_o,wbs_stb_o,wbs_adr_o,wbs_we_o,wbs_dat_o,wbs_sel_o} = (s_cmd_rd_empty) ? '0:  s_cmd_rd_data;
assign s_cmd_rd_en = wbs_ack_i;

// Write Interface
// response send only for read logic
assign s_resp_wr_en   = wbs_stb_o & (!wbs_we_o) & wbs_ack_i & !s_resp_wr_full;
assign s_resp_wr_data = {wbs_err_i,wbs_dat_i};

async_fifo #(.W(71), .DP(4), .WR_FAST(1), .RD_FAST(1)) u_cmd_if (
	           // Sync w.r.t WR clock
	           .wr_clk        (wbm_clk_i         ),
                   .wr_reset_n    (wbm_rst_n         ),
                   .wr_en         (m_cmd_wr_en       ),
                   .wr_data       (m_cmd_wr_data     ),
                   .full          (m_cmd_wr_full     ),                 
                   .afull         (m_cmd_wr_afull    ),                 

		   // Sync w.r.t RD Clock
                   .rd_clk        (wbs_clk_i         ),
                   .rd_reset_n    (wbs_rst_n         ),
                   .rd_en         (s_cmd_rd_en       ),
                   .empty         (s_cmd_rd_empty    ), // sync'ed to rd_clk
                   .aempty        (s_cmd_rd_aempty   ), // sync'ed to rd_clk
                   .rd_data       (s_cmd_rd_data     )
	     );

async_fifo #(.W(33), .DP(4), .WR_FAST(1), .RD_FAST(1)) u_resp_if (
	           // Sync w.r.t WR clock
	           .wr_clk        (wbs_clk_i          ),
                   .wr_reset_n    (wbs_rst_n          ),
                   .wr_en         (s_resp_wr_en       ),
                   .wr_data       (s_resp_wr_data     ),
                   .full          (s_resp_wr_full     ),                 
                   .afull         (s_resp_wr_afull    ),                 

		   // Sync w.r.t RD Clock
                   .rd_clk        (wbm_clk_i          ),
                   .rd_reset_n    (wbm_rst_n          ),
                   .rd_en         (m_resp_rd_en       ),
                   .empty         (m_resp_rd_empty    ), // sync'ed to rd_clk
                   .aempty        (m_resp_rd_aempty   ), // sync'ed to rd_clk
                   .rd_data       (m_resp_rd_data     )
	     );



endmodule
