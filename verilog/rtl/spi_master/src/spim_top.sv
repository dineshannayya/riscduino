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
////     There are two seperate Data path managed here            ////
////     with seperate command and response memory                ////
////     Master-0 : This is targetted for CORE IMEM request       ////
////                and expect only Read access                   ////
////     Master-1: This is targetted to CORE DMEM or              ////
////               Indirect Memory access, Both Write and Read    ////
////               accesss are supported.                         ////
////               Upto 255 Byte Read/Write Burst supported       ////
////    Limitation:                                               ////
////       1.  Write/Read FIFO Abort case not managed M1 port,    ////
////           expect user to clearly close the busrt request     ////
////       2.  Wishbone Request abort not yet supported.          ////
////       3.  Write access through M0 Port not supported         ////
////       4.  When Pre fetch feature used and both port m0 and   ////
////           m1 used, user need to make sure that data pre fetch////
////           count is withing 8DW, less Read path can hang due  ////
////           to response FIFO full from one master port         ////
////                                                              ////
////  To Do:                                                      ////
////    1. Add support for WishBone request timout                ////
////    2. Add Pre-fetch feature for M0 Port                      ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////     V.0  -  June 8, 2021                                     //// 
////     V.1  - June 25, 2021                                     ////
////            Pad logic is brought inside the block to avoid    ////
////            logic at digital core level for caravel project   ////
////     V.2  - July 6, 2021                                      ////
////            Added Hold fix cell for SPI data out signal to    ////
////            met interface hold                                ////
////     V.3  - July 13, 2021                                     ////
////            Data Prefetch feature added in M0 port, If Only   ////
////            M0 Read used, then Prefetch read can be 255 Byte, ////
////            But if the Both M0 and M1 read access enabled,    ////
////            then user need to make sure that M0 Prefetch is   ////
////            with in 8DW or 32 Byte, else there is chance      ////
////            data path can hang due to response FIFO full due  ////
////            to partial reading of data                        ////
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

    output logic                 [31:0]  spi_debug,

    // PAD I/f
    input  logic  [3:0]                  io_in    ,
    output logic  [5:0]                  io_out   ,
    output logic  [5:0]                  io_oeb

);


   
    logic                   [7:0] spi_clk_div      ;

    // Master 0 Configuration
    logic                         cfg_m0_fsm_reset ;
    logic [3:0]                   cfg_m0_cs_reg    ;  // Chip select
    logic [1:0]                   cfg_m0_spi_mode  ;  // Final SPI Mode 
    logic [1:0]                   cfg_m0_spi_switch;  // SPI Mode Switching Place
    logic [3:0]                   cfg_m0_spi_seq   ;  // SPI SEQUENCE
    logic [1:0]                   cfg_m0_addr_cnt  ;  // SPI Addr Count
    logic [1:0]                   cfg_m0_dummy_cnt ;  // SPI Dummy Count
    logic [7:0]                   cfg_m0_data_cnt  ;  // SPI Read Count
    logic [7:0]                   cfg_m0_cmd_reg   ;  // SPI MEM COMMAND
    logic [7:0]                   cfg_m0_mode_reg  ;  // SPI MODE REG

    logic [3:0]                   cfg_m1_cs_reg    ;  // Chip select
    logic [1:0]                   cfg_m1_spi_mode  ;  // Final SPI Mode 
    logic [1:0]                   cfg_m1_spi_switch;  // SPI Mode Switching Place

    logic [1:0]                   cfg_cs_early     ;  // Amount of cycle early CS asserted
    logic [1:0]                   cfg_cs_late      ;  // Amount of cycle late CS de-asserted

    // Towards Reg I/F
    logic                         spim_reg_req     ;   // Reg Request
    logic [3:0]                   spim_reg_addr    ;   // Reg Address
    logic                         spim_reg_we      ;   // Reg Write/Read Command
    logic [3:0]                   spim_reg_be      ;   // Reg Byte Enable
    logic [31:0]                  spim_reg_wdata   ;   // Reg Write Data
    logic                         spim_reg_ack     ;   // Read Ack
    logic [31:0]                  spim_reg_rdata   ;   // Read Read Data

    // Towards m0 Command FIFO
    logic                         m0_cmd_fifo_full    ;   // Command FIFO full
    logic                         m0_cmd_fifo_empty   ;   // Command FIFO empty
    logic                         m0_cmd_fifo_wr      ;   // Command FIFO Write
    logic                         m0_cmd_fifo_rd      ;   // Command FIFO read
    logic [33:0]                  m0_cmd_fifo_wdata   ;   // Command FIFO WData
    logic [33:0]                  m0_cmd_fifo_rdata   ;   // Command FIFO RData
    
    // Towards m0 Response FIFO
    logic                         m0_res_fifo_full    ;   // Response FIFO Empty
    logic                         m0_res_fifo_empty   ;   // Response FIFO Empty
    logic                         m0_res_fifo_wr      ;   // Response FIFO Write
    logic                         m0_res_fifo_rd      ;   // Response FIFO Read
    logic [31:0]                  m0_res_fifo_wdata   ;   // Response FIFO WData
    logic [31:0]                  m0_res_fifo_rdata   ;   // Response FIFO RData

    // Towards m1 Command FIFO
    logic                         m1_cmd_fifo_full    ;   // Command FIFO full
    logic                         m1_cmd_fifo_empty   ;   // Command FIFO empty
    logic                         m1_cmd_fifo_wr      ;   // Command FIFO Write
    logic                         m1_cmd_fifo_rd      ;   // Command FIFO Write
    logic [33:0]                  m1_cmd_fifo_wdata   ;   // Command FIFO WData
    logic [33:0]                  m1_cmd_fifo_rdata   ;   // Command FIFO RData
    
    // Towards m0 Response FIFO
    logic                         m1_res_fifo_full    ;   // Response FIFO Empty
    logic                         m1_res_fifo_empty   ;   // Response FIFO Empty
    logic                         m1_res_fifo_wr      ;   // Response FIFO Read
    logic                         m1_res_fifo_rd      ;   // Response FIFO Read
    logic [31:0]                  m1_res_fifo_wdata   ;   // Response FIFO WData
    logic [31:0]                  m1_res_fifo_rdata   ;   // Response FIFO RData

    logic                         m0_res_fifo_flush   ;   // m0 response fifo flush
    logic                         m1_res_fifo_flush   ;   // m0 response fifo flush

//-----------------------------------------------------
// SPI Debug monitoring
// ----------------------------------------------------
    logic [8:0]   spi_ctrl_status       ;
    logic [3:0]   m0_state         ;
    logic [3:0]   m1_state         ;
    logic [3:0]   ctrl_state        ;


    assign spi_debug  =   {m0_res_fifo_flush,m1_res_fifo_flush,spi_init_done,
		          m0_cmd_fifo_full,m0_cmd_fifo_empty,m0_res_fifo_full,m0_res_fifo_empty,
		          m1_cmd_fifo_full,m1_cmd_fifo_empty,m1_res_fifo_full,m1_res_fifo_empty,
		          ctrl_state[3:0], m0_state[3:0],m1_state[3:0],spi_ctrl_status[8:0]};

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
logic                          spi_init_done;
logic                          spi_sdo0_out;
logic                          spi_sdo1_out;
logic                          spi_sdo2_out;
logic                          spi_sdo3_out;

logic                          spi_sdo0_dl;
logic                          spi_sdo1_dl;
logic                          spi_sdo2_dl;
logic                          spi_sdo3_dl;


assign  spi_sdi0  =  io_in[0];
assign  spi_sdi1  =  io_in[1];
assign  spi_sdi2  =  io_in[2];
assign  spi_sdi3  =  io_in[3];

assign  io_out[0] =  spi_clk;
assign  io_out[1] =  spi_csn0;// No hold fix for CS#, as it asserted much eariler than SPI clock
assign  io_out[2] =  spi_sdo0_out;
assign  io_out[3] =  spi_sdo1_out;
assign  io_out[4] =  spi_sdo2_out;
assign  io_out[5] =  spi_sdo3_out;

// ADDing Delay cells for Interface hold fix
sky130_fd_sc_hd__dlygate4sd3_1 u_delay1_sdio0 (.X(spi_sdo0_d1),.A(spi_sdo0));
sky130_fd_sc_hd__dlygate4sd3_1 u_delay2_sdio0 (.X(spi_sdo0_d2),.A(spi_sdo0_d1));
sky130_fd_sc_hd__clkbuf_16 u_buf_sdio0    (.X(spi_sdo0_out),.A(spi_sdo0_d2));

sky130_fd_sc_hd__dlygate4sd3_1 u_delay1_sdio1 (.X(spi_sdo1_d1),.A(spi_sdo1));
sky130_fd_sc_hd__dlygate4sd3_1 u_delay2_sdio1 (.X(spi_sdo1_d2),.A(spi_sdo1_d1));
sky130_fd_sc_hd__clkbuf_16 u_buf_sdio1    (.X(spi_sdo1_out),.A(spi_sdo1_d2));

sky130_fd_sc_hd__dlygate4sd3_1 u_delay1_sdio2 (.X(spi_sdo2_d1),.A(spi_sdo2));
sky130_fd_sc_hd__dlygate4sd3_1 u_delay2_sdio2 (.X(spi_sdo2_d2),.A(spi_sdo2_d1));
sky130_fd_sc_hd__clkbuf_16 u_buf_sdio2    (.X(spi_sdo2_out),.A(spi_sdo2_d2));

sky130_fd_sc_hd__dlygate4sd3_1 u_delay1_sdio3 (.X(spi_sdo3_d1),.A(spi_sdo3));
sky130_fd_sc_hd__dlygate4sd3_1 u_delay2_sdio3 (.X(spi_sdo3_d2),.A(spi_sdo3_d1));
sky130_fd_sc_hd__clkbuf_16 u_buf_sdio3    (.X(spi_sdo3_out),.A(spi_sdo3_d2));


assign  io_oeb[0] =  1'b0;         // spi_clk
assign  io_oeb[1] =  1'b0;         // spi_csn
assign  io_oeb[2] =  !spi_en_tx;   // spi_dio0
assign  io_oeb[3] =  !spi_en_tx;   // spi_dio1
assign  io_oeb[4] =  (spi_mode == 0) ? 1 'b0 : !spi_en_tx;   // spi_dio2
assign  io_oeb[5] =  (spi_mode == 0) ? 1 'b0 : !spi_en_tx;   // spi_dio3

spim_if #( .WB_WIDTH(WB_WIDTH)) u_wb_if(
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

    // Configuration
        .cfg_fsm_reset                  (cfg_m0_fsm_reset             ),
        .cfg_mem_seq                    (cfg_m0_spi_seq               ), // SPI MEM SEQUENCE
        .cfg_addr_cnt                   (cfg_m0_addr_cnt              ), // SPI Addr Count
        .cfg_dummy_cnt                  (cfg_m0_dummy_cnt             ), // SPI Dummy Count
        .cfg_data_cnt                   (cfg_m0_data_cnt              ), // SPI Read Count
        .cfg_cmd_reg                    (cfg_m0_cmd_reg               ), // SPI MEM COMMAND
        .cfg_mode_reg                   (cfg_m0_mode_reg              ), // SPI MODE REG

        .spi_init_done                  (spi_init_done                ), // SPI internal Init completed

    // Towards Reg I/F
        .spim_reg_req                   (spim_reg_req                 ), // Reg Request
        .spim_reg_addr                  (spim_reg_addr                ), // Reg Address
        .spim_reg_we                    (spim_reg_we                  ), // Reg Write/Read Command
        .spim_reg_be                    (spim_reg_be                  ), // Reg Byte Enable
        .spim_reg_wdata                 (spim_reg_wdata               ), // Reg Write Data
        .spim_reg_ack                   (spim_reg_ack                 ), // Read Ack
        .spim_reg_rdata                 (spim_reg_rdata               ), // Read Read Data

    // Towards Command FIFO
        .cmd_fifo_empty                 (m0_cmd_fifo_empty            ), // Command FIFO empty
        .cmd_fifo_wr                    (m0_cmd_fifo_wr               ), // Command FIFO Write
        .cmd_fifo_wdata                 (m0_cmd_fifo_wdata            ), // Command FIFO WData
    
    // Towards Response FIFO
        .res_fifo_empty                 (m0_res_fifo_empty            ), // Response FIFO Empty
        .res_fifo_rd                    (m0_res_fifo_rd               ), // Response FIFO Read
        .res_fifo_rdata                 (m0_res_fifo_rdata            ), // Response FIFO Data

	.state                          (m0_state                     )

    );


    spim_regs
    #(
        .WB_WIDTH(WB_WIDTH)
    )
    u_spim_regs
    (
        .mclk                           (mclk                         ),
        .rst_n                          (rst_n                        ),
	.fast_sim_mode                  (1'b0                         ),

        .spi_clk_div                    (spi_clk_div                  ),
	.spi_init_done                  (spi_init_done                ),

        .spi_debug                      (spi_debug                    ),

        .cfg_m0_fsm_reset               (cfg_m0_fsm_reset             ),
        .cfg_m0_cs_reg                  (cfg_m0_cs_reg                ), // Chip select
        .cfg_m0_spi_mode                (cfg_m0_spi_mode              ), // Final SPI Mode 
        .cfg_m0_spi_switch              (cfg_m0_spi_switch            ), // SPI Mode Switching Place
        .cfg_m0_spi_seq                 (cfg_m0_spi_seq               ), // SPI SEQUENCE
        .cfg_m0_addr_cnt                (cfg_m0_addr_cnt              ), // SPI Addr Count
        .cfg_m0_dummy_cnt               (cfg_m0_dummy_cnt             ), // SPI Dummy Count
        .cfg_m0_data_cnt                (cfg_m0_data_cnt              ), // SPI Read Count
        .cfg_m0_cmd_reg                 (cfg_m0_cmd_reg               ), // SPI MEM COMMAND
        .cfg_m0_mode_reg                (cfg_m0_mode_reg              ), // SPI MODE REG

        .cfg_m1_cs_reg                  (cfg_m1_cs_reg                ), // Chip select
        .cfg_m1_spi_mode                (cfg_m1_spi_mode              ), // Final SPI Mode 
        .cfg_m1_spi_switch              (cfg_m1_spi_switch            ), // SPI Mode Switching Place

	.cfg_cs_early                   (cfg_cs_early                 ),
	.cfg_cs_late                    (cfg_cs_late                  ),

    // Towards Reg I/F
        .spim_reg_req                   (spim_reg_req                 ), // Reg Request
        .spim_reg_addr                  (spim_reg_addr                ), // Reg Address
        .spim_reg_we                    (spim_reg_we                  ), // Reg Write/Read Command
        .spim_reg_be                    (spim_reg_be                  ), // Reg Byte Enable
        .spim_reg_wdata                 (spim_reg_wdata               ), // Reg Write Data
        .spim_reg_ack                   (spim_reg_ack                 ), // Read Ack
        .spim_reg_rdata                 (spim_reg_rdata               ), // Read Read Data

    // Towards Command FIFO
        .cmd_fifo_full                  (m1_cmd_fifo_full             ), // Command FIFO empty
        .cmd_fifo_empty                 (m1_cmd_fifo_empty            ), // Command FIFO empty
        .cmd_fifo_wr                    (m1_cmd_fifo_wr               ), // Command FIFO Write
        .cmd_fifo_wdata                 (m1_cmd_fifo_wdata            ), // Command FIFO WData
    
    // Towards Response FIFO
        .res_fifo_full                  (m1_res_fifo_full             ), // Response FIFO Empty
        .res_fifo_empty                 (m1_res_fifo_empty            ), // Response FIFO Empty
        .res_fifo_rd                    (m1_res_fifo_rd               ), // Response FIFO Read
        .res_fifo_rdata                 (m1_res_fifo_rdata            ),  // Response FIFO Data

	.state                          (m1_state                     )

    );

 // Master 0 Command FIFO
 spim_fifo #(.W(34), .DP(2)) u_m0_cmd_fifo (
	 .clk                           (mclk                        ),
         .reset_n                       (rst_n                       ),
	 .flush                         (1'b0                        ),
         .wr_en                         (m0_cmd_fifo_wr              ),
         .wr_data                       (m0_cmd_fifo_wdata           ),
         .full                          (m0_cmd_fifo_full            ),                 
         .afull                         (                            ),                 
         .rd_en                         (m0_cmd_fifo_rd              ),
         .empty                         (m0_cmd_fifo_empty           ),                
         .aempty                        (                            ),                
         .rd_data                       (m0_cmd_fifo_rdata           )
   );

 // Master 0 Response FIFO
 spim_fifo #(.W(32), .DP(8)) u_m0_res_fifo (
	 .clk                           (mclk                        ),
         .reset_n                       (rst_n                       ),
	 .flush                         (m0_res_fifo_flush           ),
         .wr_en                         (m0_res_fifo_wr              ),
         .wr_data                       (m0_res_fifo_wdata           ),
         .full                          (m0_res_fifo_full            ),                 
         .afull                         (                            ),                 
         .rd_en                         (m0_res_fifo_rd              ),
         .empty                         (m0_res_fifo_empty           ),                
         .aempty                        (                            ),                
         .rd_data                       (m0_res_fifo_rdata           )
   );

 // Master 1 Command FIFO
 spim_fifo #(.W(34), .DP(4)) u_m1_cmd_fifo (
	 .clk                           (mclk                        ),
         .reset_n                       (rst_n                       ),
	 .flush                         (1'b0                        ),
         .wr_en                         (m1_cmd_fifo_wr              ),
         .wr_data                       (m1_cmd_fifo_wdata           ),
         .full                          (m1_cmd_fifo_full            ),                 
         .afull                         (                            ),                 
         .rd_en                         (m1_cmd_fifo_rd              ),
         .empty                         (m1_cmd_fifo_empty           ),                
         .aempty                        (                            ),                
         .rd_data                       (m1_cmd_fifo_rdata           )
   );
 // Master 1 Response FIFO
 spim_fifo #(.W(32), .DP(8)) u_m1_res_fifo (
	 .clk                           (mclk                        ),
         .reset_n                       (rst_n                       ),
	 .flush                         (m1_res_fifo_flush           ),
         .wr_en                         (m1_res_fifo_wr              ),
         .wr_data                       (m1_res_fifo_wdata           ),
         .full                          (m1_res_fifo_full            ),                 
         .afull                         (                            ),                 
         .rd_en                         (m1_res_fifo_rd              ),
         .empty                         (m1_res_fifo_empty           ),                
         .aempty                        (                            ),                
         .rd_data                       (m1_res_fifo_rdata           )
   );


    spim_ctrl u_spictrl
    (
        .clk                            (mclk                         ),
        .rstn                           (rst_n                        ),

        .spi_clk_div                    (spi_clk_div                  ),
        .spi_status                     (spi_ctrl_status              ),

        .cfg_m0_cs_reg                  (cfg_m0_cs_reg                ), // Chip select
        .cfg_m0_spi_mode                (cfg_m0_spi_mode              ), // Final SPI Mode 
        .cfg_m0_spi_switch              (cfg_m0_spi_switch            ), // SPI Mode Switching Place

        .cfg_m1_cs_reg                  (cfg_m1_cs_reg                ), // Chip select
        .cfg_m1_spi_mode                (cfg_m1_spi_mode              ), // Final SPI Mode 
        .cfg_m1_spi_switch              (cfg_m1_spi_switch            ), // SPI Mode Switching Place

	.cfg_cs_early                   (cfg_cs_early                 ),
	.cfg_cs_late                    (cfg_cs_late                  ),

	.m0_cmd_fifo_empty              (m0_cmd_fifo_empty            ),
        .m0_cmd_fifo_rd                 (m0_cmd_fifo_rd               ),
	.m0_cmd_fifo_rdata              (m0_cmd_fifo_rdata            ),

	.m0_res_fifo_flush              (m0_res_fifo_flush            ),
	.m0_res_fifo_empty              (m0_res_fifo_empty            ),
	.m0_res_fifo_full               (m0_res_fifo_full             ),
	.m0_res_fifo_wr                 (m0_res_fifo_wr               ),
	.m0_res_fifo_wdata              (m0_res_fifo_wdata            ),

	.m1_cmd_fifo_empty              (m1_cmd_fifo_empty            ),
        .m1_cmd_fifo_rd                 (m1_cmd_fifo_rd               ),
	.m1_cmd_fifo_rdata              (m1_cmd_fifo_rdata            ),

	.m1_res_fifo_flush              (m1_res_fifo_flush            ),
	.m1_res_fifo_empty              (m1_res_fifo_empty            ),
	.m1_res_fifo_full               (m1_res_fifo_full             ),
	.m1_res_fifo_wr                 (m1_res_fifo_wr               ),
	.m1_res_fifo_wdata              (m1_res_fifo_wdata            ),

	.ctrl_state                     (ctrl_state                   ),

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
