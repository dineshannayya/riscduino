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
module mbist_top
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
        input   wire                          mem_req,  // strobe/request
	input   wire [(BIST_NO_SRAM+1)/2-1:0] mem_cs,
        input   wire [BIST_ADDR_WD-1:0]       mem_addr,  // address
        input   wire                          mem_we ,  // write
        input   wire [BIST_DATA_WD-1:0]       mem_wdata,  // data output
        input   wire [BIST_DATA_WD/8-1:0]     mem_wmask,  // byte enable
        output  wire [BIST_DATA_WD-1:0]       mem_rdata,  // data input

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

// FUNCTIONAL PORT 
wire                    func_clk[0:BIST_NO_SRAM-1];
wire                    func_cen[0:BIST_NO_SRAM-1];
wire                    func_web[0:BIST_NO_SRAM-1];
wire [BIST_DATA_WD/8-1:0]func_mask[0:BIST_NO_SRAM-1];
wire  [BIST_ADDR_WD-1:0]func_addr[0:BIST_NO_SRAM-1];
wire  [BIST_DATA_WD-1:0]func_dout[0:BIST_NO_SRAM-1];
wire  [BIST_DATA_WD-1:0]func_din[0:BIST_NO_SRAM-1];

//----------------------------------------------------
// Local variable defination
// ---------------------------------------------------
//
wire                    srst_n     ; // sync reset w.r.t bist_clk
wire                    cmd_phase  ;  // Command Phase
wire                    cmp_phase  ;  // Compare Phase
wire                    run_op     ;  // Run next Operation
wire                    run_addr   ;  // Run Next Address
wire                    run_sti    ;  // Run Next Stimulus
wire                    run_pat    ;  // Run Next Pattern
wire                    op_updown  ;  // Adress updown direction
wire                    last_addr  ;  // last address indication
wire                    last_sti   ;  // last stimulus
wire                    last_op    ;  // last operation
wire                    last_pat   ;  // last pattern
wire [BIST_DATA_WD-1:0] pat_data   ;  // Selected Data Pattern
wire [BIST_STI_WD-1:0]  stimulus   ;  // current stimulus
wire                    compare    ;  // compare data
wire                    op_repeatflag;
wire                    op_reverse;
wire                    op_read   ;
wire                    op_write   ;
wire                    op_invert   ;


wire                    bist_error_correct[0:BIST_NO_SRAM-1]  ;
wire  [BIST_ADDR_WD-1:0]bist_error_addr[0:BIST_NO_SRAM-1] ; // bist address

wire  [BIST_ADDR_WD-1:0]bist_addr       ; // bist address
wire [BIST_DATA_WD-1:0] bist_wdata      ; // bist write data
wire                    bist_wr         ;
wire                    bist_rd         ;
wire [BIST_DATA_WD-1:0] wb_dat[0:BIST_NO_SRAM-1];  // data input

//--------------------------------------------------------
// As yosys does not support two dimensional var, 
// converting it single dimension
// -------------------------------------------------------
wire [3:0]              bist_error_cnt_i [0:BIST_NO_SRAM-1];

assign bist_error_cnt0 = bist_error_cnt_i[0];
assign bist_error_cnt1 = bist_error_cnt_i[1];
assign bist_error_cnt2 = bist_error_cnt_i[2];
assign bist_error_cnt3 = bist_error_cnt_i[3];


// Towards MEMORY PORT - A
wire   [BIST_ADDR_WD-1:0]      mem_addr_a_i[0:BIST_NO_SRAM-1];
wire [BIST_DATA_WD/8-1:0]      mem_mask_a_i[0:BIST_NO_SRAM-1];
wire   [BIST_DATA_WD-1:0]      mem_dout_a_i[0:BIST_NO_SRAM-1];
wire   [BIST_DATA_WD-1:0]      mem_din_a_i[0:BIST_NO_SRAM-1];

assign mem_addr_a0 = mem_addr_a_i[0];
assign mem_addr_a1 = mem_addr_a_i[1];
assign mem_addr_a2 = mem_addr_a_i[2];
assign mem_addr_a3 = mem_addr_a_i[3];

assign mem_din_a0 = mem_din_a_i[0];
assign mem_din_a1 = mem_din_a_i[1];
assign mem_din_a2 = mem_din_a_i[2];
assign mem_din_a3 = mem_din_a_i[3];

assign mem_mask_a0= mem_mask_a_i[0];
assign mem_mask_a1= mem_mask_a_i[1];
assign mem_mask_a2= mem_mask_a_i[2];
assign mem_mask_a3= mem_mask_a_i[3];

// FROM MEMORY
assign mem_dout_a_i[0] = mem_dout_a0;
assign mem_dout_a_i[1] = mem_dout_a1;
assign mem_dout_a_i[2] = mem_dout_a2;
assign mem_dout_a_i[3] = mem_dout_a3;

// Towards MEMORY PORT - A
assign mem_clk_b   = 'b0;
assign mem_cen_b   = 'b0;
assign mem_addr_b0 = 'b0;
assign mem_addr_b1 = 'b0;
assign mem_addr_b2 = 'b0;
assign mem_addr_b3 = 'b0;

//---------------------------------------------------
// Manage the SDI => SDO Diasy chain
// --------------------------------------------------
//---------------------------------
// SDI => SDO diasy chain
// bist_sdi => bist_addr_sdo =>  bist_sti_sdo =>  bist_op_sdo => bist_pat_sdo => bist_sdo
// ---------------------------------
wire                    bist_addr_sdo   ;                 
wire                    bist_sti_sdo    ;                 
wire                    bist_op_sdo     ;                 
wire                    bist_pat_sdo    ;                 

wire                    bist_ms_sdi[0:BIST_NO_SRAM-1];
wire                    bist_ms_sdo[0:BIST_NO_SRAM-1];

// Adjust the SDI => SDO Daisy chain
assign bist_ms_sdi[0] = bist_pat_sdo;
assign bist_ms_sdi[1] = bist_ms_sdo[0];
assign bist_ms_sdi[2] = bist_ms_sdo[1];
assign bist_ms_sdi[3] = bist_ms_sdo[2];
assign bist_sdo = bist_ms_sdo[3];

// Pick the correct read path
assign mem_rdata = wb_dat[mem_cs];

assign bist_wr = (cmd_phase && op_write);
assign bist_rd = (cmd_phase && op_read);

assign compare    = (cmp_phase && op_read);
assign bist_wdata = (op_invert) ? ~pat_data : pat_data;

// Clock Tree branching to avoid clock latency towards SRAM path
wire wb_clk_b1,wb_clk_b2;
//ctech_clk_buf u_cts_wb_clk_b1 (.A (wb_clk_i), . X(wb_clk_b1));
//ctech_clk_buf u_cts_wb_clk_b2 (.A (wb_clk_i), . X(wb_clk_b2));

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
	      .scan_mode  (1'b0 ),
              .dclk       (wb_clk_i  ), // Destination clock domain
	      .arst_n     (rst_n     ), // active low async reset
              .srst_n     (srst_n    )
          );


integer i;
reg bist_error_and;
reg bist_error_correct_or;

always_comb begin
   bist_error_and =0;
   bist_error_correct_or = 0;
   for(i=0; i <BIST_NO_SRAM; i = i+1) begin
     bist_error_and = bist_error_and & bist_error[i];
     bist_error_correct_or = bist_error_correct_or | bist_error_correct[i];
   end
end


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


	            .clk                (wb_clk_i           ),
	            .rst_n              (srst_n             ),
	            .bist_run           (bist_run           ),
	            .last_op            (last_op            ),
	            .last_addr          (last_addr          ),
	            .last_sti           (last_sti           ),
	            .last_pat           (last_pat           ),
		    .op_reverse         (op_reverse         ),
		    .bist_error         (bist_error_and     )
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

                    .clk                (wb_clk_i           ),         
                    .rst_n              (srst_n             ),       
                    .run                (run_addr           ),         
                    .updown             (op_updown          ),      
                    .bist_shift         (bist_shift         ),  
                    .bist_load          (bist_load          ),   
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

	            .clk                (wb_clk_i           ),  
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

                    .op_read            (op_read               ), 
	            .op_write           (op_write              ),
	            .op_invert          (op_invert             ),
	            .op_updown          (op_updown             ),
	            .op_reverse         (op_reverse            ),
	            .op_repeatflag      (op_repeatflag         ),
	            .sdo                (bist_op_sdo           ),
	            .last_op            (last_op               ),

	            .clk                (wb_clk_i              ),
	            .rst_n              (srst_n                ),
	            .scan_shift         (bist_shift            ),
	            .sdi                (bist_sti_sdo          ),
		    .re_init            (bist_error_correct_or ),
	            .run                (run_op                ),
                    .stimulus           (stimulus              )

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
                    .clk                (wb_clk_i           ),
                    .rst_n              (srst_n             ),
                    .run                (run_pat            ),
                    .scan_shift         (bist_shift         ),
                    .sdi                (bist_op_sdo        )

   );





genvar sram_no;
generate
for (sram_no = 0; $unsigned(sram_no) < BIST_NO_SRAM; sram_no=sram_no+1) begin : mem_no

	
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
                    .error              (bist_error[sram_no]         ),
		    .error_correct      (bist_error_correct[sram_no] ),
		    .correct            (                            ), // same signal available at bist mux
		    .error_addr         (bist_error_addr[sram_no]    ),
		    .error_cnt          (bist_error_cnt_i[sram_no]   ),
                    .clk                (wb_clk_i                    ),
                    .rst_n              (srst_n                      ),
		    .addr_inc_phase     (run_addr                    ),
                    .compare            (compare                     ), 
	            .read_invert        (op_invert                   ),
                    .comp_data          (pat_data                    ),
                    .rxd_data           (func_dout[sram_no]          ),
		    .addr               (bist_addr                   )
	     
	);

    // WB To Memory Signal Mapping
    mbist_mem_wrapper #(
	 .BIST_NO_SRAM           (BIST_NO_SRAM           ),
    	 .BIST_ADDR_WD           (BIST_ADDR_WD           ),
    	 .BIST_DATA_WD           (BIST_DATA_WD           )
              ) u_mem_wrapper_(
    	                .rst_n           (srst_n                    ),
                   // WB I/F
		        .sram_id         (NO_SRAM_WD'(sram_no)      ),
                        .wb_clk_i        (wb_clk2_i                 ),  // System clock
			.mem_cs          (mem_cs                    ),  // Chip Select
                        .mem_req         (mem_req                   ),  // strobe/request
                        .mem_addr        (mem_addr                  ),  // address
                        .mem_we          (mem_we                    ),  // write
                        .mem_wdata       (mem_wdata                 ),  // data output
                        .mem_wmask       (mem_wmask                 ),  // byte enable
                        .mem_rdata       (wb_dat[sram_no]           ),  // data input
                    // MEM A PORT 
                        .func_clk        (func_clk[sram_no]         ),
                        .func_cen        (func_cen[sram_no]         ),
                        .func_web        (func_web[sram_no]         ),
                        .func_mask       (func_mask[sram_no]        ),
                        .func_addr       (func_addr[sram_no]        ),
                        .func_din        (func_din[sram_no]         ),    
                        .func_dout       (func_dout[sram_no]        )
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

	            .scan_mode            (1'b0                       ),

                    .rst_n                (srst_n                     ),
                    // MBIST CTRL SIGNAL
                    .bist_en              (bist_en                    ),
                    .bist_addr            (bist_addr                  ),
                    .bist_wdata           (bist_wdata                 ),
                    .bist_clk             (wb_clk2_i                  ),
                    .bist_wr              (bist_wr                    ),
                    .bist_rd              (bist_rd                    ),
                    .bist_error           (bist_error_correct[sram_no]),
                    .bist_error_addr      (bist_error_addr[sram_no]   ),
                    .bist_correct         (bist_correct[sram_no]      ),
		    .bist_sdi             (bist_ms_sdi[sram_no]       ),
		    .bist_load            (bist_load                  ),
		    .bist_shift           (bist_shift                 ),
		    .bist_sdo             (bist_ms_sdo[sram_no]       ),

                    // FUNCTIONAL CTRL SIGNAL
                    .func_clk             (func_clk[sram_no]          ),
                    .func_cen             (func_cen[sram_no]          ),
	            .func_web             (func_web[sram_no]          ),
	            .func_mask            (func_mask[sram_no]         ),
                    .func_addr            (func_addr[sram_no]         ),
                    .func_din             (func_din[sram_no]          ),
                    .func_dout            (func_dout[sram_no]         ),


                    // towards memory
                    // Memory Out Port
                    .mem_clk             (mem_clk_a[sram_no]          ),
                    .mem_cen             (mem_cen_a[sram_no]          ),
                    .mem_web             (mem_web_a[sram_no]          ),
                    .mem_mask            (mem_mask_a_i[sram_no]       ),
                    .mem_addr            (mem_addr_a_i[sram_no]       ),
                    .mem_din             (mem_din_a_i[sram_no]        ),
                    .mem_dout            (mem_dout_a_i[sram_no]       )

    );
end
endgenerate

endmodule

