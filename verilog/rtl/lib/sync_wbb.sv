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
////  sync Wishbone Interface iBurst Enable and lack             ////
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
////    0.2 - 28th Feb 2021, Dinesh A                             ////
////          reduced the response FIFO path depth to 2 as        ////
////          return path used by only read logic and read is     ////
////          blocking request and expect only one location will  ////
////          be used                                             ////
////    0.3 - 20 Jan 2022, Dinesh A                               ////
////          added wishbone burst mode. Additional signal added  ////
////           A. *bl  - 10 Bit word Burst count, 1 - 1 DW(32 bit)////
////           B. *lack - Last Burst ack                          //// 
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

module sync_wbb 
     #(parameter AW  = 32,
       parameter BW  = 4,
       parameter BL  = 10,
       parameter DW  = 32)
       (

    // Master Port
       input   logic               rst_n       ,  // Regular Reset signal
       input   logic               clk_i       ,  // System clock
       input   logic               wbm_cyc_i   ,  // strobe/request
       input   logic               wbm_stb_i   ,  // strobe/request
       input   logic [AW-1:0]      wbm_adr_i   ,  // address
       input   logic               wbm_we_i    ,  // write
       input   logic [DW-1:0]      wbm_dat_i   ,  // data output
       input   logic [BW-1:0]      wbm_sel_i   ,  // byte enable
       input   logic [3:0]         wbm_tid_i   ,
       input   logic [BL-1:0]      wbm_bl_i    ,  // Burst Count
       input   logic               wbm_bry_i   ,  // Burst Ready
       output  logic [DW-1:0]      wbm_dat_o   ,  // data input
       output  logic               wbm_ack_o   ,  // acknowlegement
       output  logic               wbm_lack_o  ,  // Last Burst access
       output  logic               wbm_err_o   ,  // error

    // Slave Port
       output  logic               wbs_cyc_o   ,  // strobe/request
       output  logic               wbs_stb_o   ,  // strobe/request
       output  logic [AW-1:0]      wbs_adr_o   ,  // address
       output  logic               wbs_we_o    ,  // write
       output  logic [DW-1:0]      wbs_dat_o   ,  // data output
       output  logic [BW-1:0]      wbs_sel_o   ,  // byte enable
       output  logic [3:0]         wbs_tid_o   ,
       output  logic [BL-1:0]      wbs_bl_o    ,  // Burst Count
       output  logic               wbs_bry_o   ,  // Busrt WData Avialble Or Ready To accept Rdata  
       input   logic [DW-1:0]      wbs_dat_i   ,  // data input
       input   logic               wbs_ack_i   ,  // acknowlegement
       input   logic               wbs_lack_i  ,  // Last Ack
       input   logic               wbs_err_i      // error

    );



parameter CFW = AW+DW+BW+BL+4+1 ; // COMMAND FIFO WIDTH
parameter RFW = DW+1+1 ;        // RESPONSE FIFO WIDTH

parameter IDLE        = 2'b00;
parameter WRITE_DATA  = 2'b01;
parameter READ_DATA   = 2'b10;


//-------------------------------------------------
//  Master Interface
// -------------------------------------------------
logic           m_cmd_wr_en       ;
logic [CFW-1:0] m_cmd_wr_data     ;
logic           m_cmd_wr_full     ;
logic           m_cmd_wr_afull    ;

logic           m_resp_rd_empty    ;
logic           m_resp_rd_aempty   ;
logic           m_resp_rd_en       ;
logic [RFW-1:0] m_resp_rd_data     ;
logic [BL-1:0]  m_bl_cnt           ;
logic [1:0]     m_state            ;

// Master Write Interface



assign m_cmd_wr_data = {wbm_adr_i,wbm_we_i,wbm_dat_i,wbm_sel_i,wbm_tid_i,wbm_bl_i};

assign wbm_dat_o = m_resp_rd_data[DW-1:0];
assign wbm_err_o = 'b0;

always@(negedge rst_n or posedge clk_i)
begin
   if(rst_n == 0) begin
        m_cmd_wr_en        <= 'b0;
        m_resp_rd_en       <= 'b0;
        m_state            <= 'h0;
        m_bl_cnt           <= 'h0;
        wbm_ack_o          <= 'b0;
        wbm_lack_o         <= 'b0;
   end else begin
      case(m_state)
      IDLE:  begin
	 // Read DATA
	 // Make sure that FIFO is not overflow and there is no previous
	 // pending write + fifo is about to full
         if(wbm_stb_i && !wbm_we_i && wbm_bry_i && !m_cmd_wr_full && !(m_cmd_wr_afull && m_cmd_wr_en)  && !wbm_lack_o) begin
           m_bl_cnt         <= wbm_bl_i;
           m_cmd_wr_en      <= 'b1;
           m_state          <= READ_DATA;
         end else if(wbm_stb_i && wbm_we_i && wbm_bry_i && !m_cmd_wr_full && !(m_cmd_wr_afull && m_cmd_wr_en) && !wbm_lack_o) begin
            wbm_ack_o       <= 'b1;
            m_cmd_wr_en     <= 'b1;
            m_bl_cnt        <= wbm_bl_i-1;
            if(wbm_bl_i == 'h1) begin
               wbm_lack_o   <= 'b1;
               m_state      <= IDLE;
            end else begin
               m_bl_cnt     <= wbm_bl_i-1;
               m_state      <= WRITE_DATA;
            end
         end else begin
            m_resp_rd_en    <= 'b0;
            m_cmd_wr_en     <= 'b0;
            wbm_ack_o       <= 'b0;
            wbm_lack_o      <= 'b0;
         end
      end

      // Write next Transaction
      WRITE_DATA: begin
         if(m_cmd_wr_full != 1 && !(m_cmd_wr_afull && m_cmd_wr_en) && wbm_bry_i) begin
            wbm_ack_o       <= 'b1;
            m_cmd_wr_en     <= 'b1;
            if(m_bl_cnt == 1) begin
               wbm_lack_o   <= 'b1;
               m_state      <= IDLE;
            end else begin
               m_bl_cnt        <= m_bl_cnt-1;
            end
         end else begin
            m_cmd_wr_en     <= 'b0;
            wbm_ack_o       <= 'b0;
            wbm_lack_o      <= 'b0;
         end
      end

      // Read Transaction
      READ_DATA: begin
	   // Check Back to Back Ack and last Location case
           if(((wbm_ack_o == 0 && m_resp_rd_empty != 1) ||
	       (wbm_ack_o == 1 && m_resp_rd_aempty != 1)) && wbm_bry_i) begin
              m_resp_rd_en   <= 'b1;
              wbm_ack_o      <= 'b1;
              if(m_bl_cnt == 1) begin
                  wbm_lack_o   <= 'b1;
                  m_state      <= IDLE;
              end else begin
                 m_bl_cnt        <= m_bl_cnt-1;
	      end
           end else begin
              m_resp_rd_en    <= 'b0;
              m_cmd_wr_en     <= 'b0;
              wbm_ack_o       <= 'b0;
              wbm_lack_o      <= 'b0;
	   end
      end
      endcase
   end
end


//------------------------------
// Slave Interface
//-------------------------------

logic [CFW-1:0] s_cmd_rd_data   ;
logic [CFW-1:0] s_cmd_rd_data_l ;
logic        s_cmd_rd_empty     ;
logic        s_cmd_rd_aempty    ;
logic        s_cmd_rd_en        ;
logic        s_resp_wr_en        ;
logic [RFW-1:0] s_resp_wr_data      ;
logic        s_resp_wr_full      ;
logic        s_resp_wr_afull     ;
logic        wbs_ack_f          ;
logic        wbs_stb_l          ;
logic        wbs_burst          ;

wire wbs_stb_pedge = (wbs_stb_l == 1'b0) && wbs_stb_o;


always@(negedge rst_n or posedge clk_i)
begin
   if(rst_n == 0) begin
      wbs_ack_f <= 1'b0;
      wbs_stb_l <= 1'b0;
      wbs_burst <= 'h0;
      s_cmd_rd_data_l <= 'h0;
   end else begin
      wbs_ack_f <= wbs_lack_i;
      wbs_stb_l <= wbs_stb_o;
      if(s_cmd_rd_en)
          s_cmd_rd_data_l <= s_cmd_rd_data;
      if(wbs_stb_pedge && wbs_bl_o > 'h1)
         wbs_burst <= 1'b1;
      else if(wbs_lack_i)
         wbs_burst <= 1'b0;
   end
end


// Read Interface


assign {wbs_adr_o,wbs_we_o,wbs_dat_o,wbs_sel_o,wbs_tid_o,wbs_bl_o} = (s_cmd_rd_empty) ? s_cmd_rd_data_l:  s_cmd_rd_data;
// All the downstream logic expect Stobe is getting de-asserted 
// atleast for 1 cycle after ack is generated
assign wbs_stb_o = (wbs_burst) ? 1'b1 : ((wbs_ack_f) ? 1'b0 : (s_cmd_rd_empty) ? 1'b0: 1'b1);
assign wbs_cyc_o = (wbs_burst) ? 1'b1 : ((wbs_ack_f) ? 1'b0 : (s_cmd_rd_empty) ? 1'b0: 1'b1);

// Generate bust ready only we have space inside response fifo
// In Write Phase, 
//      Generate burst ready, only when we have wdata & space in response fifo 
// In Read Phase 
//      Generate burst ready, only when space in response fifo 
//
assign wbs_bry_o = (wbs_we_o) ? ((s_cmd_rd_empty || (s_cmd_rd_en  && s_cmd_rd_aempty)) ? 1'b0: 1'b1) :
	                         (s_resp_wr_full || (s_resp_wr_en && s_resp_wr_afull)) ? 1'b0: 1'b1;

// During Write phase, cmd fifo will have wdata, so dequeue for every ack
// During Read Phase, cmd fifo will be written only one time, hold the bus
// untill last ack received
assign s_cmd_rd_en = (wbs_stb_o && wbs_we_o) ? wbs_ack_i: wbs_lack_i;

// Write Interface
// response send only for read logic
assign s_resp_wr_en   = wbs_stb_o & (!wbs_we_o) & wbs_ack_i ;
assign s_resp_wr_data = {wbs_err_i,wbs_lack_i,wbs_dat_i};

sync_fifo2 #(.W(CFW), .DP(4),.WR_FAST(1), .RD_FAST(1)) u_cmd_if (
	           // Sync w.r.t WR clock
	           .clk           (clk_i             ),
                   .reset_n       (rst_n             ),
                   .wr_en         (m_cmd_wr_en       ),
                   .wr_data       (m_cmd_wr_data     ),
                   .full          (m_cmd_wr_full     ),                 
                   .afull         (m_cmd_wr_afull    ),                 

		   // Sync w.r.t RD Clock
                   .rd_en         (s_cmd_rd_en       ),
                   .empty         (s_cmd_rd_empty    ), // sync'ed to rd_clk
                   .aempty        (s_cmd_rd_aempty   ), // sync'ed to rd_clk
                   .rd_data       (s_cmd_rd_data     )
	     );


// Response used only for read path, 
// As cache access will be busrt of 512 location, To 
// support continous ack, depth is increase to 8 location
sync_fifo2 #(.W(RFW), .DP(4), .WR_FAST(1), .RD_FAST(1)) u_resp_if (
	           // Sync w.r.t WR clock
	           .clk           (clk_i              ),
                   .reset_n       (rst_n              ),
                   .wr_en         (s_resp_wr_en       ),
                   .wr_data       (s_resp_wr_data     ),
                   .full          (s_resp_wr_full     ),                 
                   .afull         (s_resp_wr_afull    ),                 

		   // Sync w.r.t RD Clock
                   .rd_en         (m_resp_rd_en       ),
                   .empty         (m_resp_rd_empty  ), // sync'ed to rd_clk
                   .aempty        (m_resp_rd_aempty   ), // sync'ed to rd_clk
                   .rd_data       (m_resp_rd_data     )
	     );



endmodule
