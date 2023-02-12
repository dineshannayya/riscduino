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
////  Reg2WB Interface                                            ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description : This module contains Register To Wishbone     ////
////                Translation                                   ////
////                                                              ////   
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesh.annayya@gmail.com              ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 20th July 2022, Dinesh A                            ////
////          Initial version                                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

module qspis_wb(

             //spis_if Interface
             input  logic         reg_wr          , // write request
             input  logic         reg_rd          , // read request
             input  logic [23:0]  reg_addr        , // address
             input  logic  [3:0]  reg_be          , // Byte enable
             input  logic [31:0]  reg_wdata       , // write data
             output logic  [31:0] reg_rdata       , // read data
             output logic         reg_ack         , // read valid

          // WB Master Port
             output  logic        wbm_cyc_o       ,  // strobe/request
             output  logic        wbm_stb_o       ,  // strobe/request
             output  logic [31:0] wbm_adr_o       ,  // address
             output  logic        wbm_we_o        ,  // write
             output  logic [31:0] wbm_dat_o       ,  // data output
             output  logic [3:0]  wbm_sel_o       ,  // byte enable
             input   logic [31:0] wbm_dat_i       ,  // data input
             input   logic        wbm_ack_i       ,  // acknowlegement
             input   logic        wbm_err_i          // error

);



assign wbm_cyc_o = reg_wr | reg_rd;
assign wbm_stb_o = reg_wr | reg_rd;
assign wbm_adr_o = {4'b0,reg_addr};
assign wbm_we_o  = reg_wr;
assign wbm_sel_o = reg_be;
assign wbm_dat_o = reg_wdata;
assign reg_rdata = wbm_dat_i;
assign reg_ack   = wbm_ack_i;


endmodule
