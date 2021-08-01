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
////  Wishbone host Interface                                     ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  https://github.com/dineshannayya/yifive_r0.git              ////
////  http://www.opencores.org/cores/yifive/                      ////
////                                                              ////
////  Description                                                 ////
////      This block does async Wishbone from one clock to other  ////
////      clock domain                                            ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 25th Feb 2021, Dinesh A                             ////
////          initial version                                     ////
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

module wb_host (

`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif
       input logic                 user_clock1      ,
       input logic                 user_clock2      ,

       output logic                sdram_clk        ,
       output logic                cpu_clk          ,
       output logic                rtc_clk          ,
       output logic                usb_clk          ,
       // Global Reset control
       output logic                wbd_int_rst_n    ,
       output logic                cpu_rst_n        ,
       output logic                spi_rst_n        ,
       output logic                sdram_rst_n      ,
       output logic                uart_rst_n       ,
       output logic                i2cm_rst_n       ,
       output logic                usb_rst_n        ,
       output logic  [1:0]         uart_i2c_usb_sel ,

    // Master Port
       input   logic               wbm_rst_i        ,  // Regular Reset signal
       input   logic               wbm_clk_i        ,  // System clock
       input   logic               wbm_cyc_i        ,  // strobe/request
       input   logic               wbm_stb_i        ,  // strobe/request
       input   logic [31:0]        wbm_adr_i        ,  // address
       input   logic               wbm_we_i         ,  // write
       input   logic [31:0]        wbm_dat_i        ,  // data output
       input   logic [3:0]         wbm_sel_i        ,  // byte enable
       output  logic [31:0]        wbm_dat_o        ,  // data input
       output  logic               wbm_ack_o        ,  // acknowlegement
       output  logic               wbm_err_o        ,  // error

    // Slave Port
       output  logic               wbs_clk_out      ,  // System clock
       input   logic               wbs_clk_i        ,  // System clock
       output  logic               wbs_cyc_o        ,  // strobe/request
       output  logic               wbs_stb_o        ,  // strobe/request
       output  logic [31:0]        wbs_adr_o        ,  // address
       output  logic               wbs_we_o         ,  // write
       output  logic [31:0]        wbs_dat_o        ,  // data output
       output  logic [3:0]         wbs_sel_o        ,  // byte enable
       input   logic [31:0]        wbs_dat_i        ,  // data input
       input   logic               wbs_ack_i        ,  // acknowlegement
       input   logic               wbs_err_i        ,  // error

       output logic [31:0]         cfg_clk_ctrl1    ,
       output logic [31:0]         cfg_clk_ctrl2    

    );


//--------------------------------
// local  dec
//
//--------------------------------
logic               wbm_rst_n;
logic               wbs_rst_n;
logic [31:0]        wbm_dat_int; // data input
logic               wbm_ack_int; // acknowlegement
logic               wbm_err_int; // error

logic               reg_sel    ;
logic [1:0]         sw_addr    ;
logic               sw_rd_en   ;
logic               sw_wr_en   ;
logic [31:0]        reg_rdata  ;
logic [31:0]        reg_out    ;
logic               reg_ack    ;
logic [7:0]         config_reg ;    
logic [31:0]        clk_ctrl1 ;    
logic [31:0]        clk_ctrl2 ;    
logic               sw_wr_en_0;
logic               sw_wr_en_1;
logic               sw_wr_en_2;
logic               sw_wr_en_3;
logic [7:0]         cfg_bank_sel;
logic [31:0]        wbm_adr_int;
logic               wbm_stb_int;
logic [31:0]        reg_0;  // Software_Reg_0

logic  [2:0]        cfg_wb_clk_ctrl;
logic  [3:0]        cfg_sdram_clk_ctrl;
logic  [3:0]        cfg_cpu_clk_ctrl;
logic  [7:0]        cfg_rtc_clk_ctrl;
logic  [3:0]        cfg_usb_clk_ctrl;
logic  [6:0]        cfg_glb_ctrl;


assign wbm_rst_n = !wbm_rst_i;
assign wbs_rst_n = !wbm_rst_i;

sky130_fd_sc_hd__bufbuf_16 u_buf_wb_rst        (.A(cfg_glb_ctrl[0]),.X(wbd_int_rst_n));
sky130_fd_sc_hd__bufbuf_16 u_buf_cpu_rst       (.A(cfg_glb_ctrl[1]),.X(cpu_rst_n));
sky130_fd_sc_hd__bufbuf_16 u_buf_spi_rst       (.A(cfg_glb_ctrl[2]),.X(spi_rst_n));
sky130_fd_sc_hd__bufbuf_16 u_buf_sdram_rst     (.A(cfg_glb_ctrl[3]),.X(sdram_rst_n));
sky130_fd_sc_hd__bufbuf_16 u_buf_uart_rst      (.A(cfg_glb_ctrl[4]),.X(uart_rst_n));
sky130_fd_sc_hd__bufbuf_16 u_buf_i2cm_rst      (.A(cfg_glb_ctrl[5]),.X(i2cm_rst_n));
sky130_fd_sc_hd__bufbuf_16 u_buf_usb_rst       (.A(cfg_glb_ctrl[6]),.X(usb_rst_n));


// To reduce the load/Timing Wishbone I/F, Strobe is register to create
// multi-cycle
logic wb_req;
always_ff @(negedge wbm_rst_n or posedge wbm_clk_i) begin
    if ( wbm_rst_n == 1'b0 ) begin
        wb_req   <= '0;
   end else begin
       wb_req   <= wbm_stb_i && (wbm_ack_o == 0) ;
   end
end

assign  wbm_dat_o   = (reg_sel) ? reg_rdata : wbm_dat_int;  // data input
assign  wbm_ack_o   = (reg_sel) ? reg_ack   : wbm_ack_int; // acknowlegement
assign  wbm_err_o   = (reg_sel) ? 1'b0      : wbm_err_int;  // error

//-----------------------------------------------------------------------
// Local register decide based on address[31] == 1
//
// Locally there register are define to control the reset and clock for user
// area
//-----------------------------------------------------------------------
// caravel user space is 0x3000_0000 to 0x30FF_FFFF
// So we have allocated 
// 0x3080_0000 - 0x3080_00FF - Assigned to WB Host Address Space
// Since We need more than 16MB Address space to access SDRAM/SPI we have
// added indirect MSB 8 bit address select option
// So Address will be {Bank_Sel[7:0], wbm_adr_i[23:0}
// ---------------------------------------------------------------------
assign reg_sel       = wb_req & (wbm_adr_i[23] == 1'b1);

assign sw_addr       = wbm_adr_i [3:2];
assign sw_rd_en      = reg_sel & !wbm_we_i;
assign sw_wr_en      = reg_sel & wbm_we_i;

assign  sw_wr_en_0 = sw_wr_en && (sw_addr==0);
assign  sw_wr_en_1 = sw_wr_en && (sw_addr==1);
assign  sw_wr_en_2 = sw_wr_en && (sw_addr==2);
assign  sw_wr_en_3 = sw_wr_en && (sw_addr==3);

always @ (posedge wbm_clk_i or negedge wbm_rst_n)
begin : preg_out_Seq
   if (wbm_rst_n == 1'b0)
   begin
      reg_rdata  <= 'h0;
      reg_ack    <= 1'b0;
   end
   else if (sw_rd_en && !reg_ack) 
   begin
      reg_rdata <= reg_out ;
      reg_ack   <= 1'b1;
   end
   else if (sw_wr_en && !reg_ack) 
      reg_ack          <= 1'b1;
   else
   begin
      reg_ack        <= 1'b0;
   end
end


//-------------------------------------
// Global + Clock Control
// -------------------------------------
assign cfg_glb_ctrl         = reg_0[6:0];
assign uart_i2c_usb_sel     = reg_0[8:7];
assign cfg_wb_clk_ctrl      = reg_0[11:9];
assign cfg_rtc_clk_ctrl     = reg_0[19:12];
assign cfg_cpu_clk_ctrl     = reg_0[23:20];
assign cfg_sdram_clk_ctrl   = reg_0[27:24];
assign cfg_usb_clk_ctrl     = reg_0[31:28];


always @( *)
begin 
  reg_out [31:0] = 8'd0;

  case (sw_addr [1:0])
    2'b00 :   reg_out [31:0] = reg_0;
    2'b01 :   reg_out [31:0] = {24'h0,cfg_bank_sel [7:0]};     
    2'b10 :   reg_out [31:0] = cfg_clk_ctrl1 [31:0];    
    2'b11 :   reg_out [31:0] = cfg_clk_ctrl2 [31:0];     
    default : reg_out [31:0] = 'h0;
  endcase
end



generic_register #(32,0  ) u_glb_ctrl (
	      .we            ({24{sw_wr_en_0}}   ),		 
	      .data_in       (wbm_dat_i[23:0]    ),
	      .reset_n       (wbm_rst_n         ),
	      .clk           (wbm_clk_i         ),
	      
	      //List of Outs
	      .data_out      (reg_0[31:0])
          );

generic_register #(8,8'h30 ) u_bank_sel (
	      .we            ({8{sw_wr_en_1}}   ),		 
	      .data_in       (wbm_dat_i[7:0]    ),
	      .reset_n       (wbm_rst_n         ),
	      .clk           (wbm_clk_i         ),
	      
	      //List of Outs
	      .data_out      (cfg_bank_sel[7:0] )
          );


generic_register #(32,0  ) u_clk_ctrl1 (
	      .we            ({32{sw_wr_en_2}}   ),		 
	      .data_in       (wbm_dat_i[31:0]    ),
	      .reset_n       (wbm_rst_n          ),
	      .clk           (wbm_clk_i          ),
	      
	      //List of Outs
	      .data_out      (cfg_clk_ctrl1[31:0])
          );

generic_register #(32,0  ) u_clk_ctrl2 (
	      .we            ({32{sw_wr_en_3}}  ),		 
	      .data_in       (wbm_dat_i[31:0]   ),
	      .reset_n       (wbm_rst_n         ),
	      .clk           (wbm_clk_i         ),
	      
	      //List of Outs
	      .data_out      (cfg_clk_ctrl2[31:0])
          );


assign wbm_stb_int = wb_req & !reg_sel;

// Since design need more than 16MB address space, we have implemented
// indirect access
assign wbm_adr_int = {cfg_bank_sel[7:0],wbm_adr_i[23:0]};  

async_wb u_async_wb(
// Master Port
       .wbm_rst_n   (wbm_rst_n     ),  
       .wbm_clk_i   (wbm_clk_i     ),  
       .wbm_cyc_i   (wbm_cyc_i     ),  
       .wbm_stb_i   (wbm_stb_int   ),  
       .wbm_adr_i   (wbm_adr_int   ),  
       .wbm_we_i    (wbm_we_i      ),  
       .wbm_dat_i   (wbm_dat_i     ),  
       .wbm_sel_i   (wbm_sel_i     ),  
       .wbm_dat_o   (wbm_dat_int   ),  
       .wbm_ack_o   (wbm_ack_int   ),  
       .wbm_err_o   (wbm_err_int   ),  

// Slave Port
       .wbs_rst_n   (wbs_rst_n     ),  
       .wbs_clk_i   (wbs_clk_i     ),  
       .wbs_cyc_o   (wbs_cyc_o     ),  
       .wbs_stb_o   (wbs_stb_o     ),  
       .wbs_adr_o   (wbs_adr_o     ),  
       .wbs_we_o    (wbs_we_o      ),  
       .wbs_dat_o   (wbs_dat_o     ),  
       .wbs_sel_o   (wbs_sel_o     ),  
       .wbs_dat_i   (wbs_dat_i     ),  
       .wbs_ack_i   (wbs_ack_i     ),  
       .wbs_err_i   (wbs_err_i     )

    );


//----------------------------------
// Generate Internal WishBone Clock
//----------------------------------
logic       wb_clk_div;
logic       cfg_wb_clk_div;
logic [1:0] cfg_wb_clk_ratio;

assign    cfg_wb_clk_ratio =  cfg_wb_clk_ctrl[1:0];
assign    cfg_wb_clk_div   =  cfg_wb_clk_ctrl[2];


assign wbs_clk_out  = (cfg_wb_clk_div)  ? wb_clk_div : wbm_clk_i;


clk_ctl #(1) u_wbclk (
   // Outputs
       .clk_o         (wb_clk_div      ),
   // Inputs
       .mclk          (wbm_clk_i       ),
       .reset_n       (wbm_rst_n        ), 
       .clk_div_ratio (cfg_wb_clk_ratio )
   );

//----------------------------------
// Generate SDRAM Clock Generation
//----------------------------------
wire   sdram_clk_div;
wire   sdram_ref_clk;
wire   sdram_clk_int;

wire       cfg_sdram_clk_src_sel   = cfg_sdram_clk_ctrl[0];
wire       cfg_sdram_clk_div       = cfg_sdram_clk_ctrl[1];
wire [1:0] cfg_sdram_clk_ratio     = cfg_sdram_clk_ctrl[3:2];
assign sdram_ref_clk = (cfg_sdram_clk_src_sel) ? user_clock2 :user_clock1;
assign sdram_clk_int = (cfg_sdram_clk_div) ? sdram_clk_div : sdram_ref_clk;

sky130_fd_sc_hd__clkbuf_16 u_clkbuf_sdram (.A (sdram_clk_int), . X(sdram_clk));

clk_ctl #(1) u_sdramclk (
   // Outputs
       .clk_o         (sdram_clk_div      ),
   // Inputs
       .mclk          (sdram_ref_clk      ),
       .reset_n       (reset_n            ), 
       .clk_div_ratio (cfg_sdram_clk_ratio)
   );


//----------------------------------
// Generate CORE Clock Generation
//----------------------------------
wire   cpu_clk_div;
wire   cpu_ref_clk;
wire   cpu_clk_int;

wire       cfg_cpu_clk_src_sel   = cfg_cpu_clk_ctrl[0];
wire       cfg_cpu_clk_div       = cfg_cpu_clk_ctrl[1];
wire [1:0] cfg_cpu_clk_ratio     = cfg_cpu_clk_ctrl[3:2];

assign cpu_ref_clk = (cfg_cpu_clk_src_sel) ? user_clock2 : user_clock1;
assign cpu_clk_int = (cfg_cpu_clk_div)     ? cpu_clk_div : cpu_ref_clk;


sky130_fd_sc_hd__clkbuf_16 u_clkbuf_cpu (.A (cpu_clk_int), . X(cpu_clk));

clk_ctl #(1) u_cpuclk (
   // Outputs
       .clk_o         (cpu_clk_div      ),
   // Inputs
       .mclk          (cpu_ref_clk      ),
       .reset_n       (reset_n          ), 
       .clk_div_ratio (cfg_cpu_clk_ratio)
   );

//----------------------------------
// Generate RTC Clock Generation
//----------------------------------
wire   rtc_clk_div;
wire [7:0] cfg_rtc_clk_ratio     = cfg_rtc_clk_ctrl[7:0];


sky130_fd_sc_hd__clkbuf_16 u_clkbuf_rtc (.A (rtc_clk_div), . X(rtc_clk));

clk_ctl #(7) u_rtcclk (
   // Outputs
       .clk_o         (rtc_clk_div      ),
   // Inputs
       .mclk          (user_clock2      ),
       .reset_n       (reset_n          ), 
       .clk_div_ratio (cfg_rtc_clk_ratio)
   );


//----------------------------------
// Generate USB Clock Generation
//----------------------------------
wire   usb_clk_div;
wire   usb_ref_clk;
wire   usb_clk_int;

wire       cfg_usb_clk_div       = cfg_usb_clk_ctrl[0];
wire [2:0] cfg_usb_clk_ratio     = cfg_usb_clk_ctrl[3:1];

assign usb_ref_clk = user_clock2 ;
assign usb_clk_int = (cfg_usb_clk_div)     ? usb_clk_div : usb_ref_clk;


sky130_fd_sc_hd__clkbuf_16 u_clkbuf_usb (.A (usb_clk_int), . X(usb_clk));

clk_ctl #(2) u_usbclk (
   // Outputs
       .clk_o         (usb_clk_div      ),
   // Inputs
       .mclk          (usb_ref_clk      ),
       .reset_n       (reset_n          ), 
       .clk_div_ratio (cfg_usb_clk_ratio)
   );

endmodule
