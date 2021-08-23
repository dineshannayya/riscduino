//////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2021, Dinesh Annayya
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
// SPDX-FileContributor: Dinesh Annayya <dinesha@opencores.org>
// //////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  syntacore interface block                                   ////
////                                                              ////
////  This file is part of the yifive cores project               ////
////  https://github.com/dineshannayya/yifive_r0.git              ////
////  http://www.opencores.org/cores/yifive/                      ////
////                                                              ////
////  Description:                                                ////
////     Holds interface block and timer & reset sync logic       ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
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
`include "scr1_arch_description.svh"
`include "scr1_memif.svh"
`include "scr1_wb.svh"
`ifdef SCR1_IPIC_EN
`include "scr1_ipic.svh"
`endif // SCR1_IPIC_EN

`ifdef SCR1_TCM_EN
 `define SCR1_IMEM_ROUTER_EN
`endif // SCR1_TCM_EN

module scr1_intf (
    // Control
    input   logic                                   pwrup_rst_n,            // Power-Up Reset
    input   logic                                   rst_n,                  // Regular Reset signal
    input   logic                                   cpu_rst_n,              // CPU Reset (Core Reset)
    input   logic                                   core_clk,               // Core clock
    input   logic                                   rtc_clk,                // Real-time clock
    output  logic [63:0]                            riscv_debug,

`ifdef SCR1_DBG_EN
    // -- JTAG I/F
    input   logic                                   trst_n,
`endif // SCR1_DBG_EN

    input   logic                                   wb_rst_n,       // Wish bone reset
    input   logic                                   wb_clk,         // wish bone clock
    // Instruction Memory Interface
    output  logic                                   wbd_imem_stb_o, // strobe/request
    output  logic   [SCR1_WB_WIDTH-1:0]             wbd_imem_adr_o, // address
    output  logic                                   wbd_imem_we_o,  // write
    output  logic   [SCR1_WB_WIDTH-1:0]             wbd_imem_dat_o, // data output
    output  logic   [3:0]                           wbd_imem_sel_o, // byte enable
    input   logic   [SCR1_WB_WIDTH-1:0]             wbd_imem_dat_i, // data input
    input   logic                                   wbd_imem_ack_i, // acknowlegement
    input   logic                                   wbd_imem_err_i,  // error

    // Data Memory Interface
    output  logic                                   wbd_dmem_stb_o, // strobe/request
    output  logic   [SCR1_WB_WIDTH-1:0]             wbd_dmem_adr_o, // address
    output  logic                                   wbd_dmem_we_o,  // write
    output  logic   [SCR1_WB_WIDTH-1:0]             wbd_dmem_dat_o, // data output
    output  logic   [3:0]                           wbd_dmem_sel_o, // byte enable
    input   logic   [SCR1_WB_WIDTH-1:0]             wbd_dmem_dat_i, // data input
    input   logic                                   wbd_dmem_ack_i, // acknowlegement
    input   logic                                   wbd_dmem_err_i, // error

    // Common
    output   logic                                  pwrup_rst_n_sync,                // Power-Up reset
    output   logic                                  rst_n_sync,                      // Regular reset
    output   logic                                  cpu_rst_n_sync,                  // CPU reset
    output   logic                                  test_mode,                  // DFT Test Mode
    output   logic                                  test_rst_n,                 // DFT Test Reset
    input    logic                                  core_rst_n_local,               // Core reset
    input    logic   [48:0]                         core_debug  ,
`ifdef SCR1_DBG_EN
    // Debug Interface
    output   logic                                  tapc_trst_n,                // Test Reset (TRSTn)
`endif
    // Memory-mapped external timer
    output   logic [63:0]                           timer_val,          // Machine timer value
    output   logic                                  timer_irq,
    // Instruction Memory Interface
    output   logic                                  core_imem_req_ack,        // IMEM request acknowledge
    input    logic                                  core_imem_req,            // IMEM request
    input    logic                                  core_imem_cmd,            // IMEM command
    input    logic [`SCR1_IMEM_AWIDTH-1:0]          core_imem_addr,           // IMEM address
    output   logic [`SCR1_IMEM_DWIDTH-1:0]          core_imem_rdata,          // IMEM read data
    output   logic [1:0]                            core_imem_resp,           // IMEM response

    // Data Memory Interface
    output   logic                                  core_dmem_req_ack,        // DMEM request acknowledge
    input    logic                                  core_dmem_req,            // DMEM request
    input    logic                                  core_dmem_cmd,            // DMEM command
    input    logic[1:0]                             core_dmem_width,          // DMEM data width
    input    logic [`SCR1_DMEM_AWIDTH-1:0]          core_dmem_addr,           // DMEM address
    input    logic [`SCR1_DMEM_DWIDTH-1:0]          core_dmem_wdata,          // DMEM write data
    output   logic [`SCR1_DMEM_DWIDTH-1:0]          core_dmem_rdata,          // DMEM read data
    output   logic [1:0]                            core_dmem_resp            // DMEM response

);
//-------------------------------------------------------------------------------
// Local parameters
//-------------------------------------------------------------------------------
localparam int unsigned SCR1_CLUSTER_TOP_RST_SYNC_STAGES_NUM            = 2;

//-------------------------------------------------------------------------------
// Local signal declaration
//-------------------------------------------------------------------------------

// Instruction memory interface from router to WB bridge
logic                                               wb_imem_req_ack;
logic                                               wb_imem_req;
logic                                               wb_imem_cmd;
logic [`SCR1_IMEM_AWIDTH-1:0]                       wb_imem_addr;
logic [`SCR1_IMEM_DWIDTH-1:0]                       wb_imem_rdata;
logic [1:0]                                         wb_imem_resp;

// Data memory interface from router to WB bridge
logic                                               wb_dmem_req_ack;
logic                                               wb_dmem_req;
logic                                               wb_dmem_cmd;
logic [1:0]                                         wb_dmem_width;
logic [`SCR1_DMEM_AWIDTH-1:0]                       wb_dmem_addr;
logic [`SCR1_DMEM_DWIDTH-1:0]                       wb_dmem_wdata;
logic [`SCR1_DMEM_DWIDTH-1:0]                       wb_dmem_rdata;
logic [1:0]                                         wb_dmem_resp;

`ifdef SCR1_TCM_EN
// Instruction memory interface from router to TCM
logic                                               tcm_imem_req_ack;
logic                                               tcm_imem_req;
logic                                               tcm_imem_cmd;
logic [`SCR1_IMEM_AWIDTH-1:0]                       tcm_imem_addr;
logic [`SCR1_IMEM_DWIDTH-1:0]                       tcm_imem_rdata;
logic [1:0]                                         tcm_imem_resp;

// Data memory interface from router to TCM
logic                                               tcm_dmem_req_ack;
logic                                               tcm_dmem_req;
logic                                               tcm_dmem_cmd;
logic [1:0]                                         tcm_dmem_width;
logic [`SCR1_DMEM_AWIDTH-1:0]                       tcm_dmem_addr;
logic [`SCR1_DMEM_DWIDTH-1:0]                       tcm_dmem_wdata;
logic [`SCR1_DMEM_DWIDTH-1:0]                       tcm_dmem_rdata;
logic [1:0]                                         tcm_dmem_resp;
`endif // SCR1_TCM_EN

// Data memory interface from router to memory-mapped timer
logic                                               timer_dmem_req_ack;
logic                                               timer_dmem_req;
logic                                               timer_dmem_cmd;
logic [1:0]                                         timer_dmem_width;
logic [`SCR1_DMEM_AWIDTH-1:0]                       timer_dmem_addr;
logic [`SCR1_DMEM_DWIDTH-1:0]                       timer_dmem_wdata;
logic [`SCR1_DMEM_DWIDTH-1:0]                       timer_dmem_rdata;
logic [1:0]                                         timer_dmem_resp;



//---------------------------------------------------------------------------------
// To avoid core level power hook up, we have brought this signal inside, to
// avoid any cell at digital core level
// --------------------------------------------------------------------------------
assign test_mode = 1'b0;
assign test_rst_n = 1'b0;

assign riscv_debug = {core_imem_req_ack,core_imem_req,core_imem_cmd,core_imem_resp[1:0],
	              core_dmem_req_ack,core_dmem_req,core_dmem_cmd,core_dmem_resp[1:0],
		      wb_imem_req,wb_dmem_req,wb_imem_cmd,wb_imem_resp[1:0], core_debug };
//-------------------------------------------------------------------------------
// Reset logic
//-------------------------------------------------------------------------------
// Power-Up Reset synchronizer
scr1_reset_sync_cell #(
    .STAGES_AMOUNT       (SCR1_CLUSTER_TOP_RST_SYNC_STAGES_NUM)
) i_pwrup_rstn_reset_sync (
    .rst_n          (pwrup_rst_n     ),
    .clk            (core_clk        ),
    .test_rst_n     (test_rst_n      ),
    .test_mode      (test_mode       ),
    .rst_n_in       (1'b1            ),
    .rst_n_out      (pwrup_rst_n_sync)
);

// Regular Reset synchronizer
scr1_reset_sync_cell #(
    .STAGES_AMOUNT       (SCR1_CLUSTER_TOP_RST_SYNC_STAGES_NUM)
) i_rstn_reset_sync (
    .rst_n          (pwrup_rst_n     ),
    .clk            (core_clk        ),
    .test_rst_n     (test_rst_n      ),
    .test_mode      (test_mode       ),
    .rst_n_in       (rst_n           ),
    .rst_n_out      (rst_n_sync      )
);

// CPU Reset synchronizer
scr1_reset_sync_cell #(
    .STAGES_AMOUNT       (SCR1_CLUSTER_TOP_RST_SYNC_STAGES_NUM)
) i_cpu_rstn_reset_sync (
    .rst_n          (pwrup_rst_n     ),
    .clk            (core_clk        ),
    .test_rst_n     (test_rst_n      ),
    .test_mode      (test_mode       ),
    .rst_n_in       (cpu_rst_n       ),
    .rst_n_out      (cpu_rst_n_sync  )
);

`ifdef SCR1_DBG_EN
// TAPC Reset
scr1_reset_and2_cell i_tapc_rstn_and2_cell (
    .rst_n_in       ({trst_n, pwrup_rst_n}),
    .test_rst_n     (test_rst_n      ),
    .test_mode      (test_mode       ),
    .rst_n_out      (tapc_trst_n     )
);
`endif // SCR1_DBG_EN

`ifdef SCR1_TCM_EN
//-------------------------------------------------------------------------------
// TCM instance
//-------------------------------------------------------------------------------
scr1_tcm #(
    .SCR1_TCM_SIZE  (`SCR1_DMEM_AWIDTH'(~SCR1_TCM_ADDR_MASK + 1'b1))
) i_tcm (
    .clk            (core_clk        ),
    .rst_n          (core_rst_n_local),

    // Instruction interface to TCM
    .imem_req_ack   (tcm_imem_req_ack),
    .imem_req       (tcm_imem_req    ),
    .imem_addr      (tcm_imem_addr   ),
    .imem_rdata     (tcm_imem_rdata  ),
    .imem_resp      (tcm_imem_resp   ),

    // Data interface to TCM
    .dmem_req_ack   (tcm_dmem_req_ack),
    .dmem_req       (tcm_dmem_req    ),
    .dmem_cmd       (tcm_dmem_cmd    ),
    .dmem_width     (tcm_dmem_width  ),
    .dmem_addr      (tcm_dmem_addr   ),
    .dmem_wdata     (tcm_dmem_wdata  ),
    .dmem_rdata     (tcm_dmem_rdata  ),
    .dmem_resp      (tcm_dmem_resp   )
);
`endif // SCR1_TCM_EN


//-------------------------------------------------------------------------------
// Memory-mapped timer instance
//-------------------------------------------------------------------------------
scr1_timer i_timer (
    // Common
    .rst_n          (core_rst_n_local  ),
    .clk            (core_clk          ),
    .rtc_clk        (rtc_clk           ),

    // Memory interface
    .dmem_req       (timer_dmem_req    ),
    .dmem_cmd       (timer_dmem_cmd    ),
    .dmem_width     (timer_dmem_width  ),
    .dmem_addr      (timer_dmem_addr   ),
    .dmem_wdata     (timer_dmem_wdata  ),
    .dmem_req_ack   (timer_dmem_req_ack),
    .dmem_rdata     (timer_dmem_rdata  ),
    .dmem_resp      (timer_dmem_resp   ),

    // Timer interface
    .timer_val      (timer_val         ),
    .timer_irq      (timer_irq         )
);


`ifdef SCR1_IMEM_ROUTER_EN
//-------------------------------------------------------------------------------
// Instruction memory router
//-------------------------------------------------------------------------------
scr1_imem_router #(
 `ifdef SCR1_TCM_EN
    .SCR1_ADDR_MASK     (SCR1_TCM_ADDR_MASK),
    .SCR1_ADDR_PATTERN  (SCR1_TCM_ADDR_PATTERN)
 `endif // SCR1_TCM_EN
) i_imem_router (
    .rst_n          (core_rst_n_local ),
    .clk            (core_clk         ),
    // Interface to core
    .imem_req_ack   (core_imem_req_ack),
    .imem_req       (core_imem_req    ),
    .imem_cmd       (core_imem_cmd    ),
    .imem_addr      (core_imem_addr   ),
    .imem_rdata     (core_imem_rdata  ),
    .imem_resp      (core_imem_resp   ),
    // Interface to WB bridge
    .port0_req_ack  (wb_imem_req_ack ),
    .port0_req      (wb_imem_req     ),
    .port0_cmd      (wb_imem_cmd     ),
    .port0_addr     (wb_imem_addr    ),
    .port0_rdata    (wb_imem_rdata   ),
    .port0_resp     (wb_imem_resp    ),
 `ifdef SCR1_TCM_EN
    // Interface to TCM
    .port1_req_ack  (tcm_imem_req_ack ),
    .port1_req      (tcm_imem_req     ),
    .port1_cmd      (tcm_imem_cmd     ),
    .port1_addr     (tcm_imem_addr    ),
    .port1_rdata    (tcm_imem_rdata   ),
    .port1_resp     (tcm_imem_resp    )
 `endif // SCR1_TCM_EN
);

`else // SCR1_IMEM_ROUTER_EN

assign wb_imem_req         = core_imem_req;
assign wb_imem_cmd         = core_imem_cmd;
assign wb_imem_addr        = core_imem_addr;
assign core_imem_req_ack    = wb_imem_req_ack;
assign core_imem_resp       = wb_imem_resp;
assign core_imem_rdata      = wb_imem_rdata;

`endif // SCR1_IMEM_ROUTER_EN

//-------------------------------------------------------------------------------
// Data memory router
//-------------------------------------------------------------------------------
scr1_dmem_router #(

`ifdef SCR1_TCM_EN
    .SCR1_PORT1_ADDR_MASK       (SCR1_TCM_ADDR_MASK),
    .SCR1_PORT1_ADDR_PATTERN    (SCR1_TCM_ADDR_PATTERN),
`else // SCR1_TCM_EN
    .SCR1_PORT1_ADDR_MASK       (32'h00000000),
    .SCR1_PORT1_ADDR_PATTERN    (32'hFFFFFFFF),
`endif // SCR1_TCM_EN

    .SCR1_PORT2_ADDR_MASK       (SCR1_TIMER_ADDR_MASK),
    .SCR1_PORT2_ADDR_PATTERN    (SCR1_TIMER_ADDR_PATTERN)

) i_dmem_router (
    .rst_n          (core_rst_n_local    ),
    .clk            (core_clk            ),
    // Interface to core
    .dmem_req_ack   (core_dmem_req_ack   ),
    .dmem_req       (core_dmem_req       ),
    .dmem_cmd       (core_dmem_cmd       ),
    .dmem_width     (core_dmem_width     ),
    .dmem_addr      (core_dmem_addr      ),
    .dmem_wdata     (core_dmem_wdata     ),
    .dmem_rdata     (core_dmem_rdata     ),
    .dmem_resp      (core_dmem_resp      ),
`ifdef SCR1_TCM_EN
    // Interface to TCM
    .port1_req_ack  (tcm_dmem_req_ack    ),
    .port1_req      (tcm_dmem_req        ),
    .port1_cmd      (tcm_dmem_cmd        ),
    .port1_width    (tcm_dmem_width      ),
    .port1_addr     (tcm_dmem_addr       ),
    .port1_wdata    (tcm_dmem_wdata      ),
    .port1_rdata    (tcm_dmem_rdata      ),
    .port1_resp     (tcm_dmem_resp       ),
`else // SCR1_TCM_EN
    .port1_req_ack  (1'b0),
    .port1_req      (                    ),
    .port1_cmd      (                    ),
    .port1_width    (                    ),
    .port1_addr     (                    ),
    .port1_wdata    (                    ),
    .port1_rdata    (32'h0               ),
    .port1_resp     (SCR1_MEM_RESP_RDY_ER),
`endif // SCR1_TCM_EN
    // Interface to memory-mapped timer
    .port2_req_ack  (timer_dmem_req_ack  ),
    .port2_req      (timer_dmem_req      ),
    .port2_cmd      (timer_dmem_cmd      ),
    .port2_width    (timer_dmem_width    ),
    .port2_addr     (timer_dmem_addr     ),
    .port2_wdata    (timer_dmem_wdata    ),
    .port2_rdata    (timer_dmem_rdata    ),
    .port2_resp     (timer_dmem_resp     ),
    // Interface to WB bridge
    .port0_req_ack  (wb_dmem_req_ack    ),
    .port0_req      (wb_dmem_req        ),
    .port0_cmd      (wb_dmem_cmd        ),
    .port0_width    (wb_dmem_width      ),
    .port0_addr     (wb_dmem_addr       ),
    .port0_wdata    (wb_dmem_wdata      ),
    .port0_rdata    (wb_dmem_rdata      ),
    .port0_resp     (wb_dmem_resp       )
);


//-------------------------------------------------------------------------------
// Instruction memory WB bridge
//-------------------------------------------------------------------------------
scr1_imem_wb i_imem_wb (
    .core_rst_n     (core_rst_n_local   ),
    .core_clk       (core_clk           ),
    // Interface to imem router
    .imem_req_ack   (wb_imem_req_ack   ),
    .imem_req       (wb_imem_req       ),
    .imem_addr      (wb_imem_addr      ),
    .imem_rdata     (wb_imem_rdata     ),
    .imem_resp      (wb_imem_resp      ),
    // WB interface
    .wb_rst_n       (wb_rst_n          ),
    .wb_clk         (wb_clk            ),
    .wbd_stb_o      (wbd_imem_stb_o    ), 
    .wbd_adr_o      (wbd_imem_adr_o    ), 
    .wbd_we_o       (wbd_imem_we_o     ),  
    .wbd_dat_o      (wbd_imem_dat_o    ), 
    .wbd_sel_o      (wbd_imem_sel_o    ), 
    .wbd_dat_i      (wbd_imem_dat_i    ), 
    .wbd_ack_i      (wbd_imem_ack_i    ), 
    .wbd_err_i      (wbd_imem_err_i    )
);


//-------------------------------------------------------------------------------
// Data memory WB bridge
//-------------------------------------------------------------------------------
scr1_dmem_wb i_dmem_wb (
    .core_rst_n     (core_rst_n_local   ),
    .core_clk       (core_clk           ),
    // Interface to dmem router
    .dmem_req_ack   (wb_dmem_req_ack   ),
    .dmem_req       (wb_dmem_req       ),
    .dmem_cmd       (wb_dmem_cmd       ),
    .dmem_width     (wb_dmem_width     ),
    .dmem_addr      (wb_dmem_addr      ),
    .dmem_wdata     (wb_dmem_wdata     ),
    .dmem_rdata     (wb_dmem_rdata     ),
    .dmem_resp      (wb_dmem_resp      ),
    // WB interface
    .wb_rst_n       (wb_rst_n          ),
    .wb_clk         (wb_clk            ),
    .wbd_stb_o      (wbd_dmem_stb_o    ), 
    .wbd_adr_o      (wbd_dmem_adr_o    ), 
    .wbd_we_o       (wbd_dmem_we_o     ),  
    .wbd_dat_o      (wbd_dmem_dat_o    ), 
    .wbd_sel_o      (wbd_dmem_sel_o    ), 
    .wbd_dat_i      (wbd_dmem_dat_i    ), 
    .wbd_ack_i      (wbd_dmem_ack_i    ), 
    .wbd_err_i      (wbd_dmem_err_i    )
);

endmodule : scr1_intf
