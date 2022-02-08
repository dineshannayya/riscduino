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
////  MBIST TOP                                                   ////
////                                                              ////
////  This file is part of the mbist_ctrl cores project           ////
////  https://github.com/dineshannayya/mbist_ctrl.git             ////
////                                                              ////
////  Description                                                 ////
////      This block integrate mbist controller with row          ////
////      redendency feature                                      ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.0 - 11th Oct 2021, Dinesh A                             ////
////          Initial integration                                 ////
////    0.1 - 26th Oct 2021, Dinesh A                             ////
////          Fixed Error Address are serial shifted through      ////
////          sdi/sdo                                             ////
////    0.2 - 15 Dec 2021, Dinesh A                               ////
////          Added support for common MBIST for 4 SRAM           ////
////    0.3 - 29th Dec 2021, Dinesh A                             ////
////          yosys synthesis issue for two dimension variable    ////
////          changed the variable defination from logic to wire  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "mbist_def.svh"
module mbist_wrapper
     #(  
         parameter BIST_NO_SRAM           = 4,
	 parameter BIST_ADDR_WD           = 9,
	 parameter BIST_DATA_WD           = 32,
	 parameter BIST_ADDR_START        = 9'h000,
	 parameter BIST_ADDR_END          = 9'h1FB,
	 parameter BIST_REPAIR_ADDR_START = 9'h1FC,
	 parameter BIST_RAD_WD_I          = BIST_ADDR_WD,
	 parameter BIST_RAD_WD_O          = BIST_ADDR_WD) (

`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Clock Skew Adjust
       input  wire                           wbd_clk_int, 
       output wire                           wbd_clk_mbist,
       input  wire [3:0]                     cfg_cska_mbist, // clock skew adjust for web host

	input logic                            rst_n,

	// MBIST I/F
	input wire                           bist_en,
	input wire                            bist_run,
	input wire                            bist_shift,
	input wire                            bist_load,
	input wire                            bist_sdi,

	output wire [3:0]                     bist_error_cnt0,
	output wire [3:0]                     bist_error_cnt1,
	output wire [3:0]                     bist_error_cnt2,
	output wire [3:0]                     bist_error_cnt3,
	output wire [BIST_NO_SRAM-1:0]        bist_correct   ,
	output wire [BIST_NO_SRAM-1:0]        bist_error     ,
	output wire                           bist_done,
	output wire                           bist_sdo,


        // WB I/F
        input   wire                          wb_clk_i,  // System clock
        input   wire                          wb_clk2_i, // System clock2 is no cts
        input   wire                          wb_stb_i,  // strobe/request
	input   wire [(BIST_NO_SRAM+1)/2-1:0] wb_cs_i,
        input   wire [BIST_ADDR_WD-1:0]       wb_adr_i,  // address
        input   wire                          wb_we_i ,  // write
        input   wire [BIST_DATA_WD-1:0]       wb_dat_i,  // data output
        input   wire [BIST_DATA_WD/8-1:0]     wb_sel_i,  // byte enable
        input   wire [9:0]                    wb_bl_i,   // burst 
        input   wire                          wb_bry_i,  // burst ready
        output  wire [BIST_DATA_WD-1:0]       wb_dat_o,  // data input
        output  wire                          wb_ack_o,  // acknowlegement
        output  wire                          wb_lack_o, // acknowlegement
        output  wire                          wb_err_o,  // error


     // towards memory
     // PORT-A
        output wire   [BIST_NO_SRAM-1:0]      mem_clk_a,
        output wire   [BIST_ADDR_WD-1:0]      mem_addr_a0,
        output wire   [BIST_ADDR_WD-1:0]      mem_addr_a1,
        output wire   [BIST_ADDR_WD-1:0]      mem_addr_a2,
        output wire   [BIST_ADDR_WD-1:0]      mem_addr_a3,
        output wire   [BIST_NO_SRAM-1:0]      mem_cen_a,
        output wire   [BIST_NO_SRAM-1:0]      mem_web_a,
        output wire   [BIST_DATA_WD/8-1:0]    mem_mask_a0,
        output wire   [BIST_DATA_WD/8-1:0]    mem_mask_a1,
        output wire   [BIST_DATA_WD/8-1:0]    mem_mask_a2,
        output wire   [BIST_DATA_WD/8-1:0]    mem_mask_a3,
        output wire   [BIST_DATA_WD-1:0]      mem_din_a0,
        output wire   [BIST_DATA_WD-1:0]      mem_din_a1,
        output wire   [BIST_DATA_WD-1:0]      mem_din_a2,
        output wire   [BIST_DATA_WD-1:0]      mem_din_a3,

        input  wire   [BIST_DATA_WD-1:0]      mem_dout_a0,
        input  wire   [BIST_DATA_WD-1:0]      mem_dout_a1,
        input  wire   [BIST_DATA_WD-1:0]      mem_dout_a2,
        input  wire   [BIST_DATA_WD-1:0]      mem_dout_a3,


     // PORT-B
        output wire [BIST_NO_SRAM-1:0]        mem_clk_b,
        output wire [BIST_NO_SRAM-1:0]        mem_cen_b,
        output wire   [BIST_ADDR_WD-1:0]      mem_addr_b0,
        output wire   [BIST_ADDR_WD-1:0]      mem_addr_b1,
        output wire   [BIST_ADDR_WD-1:0]      mem_addr_b2,
        output wire   [BIST_ADDR_WD-1:0]      mem_addr_b3



);

parameter  NO_SRAM_WD = (BIST_NO_SRAM+1)/2;
parameter     BIST1_ADDR_WD = 11; // 512x32 SRAM

logic                          mem_req;  // strobe/request
logic [(BIST_NO_SRAM+1)/2-1:0] mem_cs;
logic [BIST_ADDR_WD-1:0]       mem_addr;  // address
logic                          mem_we ;  // write
logic [BIST_DATA_WD-1:0]       mem_wdata;  // data output
logic [BIST_DATA_WD/8-1:0]     mem_wmask;  // byte enable
logic [BIST_DATA_WD-1:0]       mem_rdata;  // data input


mbist_wb  #(
	.BIST_NO_SRAM           (4                      ),
	.BIST_ADDR_WD           (BIST1_ADDR_WD-2        ),
	.BIST_DATA_WD           (BIST_DATA_WD           )
     ) 
	     u_wb (

`ifdef USE_POWER_PINS
       .vccd1                  (vccd1                     ),// User area 1 1.8V supply
       .vssd1                  (vssd1                     ),// User area 1 digital ground
`endif

	.rst_n                (rst_n                ),
	// WB I/F
        .wb_clk_i             (wb_clk_i             ),  
        .wb_stb_i             (wb_stb_i             ),  
        .wb_cs_i              (wb_cs_i              ),
        .wb_adr_i             (wb_adr_i             ),
        .wb_we_i              (wb_we_i              ),  
        .wb_dat_i             (wb_dat_i             ),  
        .wb_sel_i             (wb_sel_i             ),  
        .wb_bl_i              (wb_bl_i              ),  
        .wb_bry_i             (wb_bry_i             ),  
        .wb_dat_o             (wb_dat_o             ),  
        .wb_ack_o             (wb_ack_o             ),  
        .wb_lack_o            (wb_lack_o            ),  
        .wb_err_o             (                     ), 

	.mem_req              (mem_req              ),
	.mem_cs               (mem_cs               ),
	.mem_addr             (mem_addr             ),
	.mem_we               (mem_we               ),
	.mem_wdata            (mem_wdata            ),
	.mem_wmask            (mem_wmask            ),
	.mem_rdata            (mem_rdata            )

	


);


mbist_top  #(
	`ifndef SYNTHESIS
	.BIST_NO_SRAM           (4                      ),
	.BIST_ADDR_WD           (BIST1_ADDR_WD-2        ),
	.BIST_DATA_WD           (BIST_DATA_WD           ),
	.BIST_ADDR_START        (9'h000                 ),
	.BIST_ADDR_END          (9'h1FB                 ),
	.BIST_REPAIR_ADDR_START (9'h1FC                 ),
	.BIST_RAD_WD_I          (BIST1_ADDR_WD-2        ),
	.BIST_RAD_WD_O          (BIST1_ADDR_WD-2        )
        `endif
     ) 
	     u_mbist (

`ifdef USE_POWER_PINS
       .vccd1                  (vccd1                     ),// User area 1 1.8V supply
       .vssd1                  (vssd1                     ),// User area 1 digital ground
`endif

     // Clock Skew adjust
	.wbd_clk_int          (wbd_clk_int          ), 
	.cfg_cska_mbist       (cfg_cska_mbist       ), 
	.wbd_clk_mbist        (wbd_clk_mbist        ),

	// WB I/F
        .wb_clk2_i            (wb_clk2_i            ),  
        .wb_clk_i             (wb_clk_i             ),  
        .mem_req              (mem_req              ),  
	.mem_cs               (mem_cs               ),
        .mem_addr             (mem_addr             ),  
        .mem_we               (mem_we               ),  
        .mem_wdata            (mem_wdata            ),  
        .mem_wmask            (mem_wmask            ),  
        .mem_rdata            (mem_rdata            ),  

	.rst_n                (rst_n                ),

	
	.bist_en              (bist_en              ),
	.bist_run             (bist_run             ),
	.bist_shift           (bist_shift           ),
	.bist_load            (bist_load            ),
	.bist_sdi             (bist_sdi             ),

	.bist_error_cnt3      (bist_error_cnt3  ),
	.bist_error_cnt2      (bist_error_cnt2  ),
	.bist_error_cnt1      (bist_error_cnt1  ),
	.bist_error_cnt0      (bist_error_cnt0  ),
	.bist_correct         (bist_correct     ),
	.bist_error           (bist_error       ),
	.bist_done            (bist_done        ),
	.bist_sdo             (bist_sdo         ),

     // towards memory
     // PORT-A
        .mem_clk_a            (mem_clk_a        ),
        .mem_addr_a0          (mem_addr_a0      ),
        .mem_addr_a1          (mem_addr_a1      ),
        .mem_addr_a2          (mem_addr_a2      ),
        .mem_addr_a3          (mem_addr_a3      ),
        .mem_cen_a            (mem_cen_a        ),
        .mem_web_a            (mem_web_a        ),
        .mem_mask_a0          (mem_mask_a0      ),
        .mem_mask_a1          (mem_mask_a1      ),
        .mem_mask_a2          (mem_mask_a2      ),
        .mem_mask_a3          (mem_mask_a3      ),
        .mem_din_a0           (mem_din_a0       ),
        .mem_din_a1           (mem_din_a1       ),
        .mem_din_a2           (mem_din_a2       ),
        .mem_din_a3           (mem_din_a3       ),
        .mem_dout_a0          (mem_dout_a0      ),
        .mem_dout_a1          (mem_dout_a1      ),
        .mem_dout_a2          (mem_dout_a2      ),
        .mem_dout_a3          (mem_dout_a3      ),
     // PORT-B
        .mem_clk_b            (mem_clk_b        ),
        .mem_cen_b            (mem_cen_b        ),
        .mem_addr_b0          (mem_addr_b0      ),
        .mem_addr_b1          (mem_addr_b1      ),
        .mem_addr_b2          (mem_addr_b2      ),
        .mem_addr_b3          (mem_addr_b3      )


);


/**
sky130_sram_2kbyte_1rw1r_32x512_8 u_sram0_2kb(
`ifdef USE_POWER_PINS
    .vccd1 (vccd1),// User area 1 1.8V supply
    .vssd1 (vssd1),// User area 1 digital ground
`endif
// Port 0: RW
    .clk0     (mem_clk_a[0]),
    .csb0     (mem_cen_a[0]),
    .web0     (mem_web_a[0]),
    .wmask0   (mem0_mask_a),
    .addr0    (mem0_addr_a),
    .din0     (mem0_din_a),
    .dout0    (mem0_dout_a),
// Port 1: R
    .clk1     (mem_clk_b[0]),
    .csb1     (mem_cen_b[0]),
    .addr1    (mem0_addr_b),
    .dout1    ()
  );

sky130_sram_2kbyte_1rw1r_32x512_8 u_sram1_2kb(
`ifdef USE_POWER_PINS
    .vccd1 (vccd1),// User area 1 1.8V supply
    .vssd1 (vssd1),// User area 1 digital ground
`endif
// Port 0: RW
    .clk0     (mem_clk_a[1]),
    .csb0     (mem_cen_a[1]),
    .web0     (mem_web_a[1]),
    .wmask0   (mem1_mask_a),
    .addr0    (mem1_addr_a),
    .din0     (mem1_din_a),
    .dout0    (mem1_dout_a),
// Port 1: R
    .clk1     (mem_clk_b[1]),
    .csb1     (mem_cen_b[1]),
    .addr1    (mem1_addr_b),
    .dout1    ()
  );

sky130_sram_2kbyte_1rw1r_32x512_8 u_sram2_2kb(
`ifdef USE_POWER_PINS
    .vccd1 (vccd1),// User area 1 1.8V supply
    .vssd1 (vssd1),// User area 1 digital ground
`endif
// Port 0: RW
    .clk0     (mem_clk_a[2]),
    .csb0     (mem_cen_a[2]),
    .web0     (mem_web_a[2]),
    .wmask0   (mem2_mask_a),
    .addr0    (mem2_addr_a),
    .din0     (mem2_din_a),
    .dout0    (mem2_dout_a),
// Port 1: R
    .clk1     (mem_clk_b[2]),
    .csb1     (mem_cen_b[2]),
    .addr1    (mem2_addr_b),
    .dout1    ()
  );


sky130_sram_2kbyte_1rw1r_32x512_8 u_sram3_2kb(
`ifdef USE_POWER_PINS
    .vccd1 (vccd1),// User area 1 1.8V supply
    .vssd1 (vssd1),// User area 1 digital ground
`endif
// Port 0: RW
    .clk0     (mem_clk_a[3]),
    .csb0     (mem_cen_a[3]),
    .web0     (mem_web_a[3]),
    .wmask0   (mem3_mask_a),
    .addr0    (mem3_addr_a),
    .din0     (mem3_din_a),
    .dout0    (mem3_dout_a),
// Port 1: R
    .clk1     (mem_clk_b[3]),
    .csb1     (mem_cen_b[3]),
    .addr1    (mem3_addr_b),
    .dout1    ()
  );


***/

endmodule

