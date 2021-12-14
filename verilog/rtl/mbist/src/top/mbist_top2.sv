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
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "mbist_def.svh"
module mbist_top2 
     #(  parameter SCW = 8,   // SCAN CHAIN WIDTH
         parameter BIST_ADDR_WD           = 8,
	 parameter BIST_DATA_WD           = 32,
	 parameter BIST_ADDR_START        = 8'h00,
	 parameter BIST_ADDR_END          = 8'hFB,
	 parameter BIST_REPAIR_ADDR_START = 8'hFC,
	 parameter BIST_RAD_WD_I          = BIST_ADDR_WD,
	 parameter BIST_RAD_WD_O          = BIST_ADDR_WD) (

`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

       // Scan I/F
       input logic             scan_en,
       input logic             scan_mode,
       input logic [SCW-1:0]   scan_si,
       output logic [SCW-1:0]  scan_so,
       output logic            scan_en_o,
       output logic            scan_mode_o,
	
    // Clock Skew Adjust
       input   logic                        wbd_clk_int, 
       output  logic                        wbd_clk_mbist,
       input   logic [3:0]                  cfg_cska_mbist, // clock skew adjust for web host

	input logic                         rst_n,

	// MBIST I/F
	input  logic                        bist_en,
	input logic                         bist_run,
	input logic                         bist_shift,
	input logic                         bist_load,
	input logic                         bist_sdi,

	output logic [3:0]                  bist_error_cnt,
	output logic                        bist_correct,
	output logic                        bist_error,
	output logic                        bist_done,
	output logic                        bist_sdo,


        // WB I/F
        input   logic                       wb_clk_i,  // System clock
        input   logic                       wb_cyc_i,  // strobe/request
        input   logic                       wb_stb_i,  // strobe/request
        input   logic [BIST_ADDR_WD-1:0]    wb_adr_i,  // address
        input   logic                       wb_we_i ,  // write
        input   logic [BIST_DATA_WD-1:0]    wb_dat_i,  // data output
        input   logic [BIST_DATA_WD/8-1:0]  wb_sel_i,  // byte enable
        output  logic [BIST_DATA_WD-1:0]    wb_dat_o,  // data input
        output  logic                       wb_ack_o,  // acknowlegement
        output  logic                       wb_err_o,  // error

     // towards memory
     // PORT-A
        output logic                     mem_clk_a,
        output logic   [BIST_ADDR_WD-1:0]mem_addr_a,
        output logic                     mem_cen_a,
        output logic   [BIST_DATA_WD-1:0]mem_din_b,
     // PORT-B
        output logic                     mem_clk_b,
        output logic                     mem_cen_b,
        output logic                     mem_web_b,
        output logic [BIST_DATA_WD/8-1:0]mem_mask_b,
        output logic   [BIST_ADDR_WD-1:0]mem_addr_b,
        input  logic   [BIST_DATA_WD-1:0]mem_dout_a




);

// FUNCTIONAL A PORT 
logic                    func_clk_a;
logic                    func_cen_a;
logic  [BIST_ADDR_WD-1:0]func_addr_a;
logic  [BIST_DATA_WD-1:0]func_dout_a;

// Functional B Port
logic                    func_clk_b;
logic                    func_cen_b;
logic                    func_web_b;
logic [BIST_DATA_WD/8-1:0]func_mask_b;
logic  [BIST_ADDR_WD-1:0]func_addr_b;
logic  [BIST_DATA_WD-1:0]func_din_b;
//----------------------------------------------------
// Local variable defination
// ---------------------------------------------------
//
logic                    srst_n     ; // sync reset w.r.t bist_clk
logic                    cmd_phase  ;  // Command Phase
logic                    cmp_phase  ;  // Compare Phase
logic                    run_op     ;  // Run next Operation
logic                    run_addr   ;  // Run Next Address
logic                    run_sti    ;  // Run Next Stimulus
logic                    run_pat    ;  // Run Next Pattern
logic                    op_updown  ;  // Adress updown direction
logic                    last_addr  ;  // last address indication
logic                    last_sti   ;  // last stimulus
logic                    last_op    ;  // last operation
logic                    last_pat   ;  // last pattern
logic [BIST_DATA_WD-1:0] pat_data   ;  // Selected Data Pattern
logic [BIST_STI_WD-1:0]  stimulus   ;  // current stimulus
logic                    compare    ;  // compare data
logic                    op_repeatflag;
logic                    op_reverse;
logic                    op_read   ;
logic                    op_write   ;
logic                    op_invert   ;

//---------------------------------
// SDI => SDO diasy chain
// bist_sdi => bist_addr_sdo =>  bist_sti_sdo =>  bist_op_sdo => bist_pat_sdo => bist_sdo
// ---------------------------------
logic                    bist_addr_sdo   ;                 
logic                    bist_sti_sdo    ;                 
logic                    bist_op_sdo     ;                 
logic                    bist_pat_sdo    ;                 

logic                    bist_error_correct  ;
logic  [BIST_ADDR_WD-1:0]bist_error_addr ; // bist address

logic  [BIST_ADDR_WD-1:0]bist_addr       ; // bist address
logic [BIST_DATA_WD-1:0] bist_wdata      ; // bist write data
logic                    bist_wr         ;
logic                    bist_rd         ;

assign scan_en_o = scan_en;
assign scan_mode_o = scan_mode;

assign bist_wr = (cmd_phase && op_write);
assign bist_rd = (cmd_phase && op_read);

assign compare    = (cmp_phase && op_read);
assign bist_wdata = (op_invert) ? ~pat_data : pat_data;

// Clock Tree branching to avoid clock latency towards SRAM path
wire wb_clk_b1,wb_clk_b2;
ctech_clk_buf u_cts_wb_clk_b1 (.A (wb_clk_i), . X(wb_clk_b1));
ctech_clk_buf u_cts_wb_clk_b2 (.A (wb_clk_i), . X(wb_clk_b2));

// wb_host clock skew control
clk_skew_adjust u_skew_mbist
       (
`ifdef USE_POWER_PINS
               .vccd1      (vccd1                      ),// User area 1 1.8V supply
               .vssd1      (vssd1                      ),// User area 1 digital ground
`endif
	       .clk_in     (wbd_clk_int                ), 
	       .sel        (cfg_cska_mbist             ), 
	       .clk_out    (wbd_clk_mbist              ) 
       );

reset_sync   u_reset_sync (
	      .scan_mode  (scan_mode ),
              .dclk       (wb_clk_b1 ), // Destination clock domain
	      .arst_n     (rst_n     ), // active low async reset
              .srst_n     (srst_n    )
          );



// bist main control FSM

mbist_fsm  
      #(
	 .BIST_ADDR_WD           (BIST_ADDR_WD           ),
	 .BIST_DATA_WD           (BIST_DATA_WD           ),
	 .BIST_ADDR_START        (BIST_ADDR_START        ),
	 .BIST_ADDR_END          (BIST_ADDR_END          ),
	 .BIST_REPAIR_ADDR_START (BIST_REPAIR_ADDR_START ),
	 .BIST_RAD_WD_I          (BIST_RAD_WD_I          ),
	 .BIST_RAD_WD_O          (BIST_RAD_WD_O          )
          )
     u_fsm (

	            .cmd_phase          (cmd_phase           ),
	            .cmp_phase          (cmp_phase           ),
	            .run_op             (run_op             ),
	            .run_addr           (run_addr           ),
	            .run_sti            (run_sti            ),
	            .run_pat            (run_pat            ),
	            .bist_done          (bist_done          ),


	            .clk                (wb_clk_b1          ),
	            .rst_n              (srst_n             ),
	            .bist_run           (bist_run           ),
	            .last_op            (last_op            ),
	            .last_addr          (last_addr          ),
	            .last_sti           (last_sti           ),
	            .last_pat           (last_pat           ),
		    .op_reverse         (op_reverse         ),
		    .bist_error         (bist_error         )
);


// bist address generation
mbist_addr_gen   
      #(
	 .BIST_ADDR_WD           (BIST_ADDR_WD           ),
	 .BIST_DATA_WD           (BIST_DATA_WD           ),
	 .BIST_ADDR_START        (BIST_ADDR_START        ),
	 .BIST_ADDR_END          (BIST_ADDR_END          ),
	 .BIST_REPAIR_ADDR_START (BIST_REPAIR_ADDR_START ),
	 .BIST_RAD_WD_I          (BIST_RAD_WD_I          ),
	 .BIST_RAD_WD_O          (BIST_RAD_WD_O          )
          )
      u_addr_gen(
                    .last_addr          (last_addr          ), 
                    .bist_addr          (bist_addr          ),   
                    .sdo                (bist_addr_sdo      ),         

                    .clk                (wb_clk_b1          ),         
                    .rst_n              (srst_n             ),       
                    .run                (run_addr           ),         
                    .updown             (op_updown          ),      
                    .scan_shift         (bist_shift         ),  
                    .scan_load          (bist_load          ),   
                    .sdi                (bist_sdi           )

);


// BIST current stimulus selection
mbist_sti_sel 
      #(
	 .BIST_ADDR_WD           (BIST_ADDR_WD           ),
	 .BIST_DATA_WD           (BIST_DATA_WD           ),
	 .BIST_ADDR_START        (BIST_ADDR_START        ),
	 .BIST_ADDR_END          (BIST_ADDR_END          ),
	 .BIST_REPAIR_ADDR_START (BIST_REPAIR_ADDR_START ),
	 .BIST_RAD_WD_I          (BIST_RAD_WD_I          ),
	 .BIST_RAD_WD_O          (BIST_RAD_WD_O          )
          )
       u_sti_sel(

	            .sdo                (bist_sti_sdo       ),  
	            .last_stimulus      (last_sti           ),  
                    .stimulus           (stimulus           ),

	            .clk                (wb_clk_b1          ),  
	            .rst_n              (srst_n             ),  
	            .scan_shift         (bist_shift         ),  
	            .sdi                (bist_addr_sdo      ),  
	            .run                (run_sti            )              

);


// Bist Operation selection
mbist_op_sel 
      #(
	 .BIST_ADDR_WD           (BIST_ADDR_WD           ),
	 .BIST_DATA_WD           (BIST_DATA_WD           ),
	 .BIST_ADDR_START        (BIST_ADDR_START        ),
	 .BIST_ADDR_END          (BIST_ADDR_END          ),
	 .BIST_REPAIR_ADDR_START (BIST_REPAIR_ADDR_START ),
	 .BIST_RAD_WD_I          (BIST_RAD_WD_I          ),
	 .BIST_RAD_WD_O          (BIST_RAD_WD_O          )
          )
        u_op_sel (

                    .op_read            (op_read            ), 
	            .op_write           (op_write           ),
	            .op_invert          (op_invert          ),
	            .op_updown          (op_updown          ),
	            .op_reverse         (op_reverse         ),
	            .op_repeatflag      (op_repeatflag      ),
	            .sdo                (bist_op_sdo        ),
	            .last_op            (last_op            ),

	            .clk                (wb_clk_b1          ),
	            .rst_n              (srst_n             ),
	            .scan_shift         (bist_shift         ),
	            .sdi                (bist_sti_sdo       ),
		    .re_init            (bist_error_correct ),
	            .run                (run_op             ),
                    .stimulus           (stimulus           )

    );



mbist_pat_sel 
      #(
	 .BIST_ADDR_WD           (BIST_ADDR_WD           ),
	 .BIST_DATA_WD           (BIST_DATA_WD           ),
	 .BIST_ADDR_START        (BIST_ADDR_START        ),
	 .BIST_ADDR_END          (BIST_ADDR_END          ),
	 .BIST_REPAIR_ADDR_START (BIST_REPAIR_ADDR_START ),
	 .BIST_RAD_WD_I          (BIST_RAD_WD_I          ),
	 .BIST_RAD_WD_O          (BIST_RAD_WD_O          )
          )
      u_pat_sel (
                    .pat_last           (last_pat           ),
                    .pat_data           (pat_data           ),
                    .sdo                (bist_pat_sdo       ),
                    .clk                (wb_clk_b1          ),
                    .rst_n              (srst_n             ),
                    .run                (run_pat            ),
                    .scan_shift         (bist_shift         ),
                    .sdi                (bist_op_sdo        )

   );


mbist_data_cmp  
      #(
	 .BIST_ADDR_WD           (BIST_ADDR_WD           ),
	 .BIST_DATA_WD           (BIST_DATA_WD           ),
	 .BIST_ADDR_START        (BIST_ADDR_START        ),
	 .BIST_ADDR_END          (BIST_ADDR_END          ),
	 .BIST_REPAIR_ADDR_START (BIST_REPAIR_ADDR_START ),
	 .BIST_RAD_WD_I          (BIST_RAD_WD_I          ),
	 .BIST_RAD_WD_O          (BIST_RAD_WD_O          )
          )


     u_cmp (
                    .error              (bist_error         ),
		    .error_correct      (bist_error_correct ),
		    .correct            (                   ), // same signal available at bist mux
		    .error_addr         (bist_error_addr    ),
		    .error_cnt          (bist_error_cnt     ),
                    .clk                (wb_clk_b1          ),
                    .rst_n              (srst_n             ),
		    .addr_inc_phase     (run_addr           ),
                    .compare            (compare            ), 
	            .read_invert        (op_invert          ),
                    .comp_data          (pat_data           ),
                    .rxd_data           (func_dout_a        ),
		    .addr               (bist_addr          )
	     
	);


mbist_mem_wrapper #(
	 .BIST_ADDR_WD           (BIST_ADDR_WD           ),
	 .BIST_DATA_WD           (BIST_DATA_WD           )
          ) u_mem_wrapper(
	            .rst_n           (srst_n           ),
               // WB I/F
                    .wb_clk_i        (wb_clk_b2        ),  // System clock
                    .wb_cyc_i        (wb_cyc_i         ),  // strobe/request
                    .wb_stb_i        (wb_stb_i         ),  // strobe/request
                    .wb_adr_i        (wb_adr_i         ),  // address
                    .wb_we_i         (wb_we_i          ),  // write
                    .wb_dat_i        (wb_dat_i         ),  // data output
                    .wb_sel_i        (wb_sel_i         ),  // byte enable
                    .wb_dat_o        (wb_dat_o         ),  // data input
                    .wb_ack_o        (wb_ack_o         ),  // acknowlegement
                    .wb_err_o        (wb_err_o         ),  // error
                // MEM A PORT 
                    .func_clk_a      (func_clk_a       ),
                    .func_cen_a      (func_cen_a       ),
                    .func_addr_a     (func_addr_a      ),
                    .func_dout_a     (func_dout_a      ),
  
                // Functional B Port
                    .func_clk_b      (func_clk_b       ),
                    .func_cen_b      (func_cen_b       ),
                    .func_web_b      (func_web_b       ),
                    .func_mask_b     (func_mask_b      ),
                    .func_addr_b     (func_addr_b      ),
                    .func_din_b      (func_din_b       )     
     );


mbist_mux  
      #(
	 .BIST_ADDR_WD           (BIST_ADDR_WD           ),
	 .BIST_DATA_WD           (BIST_DATA_WD           ),
	 .BIST_ADDR_START        (BIST_ADDR_START        ),
	 .BIST_ADDR_END          (BIST_ADDR_END          ),
	 .BIST_REPAIR_ADDR_START (BIST_REPAIR_ADDR_START ),
	 .BIST_RAD_WD_I          (BIST_RAD_WD_I          ),
	 .BIST_RAD_WD_O          (BIST_RAD_WD_O          )
          )
       u_mem_sel (

	            .scan_mode            (scan_mode     ),

                    .rst_n                (srst_n        ),
                    // MBIST CTRL SIGNAL
                    .bist_en              (bist_en       ),
                    .bist_addr            (bist_addr     ),
                    .bist_wdata           (bist_wdata    ),
                    .bist_clk             (wb_clk_b2     ),
                    .bist_wr              (bist_wr       ),
                    .bist_rd              (bist_rd       ),
                    .bist_error           (bist_error_correct),
                    .bist_error_addr      (bist_error_addr),
                    .bist_correct         (bist_correct  ),
		    .bist_sdi             (bist_pat_sdo),
		    .bist_shift           (bist_shift),
		    .bist_sdo             (bist_sdo),

                    // FUNCTIONAL CTRL SIGNAL
                    .func_clk_a          (func_clk_a     ),
                    .func_cen_a          (func_cen_a     ),
                    .func_addr_a         (func_addr_a    ),
                    // Common for func and Mbist i/f
                    .func_dout_a         (func_dout_a    ),

                    .func_clk_b          (func_clk_b     ),
                    .func_cen_b          (func_cen_b     ),
	            .func_web_b          (func_web_b     ),
	            .func_mask_b         (func_mask_b    ),
                    .func_addr_b         (func_addr_b    ),
                    .func_din_b          (func_din_b     ),


                    // towards memory
                    // Memory Out Port
                    .mem_clk_a           (mem_clk_a      ),
                    .mem_cen_a           (mem_cen_a      ),
                    .mem_addr_a          (mem_addr_a     ),
                    .mem_dout_a          (mem_dout_a     ),

                    // Memory Input Port
                    .mem_clk_b           (mem_clk_b      ),
                    .mem_cen_b           (mem_cen_b      ),
                    .mem_web_b           (mem_web_b      ),
                    .mem_mask_b          (mem_mask_b     ),
                    .mem_addr_b          (mem_addr_b     ),
                    .mem_din_b           (mem_din_b      )
    );


endmodule

