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
////  SPI With Wishbone                                           ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description : This module contains SPI interface + WB Master////
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

module sspis_top (

	     input  logic         sys_clk         ,
	     input  logic         rst_n           ,

             input  logic         sclk            ,
             input  logic         ssn             ,
             input  logic         sdin            ,
             output logic         sdout           ,
             output logic         sdout_oen       ,

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

//-----------------------------------
// Register I/F
//-----------------------------------

logic         reg_wr          ; // write request
logic         reg_rd          ; // read request
logic [31:0]  reg_addr        ; // address
logic [3:0]   reg_be          ; // Byte enable
logic [31:0]  reg_wdata       ; // write data
logic [31:0]  reg_rdata       ; // read data
logic         reg_ack         ; // read valid

sspis_if u_if (

	     .sys_clk         (sys_clk         ),
	     .rst_n           (rst_n           ),

             .sclk            (sclk            ),
             .ssn             (ssn             ),
             .sdin            (sdin            ),
             .sdout           (sdout           ),
             .sdout_oen       (sdout_oen       ),

             //spi_sm Interface
             .reg_wr          (reg_wr          ), // write request
             .reg_rd          (reg_rd          ), // read request
             .reg_addr        (reg_addr        ), // address
             .reg_be          (reg_be          ), // Byte enable
             .reg_wdata       (reg_wdata       ), // write data
             .reg_rdata       (reg_rdata       ), // read data
             .reg_ack         (reg_ack         )  // read valid
             );

spi2wb  u_spi2wb (

             //spis_if Interface
             .reg_wr          (reg_wr          ), // write request
             .reg_rd          (reg_rd          ), // read request
             .reg_addr        (reg_addr        ), // address
             .reg_be          (reg_be          ), // Byte enable
             .reg_wdata       (reg_wdata       ), // write data
             .reg_rdata       (reg_rdata       ), // read data
             .reg_ack         (reg_ack         ), // read valid

          // WB Master Port
             .wbm_cyc_o       (wbm_cyc_o       ),  // strobe/request
             .wbm_stb_o       (wbm_stb_o       ),  // strobe/request
             .wbm_adr_o       (wbm_adr_o       ),  // address
             .wbm_we_o        (wbm_we_o        ),  // write
             .wbm_dat_o       (wbm_dat_o       ),  // data output
             .wbm_sel_o       (wbm_sel_o       ),  // byte enable
             .wbm_dat_i       (wbm_dat_i       ),  // data input
             .wbm_ack_i       (wbm_ack_i       ),  // acknowlegement
             .wbm_err_i       (wbm_err_i       )   // error

);

endmodule
