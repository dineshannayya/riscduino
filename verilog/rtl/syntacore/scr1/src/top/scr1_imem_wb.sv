//////////////////////////////////////////////////////////////////////
////                                                              ////
////  yifive Wishbone interface for Instruction memory            ////
////                                                              ////
////  This file is part of the yifive cores project               ////
////  http://www.opencores.org/cores/yifive/                      ////
////                                                              ////
////  Description:                                                ////
////     integrated wishbone i/f to instruction memory            ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////     v0:    June 7, 2021, Dinesh A                            ////
////             wishbone integration                             ////
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
//     Orginal owner Details                                      ////
//////////////////////////////////////////////////////////////////////
/// Copyright by Syntacore LLC © 2016-2021. See LICENSE for details///
/// @file       <scr1_imem_wb.sv>                                  ///
/// @brief      Instruction memory AHB bridge                      ///
//////////////////////////////////////////////////////////////////////

`include "scr1_wb.svh"
`include "scr1_memif.svh"

module scr1_imem_wb (
    // Control Signals
    input   logic                           rst_n,
    input   logic                           clk,

    // Core Interface
    output  logic                           imem_req_ack,
    input   logic                           imem_req,
    input   logic   [SCR1_WB_WIDTH-1:0]     imem_addr,
    output  logic   [SCR1_WB_WIDTH-1:0]     imem_rdata,
    output  type_scr1_mem_resp_e            imem_resp,

    // WB Interface
    output  logic                           wbd_stb_o, // strobe/request
    output  logic   [SCR1_WB_WIDTH-1:0]     wbd_adr_o, // address
    output  logic                           wbd_we_o,  // write
    output  logic   [SCR1_WB_WIDTH-1:0]     wbd_dat_o, // data output
    output  logic   [3:0]                   wbd_sel_o, // byte enable
    input   logic   [SCR1_WB_WIDTH-1:0]     wbd_dat_i, // data input
    input   logic                           wbd_ack_i, // acknowlegement
    input   logic                           wbd_err_i  // error

);

//-------------------------------------------------------------------------------
// Local parameters declaration
//-------------------------------------------------------------------------------
`ifndef SCR1_IMEM_WB_OUT_BP
localparam  SCR1_FIFO_WIDTH = 2;
localparam  SCR1_FIFO_CNT_WIDTH = $clog2(SCR1_FIFO_WIDTH+1);
`endif // SCR1_IMEM_WB_OUT_BP

//-------------------------------------------------------------------------------
// Local types declaration
//-------------------------------------------------------------------------------
typedef enum logic {
    SCR1_FSM_ADDR = 1'b0,
    SCR1_FSM_DATA = 1'b1,
    SCR1_FSM_ERR  = 1'bx
} type_scr1_fsm_e;

typedef struct packed {
    logic   [SCR1_WB_WIDTH-1:0]    haddr;
} type_scr1_req_fifo_s;

typedef struct packed {
    logic                           hresp;
    logic   [SCR1_WB_WIDTH-1:0]    hrdata;
} type_scr1_resp_fifo_s;

//-------------------------------------------------------------------------------
// Local signal declaration
//-------------------------------------------------------------------------------
type_scr1_fsm_e                             fsm;
logic                                       req_fifo_rd;
logic                                       req_fifo_wr;
logic                                       req_fifo_up;
`ifdef SCR1_IMEM_WB_OUT_BP
type_scr1_req_fifo_s                        req_fifo_r;
type_scr1_req_fifo_s [0:0]                  req_fifo;
`else // SCR1_IMEM_WB_OUT_BP
logic [SCR1_WB_WIDTH-1:0]                   req_fifo_dout;
`endif // SCR1_IMEM_WB_OUT_BP

logic                                       req_fifo_empty;
logic                                       req_fifo_full;

type_scr1_resp_fifo_s                       resp_fifo;
logic                                       resp_fifo_hready;

//-------------------------------------------------------------------------------
// Interface to Core
//-------------------------------------------------------------------------------
assign imem_req_ack = ~req_fifo_full;
assign req_fifo_wr  = ~req_fifo_full & imem_req;

assign imem_rdata = resp_fifo.hrdata;

assign imem_resp = (resp_fifo_hready)
                    ? (resp_fifo.hresp == 1'b1)
                        ? SCR1_MEM_RESP_RDY_OK
                        : SCR1_MEM_RESP_RDY_ER
                    : SCR1_MEM_RESP_NOTRDY;

//-------------------------------------------------------------------------------
// REQ_FIFO
//-------------------------------------------------------------------------------
`ifdef SCR1_IMEM_WB_OUT_BP
always_ff @(negedge rst_n, posedge clk) begin
    if (~rst_n) begin
        req_fifo_full <= 1'b0;
    end else begin
        if (~req_fifo_full) begin
            req_fifo_full <= imem_req & ~req_fifo_rd;
        end else begin
            req_fifo_full <= ~req_fifo_rd;
        end
    end
end
assign req_fifo_empty = ~(req_fifo_full | imem_req);

assign req_fifo_up    = ~req_fifo_rd & req_fifo_wr;
always_ff @(posedge clk) begin
    if (req_fifo_up) begin
        req_fifo_r.haddr <= imem_addr;
    end
end

assign req_fifo[0] = (req_fifo_full) ? req_fifo_r : imem_addr;

`else // SCR1_IMEM_WB_OUT_BP


 sync_fifo #(
      .DATA_WIDTH(SCR1_WB_WIDTH), // Data Width
      .ADDR_WIDTH(1),   // Address Width
      .FIFO_DEPTH(2)    // FIFO DEPTH
     )   u_req_fifo(

       .dout      (req_fifo_dout  ),

       .rstn      (rst_n          ),
       .clk       (clk            ),
       .wr_en     (req_fifo_wr    ), // Write
       .rd_en     (req_fifo_rd    ), // Read
       .din       (imem_addr      ),
       .full      (req_fifo_full  ),
       .empty     (req_fifo_empty )
);




`endif // SCR1_IMEM_WB_OUT_BP


always_comb begin
    req_fifo_rd = 1'b0;
    if (wbd_ack_i) begin
         req_fifo_rd = ~req_fifo_empty;
    end
end

//-------------------------------------------------------------------------------
// FIFO response
//-------------------------------------------------------------------------------
`ifdef SCR1_IMEM_WB_IN_BP
assign resp_fifo_hready = wbd_ack_i;
assign resp_fifo.hresp  = (wbd_err_i) ? 1'b0 : 1'b1;
assign resp_fifo.hrdata = wbd_dat_i;
assign wbd_stb_o        = ~req_fifo_empty;
assign wbd_adr_o        = req_fifo[0];
assign wbd_we_o         = 0; // Only Read supported
assign wbd_dat_o        = 32'h0; // No Write
assign wbd_sel_o        = 4'b1111; // Only Read allowed in imem i/f


`else // SCR1_IMEM_WB_IN_BP
always_ff @(negedge rst_n, posedge clk) begin
    if (~rst_n) begin
        resp_fifo_hready <= 1'b0;
    end else begin
        resp_fifo_hready <= wbd_ack_i ;
    end
end

always_ff @(posedge clk) begin
    if (wbd_ack_i) begin
        resp_fifo.hresp  <= (wbd_err_i) ? 1'b0 : 1'b1;
        resp_fifo.hrdata <= wbd_dat_i;
    end
end

assign wbd_stb_o    = ~req_fifo_empty;
assign wbd_adr_o    = req_fifo_dout;
assign wbd_we_o     = 0; // Only Read supported
assign wbd_dat_o    = 32'h0; // No Write
assign wbd_sel_o    = 4'b1111; // Only Read allowed in imem i/f
`endif // SCR1_IMEM_WB_IN_BP



`ifdef SCR1_TRGT_SIMULATION
//-------------------------------------------------------------------------------
// Assertion
//-------------------------------------------------------------------------------

// Check Core interface
SCR1_SVA_IMEM_WB_BRIDGE_REQ_XCHECK : assert property (
    @(negedge clk) disable iff (~rst_n)
    !$isunknown(imem_req)
    ) else $error("IMEM WB bridge Error: imem_req has unknown values");

SCR1_IMEM_WB_BRIDGE_ADDR_XCHECK : assert property (
    @(negedge clk) disable iff (~rst_n)
    imem_req |-> !$isunknown(imem_addr)
    ) else $error("IMEM WB bridge Error: imem_addr has unknown values");

SCR1_IMEM_WB_BRIDGE_ADDR_ALLIGN : assert property (
    @(negedge clk) disable iff (~rst_n)
    imem_req |-> (imem_addr[1:0] == '0)
    ) else $error("IMEM WB bridge Error: imem_addr has unalign values");

// Check WB interface
SCR1_IMEM_WB_BRIDGE_HREADY_XCHECK : assert property (
    @(negedge clk) disable iff (~rst_n)
    !$isunknown(hready)
    ) else $error("IMEM WB bridge Error: hready has unknown values");

SCR1_IMEM_WB_BRIDGE_HRESP_XCHECK : assert property (
    @(negedge clk) disable iff (~rst_n)
    !$isunknown(hresp)
    ) else $error("IMEM WB bridge Error: hresp has unknown values");

`endif // SCR1_TRGT_SIMULATION

endmodule : scr1_imem_wb
