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
////    0.2 - Nov 14 2021, Dinesh A                               ////
////          Reset connectivity bug fix clk_ctl in u_sdramclk    ////
////          u_cpuclk,u_rtcclk,u_usbclk                          ////
////    0.3 - Nov 16 2021, Dinesh A                               ////
////          Wishbone out are register for better timing         ////   
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

       output logic                cpu_clk          ,
       output logic                rtc_clk          ,
       output logic                usb_clk          ,
       // Global Reset control
       output logic                wbd_int_rst_n    ,
       output logic                cpu_rst_n        ,
       output logic                qspim_rst_n        ,
       output logic                sspim_rst_n      ,
       output logic                uart_rst_n       ,
       output logic                i2cm_rst_n       ,
       output logic                usb_rst_n        ,
       output logic                bist_rst_n        ,

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

    // Clock Skew Adjust
       input   logic               wbd_clk_int      , 
       output  logic               wbd_clk_wh       ,
       input   logic [3:0]         cfg_cska_wh      , // clock skew adjust for web host

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
       output logic [31:0]         cfg_clk_ctrl2    ,

       input  logic [17:0]         la_data_in       ,

       input  logic                uartm_rxd        ,
       output logic                uartm_txd        

    );


//--------------------------------
// local  dec
//
//--------------------------------
logic               wbm_rst_n;
logic               wbs_rst_n;

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
logic [31:0]        reg_0;  // Software_Reg_0

logic  [2:0]        cfg_wb_clk_ctrl;
logic  [3:0]        cfg_cpu_clk_ctrl;
logic  [7:0]        cfg_rtc_clk_ctrl;
logic  [3:0]        cfg_usb_clk_ctrl;
logic  [8:0]        cfg_glb_ctrl;

// uart Master Port
logic               wbm_uart_cyc_i        ;  // strobe/request
logic               wbm_uart_stb_i        ;  // strobe/request
logic [31:0]        wbm_uart_adr_i        ;  // address
logic               wbm_uart_we_i         ;  // write
logic [31:0]        wbm_uart_dat_i        ;  // data output
logic [3:0]         wbm_uart_sel_i        ;  // byte enable
logic [31:0]        wbm_uart_dat_o        ;  // data input
logic               wbm_uart_ack_o        ;  // acknowlegement
logic               wbm_uart_err_o        ;  // error

// Selected Master Port
logic               wb_cyc_i              ;  // strobe/request
logic               wb_stb_i              ;  // strobe/request
logic [31:0]        wb_adr_i              ;  // address
logic               wb_we_i               ;  // write
logic [31:0]        wb_dat_i              ;  // data output
logic [3:0]         wb_sel_i              ;  // byte enable
logic [31:0]        wb_dat_o              ;  // data input
logic               wb_ack_o              ;  // acknowlegement
logic               wb_err_o              ;  // error
logic [31:0]        wb_adr_int            ;
logic               wb_stb_int            ;
logic [31:0]        wb_dat_int            ; // data input
logic               wb_ack_int            ; // acknowlegement
logic               wb_err_int            ; // error


ctech_buf u_buf_wb_rst        (.A(cfg_glb_ctrl[0]),.X(wbd_int_rst_n));
ctech_buf u_buf_cpu_rst       (.A(cfg_glb_ctrl[1]),.X(cpu_rst_n));
ctech_buf u_buf_qspim_rst     (.A(cfg_glb_ctrl[2]),.X(qspim_rst_n));
ctech_buf u_buf_sspim_rst     (.A(cfg_glb_ctrl[3]),.X(sspim_rst_n));
ctech_buf u_buf_uart_rst      (.A(cfg_glb_ctrl[4]),.X(uart_rst_n));
ctech_buf u_buf_i2cm_rst      (.A(cfg_glb_ctrl[5]),.X(i2cm_rst_n));
ctech_buf u_buf_usb_rst       (.A(cfg_glb_ctrl[6]),.X(usb_rst_n));
ctech_buf u_buf_bist_rst      (.A(cfg_glb_ctrl[7]),.X(bist_rst_n));

//--------------------------------------------------------------------------------
// Look like wishbone reset removed early than user Power up sequence
// To control the reset phase, we have added additional control through la[0]
// ------------------------------------------------------------------------------
wire    arst_n = !wbm_rst_i & la_data_in[0];
reset_sync  u_wbm_rst (
	      .scan_mode  (1'b0           ),
              .dclk       (wbm_clk_i      ), // Destination clock domain
	      .arst_n     (arst_n         ), // active low async reset
              .srst_n     (wbm_rst_n      )
          );

reset_sync  u_wbs_rst (
	      .scan_mode  (1'b0           ),
              .dclk       (wbs_clk_i      ), // Destination clock domain
	      .arst_n     (arst_n         ), // active low async reset
              .srst_n     (wbs_rst_n      )
          );

// UART Master
uart2wb u_uart2wb (  
        .arst_n          (wbm_rst_n         ), //  sync reset
        .app_clk         (wbm_clk_i         ), //  sys clock    

	// configuration control
       .cfg_tx_enable    (la_data_in[1]     ), // Enable Transmit Path
       .cfg_rx_enable    (la_data_in[2]     ), // Enable Received Path
       .cfg_stop_bit     (la_data_in[3]     ), // 0 -> 1 Start , 1 -> 2 Stop Bits
       .cfg_baud_16x     (la_data_in[15:4]  ), // 16x Baud clock generation
       .cfg_pri_mod      (la_data_in[17:16] ), // priority mode, 0 -> nop, 1 -> Even, 2 -> Odd

    // Master Port
       .wbm_cyc_o        (wbm_uart_cyc_i ),  // strobe/request
       .wbm_stb_o        (wbm_uart_stb_i ),  // strobe/request
       .wbm_adr_o        (wbm_uart_adr_i ),  // address
       .wbm_we_o         (wbm_uart_we_i  ),  // write
       .wbm_dat_o        (wbm_uart_dat_i ),  // data output
       .wbm_sel_o        (wbm_uart_sel_i ),  // byte enable
       .wbm_dat_i        (wbm_uart_dat_o ),  // data input
       .wbm_ack_i        (wbm_uart_ack_o ),  // acknowlegement
       .wbm_err_i        (wbm_uart_err_o ),  // error

       // Status information
       .frm_error        (), // framing error
       .par_error        (), // par error

       .baud_clk_16x     (), // 16x Baud clock

       // Line Interface
       .rxd              (uartm_rxd) , // uart rxd
       .txd              (uartm_txd)   // uart txd

     );


// Arbitor to select between external wb vs uart wb
wire [1:0] grnt;
wb_arb u_arb(
	.clk      (wbm_clk_i), 
	.rstn     (wbm_rst_n), 
	.req      ({1'b0,wbm_uart_stb_i,wbm_stb_i}), 
	.gnt      (grnt)
        );

// Select  the master based on the grant
assign wb_cyc_i = (grnt == 2'b00) ? wbm_cyc_i : wbm_uart_cyc_i; 
assign wb_stb_i = (grnt == 2'b00) ? wbm_stb_i : wbm_uart_stb_i; 
assign wb_adr_i = (grnt == 2'b00) ? wbm_adr_i : wbm_uart_adr_i; 
assign wb_we_i  = (grnt == 2'b00) ? wbm_we_i  : wbm_uart_we_i; 
assign wb_dat_i = (grnt == 2'b00) ? wbm_dat_i : wbm_uart_dat_i; 
assign wb_sel_i = (grnt == 2'b00) ? wbm_sel_i : wbm_uart_sel_i; 

assign wbm_dat_o = (grnt == 2'b00) ? wb_dat_o : 'h0;
assign wbm_ack_o = (grnt == 2'b00) ? wb_ack_o : 'h0;
assign wbm_err_o = (grnt == 2'b00) ? wb_err_o : 'h0;


assign wbm_uart_dat_o = (grnt == 2'b01) ? wb_dat_o : 'h0;
assign wbm_uart_ack_o = (grnt == 2'b01) ? wb_ack_o : 'h0;
assign wbm_uart_err_o = (grnt == 2'b01) ? wb_err_o : 'h0;





// wb_host clock skew control
clk_skew_adjust u_skew_wh
       (
`ifdef USE_POWER_PINS
               .vccd1      (vccd1                      ),// User area 1 1.8V supply
               .vssd1      (vssd1                      ),// User area 1 digital ground
`endif
	       .clk_in     (wbd_clk_int               ), 
	       .sel        (cfg_cska_wh               ), 
	       .clk_out    (wbd_clk_wh                ) 
       );


// To reduce the load/Timing Wishbone I/F, Strobe is register to create
// multi-cycle
wire [31:0]  wb_dat_o1   = (reg_sel) ? reg_rdata : wb_dat_int;  // data input
wire         wb_ack_o1   = (reg_sel) ? reg_ack   : wb_ack_int; // acknowlegement
wire         wb_err_o1   = (reg_sel) ? 1'b0      : wb_err_int;  // error

logic wb_req;
// Hold fix for STROBE
wire  wb_stb_d1,wb_stb_d2,wb_stb_d3;
ctech_delay_buf u_delay1_stb0 (.X(wb_stb_d1),.A(wb_stb_i));
ctech_delay_buf u_delay2_stb1 (.X(wb_stb_d2),.A(wb_stb_d1));
ctech_delay_buf u_delay2_stb2 (.X(wb_stb_d3),.A(wb_stb_d2));
always_ff @(negedge wbm_rst_n or posedge wbm_clk_i) begin
    if ( wbm_rst_n == 1'b0 ) begin
        wb_req    <= '0;
	wb_dat_o <= '0;
	wb_ack_o <= '0;
	wb_err_o <= '0;
   end else begin
       wb_req   <= wb_stb_d3 && ((wb_ack_o == 0) && (wb_ack_o1 == 0)) ;
       wb_ack_o <= wb_ack_o1;
       wb_err_o <= wb_err_o1;
       if(wb_ack_o1) // Keep last data in the bus
          wb_dat_o <= wb_dat_o1;
   end
end


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
assign reg_sel       = wb_req & (wb_adr_i[23] == 1'b1);

assign sw_addr       = wb_adr_i [3:2];
assign sw_rd_en      = reg_sel & !wb_we_i;
assign sw_wr_en      = reg_sel & wb_we_i;

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
assign cfg_glb_ctrl         = reg_0[8:0];
assign cfg_wb_clk_ctrl      = reg_0[11:9];
assign cfg_rtc_clk_ctrl     = reg_0[19:12];
assign cfg_cpu_clk_ctrl     = reg_0[23:20];
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
	      .we            ({32{sw_wr_en_0}}   ),		 
	      .data_in       (wb_dat_i[31:0]    ),
	      .reset_n       (wbm_rst_n         ),
	      .clk           (wbm_clk_i         ),
	      
	      //List of Outs
	      .data_out      (reg_0[31:0])
          );

generic_register #(8,8'h10 ) u_bank_sel (
	      .we            ({8{sw_wr_en_1}}   ),		 
	      .data_in       (wb_dat_i[7:0]    ),
	      .reset_n       (wbm_rst_n         ),
	      .clk           (wbm_clk_i         ),
	      
	      //List of Outs
	      .data_out      (cfg_bank_sel[7:0] )
          );


generic_register #(32,0  ) u_clk_ctrl1 (
	      .we            ({32{sw_wr_en_2}}   ),		 
	      .data_in       (wb_dat_i[31:0]    ),
	      .reset_n       (wbm_rst_n          ),
	      .clk           (wbm_clk_i          ),
	      
	      //List of Outs
	      .data_out      (cfg_clk_ctrl1[31:0])
          );

generic_register #(32,0  ) u_clk_ctrl2 (
	      .we            ({32{sw_wr_en_3}}  ),		 
	      .data_in       (wb_dat_i[31:0]   ),
	      .reset_n       (wbm_rst_n         ),
	      .clk           (wbm_clk_i         ),
	      
	      //List of Outs
	      .data_out      (cfg_clk_ctrl2[31:0])
          );


assign wb_stb_int = wb_req & !reg_sel;

// Since design need more than 16MB address space, we have implemented
// indirect access
assign wb_adr_int = {cfg_bank_sel[7:0],wb_adr_i[23:0]};  

async_wb u_async_wb(
// Master Port
       .wbm_rst_n   (wbm_rst_n     ),  
       .wbm_clk_i   (wbm_clk_i     ),  
       .wbm_cyc_i   (wb_cyc_i      ),  
       .wbm_stb_i   (wb_stb_int    ),  
       .wbm_adr_i   (wb_adr_int    ),  
       .wbm_we_i    (wb_we_i       ),  
       .wbm_dat_i   (wb_dat_i      ),  
       .wbm_sel_i   (wb_sel_i      ),  
       .wbm_dat_o   (wb_dat_int    ),  
       .wbm_ack_o   (wb_ack_int    ),  
       .wbm_err_o   (wb_err_int    ),  

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


//assign wbs_clk_out  = (cfg_wb_clk_div)  ? wb_clk_div : wbm_clk_i;
ctech_mux2x1 u_wbs_clk_sel (.A0 (wbm_clk_i), .A1 (wb_clk_div), .S  (cfg_wb_clk_div), .X  (wbs_clk_out));


clk_ctl #(1) u_wbclk (
   // Outputs
       .clk_o         (wb_clk_div      ),
   // Inputs
       .mclk          (wbm_clk_i       ),
       .reset_n       (wbm_rst_n        ), 
       .clk_div_ratio (cfg_wb_clk_ratio )
   );


//----------------------------------
// Generate CORE Clock Generation
//----------------------------------
wire   cpu_clk_div;
wire   cpu_ref_clk;
wire   cpu_clk_int;

wire       cfg_cpu_clk_src_sel   = cfg_cpu_clk_ctrl[3];
wire       cfg_cpu_clk_div       = cfg_cpu_clk_ctrl[2];
wire [1:0] cfg_cpu_clk_ratio     = cfg_cpu_clk_ctrl[1:0];

//assign cpu_ref_clk = (cfg_cpu_clk_src_sel) ? user_clock2 : user_clock1;
//assign cpu_clk_int = (cfg_cpu_clk_div)     ? cpu_clk_div : cpu_ref_clk;

ctech_mux2x1 u_cpu_ref_sel (.A0 (user_clock1), .A1 (user_clock2), .S  (cfg_cpu_clk_src_sel), .X  (cpu_ref_clk));
ctech_mux2x1 u_cpu_clk_sel (.A0 (cpu_ref_clk), .A1 (cpu_clk_div), .S  (cfg_cpu_clk_div),     .X  (cpu_clk_int));

ctech_clk_buf u_clkbuf_cpu (.A (cpu_clk_int), . X(cpu_clk));

clk_ctl #(1) u_cpuclk (
   // Outputs
       .clk_o         (cpu_clk_div      ),
   // Inputs
       .mclk          (cpu_ref_clk      ),
       .reset_n       (wbm_rst_n        ), 
       .clk_div_ratio (cfg_cpu_clk_ratio)
   );

//----------------------------------
// Generate RTC Clock Generation
//----------------------------------
wire   rtc_clk_div;
wire [7:0] cfg_rtc_clk_ratio     = cfg_rtc_clk_ctrl[7:0];


ctech_clk_buf u_clkbuf_rtc (.A (rtc_clk_div), . X(rtc_clk));

clk_ctl #(7) u_rtcclk (
   // Outputs
       .clk_o         (rtc_clk_div      ),
   // Inputs
       .mclk          (user_clock2      ),
       .reset_n       (wbm_rst_n        ), 
       .clk_div_ratio (cfg_rtc_clk_ratio)
   );


//----------------------------------
// Generate USB Clock Generation
//----------------------------------
wire   usb_clk_div;
wire   usb_ref_clk;
wire   usb_clk_int;

wire       cfg_usb_clk_div       = cfg_usb_clk_ctrl[3];
wire [2:0] cfg_usb_clk_ratio     = cfg_usb_clk_ctrl[2:0];

assign usb_ref_clk = user_clock2 ;
//assign usb_clk_int = (cfg_usb_clk_div)     ? usb_clk_div : usb_ref_clk;
ctech_mux2x1 u_usb_clk_sel (.A0 (usb_ref_clk), .A1 (usb_clk_div), .S  (cfg_usb_clk_div), .X  (usb_clk_int));


ctech_clk_buf u_clkbuf_usb (.A (usb_clk_int), . X(usb_clk));

clk_ctl #(2) u_usbclk (
   // Outputs
       .clk_o         (usb_clk_div      ),
   // Inputs
       .mclk          (usb_ref_clk      ),
       .reset_n       (wbm_rst_n        ), 
       .clk_div_ratio (cfg_usb_clk_ratio)
   );

endmodule
