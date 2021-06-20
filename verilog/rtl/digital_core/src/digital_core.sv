//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Digital core                                                ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  http://www.opencores.org/cores/yifive/                      ////
////                                                              ////
////  Description                                                 ////
////      This is digital core and integrate all the main block   ////
////      here.  Following block are integrated here              ////
////      1. Risc V Core                                          ////
////      2. SPI Master                                           ////
////      3. Wishbone Cross Bar                                   ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 16th Feb 2021, Dinesh A                             ////
////          Initial integration with Risc-V core +              ////
////          Wishbone Cross Bar + SPI  Master                    ////
////    0.2 - 17th June 2021, Dinesh A                            ////
////        1. In risc core, wishbone and core domain is          ////
////           created                                            ////
////        2. cpu and rtc clock are generated in glbl reg block  ////
////        3. in wishbone interconnect:- Stagging flop are added ////
////           at interface to break wishbone timing path         ////
////        4. buswidth warning are fixed inside spi_master       ////
////        modified rtl files are                                ////
////           verilog/rtl/digital_core/src/digital_core.sv       ////
///            verilog/rtl/digital_core/src/glbl_cfg.sv           ////
///            verilog/rtl/lib/wb_stagging.sv                     ////
///            verilog/rtl/syntacore/scr1/src/top/scr1_dmem_wb.sv ////
///            verilog/rtl/syntacore/scr1/src/top/scr1_imem_wb.sv ////
///            verilog/rtl/syntacore/scr1/src/top/scr1_top_wb.sv  ////
///            verilog/rtl/user_project_wrapper.v                 ////
///            verilog/rtl/wb_interconnect/src/wb_interconnect.sv ////
///            verilog/rtl/spi_master/src/spim_clkgen.sv          ////
///            verilog/rtl/spi_master/src/spim_ctrl.sv            ////
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

`include "scr1_arch_description.svh"
`ifdef SCR1_IPIC_EN
`include "scr1_ipic.svh"
`endif // SCR1_IPIC_EN

`include "sdrc_define.v"
module digital_core 
#(
	parameter      SDR_DW   = 8,  // SDR Data Width 
        parameter      SDR_BW   = 1,  // SDR Byte Width
	parameter      WB_WIDTH = 32  // WB ADDRESS/DARA WIDTH
 ) (
`ifdef USE_POWER_PINS
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
`endif
    input   logic                       wb_clk_i        ,  // System clock
    input   logic                       user_clock2     ,  // user Clock
    input   logic                       wb_rst_i        ,  // Regular Reset signal

    input   logic                       wbd_ext_cyc_i   ,  // strobe/request
    input   logic                       wbd_ext_stb_i   ,  // strobe/request
    input   logic [WB_WIDTH-1:0]        wbd_ext_adr_i   ,  // address
    input   logic                       wbd_ext_we_i    ,  // write
    input   logic [WB_WIDTH-1:0]        wbd_ext_dat_i   ,  // data output
    input   logic [3:0]                 wbd_ext_sel_i   ,  // byte enable
    output  logic [WB_WIDTH-1:0]        wbd_ext_dat_o   ,  // data input
    output  logic                       wbd_ext_ack_o   ,  // acknowlegement
    output  logic                       wbd_ext_err_o   ,  // error

 
    // Logic Analyzer Signals
    input  logic [127:0]                la_data_in      ,
    output logic [127:0]                la_data_out     ,
    input  logic [127:0]                la_oenb         ,
 

    // IOs
    input  logic  [37:0]                io_in           ,
    output logic  [37:0]                io_out          ,
    output logic  [37:0]                io_oeb          ,

    output logic  [2:0]                 user_irq             

);

//---------------------------------------------------
// Local Parameter Declaration
// --------------------------------------------------


//---------------------------------------------------------------------
// Wishbone Risc V Instruction Memory Interface
//---------------------------------------------------------------------
logic                           wbd_riscv_imem_stb_i; // strobe/request
logic   [WB_WIDTH-1:0]          wbd_riscv_imem_adr_i; // address
logic                           wbd_riscv_imem_we_i;  // write
logic   [WB_WIDTH-1:0]          wbd_riscv_imem_dat_i; // data output
logic   [3:0]                   wbd_riscv_imem_sel_i; // byte enable
logic   [WB_WIDTH-1:0]          wbd_riscv_imem_dat_o; // data input
logic                           wbd_riscv_imem_ack_o; // acknowlegement
logic                           wbd_riscv_imem_err_o;  // error

//---------------------------------------------------------------------
// RISC V Wishbone Data Memory Interface
//---------------------------------------------------------------------
logic                           wbd_riscv_dmem_stb_i; // strobe/request
logic   [WB_WIDTH-1:0]          wbd_riscv_dmem_adr_i; // address
logic                           wbd_riscv_dmem_we_i;  // write
logic   [WB_WIDTH-1:0]          wbd_riscv_dmem_dat_i; // data output
logic   [3:0]                   wbd_riscv_dmem_sel_i; // byte enable
logic   [WB_WIDTH-1:0]          wbd_riscv_dmem_dat_o; // data input
logic                           wbd_riscv_dmem_ack_o; // acknowlegement
logic                           wbd_riscv_dmem_err_o; // error

//---------------------------------------------------------------------
//    SPI Master Wishbone Interface
//---------------------------------------------------------------------
logic                           wbd_spim_stb_o; // strobe/request
logic   [WB_WIDTH-1:0]          wbd_spim_adr_o; // address
logic                           wbd_spim_we_o;  // write
logic   [WB_WIDTH-1:0]          wbd_spim_dat_o; // data output
logic   [3:0]                   wbd_spim_sel_o; // byte enable
logic                           wbd_spim_cyc_o ;
logic   [WB_WIDTH-1:0]          wbd_spim_dat_i; // data input
logic                           wbd_spim_ack_i; // acknowlegement
logic                           wbd_spim_err_i;  // error

//---------------------------------------------------------------------
//    SPI Master Wishbone Interface
//---------------------------------------------------------------------
logic                           wbd_sdram_stb_o ;
logic [WB_WIDTH-1:0]            wbd_sdram_adr_o ;
logic                           wbd_sdram_we_o  ; // 1 - Write, 0 - Read
logic [WB_WIDTH-1:0]            wbd_sdram_dat_o ;
logic [WB_WIDTH/8-1:0]          wbd_sdram_sel_o ; // Byte enable
logic                           wbd_sdram_cyc_o ;
logic  [2:0]                    wbd_sdram_cti_o ;
logic  [WB_WIDTH-1:0]           wbd_sdram_dat_i ;
logic                           wbd_sdram_ack_i ;

//---------------------------------------------------------------------
//    Global Register Wishbone Interface
//---------------------------------------------------------------------
logic                           wbd_glbl_stb_o; // strobe/request
logic   [7:0]                   wbd_glbl_adr_o; // address
logic                           wbd_glbl_we_o;  // write
logic   [WB_WIDTH-1:0]          wbd_glbl_dat_o; // data output
logic   [3:0]                   wbd_glbl_sel_o; // byte enable
logic                           wbd_glbl_cyc_o ;
logic   [WB_WIDTH-1:0]          wbd_glbl_dat_i; // data input
logic                           wbd_glbl_ack_i; // acknowlegement
logic                           wbd_glbl_err_i;  // error


//----------------------------------------------------
//  CPU Configuration
//----------------------------------------------------
logic                              cpu_rst_n     ;
logic                              spi_rst_n     ;
logic                              sdram_rst_n   ;

logic [31:0]                       fuse_mhartid  ;
logic [15:0]                       irq_lines     ;
logic                              soft_irq      ;

//------------------------------------------------
// Configuration Parameter
//------------------------------------------------
logic [1:0]                        cfg_sdr_width       ; // 2'b00 - 32 Bit SDR, 2'b01 - 16 Bit SDR, 2'b1x - 8 Bit
logic [1:0]                        cfg_colbits         ; // 2'b00 - 8 Bit column address, 
logic                              sdr_init_done       ; // Indicate SDRAM Initialisation Done
logic [3:0] 		           cfg_sdr_tras_d      ; // Active to precharge delay
logic [3:0]                        cfg_sdr_trp_d       ; // Precharge to active delay
logic [3:0]                        cfg_sdr_trcd_d      ; // Active to R/W delay
logic 			           cfg_sdr_en          ; // Enable SDRAM controller
logic [1:0] 		           cfg_req_depth       ; // Maximum Request accepted by SDRAM controller
logic [12:0] 		           cfg_sdr_mode_reg    ;
logic [2:0] 		           cfg_sdr_cas         ; // SDRAM CAS Latency
logic [3:0] 		           cfg_sdr_trcar_d     ; // Auto-refresh period
logic [3:0]                        cfg_sdr_twr_d       ; // Write recovery delay
logic [`SDR_RFSH_TIMER_W-1 : 0]    cfg_sdr_rfsh        ;
logic [`SDR_RFSH_ROW_CNT_W -1 : 0] cfg_sdr_rfmax       ;

//----------------------------------------------------------------------
// Interface to SDRAMs 
//--------------------------------------------------------------------------
logic                              sdr_cke             ;  // SDRAM CKE
logic			           sdr_cs_n            ;  // SDRAM Chip Select
logic                              sdr_ras_n           ;  // SDRAM ras
logic                              sdr_cas_n           ;  // SDRAM cas
logic			           sdr_we_n            ;  // SDRAM write enable
logic [SDR_BW-1:0] 	           sdr_dqm             ;  // SDRAM Data Mask
logic [1:0] 		           sdr_ba              ;  // SDRAM Bank Enable
logic [12:0] 		           sdr_addr            ;  // SDRAM Address
logic [SDR_DW-1:0] 	           pad_sdr_din         ;  // SDRA Data Input
logic [SDR_DW-1:0] 	           sdr_dout            ;  // SDRA Data output
logic [SDR_BW-1:0] 	           sdr_den_n           ;  // SDRAM Data Output enable
logic                              sdram_clk           ;  // Sdram clock loop back from pad
logic                              pad_sdram_clk       ;  // Sdram clock loop back from pad


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
assign pad_sdram_clk         =      io_in[29]          ;

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



//-----------------------------------------------------------
//  SPI I/F
//  ////////////////////////////////////////////////////
logic                          spim_sdo0               ; // SPI Master Data Out[0]
logic                          spim_sdo1               ; // SPI Master Data Out[1]
logic                          spim_sdo2               ; // SPI Master Data Out[2]
logic                          spim_sdo3               ; // SPI Master Data Out[3]
logic                          spim_sdi0               ; // SPI Master Data In[0]
logic                          spim_sdi1               ; // SPI Master Data In[1]
logic                          spim_sdi2               ; // SPI Master Data In[2]
logic                          spim_sdi3               ; // SPI Master Data In[3]
logic                          spim_clk                ;
logic                          spim_csn                ;
logic                          spi_en_tx               ;

assign  spim_sdi0  =  io_in[32];
assign  spim_sdi1  =  io_in[33];
assign  spim_sdi2  =  io_in[34];
assign  spim_sdi3  =  io_in[35];

assign  io_out[30] =  spim_clk;
assign  io_out[31] =  spim_csn;
assign  io_out[32] =  spim_sdo0;
assign  io_out[33] =  spim_sdo1;
assign  io_out[34] =  spim_sdo2;
assign  io_out[35] =  spim_sdo3;
   
assign  io_oeb[30] =  1'b0;         // spi_clk
assign  io_oeb[31] =  1'b0;         // spi_csn
assign  io_oeb[32] =  !spi_en_tx;   // spi_dio0
assign  io_oeb[33] =  !spi_en_tx;   // spi_dio1
assign  io_oeb[34] =  !spi_en_tx;   // spi_dio2
assign  io_oeb[35] =  !spi_en_tx;   // spi_dio3


// for uart
assign  io_oeb[36] =  1'b1; // Unused
assign  io_oeb[37] =  1'b1; // Unused


wire wb_rst_n = !wb_rst_i;


//------------------------------------------------------------------------------
// RISC V Core instance
//------------------------------------------------------------------------------
scr1_top_wb u_riscv_top (
    // Reset
    .pwrup_rst_n            (wb_rst_n                  ),
    .rst_n                  (wb_rst_n                  ),
    .cpu_rst_n              (cpu_rst_n                 ),
`ifdef SCR1_DBG_EN
    .sys_rst_n_o            (sys_rst_n_o               ),
    .sys_rdc_qlfy_o         (sys_rdc_qlfy_o            ),
`endif // SCR1_DBG_EN

    // Clock
    .core_clk               (cpu_clk                   ),
    .rtc_clk                (rtc_clk                   ),

    // Fuses
    .fuse_mhartid           (fuse_mhartid              ),
`ifdef SCR1_DBG_EN
    .fuse_idcode            (`SCR1_TAP_IDCODE          ),
`endif // SCR1_DBG_EN

    // IRQ
`ifdef SCR1_IPIC_EN
    .irq_lines              (irq_lines                 ), 
`else // SCR1_IPIC_EN
    .ext_irq                (ext_irq                   ), // TODO - Interrupts
`endif // SCR1_IPIC_EN
    .soft_irq               (soft_irq                  ), // TODO - Interrupts

    // DFT
    .test_mode              (1'b0                      ),
    .test_rst_n             (1'b1                      ),

`ifdef SCR1_DBG_EN
    // JTAG
    .trst_n                 (trst_n                    ),
    .tck                    (tck                       ),
    .tms                    (tms                       ),
    .tdi                    (tdi                       ),
    .tdo                    (tdo                       ),
    .tdo_en                 (tdo_en                    ),
`endif // SCR1_DBG_EN

    
    .wb_rst_n               (wb_rst_n                  ),
    .wb_clk                 (wb_clk_i                  ),
    // Instruction memory interface
    .wbd_imem_stb_o         (wbd_riscv_imem_stb_i      ),
    .wbd_imem_adr_o         (wbd_riscv_imem_adr_i      ),
    .wbd_imem_we_o          (wbd_riscv_imem_we_i       ), 
    .wbd_imem_dat_o         (wbd_riscv_imem_dat_i      ),
    .wbd_imem_sel_o         (wbd_riscv_imem_sel_i      ),
    .wbd_imem_dat_i         (wbd_riscv_imem_dat_o      ),
    .wbd_imem_ack_i         (wbd_riscv_imem_ack_o      ),
    .wbd_imem_err_i         (wbd_riscv_imem_err_o      ),

    // Data memory interface
    .wbd_dmem_stb_o         (wbd_riscv_dmem_stb_i      ),
    .wbd_dmem_adr_o         (wbd_riscv_dmem_adr_i      ),
    .wbd_dmem_we_o          (wbd_riscv_dmem_we_i       ), 
    .wbd_dmem_dat_o         (wbd_riscv_dmem_dat_i      ),
    .wbd_dmem_sel_o         (wbd_riscv_dmem_sel_i      ),
    .wbd_dmem_dat_i         (wbd_riscv_dmem_dat_o      ),
    .wbd_dmem_ack_i         (wbd_riscv_dmem_ack_o      ),
    .wbd_dmem_err_i         (wbd_riscv_dmem_err_o      ) 
);

/*********************************************************
* SPI Master
* This is an implementation of an SPI master that is controlled via an AXI bus. 
* It has FIFOs for transmitting and receiving data. 
* It supports both the normal SPI mode and QPI mode with 4 data lines.
* *******************************************************/

spim_top
#(
`ifndef SYNTHESIS
    .WB_WIDTH  (WB_WIDTH)
`endif
) u_spi_master
(
    .mclk                   (wb_clk_i                  ),
    .rst_n                  (spi_rst_n                 ),

    .wbd_stb_i              (wbd_spim_stb_o            ),
    .wbd_adr_i              (wbd_spim_adr_o            ),
    .wbd_we_i               (wbd_spim_we_o             ), 
    .wbd_dat_i              (wbd_spim_dat_o            ),
    .wbd_sel_i              (wbd_spim_sel_o            ),
    .wbd_dat_o              (wbd_spim_dat_i            ),
    .wbd_ack_o              (wbd_spim_ack_i            ),
    .wbd_err_o              (wbd_spim_err_i            ),

    .events_o               (                          ), // TODO - Need to connect to intr ?

    .spi_clk                (spim_clk                  ),
    .spi_csn0               (spim_csn                  ),
    .spi_csn1               (                          ),
    .spi_csn2               (                          ),
    .spi_csn3               (                          ),
    .spi_mode               (                          ),
    .spi_sdo0               (spim_sdo0                 ),
    .spi_sdo1               (spim_sdo1                 ),
    .spi_sdo2               (spim_sdo2                 ),
    .spi_sdo3               (spim_sdo3                 ),
    .spi_sdi0               (spim_sdi0                 ),
    .spi_sdi1               (spim_sdi1                 ),
    .spi_sdi2               (spim_sdi2                 ),
    .spi_sdi3               (spim_sdi3                 ),
    .spi_en_tx              (spi_en_tx                 )
);


sdrc_top  
    `ifndef SYNTHESIS
    #(.APP_AW(WB_WIDTH), 
	    .APP_DW(WB_WIDTH), 
	    .APP_BW(4),
	    .SDR_DW(8), 
	    .SDR_BW(1))
      `endif
     u_sdram_ctrl (
    .cfg_sdr_width          (cfg_sdr_width              ),
    .cfg_colbits            (cfg_colbits                ),
                    
    // WB bus
    .wb_rst_i               (wb_rst_i                   ),
    .wb_clk_i               (wb_clk_i                   ),
    
    .wb_stb_i               (wbd_sdram_stb_o            ),
    .wb_addr_i              (wbd_sdram_adr_o            ),
    .wb_we_i                (wbd_sdram_we_o             ),
    .wb_dat_i               (wbd_sdram_dat_o            ),
    .wb_sel_i               (wbd_sdram_sel_o            ),
    .wb_cyc_i               (wbd_sdram_cyc_o            ),
    .wb_cti_i               (wbd_sdram_cti_o            ), 
    .wb_ack_o               (wbd_sdram_ack_i            ),
    .wb_dat_o               (wbd_sdram_dat_i            ),

		
    /* Interface to SDRAMs */
    .sdram_clk              (sdram_clk                 ),
    .sdram_resetn           (sdram_rst_n               ),
    .sdr_cs_n               (sdr_cs_n                  ),
    .sdr_cke                (sdr_cke                   ),
    .sdr_ras_n              (sdr_ras_n                 ),
    .sdr_cas_n              (sdr_cas_n                 ),
    .sdr_we_n               (sdr_we_n                  ),
    .sdr_dqm                (sdr_dqm                   ),
    .sdr_ba                 (sdr_ba                    ),
    .sdr_addr               (sdr_addr                  ), 
    .pad_sdr_din            (pad_sdr_din               ), 
    .sdr_dout               (sdr_dout                  ), 
    .sdr_den_n              (sdr_den_n                 ),
    .sdram_pad_clk          (pad_sdram_clk             ),
                    
    /* Parameters */
    .sdr_init_done          (sdr_init_done             ),
    .cfg_req_depth          (cfg_req_depth             ), //how many req. buffer should hold
    .cfg_sdr_en             (cfg_sdr_en                ),
    .cfg_sdr_mode_reg       (cfg_sdr_mode_reg          ),
    .cfg_sdr_tras_d         (cfg_sdr_tras_d            ),
    .cfg_sdr_trp_d          (cfg_sdr_trp_d             ),
    .cfg_sdr_trcd_d         (cfg_sdr_trcd_d            ),
    .cfg_sdr_cas            (cfg_sdr_cas               ),
    .cfg_sdr_trcar_d        (cfg_sdr_trcar_d           ),
    .cfg_sdr_twr_d          (cfg_sdr_twr_d             ),
    .cfg_sdr_rfsh           (cfg_sdr_rfsh              ),
    .cfg_sdr_rfmax          (cfg_sdr_rfmax             )
   );


wb_interconnect  u_intercon (
         .clk_i         (wb_clk_i              ), 
         .rst_n         (wb_rst_n              ),
         
         // Master 0 Interface
         .m0_wbd_dat_i  (wbd_riscv_imem_dat_i  ),
         .m0_wbd_adr_i  (wbd_riscv_imem_adr_i  ),
         .m0_wbd_sel_i  (wbd_riscv_imem_sel_i  ),
         .m0_wbd_we_i   (wbd_riscv_imem_we_i   ),
         .m0_wbd_cyc_i  (wbd_riscv_imem_stb_i  ),
         .m0_wbd_stb_i  (wbd_riscv_imem_stb_i  ),
         .m0_wbd_dat_o  (wbd_riscv_imem_dat_o  ),
         .m0_wbd_ack_o  (wbd_riscv_imem_ack_o  ),
         .m0_wbd_err_o  (wbd_riscv_imem_err_o  ),
         
         // Master 1 Interface
         .m1_wbd_dat_i  (wbd_riscv_dmem_dat_i  ),
         .m1_wbd_adr_i  (wbd_riscv_dmem_adr_i  ),
         .m1_wbd_sel_i  (wbd_riscv_dmem_sel_i  ),
         .m1_wbd_we_i   (wbd_riscv_dmem_we_i   ),
         .m1_wbd_cyc_i  (wbd_riscv_dmem_stb_i  ),
         .m1_wbd_stb_i  (wbd_riscv_dmem_stb_i  ),
         .m1_wbd_dat_o  (wbd_riscv_dmem_dat_o  ),
         .m1_wbd_ack_o  (wbd_riscv_dmem_ack_o  ),
         .m1_wbd_err_o  (wbd_riscv_dmem_err_o  ),
         
         // Master 2 Interface
         .m2_wbd_dat_i  (wbd_ext_dat_i  ),
         .m2_wbd_adr_i  (wbd_ext_adr_i  ),
         .m2_wbd_sel_i  (wbd_ext_sel_i  ),
         .m2_wbd_we_i   (wbd_ext_we_i   ),
         .m2_wbd_cyc_i  (wbd_ext_cyc_i  ),
         .m2_wbd_stb_i  (wbd_ext_stb_i  ),
         .m2_wbd_dat_o  (wbd_ext_dat_o  ),
         .m2_wbd_ack_o  (wbd_ext_ack_o  ),
         .m2_wbd_err_o  (wbd_ext_err_o  ),
         
         
         // Slave 0 Interface
         .s0_wbd_err_i  (1'b0           ),
         .s0_wbd_dat_i  (wbd_spim_dat_i ),
         .s0_wbd_ack_i  (wbd_spim_ack_i ),
         .s0_wbd_dat_o  (wbd_spim_dat_o ),
         .s0_wbd_adr_o  (wbd_spim_adr_o ),
         .s0_wbd_sel_o  (wbd_spim_sel_o ),
         .s0_wbd_we_o   (wbd_spim_we_o  ),  
         .s0_wbd_cyc_o  (wbd_spim_cyc_o ),
         .s0_wbd_stb_o  (wbd_spim_stb_o ),
         
         // Slave 1 Interface
         .s1_wbd_err_i  (1'b0           ),
         .s1_wbd_dat_i  (wbd_sdram_dat_i ),
         .s1_wbd_ack_i  (wbd_sdram_ack_i ),
         .s1_wbd_dat_o  (wbd_sdram_dat_o ),
         .s1_wbd_adr_o  (wbd_sdram_adr_o ),
         .s1_wbd_sel_o  (wbd_sdram_sel_o ),
         .s1_wbd_we_o   (wbd_sdram_we_o  ),  
         .s1_wbd_cyc_o  (wbd_sdram_cyc_o ),
         .s1_wbd_stb_o  (wbd_sdram_stb_o ),
         
         // Slave 2 Interface
         .s2_wbd_err_i  (1'b0           ),
         .s2_wbd_dat_i  (wbd_glbl_dat_i ),
         .s2_wbd_ack_i  (wbd_glbl_ack_i ),
         .s2_wbd_dat_o  (wbd_glbl_dat_o ),
         .s2_wbd_adr_o  (wbd_glbl_adr_o ),
         .s2_wbd_sel_o  (wbd_glbl_sel_o ),
         .s2_wbd_we_o   (wbd_glbl_we_o  ),  
         .s2_wbd_cyc_o  (wbd_glbl_cyc_o ),
         .s2_wbd_stb_o  (wbd_glbl_stb_o )
	);

glbl_cfg   u_glbl_cfg (

       .mclk                   (wb_clk_i                  ),
       .reset_n                (wb_rst_n                  ),
       .user_clock2            (user_clock2               ),
       .device_idcode          (                          ),

        // Reg Bus Interface Signal
       .reg_cs                 (wbd_glbl_stb_o            ),
       .reg_wr                 (wbd_glbl_we_o             ),
       .reg_addr               (wbd_glbl_adr_o            ),
       .reg_wdata              (wbd_glbl_dat_o            ),
       .reg_be                 (wbd_glbl_sel_o            ),

       // Outputs
       .reg_rdata              (wbd_glbl_dat_i            ),
       .reg_ack                (wbd_glbl_ack_i            ),

       // SDRAM Clock

       .sdram_clk              (sdram_clk                 ),
       .cpu_clk                (cpu_clk                   ),
       .rtc_clk                (rtc_clk                   ),

       // reset
       .cpu_rst_n              (cpu_rst_n                 ),
       .spi_rst_n              (spi_rst_n                 ),
       .sdram_rst_n            (sdram_rst_n               ),

       // Risc configuration
       .fuse_mhartid           (fuse_mhartid              ),
       .irq_lines              (irq_lines                 ), 
       .soft_irq               (soft_irq                  ),
       .user_irq               (user_irq                  ),

       // SDRAM Config
       .cfg_sdr_width          (cfg_sdr_width             ),
       .cfg_colbits            (cfg_colbits               ),

	/* Parameters */
       .sdr_init_done          (sdr_init_done             ),
       .cfg_req_depth          (cfg_req_depth             ), //how many req. buffer should hold
       .cfg_sdr_en             (cfg_sdr_en                ),
       .cfg_sdr_mode_reg       (cfg_sdr_mode_reg          ),
       .cfg_sdr_tras_d         (cfg_sdr_tras_d            ),
       .cfg_sdr_trp_d          (cfg_sdr_trp_d             ),
       .cfg_sdr_trcd_d         (cfg_sdr_trcd_d            ),
       .cfg_sdr_cas            (cfg_sdr_cas               ),
       .cfg_sdr_trcar_d        (cfg_sdr_trcar_d           ),
       .cfg_sdr_twr_d          (cfg_sdr_twr_d             ),
       .cfg_sdr_rfsh           (cfg_sdr_rfsh              ),
       .cfg_sdr_rfmax          (cfg_sdr_rfmax             )


        );



endmodule : digital_core
