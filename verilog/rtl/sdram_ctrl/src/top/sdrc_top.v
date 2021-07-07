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
/*********************************************************************
                                                              
  SDRAM Controller top File                                  
                                                              
  This file is part of the sdram controller project           
  https://github.com/dineshannayya/yifive_r0.git
  http://www.opencores.org/cores/yifive/              
  http://www.opencores.org/cores/sdr_ctrl/                    
                                                              
  Description: SDRAM Controller Top Module.
    Support 81/6/32 Bit SDRAM.
    Column Address is Programmable
    Bank Bit are 2 Bit
    Row Bits are 12 Bits

    This block integrate following sub modules

    sdrc_core   
        SDRAM Controller file
    wb2sdrc    
        This module transalate the bus protocl from wishbone to custome
	sdram controller
                                                              
  To Do:                                                      
    nothing                                                   
                                                              
  Author(s): Dinesh Annayya, dinesha@opencores.org                 
  Version  : 0.0 - 8th Jan 2012
                Initial version with 16/32 Bit SDRAM Support
           : 0.1 - 24th Jan 2012
	         8 Bit SDRAM Support is added
	     0.2 - 31st Jan 2012
	         sdram_dq and sdram_pad_clk are internally generated
	     0.3 - 26th April 2013
                  Sdram Address witdh is increased from 12 to 13bits
	     0.3 - 25th June 2021
                  Move the Pad logic inside the sdram to avoid combo logic
		  at digital core level
             0.4 - 27th June 2021
	          Unused port wb_cti_i removed
             0.5 - 29th June 2021
	          Wishbone Stagging FF added to break timing path
             0.6 - 6th July 2021, Dinesh A
	          32 bit debug port added

                                                             
 Copyright (C) 2000 Authors and OPENCORES.ORG                
                                                             
 This source file may be used and distributed without         
 restriction provided that this copyright statement is not    
 removed from the file and that any derivative work contains  
 the original copyright notice and the associated disclaimer. 
                                                              
 This source file is free software; you can redistribute it   
 and/or modify it under the terms of the GNU Lesser General   
 Public License as published by the Free Software Foundation; 
 either version 2.1 of the License, or (at your option) any   
later version.                                               
                                                              
 This source is distributed in the hope that it will be       
 useful, but WITHOUT ANY WARRANTY; without even the implied   
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
 PURPOSE.  See the GNU Lesser General Public License for more 
 details.                                                     
                                                              
 You should have received a copy of the GNU Lesser General    
 Public License along with this source; if not, download it   
 from http://www.opencores.org/lgpl.shtml                     
                                                              
*******************************************************************/


`include "sdrc_define.v"
module sdrc_top 
           (
                    cfg_sdr_width       ,
                    cfg_colbits         ,

		    sdram_debug         ,
                    
                // WB bus
                    wb_rst_n            ,
                    wb_clk_i            ,
                    
                    wb_stb_i            ,
                    wb_ack_o            ,
                    wb_addr_i           ,
                    wb_we_i             ,
                    wb_dat_i            ,
                    wb_sel_i            ,
                    wb_dat_o            ,
                    wb_cyc_i            ,

		
		/* Interface to SDRAMs */
                    sdram_clk           ,
                    sdram_resetn        ,

                    
		/** Pad Interface       **/
		     io_in              ,
		     io_oeb             ,
	             io_out             ,

		/* Parameters */
                    sdr_init_done       ,
                    cfg_req_depth       ,	        //how many req. buffer should hold
                    cfg_sdr_en          ,
                    cfg_sdr_mode_reg    ,
                    cfg_sdr_tras_d      ,
                    cfg_sdr_trp_d       ,
                    cfg_sdr_trcd_d      ,
                    cfg_sdr_cas         ,
                    cfg_sdr_trcar_d     ,
                    cfg_sdr_twr_d       ,
                    cfg_sdr_rfsh        ,
	            cfg_sdr_rfmax
	    );
  
parameter      APP_AW   = 32;  // Application Address Width
parameter      APP_DW   = 32;  // Application Data Width 
parameter      APP_BW   = 4;   // Application Byte Width
parameter      APP_RW   = 9;   // Application Request Width

parameter      SDR_DW   = 8;  // SDR Data Width 
parameter      SDR_BW   = 1;   // SDR Byte Width
             
parameter      tw       = 8;   // tag id width
parameter      bl       = 9;   // burst_lenght_width 

//-----------------------------------------------
// Global Variable
// ----------------------------------------------
input                   sdram_clk          ; // SDRAM Clock 
input                   sdram_resetn       ; // Reset Signal
input [1:0]             cfg_sdr_width      ; // 2'b00 - 32 Bit SDR, 2'b01 - 16 Bit SDR, 2'b1x - 8 Bit
input [1:0]             cfg_colbits        ; // 2'b00 - 8 Bit column address, 
                                             // 2'b01 - 9 Bit, 10 - 10 bit, 11 - 11Bits
output [31:0]           sdram_debug        ; // SDRAM debug signals

//--------------------------------------
// Wish Bone Interface
// -------------------------------------      
input                   wb_rst_n           ;
input                   wb_clk_i           ;

input                   wb_stb_i           ;
output                  wb_ack_o           ;
input [APP_AW-1:0]      wb_addr_i          ;
input                   wb_we_i            ; // 1 - Write, 0 - Read
input [APP_DW-1:0]      wb_dat_i           ;
input [APP_DW/8-1:0]    wb_sel_i           ; // Byte enable
output [APP_DW-1:0]     wb_dat_o           ;
input                   wb_cyc_i           ;

//--------------------------------------
// Pad Interface
// -------------------------------------      
input [29:0]	        io_in              ;
output [29:0]		io_oeb             ;
output [29:0]		io_out             ;
//------------------------------------------------
// Interface to SDRAMs
//------------------------------------------------
wire                  sdram_pad_clk       ; // Sdram clock loop back from pad
wire                  sdr_cke             ; // SDRAM CKE
wire 		      sdr_cs_n            ; // SDRAM Chip Select
wire                  sdr_ras_n           ; // SDRAM ras
wire                  sdr_cas_n           ; // SDRAM cas
wire		      sdr_we_n            ; // SDRAM write enable
wire [SDR_BW-1:0]     sdr_dqm             ; // SDRAM Data Mask
wire [1:0] 	      sdr_ba              ; // SDRAM Bank Enable
wire [12:0] 	      sdr_addr            ; // SDRAM Address
wire [SDR_DW-1:0]     pad_sdr_din         ; // SDRA Data Input
wire  [SDR_DW-1:0]    sdr_dout            ; // SDRAM Data Output
wire  [SDR_BW-1:0]    sdr_den_n           ; // SDRAM Data Output enable

//------------------------------------------------
// Configuration Parameter
//------------------------------------------------
output                  sdr_init_done       ; // Indicate SDRAM Initialisation Done
input [3:0] 		cfg_sdr_tras_d      ; // Active to precharge delay
input [3:0]             cfg_sdr_trp_d       ; // Precharge to active delay
input [3:0]             cfg_sdr_trcd_d      ; // Active to R/W delay
input 			cfg_sdr_en          ; // Enable SDRAM controller
input [1:0] 		cfg_req_depth       ; // Maximum Request accepted by SDRAM controller
input [12:0] 		cfg_sdr_mode_reg    ;
input [2:0] 		cfg_sdr_cas         ; // SDRAM CAS Latency
input [3:0] 		cfg_sdr_trcar_d     ; // Auto-refresh period
input [3:0]             cfg_sdr_twr_d       ; // Write recovery delay
input [`SDR_RFSH_TIMER_W-1 : 0] cfg_sdr_rfsh;
input [`SDR_RFSH_ROW_CNT_W -1 : 0] cfg_sdr_rfmax;

//--------------------------------------------
// SDRAM controller Interface 
//--------------------------------------------
wire                  app_req            ; // SDRAM request
wire [APP_AW-1:0]     app_req_addr       ; // SDRAM Request Address
wire [bl-1:0]         app_req_len        ;
wire                  app_req_wr_n       ; // 0 - Write, 1 -> Read
wire                  app_req_ack        ; // SDRAM request Accepted
wire                  app_busy_n         ; // 0 -> sdr busy
wire [APP_DW/8-1:0]   app_wr_en_n        ; // Active low sdr byte-wise write data valid
wire                  app_wr_next_req    ; // Ready to accept the next write
wire                  app_rd_valid       ; // sdr read valid
wire                  app_last_rd        ; // Indicate last Read of Burst Transfer
wire                  app_last_wr        ; // Indicate last Write of Burst Transfer
wire [APP_DW-1:0]     app_wr_data        ; // sdr write data
wire  [APP_DW-1:0]    app_rd_data        ; // sdr read data

//--------------------------------------------------
//  WishBone Stagging FF
//--------------------------------------------------
wire                   wb_stag_stb_i     ;
wire                   wb_stag_ack_o     ;
wire [APP_AW-1:0]      wb_stag_addr_i    ;
wire                   wb_stag_we_i      ; // 1 - Write, 0 - Read
wire [APP_DW-1:0]      wb_stag_dat_i     ;
wire [APP_DW/8-1:0]    wb_stag_sel_i     ; // Byte enable
wire  [APP_DW-1:0]     wb_stag_dat_o     ;
wire                   wb_stag_cyc_i     ;
//-----------------------------------------------------------------
// To avoid the logic at digital core, pad control are brought inside the
// block to support efabless/carvel soc enviornmental support
// -----------------------------------------------------------------
assign pad_sdr_din[7:0]      =      io_in[7:0]         ;
assign io_out     [7:0]      =      sdr_dout[7:0]      ;
assign io_out     [20:8]     =      sdr_addr[12:0]     ;
assign io_out     [22:21]    =      sdr_ba[1:0]        ;
assign io_out     [23]       =      sdr_dqm[0]         ;
assign io_out     [24]       =      sdr_we_n           ;
assign io_out     [25]       =      sdr_cas_n          ;
assign io_out     [26]       =      sdr_ras_n          ;
assign io_out     [27]       =      sdr_cs_n           ;
assign io_out     [28]       =      sdr_cke            ;
assign io_out     [29]       =      sdram_clk          ;
assign sdram_pad_clk         =      io_in[29]          ;

assign io_oeb     [7:0]      =      sdr_den_n         ;
assign io_oeb     [20:8]     =      {(13) {1'b0}}      ;
assign io_oeb     [22:21]    =      {(2) {1'b0}}       ;
assign io_oeb     [23]       =      1'b0               ;
assign io_oeb     [24]       =      1'b0               ;
assign io_oeb     [25]       =      1'b0               ;
assign io_oeb     [26]       =      1'b0               ;
assign io_oeb     [27]       =      1'b0               ;
assign io_oeb     [28]       =      1'b0               ;
assign io_oeb     [29]       =      1'b0               ;

//assign   sdr_dq = (&sdr_den_n == 1'b0) ? sdr_dout :  {SDR_DW{1'bz}}; 
//assign   pad_sdr_din = sdr_dq;

// sdram pad clock is routed back through pad
// SDRAM Clock from Pad, used for registering Read Data
//wire #(1.0) sdram_pad_clk = sdram_clk;
//
wire [21:0] core_debug;
assign sdram_debug = {sdr_init_done,wb_stag_stb_i,wb_stag_we_i,wb_stag_ack_o, 
                      app_req,app_req_wr_n,app_req_ack,app_busy_n,app_wr_next_req, app_rd_valid,	      
		      core_debug[21:0]};

/************** Ends Here **************************/

// Adding Wishbone stagging FF to break timing path
//
wb_stagging u_wb_stage (
         .clk_i                 (wb_clk_i         ), 
         .rst_n                 (wb_rst_n         ),
         // WishBone Input master I/P
         .m_wbd_dat_i           (wb_dat_i         ),
         .m_wbd_adr_i           (wb_addr_i        ),
         .m_wbd_sel_i           (wb_sel_i         ),
         .m_wbd_we_i            (wb_we_i          ),
         .m_wbd_cyc_i           (wb_cyc_i         ),
         .m_wbd_stb_i           (wb_stb_i         ),
         .m_wbd_tid_i           ('h0              ),
         .m_wbd_dat_o           (wb_dat_o         ),
         .m_wbd_ack_o           (wb_ack_o         ),
         .m_wbd_err_o           (                 ),

         // Slave Interface
         .s_wbd_dat_i          (wb_stag_dat_o     ),
         .s_wbd_ack_i          (wb_stag_ack_o     ),
         .s_wbd_err_i          (1'b0              ),
         .s_wbd_dat_o          (wb_stag_dat_i     ),
         .s_wbd_adr_o          (wb_stag_addr_i    ),
         .s_wbd_sel_o          (wb_stag_sel_i     ),
         .s_wbd_we_o           (wb_stag_we_i      ),
         .s_wbd_cyc_o          (wb_stag_cyc_i     ),
         .s_wbd_stb_o          (wb_stag_stb_i     ),
         .s_wbd_tid_o          (                  )

);


wb2sdrc #(.dw(APP_DW),.tw(tw),.bl(bl),.APP_AW(APP_AW)) u_wb2sdrc (
      // WB bus
          .wb_rst_n           (wb_rst_n           ) ,
          .wb_clk_i           (wb_clk_i           ) ,

          .wb_stb_i           (wb_stag_stb_i      ) ,
          .wb_ack_o           (wb_stag_ack_o      ) ,
          .wb_addr_i          (wb_stag_addr_i     ) ,
          .wb_we_i            (wb_stag_we_i       ) ,
          .wb_dat_i           (wb_stag_dat_i      ) ,
          .wb_sel_i           (wb_stag_sel_i      ) ,
          .wb_dat_o           (wb_stag_dat_o      ) ,
          .wb_cyc_i           (wb_stag_cyc_i      ) ,


      //SDRAM Controller Hand-Shake Signal 
          .sdram_clk          (sdram_clk          ) ,
          .sdram_resetn       (sdram_resetn       ) ,
          .sdr_req            (app_req            ) ,
          .sdr_req_addr       (app_req_addr       ) ,
          .sdr_req_len        (app_req_len        ) ,
          .sdr_req_wr_n       (app_req_wr_n       ) ,
          .sdr_req_ack        (app_req_ack        ) ,
          .sdr_busy_n         (app_busy_n         ) ,
          .sdr_wr_en_n        (app_wr_en_n        ) ,
          .sdr_wr_next        (app_wr_next_req    ) ,
          .sdr_rd_valid       (app_rd_valid       ) ,
          .sdr_last_rd        (app_last_rd        ) ,
          .sdr_wr_data        (app_wr_data        ) ,
          .sdr_rd_data        (app_rd_data        ) 

      ); 


sdrc_core #(.SDR_DW(SDR_DW) , .SDR_BW(SDR_BW),.APP_AW(APP_AW)) u_sdrc_core (
          .clk                (sdram_clk          ) ,
          .pad_clk            (sdram_pad_clk      ) ,
          .reset_n            (sdram_resetn       ) ,
          .sdr_width          (cfg_sdr_width      ) ,
          .cfg_colbits        (cfg_colbits        ) ,
	  .debug              (core_debug         ) ,

 		/* Request from app */
          .app_req            (app_req            ) ,// Transfer Request
          .app_req_addr       (app_req_addr       ) ,// SDRAM Address
          .app_req_len        (app_req_len        ) ,// Burst Length (in 16 bit words)
          .app_req_wrap       (1'b0               ) ,// Wrap mode request 
          .app_req_wr_n       (app_req_wr_n       ) ,// 0 => Write request, 1 => read req
          .app_req_ack        (app_req_ack        ) ,// Request has been accepted
          .cfg_req_depth      (cfg_req_depth      ) ,//how many req. buffer should hold
 		
          .app_wr_data        (app_wr_data        ) ,
          .app_wr_en_n        (app_wr_en_n        ) ,
          .app_rd_data        (app_rd_data        ) ,
          .app_rd_valid       (app_rd_valid       ) ,
	  .app_last_rd        (app_last_rd        ) ,
          .app_last_wr        (app_last_wr        ) ,
          .app_wr_next_req    (app_wr_next_req    ) ,
          .sdr_init_done      (sdr_init_done      ) ,
          .app_req_dma_last   (app_req            ) ,
 
 		/* Interface to SDRAMs */
          .sdr_cs_n           (sdr_cs_n           ) ,
          .sdr_cke            (sdr_cke            ) ,
          .sdr_ras_n          (sdr_ras_n          ) ,
          .sdr_cas_n          (sdr_cas_n          ) ,
          .sdr_we_n           (sdr_we_n           ) ,
          .sdr_dqm            (sdr_dqm            ) ,
          .sdr_ba             (sdr_ba             ) ,
          .sdr_addr           (sdr_addr           ) , 
          .pad_sdr_din        (pad_sdr_din        ) ,
          .sdr_dout           (sdr_dout           ) ,
          .sdr_den_n          (sdr_den_n          ) ,
 
 		/* Parameters */
          .cfg_sdr_en         (cfg_sdr_en         ) ,
          .cfg_sdr_mode_reg   (cfg_sdr_mode_reg   ) ,
          .cfg_sdr_tras_d     (cfg_sdr_tras_d     ) ,
          .cfg_sdr_trp_d      (cfg_sdr_trp_d      ) ,
          .cfg_sdr_trcd_d     (cfg_sdr_trcd_d     ) ,
          .cfg_sdr_cas        (cfg_sdr_cas        ) ,
          .cfg_sdr_trcar_d    (cfg_sdr_trcar_d    ) ,
          .cfg_sdr_twr_d      (cfg_sdr_twr_d      ) ,
          .cfg_sdr_rfsh       (cfg_sdr_rfsh       ) ,
          .cfg_sdr_rfmax      (cfg_sdr_rfmax      ) 
	       );
   
endmodule // sdrc_core
