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
////    0.4 - Mar 15 2021, Dinesh A                               ////
////          1. To fix the bug in caravel mgmt soc address range ////
////          reduction to 0x3000_0000 to 0x300F_FFFF             ////
////          Address Map has changes as follows                  ////
////          0x3008_0000 to 0x3008_00FF - Local Wishbone Reg     ////
////          0x3000_0000 to 0x3007_FFFF - SOC access with        ////
////              indirect Map {Bank_Sel[15:3], wbm_adr_i[18:0]}  ////
////          2.wbm_cyc_i need to qualified with wbm_stb_i        //// 
////                                                              ////
////    0.5 - Aug 30 2022, Dinesh A                               ////
////          A. System strap related changes, reset_fsm added    ////
////          B. rtc and usb clock moved to pinmux                ////
////                                                              //// 
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

`include "user_params.svh"

module wb_host (

`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif
       input logic                 user_clock1      ,
       input logic                 user_clock2      ,

       output logic                cpu_clk          ,

       // Global Reset control
       output logic                wbd_int_rst_n    ,
       output logic                wbd_pll_rst_n    ,


       // to/from Pinmux
        output  logic              int_pll_clock     ,
        input   logic              xtal_clk          ,
	    output  logic              e_reset_n         ,  // external reset
	    output  logic              p_reset_n         ,  // power-on reset
        output  logic              s_reset_n         ,  // soft reset
        output  logic              cfg_strap_pad_ctrl,
	    output  logic [31:0]       system_strap      ,
	    input   logic [31:0]       strap_sticky      ,


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
       // Digital PLL I/F
       output logic                cfg_pll_enb      , // Enable PLL
       output logic[4:0]           cfg_pll_fed_div  , // PLL feedback division ratio
       output logic                cfg_dco_mode     , // Run PLL in DCO mode
       output logic[25:0]          cfg_dc_trim      , // External trim for DCO mode
       output logic                pll_ref_clk      , // Input oscillator to match
       input  logic [1:0]          pll_clk_out      , // Two 90 degree clock phases

       input  logic [17:0]         la_data_in       ,

       input  logic                uartm_rxd        ,
       output logic                uartm_txd        ,

       input  logic                sclk             ,
       input  logic                ssn              ,
       input  logic                sdin             ,
       output logic                sdout            ,
       output logic                sdout_oen        ,

       output logic                dbg_clk_mon

    );


//--------------------------------
// local  dec
//
//--------------------------------
logic               wbm_rst_n;
logic               wbs_rst_n;

logic               reg_sel    ;
logic [2:0]         sw_addr    ;
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
logic [15:0]        cfg_bank_sel;
logic [31:0]        reg_0;  // Software_Reg_0
logic [8:0]         cfg_clk_ctrl2;

logic  [31:0]       cfg_pll_ctrl; 
logic  [3:0]        cfg_wb_clk_ctrl;
logic  [3:0]        cfg_cpu_clk_ctrl;
logic  [31:0]       cfg_glb_ctrl;


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

// SPI SLAVE Port
logic               wbm_spi_cyc_i        ;  // strobe/request
logic               wbm_spi_stb_i        ;  // strobe/request
logic [31:0]        wbm_spi_adr_i        ;  // address
logic               wbm_spi_we_i         ;  // write
logic [31:0]        wbm_spi_dat_i        ;  // data output
logic [3:0]         wbm_spi_sel_i        ;  // byte enable
logic [31:0]        wbm_spi_dat_o        ;  // data input
logic               wbm_spi_ack_o        ;  // acknowlegement
logic               wbm_spi_err_o        ;  // error

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

logic [3:0]         cfg_mon_sel           ;
logic               pll_clk_div16         ;
logic               pll_clk_div16_buf     ;
logic [2:0]         cfg_ref_pll_div       ;
logic               arst_n                ;
logic               soft_reboot           ;
logic               clk_enb               ;

assign	  e_reset_n              = wbm_rst_n ;  // sync external reset
assign    cfg_strap_pad_ctrl     = !p_reset_n;

wire      soft_boot_req     = strap_sticky[`STRAP_SOFT_REBOOT_REQ];


//------------------------------------------
// PLL Trim Value
//-----------------------------------------
assign    cfg_dco_mode     = cfg_pll_ctrl[31];
assign    cfg_pll_fed_div  = cfg_pll_ctrl[30:26];
assign    cfg_dc_trim      = cfg_pll_ctrl[25:0];

//assign   int_pll_clock    = pll_clk_out[0];
ctech_clk_buf u_clkbuf_pll     (.A (pll_clk_out[0]), . X(int_pll_clock));
ctech_clk_buf u_clkbuf_pll_div (.A (pll_clk_div16), . X(pll_clk_div16_buf));


// Debug clock monitor optin
assign dbg_clk_mon  = (cfg_mon_sel == 4'b000) ? pll_clk_div16_buf:
	                  (cfg_mon_sel == 4'b001) ? pll_ref_clk  :
	                  (cfg_mon_sel == 4'b010) ? wbs_clk_out  :
	                  (cfg_mon_sel == 4'b011) ? cpu_clk_int  : 1'b0;




//--------------------------------------------------------------------------------
// Look like wishbone reset removed early than user Power up sequence
// To control the reset phase, we have added additional control through la[0]
// ------------------------------------------------------------------------------
assign    arst_n = !wbm_rst_i;
reset_sync  u_wbm_rst (
	          .scan_mode  (1'b0           ),
              .dclk       (wbm_clk_i      ), // Destination clock domain
	          .arst_n     (arst_n         ), // active low async reset
              .srst_n     (wbm_rst_n      )
          );

reset_sync  u_wbs_rst (
	          .scan_mode  (1'b0           ),
              .dclk       (wbs_clk_i      ), // Destination clock domain
	          .arst_n     (s_reset_n      ), // active low async reset
              .srst_n     (wbs_rst_n      )
          );

//------------------------------------------
// Reset FSM
//------------------------------------------
// Keep WBS in Ref clock during initial boot to strap loading 
logic force_refclk;
wb_reset_fsm u_reset_fsm (
	      .clk                 (wbm_clk_i   ),
	      .e_reset_n           (e_reset_n   ),  // external reset
          .cfg_fast_sim        (cfg_fast_sim),
          .soft_boot_req       (soft_boot_req),

	      .p_reset_n           (p_reset_n   ),  // power-on reset
	      .s_reset_n           (s_reset_n   ),  // soft reset
          .clk_enb             (clk_enb     ),
          .soft_reboot         (soft_reboot ),
          .force_refclk        (force_refclk)

);


//-------------------------------------------------
// UART2WB HOST
//    Uart Baud-16x computation
//      Assumption is default wb clock is 40Mhz 
//      For 9600 Baud
//        40,000,000/(9600*16) = 260;
//      Configured Value = 260-1 = 259
//-------------------------------------------------

wire strap_uart_cfg_mode = system_strap[`STRAP_UARTM_CFG];

wire       cfg_uartm_tx_enable   = (strap_uart_cfg_mode==0) ? la_data_in[1]     : 1'b1;
wire       cfg_uartm_rx_enable   = (strap_uart_cfg_mode==0) ? la_data_in[2]     : 1'b1;
wire       cfg_uartm_stop_bit    = (strap_uart_cfg_mode==0) ? la_data_in[3]     : 1'b1;
wire [11:0]cfg_uart_baud_16x     = (strap_uart_cfg_mode==0) ? la_data_in[15:4]  : 258;
wire [1:0] cfg_uartm_cfg_pri_mod = (strap_uart_cfg_mode==0) ? la_data_in[17:16] : 2'b0;


// UART Master
uart2wb u_uart2wb (  
        .arst_n          (s_reset_n               ), //  sync reset
        .app_clk         (wbm_clk_i               ), //  sys clock    

	// configuration control
       .cfg_tx_enable    (cfg_uartm_tx_enable     ), // Enable Transmit Path
       .cfg_rx_enable    (cfg_uartm_rx_enable     ), // Enable Received Path
       .cfg_stop_bit     (cfg_uartm_stop_bit      ), // 0 -> 1 Start , 1 -> 2 Stop Bits
       .cfg_baud_16x     (cfg_uart_baud_16x       ), // 16x Baud clock generation
       .cfg_pri_mod      (cfg_uartm_cfg_pri_mod   ), // priority mode, 0 -> nop, 1 -> Even, 2 -> Odd

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

//----------------------------------------
// SPI as ISP
//----------------------------------------

sspis_top u_spi2wb(

	     .sys_clk         (wbm_clk_i       ),
	     .rst_n           (e_reset_n       ),

         .sclk            (sclk            ),
         .ssn             (ssn             ),
         .sdin            (sdin            ),
         .sdout           (sdout           ),
         .sdout_oen       (sdout_oen       ),

          // WB Master Port
         .wbm_cyc_o       (wbm_spi_cyc_i   ),  // strobe/request
         .wbm_stb_o       (wbm_spi_stb_i   ),  // strobe/request
         .wbm_adr_o       (wbm_spi_adr_i   ),  // address
         .wbm_we_o        (wbm_spi_we_i    ),  // write
         .wbm_dat_o       (wbm_spi_dat_i   ),  // data output
         .wbm_sel_o       (wbm_spi_sel_i   ),  // byte enable
         .wbm_dat_i       (wbm_spi_dat_o   ),  // data input
         .wbm_ack_i       (wbm_spi_ack_o   ),  // acknowlegement
         .wbm_err_i       (wbm_spi_err_o   )   // error
    );

//--------------------------------------------------
// Arbitor to select between external wb vs uart wb vs spi
//---------------------------------------------------
wire [1:0] grnt;
wb_arb u_arb(
	.clk      (wbm_clk_i), 
	.rstn     (s_reset_n), 
	.req      ({1'b0,wbm_spi_stb_i,wbm_uart_stb_i,(wbm_stb_i & wbm_cyc_i)}), 
	.gnt      (grnt)
        );

// Select  the master based on the grant
assign wb_cyc_i = (grnt == 2'b00) ? wbm_cyc_i               :(grnt == 2'b01) ? wbm_uart_cyc_i :wbm_spi_cyc_i; 
assign wb_stb_i = (grnt == 2'b00) ? (wbm_cyc_i & wbm_stb_i) :(grnt == 2'b01) ? wbm_uart_stb_i :wbm_spi_stb_i; 
assign wb_adr_i = (grnt == 2'b00) ? wbm_adr_i               :(grnt == 2'b01) ? wbm_uart_adr_i :wbm_spi_adr_i; 
assign wb_we_i  = (grnt == 2'b00) ? wbm_we_i                :(grnt == 2'b01) ? wbm_uart_we_i  :wbm_spi_we_i ; 
assign wb_dat_i = (grnt == 2'b00) ? wbm_dat_i               :(grnt == 2'b01) ? wbm_uart_dat_i :wbm_spi_dat_i; 
assign wb_sel_i = (grnt == 2'b00) ? wbm_sel_i               :(grnt == 2'b01) ? wbm_uart_sel_i :wbm_spi_sel_i; 

assign wbm_dat_o = (grnt == 2'b00) ? wb_dat_o : 'h0;
assign wbm_ack_o = (grnt == 2'b00) ? wb_ack_o : 'h0;
assign wbm_err_o = (grnt == 2'b00) ? wb_err_o : 'h0;

assign wbm_uart_dat_o = (grnt == 2'b01) ? wb_dat_o : 'h0;
assign wbm_uart_ack_o = (grnt == 2'b01) ? wb_ack_o : 'h0;
assign wbm_uart_err_o = (grnt == 2'b01) ? wb_err_o : 'h0;

assign wbm_spi_dat_o = (grnt == 2'b10) ? wb_dat_o : 'h0;
assign wbm_spi_ack_o = (grnt == 2'b10) ? wb_ack_o : 'h0;
assign wbm_spi_err_o = (grnt == 2'b10) ? wb_err_o : 'h0;




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
always_ff @(negedge s_reset_n or posedge wbm_clk_i) begin
    if ( s_reset_n == 1'b0 ) begin
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
// Local register decide based on address[19] == 1
//
// Locally there register are define to control the reset and clock for user
// area
//-----------------------------------------------------------------------
// caravel user space is 0x3000_0000 to 0x300F_FFFF
// So we have allocated 
// 0x3008_0000 - 0x3008_00FF - Assigned to WB Host Address Space
// Since We need more than 16MB Address space to access SDRAM/SPI we have
// added indirect MSB 13 bit address select option
// So Address will be {Bank_Sel[15:3], wbm_adr_i[18:0]}
// ---------------------------------------------------------------------
assign reg_sel       = wb_req & (wb_adr_i[19] == 1'b1);

assign sw_addr       = wb_adr_i [4:2];
assign sw_rd_en      = reg_sel & !wb_we_i;
assign sw_wr_en      = reg_sel & wb_we_i;

assign  sw_wr_en_0 = sw_wr_en && (sw_addr==0);
assign  sw_wr_en_1 = sw_wr_en && (sw_addr==1);
assign  sw_wr_en_2 = sw_wr_en && (sw_addr==2);
assign  sw_wr_en_3 = sw_wr_en && (sw_addr==3);
assign  sw_wr_en_4 = sw_wr_en && (sw_addr==4);
assign  sw_wr_en_5 = sw_wr_en && (sw_addr==5);

always @ (posedge wbm_clk_i or negedge s_reset_n)
begin : preg_out_Seq
   if (s_reset_n == 1'b0)
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
assign cfg_glb_ctrl     = reg_0[31:0];
// Reset control
// On Power-up wb & pll power default enabled
ctech_buf u_buf_wb_rst        (.A(cfg_glb_ctrl[0] & s_reset_n),.X(wbd_int_rst_n));
ctech_buf u_buf_pll_rst       (.A(cfg_glb_ctrl[1] & s_reset_n),.X(wbd_pll_rst_n));

//assign cfg_fast_sim        = cfg_glb_ctrl[8]; 
ctech_clk_buf u_fastsim_buf (.A (cfg_glb_ctrl[8]), . X(cfg_fast_sim)); // To Bypass Reset FSM initial wait time

assign cfg_pll_enb         = cfg_glb_ctrl[15];
assign cfg_ref_pll_div     = cfg_glb_ctrl[14:12];
assign cfg_mon_sel         = cfg_glb_ctrl[11:8];


assign cfg_wb_clk_ctrl      = cfg_clk_ctrl2[3:0];
assign cfg_cpu_clk_ctrl     = cfg_clk_ctrl2[7:4];


always @( *)
begin 
  reg_out [31:0] = 8'd0;

  case (sw_addr [1:0])
    3'b000 :   reg_out [31:0] = reg_0;
    3'b001 :   reg_out [31:0] = {16'h0,cfg_bank_sel [15:0]};     
    3'b010 :   reg_out [31:0] = cfg_clk_ctrl1 [31:0];    
    3'b011 :   reg_out [31:0] = {24'h0,cfg_clk_ctrl2 [7:0]};    
    3'b100 :   reg_out [31:0] = cfg_pll_ctrl [31:0];     
    3'b101 :   reg_out [31:0] = system_strap [31:0];     
    default : reg_out [31:0] = 'h0;
  endcase
end



generic_register #(32,32'h8003  ) u_glb_ctrl (
	      .we            ({32{sw_wr_en_0}}   ),		 
	      .data_in       (wb_dat_i[31:0]    ),
	      .reset_n       (e_reset_n         ),
	      .clk           (wbm_clk_i         ),
	      
	      //List of Outs
	      .data_out      (reg_0[31:0])
          );

generic_register #(16,16'h1000 ) u_bank_sel (
	      .we            ({16{sw_wr_en_1}}   ),		 
	      .data_in       (wb_dat_i[15:0]    ),
	      .reset_n       (e_reset_n         ),
	      .clk           (wbm_clk_i         ),
	      
	      //List of Outs
	      .data_out      (cfg_bank_sel[15:0] )
          );

//-----------------------------------------------
// clock control-1
//----------------------------------------------

wire [31:0] rst_clk_ctrl1;

assign rst_clk_ctrl1[3:0]   = (strap_sticky[`STRAP_CLK_SKEW_WI] == 2'b00) ?  SKEW_RESET_VAL[3:0] :
                              (strap_sticky[`STRAP_CLK_SKEW_WI] == 2'b01) ?  SKEW_RESET_VAL[3:0] + 2 :
                              (strap_sticky[`STRAP_CLK_SKEW_WI] == 2'b10) ?  SKEW_RESET_VAL[3:0] + 4 : SKEW_RESET_VAL[3:0]-4;

assign rst_clk_ctrl1[7:4]   = (strap_sticky[`STRAP_CLK_SKEW_WH] == 2'b00) ?  SKEW_RESET_VAL[7:4]  :
                              (strap_sticky[`STRAP_CLK_SKEW_WH] == 2'b01) ?  SKEW_RESET_VAL[7:4] + 2 :
                              (strap_sticky[`STRAP_CLK_SKEW_WH] == 2'b10) ?  SKEW_RESET_VAL[7:4] + 4 : SKEW_RESET_VAL[7:4]-4;

assign rst_clk_ctrl1[11:8]  = (strap_sticky[`STRAP_CLK_SKEW_RISCV] == 2'b00) ?  SKEW_RESET_VAL[11:8]  :
                              (strap_sticky[`STRAP_CLK_SKEW_RISCV] == 2'b01) ?  SKEW_RESET_VAL[11:8] + 2 :
                              (strap_sticky[`STRAP_CLK_SKEW_RISCV] == 2'b10) ?  SKEW_RESET_VAL[11:8] + 4 : SKEW_RESET_VAL[11:8]-4;

assign rst_clk_ctrl1[15:12] = (strap_sticky[`STRAP_CLK_SKEW_QSPI] == 2'b00) ?  SKEW_RESET_VAL[15:12]  :
                              (strap_sticky[`STRAP_CLK_SKEW_QSPI] == 2'b01) ?  SKEW_RESET_VAL[15:12] + 2 :
                              (strap_sticky[`STRAP_CLK_SKEW_QSPI] == 2'b10) ?  SKEW_RESET_VAL[15:12] + 4 : SKEW_RESET_VAL[15:12]-4;

assign rst_clk_ctrl1[19:16] = (strap_sticky[`STRAP_CLK_SKEW_UART] == 2'b00) ?  SKEW_RESET_VAL[19:16]  :
                              (strap_sticky[`STRAP_CLK_SKEW_UART] == 2'b01) ?  SKEW_RESET_VAL[19:16] + 2 :
                              (strap_sticky[`STRAP_CLK_SKEW_UART] == 2'b10) ?  SKEW_RESET_VAL[19:16] + 4 : SKEW_RESET_VAL[19:16]-4;

assign rst_clk_ctrl1[23:20] = (strap_sticky[`STRAP_CLK_SKEW_PINMUX] == 2'b00) ?  SKEW_RESET_VAL[23:20]  :
                              (strap_sticky[`STRAP_CLK_SKEW_PINMUX] == 2'b01) ?  SKEW_RESET_VAL[23:20] + 2 :
                              (strap_sticky[`STRAP_CLK_SKEW_PINMUX] == 2'b10) ?  SKEW_RESET_VAL[23:20] + 4 : SKEW_RESET_VAL[23:20]-4;

assign rst_clk_ctrl1[27:24] = (strap_sticky[`STRAP_CLK_SKEW_QSPI_CO] == 2'b00) ?  SKEW_RESET_VAL[27:24] :
                              (strap_sticky[`STRAP_CLK_SKEW_QSPI_CO] == 2'b01) ?  SKEW_RESET_VAL[27:24] + 2 :
                              (strap_sticky[`STRAP_CLK_SKEW_QSPI_CO] == 2'b10) ?  SKEW_RESET_VAL[27:24] + 4 : SKEW_RESET_VAL[27:24]-4;

assign rst_clk_ctrl1[31:28] = 4'b0;


always @ (posedge wbm_clk_i ) begin 
  if (p_reset_n == 1'b0) begin
     cfg_clk_ctrl1  <= rst_clk_ctrl1 ;
  end
  else begin 
     if(sw_wr_en_2 ) 
       cfg_clk_ctrl1   <= wb_dat_i[31:0];
  end
end

//--------------------------------
// clock control-2
//--------------------------------
always @ (posedge wbm_clk_i) begin 
  if (p_reset_n == 1'b0) begin
     cfg_clk_ctrl2  <= strap_sticky[7:0] ;
  end
  else begin 
     if(sw_wr_en_3 ) 
       cfg_clk_ctrl2   <= wb_dat_i[7:0];
  end
end
//--------------------------------
// Pll Control
//--------------------------------
// PLL clock : 199.680 Mhz Period: 5.008 & bcount: 7, period
// cfg_dc_trim = 26'b0000000000000_1010101101001
// cfg_pll_fed_div = 5'b00000
// cfg_dco_mode    = 1'b1

generic_register #(32,{1'b1,5'b00000,26'b0000000000000_1010101101001} ) u_pll_ctrl (
	      .we            ({32{sw_wr_en_4}}  ),		 
	      .data_in       (wb_dat_i[31:0]   ),
	      .reset_n       (e_reset_n         ),
	      .clk           (wbm_clk_i         ),
	      
	      //List of Outs
	      .data_out      (cfg_pll_ctrl[31:0])
          );


always @ (posedge wbm_clk_i ) begin 
  if (p_reset_n == 1'b0) begin
     cfg_clk_ctrl2  <= strap_sticky[7:0] ;
  end
  else begin 
     if(sw_wr_en_3 ) 
       cfg_clk_ctrl2   <= wb_dat_i[7:0];
  end
end
//-------------------------------------------------------------
// Note: system_strap reset (p_reset_n) will be released
//     eariler than s_reset_n to take care of strap loading
//--------------------------------------------------------------
always @ (posedge wbm_clk_i) begin 
  if (s_reset_n == 1'b0) begin
     system_strap  <= {soft_reboot,strap_sticky[30:0]};
  end
  else if(sw_wr_en_5 ) begin
       system_strap   <= wb_dat_i;
  end
end


//--------------------- End of Register Bank  ------------------------


assign wb_stb_int = wb_req & !reg_sel;

// Since design need more than 16MB address space, we have implemented
// indirect access
assign wb_adr_int = {cfg_bank_sel[15:3],wb_adr_i[18:0]};  

async_wb u_async_wb(
// Master Port
       .wbm_rst_n   (s_reset_n     ),  
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

// PLL Ref CLock

clk_ctl #(2) u_pll_ref_clk (
   // Outputs
       .clk_o         (pll_ref_clk      ),
   // Inputs
       .mclk          (user_clock1      ),
       .reset_n       (e_reset_n        ), 
       .clk_div_ratio (cfg_ref_pll_div  )
   );

// PLL DIv16 to debug monitor purpose

clk_ctl #(3) u_pllclk (
   // Outputs
       .clk_o         (pll_clk_div16    ),
   // Inputs
       .mclk          (int_pll_clock    ),
       .reset_n       (e_reset_n        ), 
       .clk_div_ratio (4'hF )
   );

//----------------------------------
// Generate Internal WishBone Clock
//----------------------------------
logic         wb_clk_div;
logic         wbs_ref_clk_int;
logic         wbs_ref_clk;

wire  [1:0]   cfg_wb_clk_src_sel   =  cfg_wb_clk_ctrl[1:0];
wire  [1:0]   cfg_wb_clk_ratio     =  cfg_wb_clk_ctrl[3:2];

 // Keep WBS in Ref clock during initial boot to strap loading 
assign wbs_ref_clk_int = (cfg_wb_clk_src_sel ==2'b00) ? user_clock1 :
                         (cfg_wb_clk_src_sel ==2'b01) ? user_clock2 :	
                         (cfg_wb_clk_src_sel ==2'b10) ? int_pll_clock :	xtal_clk;

ctech_clk_buf u_wbs_ref_clkbuf (.A (wbs_ref_clk_int), . X(wbs_ref_clk));
ctech_clk_gate u_clkgate_wbs (.GATE (clk_enb), . CLK(wbs_clk_div), .GCLK(wbs_clk_out));

assign wbs_clk_div   =(force_refclk)             ? user_clock1 :
                      (cfg_wb_clk_ratio == 2'b00) ? wbs_ref_clk :
                      (cfg_wb_clk_ratio == 2'b01) ? wbs_ref_clk_div_2 :
                      (cfg_wb_clk_ratio == 2'b10) ? wbs_ref_clk_div_4 : wbs_ref_clk_div_8;

clk_div8  u_wbclk (
   // Outputs
       .clk_div_8     (wbs_ref_clk_div_8      ),
       .clk_div_4     (wbs_ref_clk_div_4      ),
       .clk_div_2     (wbs_ref_clk_div_2      ),
   // Inputs
       .mclk          (wbs_ref_clk            ),
       .reset_n       (p_reset_n              ) 
   );


//----------------------------------
// Generate CORE Clock Generation
//----------------------------------
wire   cpu_clk_div;
wire   cpu_ref_clk_int;
wire   cpu_ref_clk;
wire   cpu_clk_int;

wire [1:0] cfg_cpu_clk_src_sel   = cfg_cpu_clk_ctrl[1:0];
wire [1:0] cfg_cpu_clk_ratio     = cfg_cpu_clk_ctrl[3:2];

assign cpu_ref_clk_int = (cfg_cpu_clk_src_sel ==2'b00) ? user_clock1 :
                         (cfg_cpu_clk_src_sel ==2'b01) ? user_clock2 :	
                         (cfg_cpu_clk_src_sel ==2'b10) ? int_pll_clock : xtal_clk;	

ctech_clk_buf u_cpu_ref_clkbuf (.A (cpu_ref_clk_int), . X(cpu_ref_clk));

ctech_clk_gate u_clkgate_cpu (.GATE (clk_enb), . CLK(cpu_clk_div), .GCLK(cpu_clk));

assign cpu_clk_div   = (cfg_wb_clk_ratio == 2'b00) ? cpu_ref_clk :
                       (cfg_wb_clk_ratio == 2'b01) ? cpu_ref_clk_div_2 :
                       (cfg_wb_clk_ratio == 2'b10) ? cpu_ref_clk_div_4 : cpu_ref_clk_div_8;


clk_div8 u_cpuclk (
   // Outputs
       .clk_div_8     (cpu_ref_clk_div_8      ),
       .clk_div_4     (cpu_ref_clk_div_4      ),
       .clk_div_2     (cpu_ref_clk_div_2      ),
   // Inputs
       .mclk          (cpu_ref_clk            ),
       .reset_n       (p_reset_n              )
   );
endmodule
