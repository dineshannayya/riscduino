//////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: Syntacore LLC © 2016-2021
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
// SPDX-FileContributor: Syntacore LLC
// //////////////////////////////////////////////////////////////////////////
/// @file       <scr1_tcm.sv>
/// @brief      Tightly-Coupled Memory (TCM)
///

`include "scr1_memif.svh"
`include "scr1_arch_description.svh"

`ifdef SCR1_TCM_EN
module scr1_tcm
#(
    parameter SCR1_TCM_SIZE = `SCR1_IMEM_AWIDTH'h00010000
)
(
    // Control signals
    input   logic                           clk,
    input   logic                           rst_n,

`ifndef SCR1_TCM_MEM
    // SRAM0 PORT-0
    output  logic                           sram0_clk0,
    output  logic                           sram0_csb0,
    output  logic                           sram0_web0,
    output  logic   [8:0]                   sram0_addr0,
    output  logic   [3:0]                   sram0_wmask0,
    output  logic   [31:0]                  sram0_din0,
    input   logic   [31:0]                  sram0_dout0,

    // SRAM-0 PORT-1
    output  logic                           sram0_clk1,
    output  logic                           sram0_csb1,
    output  logic  [8:0]                    sram0_addr1,
    input   logic  [31:0]                   sram0_dout1,

    // SRAM1 PORT-0
    output  logic                           sram1_clk0,
    output  logic                           sram1_csb0,
    output  logic                           sram1_web0,
    output  logic   [8:0]                   sram1_addr0,
    output  logic   [3:0]                   sram1_wmask0,
    output  logic   [31:0]                  sram1_din0,
    input   logic   [31:0]                  sram1_dout0,

    // SRAM-1 PORT-1
    output  logic                           sram1_clk1,
    output  logic                           sram1_csb1,
    output  logic  [8:0]                    sram1_addr1,
    input   logic  [31:0]                   sram1_dout1,

`endif

    // Core instruction interface
    output  logic                           imem_req_ack,
    input   logic                           imem_req,
    input   logic [`SCR1_IMEM_AWIDTH-1:0]   imem_addr,
    output  logic [`SCR1_IMEM_DWIDTH-1:0]   imem_rdata,
    output  logic [1:0]                     imem_resp,

    // Core data interface
    output  logic                           dmem_req_ack,
    input   logic                           dmem_req,
    input   logic                           dmem_cmd,
    input   logic [1:0]                     dmem_width,
    input   logic [`SCR1_DMEM_AWIDTH-1:0]   dmem_addr,
    input   logic [`SCR1_DMEM_DWIDTH-1:0]   dmem_wdata,
    output  logic [`SCR1_DMEM_DWIDTH-1:0]   dmem_rdata,
    output  logic [1:0]                     dmem_resp
);

//-------------------------------------------------------------------------------
// Local signal declaration
//-------------------------------------------------------------------------------
logic                               imem_req_en;
logic                               dmem_req_en;
logic                               imem_rd;
logic                               dmem_rd;
logic                               dmem_wr;
logic [`SCR1_DMEM_DWIDTH-1:0]       dmem_writedata;
logic [`SCR1_DMEM_DWIDTH-1:0]       dmem_rdata_local;
logic [3:0]                         dmem_byteen;
logic [1:0]                         dmem_rdata_shift_reg;
//-------------------------------------------------------------------------------
// Core interface
//-------------------------------------------------------------------------------
assign imem_req_en = (imem_resp == SCR1_MEM_RESP_RDY_OK) ^ imem_req;
assign dmem_req_en = (dmem_resp == SCR1_MEM_RESP_RDY_OK) ^ dmem_req;

always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        imem_resp <= SCR1_MEM_RESP_NOTRDY;
    end else if (imem_req_en) begin
        imem_resp <= imem_req ? SCR1_MEM_RESP_RDY_OK : SCR1_MEM_RESP_NOTRDY;
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        dmem_resp <= SCR1_MEM_RESP_NOTRDY;
    end else if (dmem_req_en) begin
        dmem_resp <= dmem_req ? SCR1_MEM_RESP_RDY_OK : SCR1_MEM_RESP_NOTRDY;
    end
end

assign imem_req_ack = 1'b1;
assign dmem_req_ack = 1'b1;
//-------------------------------------------------------------------------------
// Memory data composing
//-------------------------------------------------------------------------------
`ifndef SCR1_TCM_MEM
// connect the TCM memory to SRAM-0
assign sram0_clk1 = clk;
assign sram0_csb1 =!(imem_req & imem_addr[11] == 1'b0);
assign sram0_addr1 = imem_addr[10:2];

// connect the TCM memory to SRAM-1
assign sram1_clk1 = clk;
assign sram1_csb1 =!(imem_req & imem_addr[11] == 1'b1);
assign sram1_addr1 = imem_addr[10:2];

// IMEM Read Data Selection Based on Address bit[11]
assign imem_rdata  = (imem_addr[11] == 1'b0) ?  sram0_dout1: sram1_dout1;

// SRAM-0 Port 0 Control Generation
assign sram0_clk0 = clk;
assign sram0_csb0   = !(dmem_req & (dmem_addr[11] == 1'b0) & ((dmem_cmd == SCR1_MEM_CMD_RD) | (dmem_cmd == SCR1_MEM_CMD_WR)));
assign sram0_web0   = !(dmem_req & (dmem_cmd == SCR1_MEM_CMD_WR));
assign sram0_addr0  = dmem_addr[10:2];
assign sram0_wmask0 =  dmem_byteen;
assign sram0_din0   =  dmem_writedata;

// SRAM-1 Port 0 Control Generation
assign sram1_clk0 = clk;
assign sram1_csb0   = !(dmem_req & (dmem_addr[11] == 1'b1) & ((dmem_cmd == SCR1_MEM_CMD_RD) | (dmem_cmd == SCR1_MEM_CMD_WR)));
assign sram1_web0   = !(dmem_req & (dmem_cmd == SCR1_MEM_CMD_WR));
assign sram1_addr0  = dmem_addr[10:2];
assign sram1_wmask0 =  dmem_byteen;
assign sram1_din0   =  dmem_writedata;


// DMEM Read Data Selection Based on Address bit[11]
assign dmem_rdata_local = (dmem_addr[11] == 1'b0) ? sram0_dout0: sram1_dout0;

`endif

//------------------------------
always_comb begin
    dmem_writedata = dmem_wdata;
    dmem_byteen    = 4'b1111;
    case ( dmem_width )
        SCR1_MEM_WIDTH_BYTE : begin
            dmem_writedata  = {(`SCR1_DMEM_DWIDTH /  8){dmem_wdata[7:0]}};
            dmem_byteen     = 4'b0001 << dmem_addr[1:0];
        end
        SCR1_MEM_WIDTH_HWORD : begin
            dmem_writedata  = {(`SCR1_DMEM_DWIDTH / 16){dmem_wdata[15:0]}};
            dmem_byteen     = 4'b0011 << {dmem_addr[1], 1'b0};
        end
        default : begin
        end
    endcase
end
//-------------------------------------------------------------------------------
// Memory instantiation
//-------------------------------------------------------------------------------
`ifdef SCR1_TCM_MEM
scr1_dp_memory #(
    .SCR1_WIDTH ( 32            ),
    .SCR1_SIZE  ( SCR1_TCM_SIZE )
) i_dp_memory (
    .clk    ( clk                                   ),
    // Instruction port
    // Port A
    .rena   ( imem_rd                               ),
    .addra  ( imem_addr[$clog2(SCR1_TCM_SIZE)-1:2]  ),
    .qa     ( imem_rdata                            ),
    // Data port
    // Port B
    .renb   ( dmem_rd                               ),
    .wenb   ( dmem_wr                               ),
    .webb   ( dmem_byteen                           ),
    .addrb  ( dmem_addr[$clog2(SCR1_TCM_SIZE)-1:2]  ),
    .qb     ( dmem_rdata_local                      ),
    .datab  ( dmem_writedata                        )
);
`endif

//-------------------------------------------------------------------------------
// Data memory output generation
//-------------------------------------------------------------------------------

assign dmem_rdata_shift_reg = dmem_addr[1:0];
assign dmem_rdata = dmem_rdata_local >> ( 8 * dmem_rdata_shift_reg );

endmodule : scr1_tcm

`endif // SCR1_TCM_EN
