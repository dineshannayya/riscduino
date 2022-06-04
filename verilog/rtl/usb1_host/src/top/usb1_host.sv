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
////  USB1.1 HOST Controller + PHY                                ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  https://github.com/dineshannayya/yifive_r0.git              ////
////  USB1 Core from github.com/ultraembedded/core_usb_host       ////
////  USBB Phy from github.com/ultraembedded/core_usb_fs_phy.git  ////
////                                                              ////
////  Description                                                 ////
//// Following Modification are Done                              ////
////   1. Integrated the Wishbone Interface                       ////
////   2. WishBone interface made async w.r.t usb clock           ////
////   3. usb1 core Axi logic is modified to normal Register      ////
////      read/write I/F                                          ////
////                                                              ////
////   This module integrate following sub module                 ////
////   1. async_wb : Async wishbone interface does the wishbone   ////
////      to usbclk clock synchronization                         ////
////   2. usb1_core:  usb1 core                                   ////
////   3. usb1_host : usb phy                                     ////
////                                                              ////
////   Assumptiom: usb_clk is 60Mhz                               ////
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

module usb1_host 
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
     parameter USB_CLK_FREQ     = 60000000
)

(
    input  logic           usb_clk_i   ,
    input  logic           usb_rstn_i  ,

        // USB D+/D-
    input                  in_dp   ,
    input                  in_dn   ,

    output                 out_dp   ,
    output                 out_dn   ,
    output                 out_tx_oen,

    // Master Port
    input   logic          wbm_rst_n   ,  // Regular Reset signal
    input   logic          wbm_clk_i   ,  // System clock
    input   logic          wbm_stb_i   ,  // strobe/request
    input   logic [5:0]    wbm_adr_i   ,  // address
    input   logic          wbm_we_i    ,  // write
    input   logic [31:0]   wbm_dat_i   ,  // data output
    input   logic [3:0]    wbm_sel_i   ,  // byte enable
    output  logic [31:0]   wbm_dat_o   ,  // data input
    output  logic          wbm_ack_o   ,  // acknowlegement
    output  logic          wbm_err_o   ,  // error

    // Outputs
    output                 usb_intr_o


    );

    logic  [7:0]           utmi_data_in_i;
    logic                  utmi_txready_i;
    logic                  utmi_rxvalid_i;
    logic                  utmi_rxactive_i;
    logic                  utmi_rxerror_i;
    logic  [1:0]           utmi_linestate_i;

    logic [7:0]            utmi_data_out_o;
    logic                  utmi_txvalid_o;
    logic [1:0]            utmi_op_mode_o;
    logic [1:0]            utmi_xcvrselect_o;
    logic                  utmi_termselect_o;
    logic                  utmi_dppulldown_o;
    logic                  utmi_dmpulldown_o;
    logic                  usb_pads_tx_dp_w;
    logic                  usb_pads_tx_oen_w;
    logic                  usb_pads_rx_dn_w;
    logic                  usb_pads_tx_dn_w;
    logic                  usb_pads_rx_rcv_w;
    logic                  usb_pads_rx_dp_w;
    logic                  usb_xcvr_mode_w = 1'h1;

    // Reg Bus Interface Signal
    logic                  reg_cs;
    logic                  reg_wr;
    logic [5:0]            reg_addr;
    logic [31:0]           reg_wdata;
    logic [3:0]            reg_be;

   // Outputs
    logic [31:0]           reg_rdata;
    logic                  reg_ack;

    logic                  wbm_rst_ssn;
    logic                  usb_rst_ssn;


//###################################
// Wishbone Reset Synchronization
//###################################
reset_sync  u_wb_rst (
	      .scan_mode  (1'b0           ),
              .dclk       (wbm_clk_i      ), // Destination clock domain
	      .arst_n     (wbm_rst_n      ), // active low async reset
              .srst_n     (wbm_rst_ssn    )
          );

//###################################
// USB Reset Synchronization
//###################################
reset_sync  u_usb_rst (
	      .scan_mode  (1'b0           ),
              .dclk       (usb_clk_i      ), // Destination clock domain
	      .arst_n     (usb_rstn_i     ), // active low async reset
              .srst_n     (usb_rst_ssn    )
          );

async_wb  #(.AW (6))
     u_async_wb(

    // Master Port
       .wbm_rst_n        (wbm_rst_ssn          ),  // Regular Reset signal
       .wbm_clk_i        (wbm_clk_i            ),  // System clock
       .wbm_cyc_i        (wbm_stb_i            ),  // strobe/request
       .wbm_stb_i        (wbm_stb_i            ),  // strobe/request
       .wbm_adr_i        (wbm_adr_i            ),  // address
       .wbm_we_i         (wbm_we_i             ),  // write
       .wbm_dat_i        (wbm_dat_i            ),  // data output
       .wbm_sel_i        (wbm_sel_i            ),  // byte enable
       .wbm_dat_o        (wbm_dat_o            ),  // data input
       .wbm_ack_o        (wbm_ack_o            ),  // acknowlegement
       .wbm_err_o        (wbm_err_o            ),  // error

    // Slave Port
       .wbs_rst_n        (usb_rst_ssn          ),  // Regular Reset signal
       .wbs_clk_i        (usb_clk_i            ),  // System clock
       .wbs_cyc_o        (                     ),  // strobe/request
       .wbs_stb_o        (reg_cs               ),  // strobe/request
       .wbs_adr_o        (reg_addr             ),  // address
       .wbs_we_o         (reg_wr               ),  // write
       .wbs_dat_o        (reg_wdata            ),  // data output
       .wbs_sel_o        (reg_be               ),  // byte enable
       .wbs_dat_i        (reg_rdata            ),  // data input
       .wbs_ack_i        (reg_ack              ),  // acknowlegement
       .wbs_err_i        (1'b0                 )      // error

    );

usbh_core  #(.USB_CLK_FREQ(USB_CLK_FREQ)) u_core (
    // Inputs
    .clk_i               (usb_clk_i           ),
    .rstn_i              (usb_rst_ssn         ),

    .reg_cs              (reg_cs              ),
    .reg_wr              (reg_wr              ),
    .reg_addr            (reg_addr            ),
    .reg_wdata           (reg_wdata           ),
    .reg_be              (reg_be              ),

   // Outputs
    .reg_rdata           (reg_rdata           ),
    .reg_ack             (reg_ack             ),

    // Outputs
    .intr_o              (usb_intr_o          ),

    .utmi_data_in_i      (utmi_data_in_i      ),
    .utmi_rxvalid_i      (utmi_rxvalid_i      ),
    .utmi_rxactive_i     (utmi_rxactive_i     ),
    .utmi_rxerror_i      (utmi_rxerror_i      ),
    .utmi_linestate_i    (utmi_linestate_i    ),

    .utmi_txready_i      (utmi_txready_i      ),
    .utmi_data_out_o     (utmi_data_out_o     ),
    .utmi_txvalid_o      (utmi_txvalid_o      ),

    .utmi_op_mode_o      (utmi_op_mode_o      ),
    .utmi_xcvrselect_o   (utmi_xcvrselect_o   ),
    .utmi_termselect_o   (utmi_termselect_o   ),
    .utmi_dppulldown_o   (utmi_dppulldown_o   ),
    .utmi_dmpulldown_o   (utmi_dmpulldown_o   )
);



usb_fs_phy  #(.USB_CLK_FREQ(USB_CLK_FREQ)) u_phy(
    // Inputs
         .clk_i               (usb_clk_i           ),
         .rstn_i              (usb_rst_ssn         ),
         .utmi_data_out_i     (utmi_data_out_o     ),
         .utmi_txvalid_i      (utmi_txvalid_o      ),
         .utmi_op_mode_i      (utmi_op_mode_o      ),
         .utmi_xcvrselect_i   (utmi_xcvrselect_o   ),
         .utmi_termselect_i   (utmi_termselect_o   ),
         .utmi_dppulldown_i   (utmi_dppulldown_o   ),
         .utmi_dmpulldown_i   (utmi_dmpulldown_o   ),
         .usb_rx_rcv_i        (usb_pads_rx_rcv_w   ),
         .usb_rx_dp_i         (usb_pads_rx_dp_w    ),
         .usb_rx_dn_i         (usb_pads_rx_dn_w    ),
         .usb_reset_assert_i  ( 1'b0               ),

    // Outputs
         .utmi_data_in_o     (utmi_data_in_i      ),
         .utmi_txready_o     (utmi_txready_i      ),
         .utmi_rxvalid_o     (utmi_rxvalid_i      ),
         .utmi_rxactive_o    (utmi_rxactive_i     ),
         .utmi_rxerror_o     (utmi_rxerror_i      ),
         .utmi_linestate_o   (utmi_linestate_i    ),
         .usb_tx_dp_o        (usb_pads_tx_dp_w    ),
         .usb_tx_dn_o        (usb_pads_tx_dn_w    ),
         .usb_tx_oen_o       (usb_pads_tx_oen_w   ),
         .usb_reset_detect_o (                    ),
         .usb_en_o           (                    )
    );


 usb_transceiver u_usb_xcvr (
    // Inputs
         .usb_phy_tx_dp_i    (usb_pads_tx_dp_w   ),
         .usb_phy_tx_dn_i    (usb_pads_tx_dn_w   ),
         .usb_phy_tx_oen_i   (usb_pads_tx_oen_w  ),
         .mode_i             (usb_xcvr_mode_w    ),

	 .out_dp             (out_dp             ),
         .out_dn             (out_dn             ),
	 .out_tx_oen         (out_tx_oen         ),

         .in_dp              (in_dp              ),
         .in_dn              (in_dn              ),


    // Outputs
         .usb_phy_rx_rcv_o  (usb_pads_rx_rcv_w   ),
         .usb_phy_rx_dp_o   (usb_pads_rx_dp_w    ),
         .usb_phy_rx_dn_o   (usb_pads_rx_dn_w    )
);


endmodule
