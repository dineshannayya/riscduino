//////////////////////////////////////////////////////////////////////
////                                                              ////
////  yifive Wishbone interface for Data memory                   ////
////                                                              ////
////  This file is part of the yifive cores project               ////
////  http://www.opencores.org/cores/yifive/                      ////
////                                                              ////
////  Description:                                                ////
////     integrated wishbone i/f to data  memory                  ////
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
/// @file       <scr1_dmem_wb.sv>                                  ///
/// @brief      Data memory WB bridge                              ///
/////////////////////////////////////////////////////////////////////

`include "scr1_wb.svh"
`include "scr1_memif.svh"

module scr1_dmem_wb (
    // Control Signals
    input   logic                           rst_n,
    input   logic                           clk,

    // Core Interface
    output  logic                           dmem_req_ack,
    input   logic                           dmem_req,
    input   type_scr1_mem_cmd_e             dmem_cmd,
    input   type_scr1_mem_width_e           dmem_width,
    input   logic   [SCR1_WB_WIDTH-1:0]     dmem_addr,
    input   logic   [SCR1_WB_WIDTH-1:0]     dmem_wdata,
    output  logic   [SCR1_WB_WIDTH-1:0]     dmem_rdata,
    output  type_scr1_mem_resp_e            dmem_resp,

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
// Local Parameters
//-------------------------------------------------------------------------------
`ifndef SCR1_DMEM_WB_OUT_BP
localparam  SCR1_FIFO_WIDTH = 2;
localparam  SCR1_FIFO_CNT_WIDTH = 2;
`endif // SCR1_DMEM_WB_OUT_BP

//-------------------------------------------------------------------------------
// Local type declaration
//-------------------------------------------------------------------------------
typedef enum logic {
    SCR1_FSM_ADDR = 1'b0,
    SCR1_FSM_DATA = 1'b1,
    SCR1_FSM_ERR  = 1'bx
} type_scr1_fsm_e;

typedef struct packed {
    logic                           hwrite;
    logic   [2:0]                   hwidth;
    logic   [SCR1_WB_WIDTH-1:0]     haddr;
    logic   [SCR1_WB_WIDTH-1:0]     hwdata;
} type_scr1_req_fifo_s;

typedef struct packed {
    logic                           hwrite;
    logic   [2:0]                   hwidth;
    logic   [1:0]                   haddr;
} type_scr1_data_fifo_s;

typedef struct packed {
    logic                           hresp;
    logic   [2:0]                   hwidth;
    logic   [1:0]                   haddr;
    logic   [SCR1_WB_WIDTH-1:0]    hrdata;
} type_scr1_resp_fifo_s;

//-------------------------------------------------------------------------------
// Local functions
//-------------------------------------------------------------------------------
function automatic logic   [2:0] scr1_conv_mem2wb_width (
    input   type_scr1_mem_width_e    dmem_width
);
    logic   [2:0]   tmp;
begin
    case (dmem_width)
        SCR1_MEM_WIDTH_BYTE : begin
            tmp = SCR1_DSIZE_8B;
        end
        SCR1_MEM_WIDTH_HWORD : begin
            tmp = SCR1_DSIZE_16B;
        end
        SCR1_MEM_WIDTH_WORD : begin
            tmp = SCR1_DSIZE_32B;
        end
        default : begin
            tmp = SCR1_DSIZE_32B;
        end
    endcase
    scr1_conv_mem2wb_width =  tmp; // cp.11
end
endfunction

function automatic logic[SCR1_WB_WIDTH-1:0] scr1_conv_mem2wb_wdata (
    input   logic   [1:0]                   dmem_addr,
    input   type_scr1_mem_width_e           dmem_width,
    input   logic   [SCR1_WB_WIDTH-1:0]    dmem_wdata
);
    logic   [SCR1_WB_WIDTH-1:0]  tmp;
begin
    tmp = 'x;
    case (dmem_width)
        SCR1_MEM_WIDTH_BYTE : begin
            case (dmem_addr)
                2'b00 : begin
                    tmp[7:0]   = dmem_wdata[7:0];
                end
                2'b01 : begin
                    tmp[15:8]  = dmem_wdata[7:0];
                end
                2'b10 : begin
                    tmp[23:16] = dmem_wdata[7:0];
                end
                2'b11 : begin
                    tmp[31:24] = dmem_wdata[7:0];
                end
                default : begin
                end
            endcase
        end
        SCR1_MEM_WIDTH_HWORD : begin
            case (dmem_addr[1])
                1'b0 : begin
                    tmp[15:0]  = dmem_wdata[15:0];
                end
                1'b1 : begin
                    tmp[31:16] = dmem_wdata[15:0];
                end
                default : begin
                end
            endcase
        end
        SCR1_MEM_WIDTH_WORD : begin
            tmp = dmem_wdata;
        end
        default : begin
        end
    endcase
    scr1_conv_mem2wb_wdata = tmp;
end
endfunction

function automatic logic[SCR1_WB_WIDTH-1:0] scr1_conv_wb2mem_rdata (
    input   logic [2:0]                 hwidth,
    input   logic [1:0]                 haddr,
    input   logic [SCR1_WB_WIDTH-1:0]  hrdata
);
    logic   [SCR1_WB_WIDTH-1:0]  tmp;
begin
    tmp = 'x;
    case (hwidth)
        SCR1_DSIZE_8B : begin
            case (haddr)
                2'b00 : tmp[7:0] = hrdata[7:0];
                2'b01 : tmp[7:0] = hrdata[15:8];
                2'b10 : tmp[7:0] = hrdata[23:16];
                2'b11 : tmp[7:0] = hrdata[31:24];
                default : begin
                end
            endcase
        end
        SCR1_DSIZE_16B : begin
            case (haddr[1])
                1'b0 : tmp[15:0] = hrdata[15:0];
                1'b1 : tmp[15:0] = hrdata[31:16];
                default : begin
                end
            endcase
        end
        SCR1_DSIZE_32B : begin
            tmp = hrdata;
        end
        default : begin
        end
    endcase
    scr1_conv_wb2mem_rdata = tmp;
end
endfunction

//-------------------------------------------------------------------------------
// Local signal declaration
//-------------------------------------------------------------------------------
logic                                       req_fifo_rd;
logic                                       req_fifo_wr;
logic                                       req_fifo_up;
`ifdef SCR1_DMEM_WB_OUT_BP
type_scr1_req_fifo_s                        req_fifo_new;
type_scr1_req_fifo_s                        req_fifo_r;
type_scr1_req_fifo_s [0:0]                  req_fifo;
`else // SCR1_DMEM_WB_OUT_BP
type_scr1_req_fifo_s [0:SCR1_FIFO_WIDTH-1]  req_fifo;
type_scr1_req_fifo_s [0:SCR1_FIFO_WIDTH-1]  req_fifo_new;
logic       [SCR1_FIFO_CNT_WIDTH-1:0]       req_fifo_cnt;
logic       [SCR1_FIFO_CNT_WIDTH-1:0]       req_fifo_cnt_new;
`endif // SCR1_DMEM_WB_OUT_BP
logic                                       req_fifo_empty;
logic                                       req_fifo_full;

type_scr1_data_fifo_s                       data_fifo;
type_scr1_resp_fifo_s                       resp_fifo;
logic                                       resp_fifo_hready;

//-------------------------------------------------------------------------------
// Interface to Core
//-------------------------------------------------------------------------------
assign dmem_req_ack = ~req_fifo_full;
assign req_fifo_wr  = ~req_fifo_full & dmem_req;

assign dmem_rdata = scr1_conv_wb2mem_rdata(resp_fifo.hwidth, resp_fifo.haddr, resp_fifo.hrdata);

assign dmem_resp = (resp_fifo_hready)
                    ? (resp_fifo.hresp == 1'b1)
                        ? SCR1_MEM_RESP_RDY_OK
                        : SCR1_MEM_RESP_RDY_ER
                    : SCR1_MEM_RESP_NOTRDY ;

//-------------------------------------------------------------------------------
// REQ_FIFO
//-------------------------------------------------------------------------------
`ifdef SCR1_DMEM_WB_OUT_BP
always_ff @(negedge rst_n, posedge clk) begin
    if (~rst_n) begin
        req_fifo_full <= 1'b0;
    end else begin
        if (~req_fifo_full) begin
            req_fifo_full <= dmem_req & ~req_fifo_rd;
        end else begin
            req_fifo_full <= ~req_fifo_rd;
        end
    end
end
assign req_fifo_empty = ~(req_fifo_full | dmem_req);

assign req_fifo_up = ~req_fifo_rd & req_fifo_wr;
always_ff @(posedge clk) begin
    if (req_fifo_up) begin
        req_fifo_r <= req_fifo_new;
    end
end

assign req_fifo_new.hwrite = dmem_req ? (dmem_cmd == SCR1_MEM_CMD_WR)       : 1'b0;
assign req_fifo_new.hwidth = dmem_req ? scr1_conv_mem2wb_width(dmem_width) : '0;
assign req_fifo_new.haddr  = dmem_req ? dmem_addr                           : '0;
assign req_fifo_new.hwdata = (dmem_req & (dmem_cmd == SCR1_MEM_CMD_WR))
                                ? scr1_conv_mem2wb_wdata(dmem_addr[1:0], dmem_width, dmem_wdata)
                                : '0;
assign req_fifo[0] = (req_fifo_full) ? req_fifo_r: req_fifo_new;

//-------------------------------------------------------------------------------
// Register Data from response path - Used by Read path logic
//-------------------------------------------------------------------------------
always_ff @(posedge clk) begin
    if (wbd_ack_i) begin
         if (~req_fifo_empty) begin
             data_fifo.hwidth <= req_fifo[0].hwidth;
             data_fifo.haddr  <= req_fifo[0].haddr[1:0];
         end
    end
end

`else // SCR1_DMEM_WB_OUT_BP


wire	                 hwrite_in = (dmem_cmd == SCR1_MEM_CMD_WR);
wire [2:0]               hwidth_in = scr1_conv_mem2wb_width(dmem_width);
wire [SCR1_WB_WIDTH-1:0] haddr_in  = dmem_addr;
wire [SCR1_WB_WIDTH-1:0] hwdata_in = scr1_conv_mem2wb_wdata(dmem_addr[1:0], dmem_width, dmem_wdata);

reg  [3:0]              hbel_in; // byte select
always_comb begin
	hbel_in = 0;
    case (hwidth_in)
        SCR1_DSIZE_8B : begin
            hbel_in = 4'b0001 << haddr_in[1:0];
        end
        SCR1_DSIZE_16B : begin
            hbel_in = 4'b0011 << haddr_in[1:0];
        end
        SCR1_DSIZE_32B : begin
            hbel_in = 4'b1111;
        end
    endcase
end


wire [SCR1_WB_WIDTH+SCR1_WB_WIDTH+3+4:0] req_fifo_din = {hbel_in,hwrite_in,hwidth_in,haddr_in,hwdata_in};

 sync_fifo #(
      .DATA_WIDTH(SCR1_WB_WIDTH+SCR1_WB_WIDTH+3+1+4), // Data Width
      .ADDR_WIDTH(1),   // Address Width
      .FIFO_DEPTH(2)    // FIFO DEPTH
     )   u_req_fifo(

       .dout      (req_fifo_dout  ),

       .rstn      (rst_n          ),
       .clk       (clk            ),
       .wr_en     (req_fifo_wr    ), // Write
       .rd_en     (req_fifo_rd    ), // Read
       .din       (req_fifo_din   ),
       .full      (req_fifo_full  ),
       .empty     (req_fifo_empty )
);

//-------------------------------------------------------------------------------
// Register Data from response path - Used by Read path logic
//-------------------------------------------------------------------------------
wire	                 hwrite_out;
wire [2:0]               hwidth_out;
wire [SCR1_WB_WIDTH-1:0] haddr_out;
wire [SCR1_WB_WIDTH-1:0] hwdata_out;
wire [3:0]               hbel_out;

assign {hbel_out,hwrite_out,hwidth_out,haddr_out,hwdata_out} = req_fifo_dout;

always_ff @(posedge clk) begin
    if (wbd_ack_i) begin
         if (~req_fifo_empty) begin
             data_fifo.hwidth <= hwidth_out;
             data_fifo.haddr  <= haddr_out[1:0];
         end
    end
end

`endif // SCR1_DMEM_WB_OUT_BP


always_comb begin
    req_fifo_rd = 1'b0;
    if (wbd_ack_i) begin
         req_fifo_rd = ~req_fifo_empty;
    end
end


//-------------------------------------------------------------------------------
// FIFO response
//-------------------------------------------------------------------------------
`ifdef SCR1_DMEM_WB_IN_BP

assign resp_fifo_hready = wbd_ack_i;
assign resp_fifo.hresp  = (wbd_err_i) ? 1'b0 : 1'b1;
assign resp_fifo.hwidth = data_fifo.hwidth;
assign resp_fifo.haddr  = data_fifo.haddr;
assign resp_fifo.hrdata = wbd_dat_i;

assign wbd_stb_o     = ~req_fifo_empty;
assign wbd_adr_o    = req_fifo[0].haddr;
assign wbd_we_o     = req_fifo[0].hwrite;
assign wbd_dat_o    = req_fifo[0].hwdata;

always_comb begin
	wbd_sel_o = 0;
    case (req_fifo[0].hwidth)
        SCR1_DSIZE_8B : begin
            wbd_sel_o = 4'b0001 << req_fifo[0].haddr[1:0];
        end
        SCR1_DSIZE_16B : begin
            wbd_sel_o = 4'b0011 << req_fifo[0].haddr[1:0];
        end
        SCR1_DSIZE_32B : begin
            wbd_sel_o = 4'b1111;
        end
    endcase
end
`else // SCR1_DMEM_WB_IN_BP
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
        resp_fifo.hwidth <= data_fifo.hwidth;
        resp_fifo.haddr  <= data_fifo.haddr;
        resp_fifo.hrdata <= wbd_dat_i;
    end
end


assign wbd_stb_o    = ~req_fifo_empty;
assign wbd_adr_o    = haddr_out;
assign wbd_we_o     = hwrite_out;
assign wbd_dat_o    = hwdata_out;
assign wbd_sel_o    = hbel_out;

`endif // SCR1_DMEM_WB_IN_BP



endmodule : scr1_dmem_wb
