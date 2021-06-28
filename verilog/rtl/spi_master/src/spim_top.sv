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
////  SPI Master Top Module                                       ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  https://github.com/dineshannayya/yifive_r0.git              ////
////  http://www.opencores.org/cores/yifive/                      ////
////                                                              ////
////  Description                                                 ////
////     SPI Master Top module                                    ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////     V.0  -  June 8, 2021                                     //// 
////     V.1  - June 25, 2021                                     ////
////            Pad logic is brought inside the block to avoid    ////
////            logic at digital core level for caravel project   ////
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



module spim_top
#( parameter WB_WIDTH = 32)
(
    input  logic                          mclk,
    input  logic                          rst_n,


    input  logic                         wbd_stb_i, // strobe/request
    input  logic   [WB_WIDTH-1:0]        wbd_adr_i, // address
    input  logic                         wbd_we_i,  // write
    input  logic   [WB_WIDTH-1:0]        wbd_dat_i, // data output
    input  logic   [3:0]                 wbd_sel_i, // byte enable
    output logic   [WB_WIDTH-1:0]        wbd_dat_o, // data input
    output logic                         wbd_ack_o, // acknowlegement
    output logic                         wbd_err_o,  // error

    output logic                   [1:0] events_o,

    // PAD I/f
    input  [5:0]                         io_in    ,
    output  [5:0]                        io_out   ,
    output  [5:0]                        io_oeb

);



    logic   [5:0] spi_clk_div;
    logic         spi_req;
    logic         spi_ack;
    logic  [31:0] spi_addr;
    logic   [5:0] spi_addr_len;
    logic  [7:0]  spi_cmd;
    logic   [5:0] spi_cmd_len;
    logic  [7:0]  spi_mode_cmd;
    logic         spi_mode_cmd_enb;
    logic  [15:0] spi_data_len;
    logic  [15:0] spi_dummy_rd_len;
    logic  [15:0] spi_dummy_wr_len;
    logic         spi_swrst;
    logic         spi_rd;
    logic         spi_wr;
    logic         spi_qrd;
    logic         spi_qwr;
    logic [31:0]  spi_wdata;
    logic [31:0]  spi_rdata;
    logic   [3:0] spi_csreg;
    logic  [31:0] spi_data_tx;
    logic         spi_data_tx_valid;
    logic         spi_data_tx_ready;
    logic  [31:0] spi_data_rx;
    logic         spi_data_rx_valid;
    logic         spi_data_rx_ready;
    logic   [8:0] spi_ctrl_status;
    logic  [31:0] spi_ctrl_data_tx;
    logic         spi_ctrl_data_tx_valid;
    logic         spi_ctrl_data_tx_ready;
    logic  [31:0] spi_ctrl_data_rx;
    logic         spi_ctrl_data_rx_valid;
    logic         spi_ctrl_data_rx_ready;
    logic  [31:0] reg2spi_wdata;

    logic         s_eot;


//-------------------------------------------------------
// SPI Interface moved inside to support carvel IO pad 
// -------------------------------------------------------

logic                          spi_clk;
logic                          spi_csn0;
logic                          spi_csn1;
logic                          spi_csn2;
logic                          spi_csn3;
logic                    [1:0] spi_mode;
logic                          spi_sdo0;
logic                          spi_sdo1;
logic                          spi_sdo2;
logic                          spi_sdo3;
logic                          spi_sdi0;
logic                          spi_sdi1;
logic                          spi_sdi2;
logic                          spi_sdi3;
logic                          spi_en_tx;


assign  spi_sdi0  =  io_in[2];
assign  spi_sdi1  =  io_in[3];
assign  spi_sdi2  =  io_in[4];
assign  spi_sdi3  =  io_in[5];

assign  io_out[0] =  spi_clk;
assign  io_out[1] =  spi_csn0;
assign  io_out[2] =  spi_sdo0;
assign  io_out[3] =  spi_sdo1;
assign  io_out[4] =  spi_sdo2;
assign  io_out[5] =  spi_sdo3;
   
assign  io_oeb[0] =  1'b0;         // spi_clk
assign  io_oeb[1] =  1'b0;         // spi_csn
assign  io_oeb[2] =  !spi_en_tx;   // spi_dio0
assign  io_oeb[3] =  !spi_en_tx;   // spi_dio1
assign  io_oeb[4] =  !spi_en_tx;   // spi_dio2
assign  io_oeb[5] =  !spi_en_tx;   // spi_dio3



    spim_regs
    #(
        .WB_WIDTH(WB_WIDTH)
    )
    u_spim_regs
    (
        .mclk                           (mclk                         ),
        .rst_n                          (rst_n                        ),

        .wbd_stb_i                      (wbd_stb_i                    ), // strobe/request
        .wbd_adr_i                      (wbd_adr_i                    ), // address
        .wbd_we_i                       (wbd_we_i                     ),  // write
        .wbd_dat_i                      (wbd_dat_i                    ), // data output
        .wbd_sel_i                      (wbd_sel_i                    ), // byte enable
        .wbd_dat_o                      (wbd_dat_o                    ), // data input
        .wbd_ack_o                      (wbd_ack_o                    ), // acknowlegement
        .wbd_err_o                      (wbd_err_o                    ),  // error

        .spi_clk_div                    (spi_clk_div                  ),
        .spi_status                     (spi_ctrl_status              ),


        .spi_req                        (spi_req                     ),
        .spi_addr                       (spi_addr                     ),
        .spi_addr_len                   (spi_addr_len                 ),
        .spi_cmd                        (spi_cmd                      ),
        .spi_cmd_len                    (spi_cmd_len                  ),
        .spi_mode_cmd                   (spi_mode_cmd                 ),
        .spi_mode_cmd_enb               (spi_mode_cmd_enb             ),
        .spi_csreg                      (spi_csreg                    ),
        .spi_data_len                   (spi_data_len                 ),
        .spi_dummy_rd_len               (spi_dummy_rd_len             ),
        .spi_dummy_wr_len               (spi_dummy_wr_len             ),
        .spi_swrst                      (spi_swrst                    ),
        .spi_rd                         (spi_rd                       ),
        .spi_wr                         (spi_wr                       ),
        .spi_qrd                        (spi_qrd                      ),
        .spi_qwr                        (spi_qwr                      ),
        .spi_wdata                      (spi_wdata                    ),
        .spi_rdata                      (spi_rdata                    ),
        .spi_ack                        (spi_ack                      )
    );

    spim_ctrl u_spictrl
    (
        .clk                            (mclk                         ),
        .rstn                           (rst_n                        ),
        .eot                            (                             ),

        .spi_clk_div                    (spi_clk_div                  ),
        .spi_status                     (spi_ctrl_status              ),

        .spi_req                        (spi_req                      ),
        .spi_addr                       (spi_addr                     ),
        .spi_addr_len                   (spi_addr_len                 ),
        .spi_cmd                        (spi_cmd                      ),
        .spi_cmd_len                    (spi_cmd_len                  ),
        .spi_mode_cmd                   (spi_mode_cmd                 ),
        .spi_mode_cmd_enb               (spi_mode_cmd_enb             ),
        .spi_csreg                      (spi_csreg                    ),
        .spi_data_len                   (spi_data_len                 ),
        .spi_dummy_rd_len               (spi_dummy_rd_len             ),
        .spi_dummy_wr_len               (spi_dummy_wr_len             ),
        .spi_swrst                      (spi_swrst                    ),
        .spi_rd                         (spi_rd                       ),
        .spi_wr                         (spi_wr                       ),
        .spi_qrd                        (spi_qrd                      ),
        .spi_qwr                        (spi_qwr                      ),
        .spi_wdata                      (spi_wdata                    ),
        .spi_rdata                      (spi_rdata                    ),
        .spi_ack                        (spi_ack                      ),

        .spi_clk                        (spi_clk                      ),
        .spi_csn0                       (spi_csn0                     ),
        .spi_csn1                       (spi_csn1                     ),
        .spi_csn2                       (spi_csn2                     ),
        .spi_csn3                       (spi_csn3                     ),
        .spi_mode                       (spi_mode                     ),
        .spi_sdo0                       (spi_sdo0                     ),
        .spi_sdo1                       (spi_sdo1                     ),
        .spi_sdo2                       (spi_sdo2                     ),
        .spi_sdo3                       (spi_sdo3                     ),
        .spi_sdi0                       (spi_sdi0                     ),
        .spi_sdi1                       (spi_sdi1                     ),
        .spi_sdi2                       (spi_sdi2                     ),
        .spi_sdi3                       (spi_sdi3                     ),
	.spi_en_tx                      (spi_en_tx                    )
    );

endmodule
