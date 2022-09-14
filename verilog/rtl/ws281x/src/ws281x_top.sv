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
////  ws281x Top                                                  ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 23rd Aug 2022, Dinesh A                             ////
////          initial version                                     ////
//////////////////////////////////////////////////////////////////////

module ws281x_top  (
                       // System Signals
                       // Inputs
		               input logic           mclk,
                       input logic           h_reset_n,

		               // Reg Bus Interface Signal
                       input logic           reg_cs,
                       input logic           reg_wr,
                       input logic [3:0]     reg_addr,
                       input logic [31:0]    reg_wdata,
                       input logic [3:0]     reg_be,

                       // Outputs
                       output logic [31:0]   reg_rdata,
                       output logic          reg_ack,

                       output logic [3:0]    txd 

                ); 

assign txd[2] = txd[0];
assign txd[3] = txd[1];

logic[15:0]    cfg_reset_period     ;   // Reset period interm of clk
logic [9:0]    cfg_clk_period       ;   // Total bit clock period
logic [9:0]    cfg_th0_period       ;   // bit-0 drive low period
logic [9:0]    cfg_th1_period       ;   // bit-1 drive low period

logic          port0_enb            ;
logic          port0_rd             ;
logic          port0_dval           ;
logic [23:0]   port0_data           ;
logic          port1_enb            ;
logic          port1_rd             ;
logic          port1_dval           ;
logic [23:0]   port1_data           ;
//logic [23:0]   port2_data         ;
//logic [23:0]   port3_data         ;

ws281x_reg  u_reg (
                .mclk                ( mclk                 ),
                .h_reset_n           ( h_reset_n            ),

                .reg_cs              ( reg_cs               ),
                .reg_wr              ( reg_wr               ),
                .reg_addr            ( reg_addr             ),
                .reg_wdata           ( reg_wdata            ),
                .reg_be              ( reg_be               ),

                .reg_rdata           ( reg_rdata            ),
                .reg_ack             ( reg_ack              ),

                .cfg_reset_period    ( cfg_reset_period     ),   // Reset period interm of clk
                .cfg_clk_period      ( cfg_clk_period       ),   // Total bit clock period
                .cfg_th0_period      ( cfg_th0_period       ),   // bit-0 drive low period
                .cfg_th1_period      ( cfg_th1_period       ),   // bit-1 drive low period

                .port0_enb           ( port0_enb            ),
                .port0_rd            ( port0_rd             ),
                .port0_data          ( port0_data           ),
                .port0_dval          ( port0_dval           ),

                .port1_enb           ( port1_enb            ),
                .port1_rd            ( port1_rd             ),
                .port1_data          ( port1_data           ),
                .port1_dval          ( port1_dval           )

                //.port2_enb           ( port2_enb            ),
                //.port2_rd            ( port2_rd             ),
                //.port2_data          ( port2_data           ),
                //.port2_dval          ( port2_dval           ),

                //.port3_enb           ( port3_enb            ),
                //.port3_rd            ( port3_rd             ),    
                //.port3_data          ( port3_data           ),
                //.port3_dval          ( port3_dval           )  

                ); 


//wx281x port-0
ws281x_driver u_txd_0(
    .clk                 (mclk             ), // Clock input.
    .reset_n             (h_reset_n        ), // Resets the internal state of the driver

    .cfg_reset_period    (cfg_reset_period ), // Reset period interm of clk
    .cfg_clk_period      (cfg_clk_period   ), // Total bit clock period
    .cfg_th0_period      (cfg_th0_period   ), // bit-0 drive low period
    .cfg_th1_period      (cfg_th1_period   ), // bit-1 drive low period

    .port_enb            (port0_enb        ), 
    .data_available      (port0_dval       ), 
    .green_in            (port0_data[23:16]), // 8-bit green data
    .red_in              (port0_data[15:8] ), // 8-bit red data
    .blue_in             (port0_data[7:0]  ), // 8-bit blue data
    .data_rd             (port0_rd         ), // data read

    .txd                 (txd[0]           )  // Signal to send to WS2811 chain.
    );

//wx281x port-1
ws281x_driver u_txd_1(
    .clk                 (mclk             ), // Clock input.
    .reset_n             (h_reset_n        ), // Resets the internal state of the driver

    .cfg_reset_period    (cfg_reset_period ), // Reset period interm of clk
    .cfg_clk_period      (cfg_clk_period   ), // Total bit clock period
    .cfg_th0_period      (cfg_th0_period   ), // bit-0 drive low period
    .cfg_th1_period      (cfg_th1_period   ), // bit-1 drive low period

    .port_enb            (port1_enb        ), 
    .data_available      (port1_dval       ), 
    .green_in            (port1_data[23:16]), // 8-bit green data
    .red_in              (port1_data[15:8] ), // 8-bit red data
    .blue_in             (port1_data[7:0]  ), // 8-bit blue data
    .data_rd             (port1_rd         ), // data read

    .txd                 (txd[1]           )  // Signal to send to WS2811 chain.
    );

/***
//wx281x port-2
ws281x_driver u_txd_2(
    .clk                 (mclk             ), // Clock input.
    .reset_n             (h_reset_n        ), // Resets the internal state of the driver

    .cfg_reset_period    (cfg_reset_period ), // Reset period interm of clk
    .cfg_clk_period      (cfg_clk_period   ), // Total bit clock period
    .cfg_th0_period      (cfg_th0_period   ), // bit-0 drive low period
    .cfg_th1_period      (cfg_th1_period   ), // bit-1 drive low period

    .port_enb            (port2_enb     ), 
    .data_available      (port2_dval       ), 
    .green_in            (port2_data[23:16]), // 8-bit green data
    .red_in              (port2_data[15:8] ), // 8-bit red data
    .blue_in             (port2_data[7:0]  ), // 8-bit blue data
    .data_rd             (port2_rd         ), // data read

    .txd                 (txd[2]           )  // Signal to send to WS2811 chain.
    );

//wx281x port-3
ws281x_driver u_txd_3(
    .clk                 (mclk             ), // Clock input.
    .reset_n             (h_reset_n        ), // Resets the internal state of the driver

    .cfg_reset_period    (cfg_reset_period ), // Reset period interm of clk
    .cfg_clk_period      (cfg_clk_period   ), // Total bit clock period
    .cfg_th0_period      (cfg_th0_period   ), // bit-0 drive low period
    .cfg_th1_period      (cfg_th1_period   ), // bit-1 drive low period

    .port_enb            (port3_enb        ), 
    .data_available      (port3_dval       ), 
    .green_in            (port3_data[23:16]), // 8-bit green data
    .red_in              (port3_data[15:8] ), // 8-bit red data
    .blue_in             (port3_data[7:0]  ), // 8-bit blue data
    .data_rd             (port3_rd         ), // data read

    .txd                 (txd[3]           )  // Signal to send to WS2811 chain.
    );
***/
endmodule
