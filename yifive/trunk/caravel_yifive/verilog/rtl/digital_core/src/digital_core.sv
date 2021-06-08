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
    input   logic                      clk,              // System clock
    input   logic                      rtc_clk,          // Real-time clock
    input   logic                      pwrup_rst_n,      // Power-Up Reset
    input   logic                      cpu_rst_n,        // CPU Reset (Core Reset)
    input logic                        rst_n,            // Regular Reset signal

`ifdef SCR1_DBG_EN
    output  logic                      sys_rst_n_o,      // External System Reset output
                                                         //   (for the processor cluster's components or
                                                         //    external SOC (could be useful in small
                                                         //    SCR-core-centric SOCs))
    output  logic                      sys_rdc_qlfy_o,   // System-to-External SOC Reset Domain Crossing Qualifier
`endif // SCR1_DBG_EN
    // Fuses
    input   logic [`SCR1_XLEN-1:0]     fuse_mhartid,     // Hart ID

`ifdef SCR1_DBG_EN
    input   logic [31:0]               fuse_idcode,            // TAPC IDCODE
`endif // SCR1_DBG_EN
    // IRQ
`ifdef SCR1_IPIC_EN
    input   logic [SCR1_IRQ_LINES_NUM-1:0]          irq_lines,              // IRQ lines to IPIC
`else // SCR1_IPIC_EN
    input   logic                     ext_irq,                // External IRQ input
`endif // SCR1_IPIC_EN
    input   logic                     soft_irq,               // Software IRQ input

`ifdef SCR1_DBG_EN
    // -- JTAG I/F
    input   logic                       trst_n,
    input   logic                       tck,
    input   logic                       tms,
    input   logic                       tdi,
    output  logic                       tdo,
    output  logic                       tdo_en,
`endif // SCR1_DBG_EN
    input   logic                       wbd_ext_stb_i, // strobe/request
    input   logic [WB_WIDTH-1:0]        wbd_ext_adr_i, // address
    input   logic                       wbd_ext_we_i,  // write
    input   logic [WB_WIDTH-1:0]        wbd_ext_dat_i, // data output
    input   logic [3:0]                 wbd_ext_sel_i, // byte enable
    output  logic [WB_WIDTH-1:0]        wbd_ext_dat_o, // data input
    output  logic                       wbd_ext_ack_o, // acknowlegement
    output  logic                       wbd_ext_err_o,  // error

    /* Interface to SDRAMs */
    output  logic                       sdr_cke,      // SDRAM CKE
    output  logic			sdr_cs_n,     // SDRAM Chip Select
    output  logic                       sdr_ras_n,    // SDRAM ras
    output  logic                       sdr_cas_n,    // SDRAM cas
    output  logic			sdr_we_n,     // SDRAM write enable
    output  logic [SDR_BW-1:0] 	        sdr_dqm,      // SDRAM Data Mask
    output  logic [1:0] 		sdr_ba,       // SDRAM Bank Enable
    output  logic [12:0] 		sdr_addr,     // SDRAM Address
    input   logic [SDR_DW-1:0] 	        pad_sdr_din,  // SDRA Data Input
    output  logic [SDR_DW-1:0] 	        sdr_dout,     // SDRA Data output
    output  logic [SDR_BW-1:0] 	        sdr_den_n,    // SDRAM Data Output enable
    input                               sdram_pad_clk,// Sdram clock loop back from pad

    // SPI Master I/F
    output logic                        spim_clk,
    output logic                        spim_csn0,
    output logic                        spim_csn1,
    output logic                        spim_csn2,
    output logic                        spim_csn3,
    output logic       [1:0]            spim_mode,
    input logic        [3:0]            spim_sdi, // SPI Master out
    output logic       [3:0]            spim_sdo,  // SPI Master out
    output logic                        spi_en_tx // SPI Pad directional control

    //inout tri        [3:0]              spim_sdio // SPI Master in/out
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
logic [WB_WIDTH-1:0]            wbd_sdram_addr_o;
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
logic   [WB_WIDTH-1:0]          wbd_glbl_addr_o; // address
logic                           wbd_glbl_we_o;  // write
logic   [WB_WIDTH-1:0]          wbd_glbl_dat_o; // data output
logic   [3:0]                   wbd_glbl_sel_o; // byte enable
logic                           wbd_glbl_cyc_o ;
logic   [WB_WIDTH-1:0]          wbd_glbl_dat_i; // data input
logic                           wbd_glbl_ack_i; // acknowlegement
logic                           wbd_glbl_err_i;  // error
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

//`ifdef VERILATOR // Verilator has limited support for bi-di pad
   assign  spim_sdi0 =   spim_sdi[0];
   assign  spim_sdi1 =   spim_sdi[1];
   assign  spim_sdi2 =   spim_sdi[2];
   assign  spim_sdi3 =   spim_sdi[3];
   
   assign  spim_sdo  =   {spim_sdo3,spim_sdo2,spim_sdo1,spim_sdo0};
//`else 
//   assign  spim_sdi0 =   spim_sdio[0];
//   assign  spim_sdi1 =   spim_sdio[1];
//   assign  spim_sdi2 =   spim_sdio[2];
//   assign  spim_sdi3 =   spim_sdio[3];
//
//   assign  spim_sdio[0]  =  (spi_en_tx) ? spim_sdo0 : 1'bz;
//   assign  spim_sdio[1]  =  (spi_en_tx) ? spim_sdo1 : 1'bz;
//   assign  spim_sdio[2]  =  (spi_en_tx) ? spim_sdo2 : 1'bz;
//   assign  spim_sdio[3]  =  (spi_en_tx) ? spim_sdo3 : 1'bz;
//
//`endif
//------------------------------------------------------------------------------
// RISC V Core instance
//------------------------------------------------------------------------------
scr1_top_wb u_riscv_top (
    // Reset
    .pwrup_rst_n            (pwrup_rst_n               ),
    .rst_n                  (rst_n                     ),
    .cpu_rst_n              (cpu_rst_n                 ),
`ifdef SCR1_DBG_EN
    .sys_rst_n_o            (sys_rst_n_o               ),
    .sys_rdc_qlfy_o         (sys_rdc_qlfy_o            ),
`endif // SCR1_DBG_EN

    // Clock
    .clk                    (clk                       ),
    .rtc_clk                (rtc_clk                   ),

    // Fuses
    .fuse_mhartid           (fuse_mhartid              ),
`ifdef SCR1_DBG_EN
    .fuse_idcode            (`SCR1_TAP_IDCODE          ),
`endif // SCR1_DBG_EN

    // IRQ
`ifdef SCR1_IPIC_EN
    .irq_lines              ('0                        ), // TODO - Interrupts
`else // SCR1_IPIC_EN
    .ext_irq                ('0                        ), // TODO - Interrupts
`endif // SCR1_IPIC_EN
    .soft_irq               ('0                        ), // TODO - Interrupts

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
    .mclk                   (clk                       ),
    .rst_n                  (rst_n                     ),

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
    .spi_csn0               (spim_csn0                 ),
    .spi_csn1               (spim_csn1                 ),
    .spi_csn2               (spim_csn2                 ),
    .spi_csn3               (spim_csn3                 ),
    .spi_mode               (spim_mode                 ),
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


sdrc_top  #(.APP_AW(WB_WIDTH), 
	    .APP_DW(WB_WIDTH), 
	    .APP_BW(4),
	    .SDR_DW(8), 
	    .SDR_BW(1))
     u_sdram_ctrl (
    .cfg_sdr_width          (cfg_sdr_width             ),
    .cfg_colbits            (cfg_colbits               ),
                    
    // WB bus
    .wb_rst_i               (rst_n                     ),
    .wb_clk_i               (clk                       ),
    
    .wb_stb_i               (wbd_sdram_stb_o            ),
    .wb_addr_i              (wbd_sdram_addr_o           ),
    .wb_we_i                (wbd_sdram_we_o             ),
    .wb_dat_i               (wbd_sdram_dat_o            ),
    .wb_sel_i               (wbd_sdram_sel_o            ),
    .wb_cyc_i               (wbd_sdram_cyc_o            ),
    .wb_cti_i               (wbd_sdram_cti_o            ), 
    .wb_ack_o               (wbd_sdram_ack_i            ),
    .wb_dat_o               (wbd_sdram_dat_i            ),

		
    /* Interface to SDRAMs */
    .sdram_clk              (sdram_clk                 ),
    .sdram_resetn           (sdram_resetn              ),
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
    .sdram_pad_clk          (sdram_pad_clk             ),
                    
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


//------------------------------
// RISC Data Memory Map
// 0x0000_0000 to 0x0FFF_FFFF  - SPI FLASH MEMORY
// 0x1000_0000 to 0x1000_00FF  - SPI REGISTER
// 0x2000_0000 to 0x2FFF_FFFF  - SDRAM
// 0x3000_0000 to 0x3000_00FF  - GLOBAL REGISTER
//-----------------------------
// 
wire [3:0] wbd_riscv_imem_tar_id     = (wbd_riscv_imem_adr_i[31:28] == 4'b0000 ) ? 4'b0001 :
                                       (wbd_riscv_imem_adr_i[31:28] == 4'b0001 ) ? 4'b0001 :
                                       (wbd_riscv_imem_adr_i[31:28] == 4'b0010 ) ? 4'b0010 :
                                       (wbd_riscv_imem_adr_i[31:28] == 4'b0011 ) ? 4'b0011 : 4'b0001;

wire [3:0] wbd_riscv_dmem_tar_id     = (wbd_riscv_dmem_adr_i[31:28] == 4'b0000 ) ? 4'b0001 :
                                       (wbd_riscv_dmem_adr_i[31:28] == 4'b0001 ) ? 4'b0001 :
                                       (wbd_riscv_dmem_adr_i[31:28] == 4'b0010 ) ? 4'b0010 :
                                       (wbd_riscv_dmem_adr_i[31:28] == 4'b0011 ) ? 4'b0011 : 4'b0001;

wire [3:0] wbd_ext_tar_id            = (wbd_ext_adr_i[31:28] == 4'b0000 ) ? 4'b0001 :
                                       (wbd_ext_adr_i[31:28] == 4'b0001 ) ? 4'b0001 :
                                       (wbd_ext_adr_i[31:28] == 4'b0010 ) ? 4'b0010 :
                                       (wbd_ext_adr_i[31:28] == 4'b0011 ) ? 4'b0011 : 4'b0001;
wb_crossbar #(
    .WB_SLAVE(3),
    .WB_MASTER(3),
    .D_WD(32),
    .BE_WD(4),
    .ADR_WD(32),
    .TAR_WD(4)
   ) u_wb_crossbar(

    .rst_n               (rst_n               ), 
    .clk                 (clk                 ),


    // Master Interface Signal
    .wbd_taddr_master    ({wbd_ext_tar_id,
                           wbd_riscv_dmem_tar_id,
	                   wbd_riscv_imem_tar_id}),
    .wbd_din_master      ({wbd_ext_dat_i,
                          wbd_riscv_dmem_dat_i,
                          wbd_riscv_imem_dat_i}),
    .wbd_dout_master     ({wbd_ext_dat_o,
                          wbd_riscv_dmem_dat_o,
                          wbd_riscv_imem_dat_o}),
    .wbd_adr_master      ({wbd_ext_adr_i,
                          wbd_riscv_dmem_adr_i,
                          wbd_riscv_imem_adr_i}      ), 
    .wbd_be_master       ({wbd_ext_sel_i,
                          wbd_riscv_dmem_sel_i,
                          wbd_riscv_imem_sel_i}), 
    .wbd_we_master       ({wbd_ext_we_i,
                          wbd_riscv_dmem_we_i,
                          wbd_riscv_imem_we_i}), 
    .wbd_ack_master      ({wbd_ext_ack_o,
                          wbd_riscv_dmem_ack_o,
                          wbd_riscv_imem_ack_o}),
    .wbd_stb_master      ({wbd_ext_stb_i,
                           wbd_riscv_dmem_stb_i,
                           wbd_riscv_imem_stb_i}), 
    .wbd_cyc_master      ({wbd_ext_stb_i,
                          wbd_riscv_dmem_stb_i,
	                  wbd_riscv_imem_stb_i}), 
    .wbd_err_master      ({wbd_ext_err_o,
                          wbd_riscv_dmem_err_o,
                          wbd_riscv_imem_err_o}),
    .wbd_rty_master      (                    ),
 
    // Slave Interface Signal
    .wbd_din_slave       ({wbd_glbl_dat_o,
	                  wbd_sdram_dat_o,
                          wbd_spim_dat_o}     ), 
    .wbd_dout_slave      ({wbd_glbl_dat_i,
                          wbd_sdram_dat_i,
                          wbd_spim_dat_i}     ),
    .wbd_adr_slave       ({wbd_glbl_addr_o,
                          wbd_sdram_addr_o,
                          wbd_spim_adr_o}     ), 
    .wbd_be_slave        ({wbd_glbl_sel_o,
                          wbd_sdram_sel_o,
                          wbd_spim_sel_o}     ), 
    .wbd_we_slave        ({wbd_glbl_we_o,
                          wbd_sdram_we_o,
                          wbd_spim_we_o}      ), 
    .wbd_ack_slave       ({wbd_glbl_ack_i,
                          wbd_sdram_ack_i,
                          wbd_spim_ack_i}     ),
    .wbd_stb_slave       ({wbd_glbl_stb_o,
                          wbd_sdram_stb_o,
                          wbd_spim_stb_o}     ), 
    .wbd_cyc_slave       ({wbd_glbl_cyc_o,
                          wbd_sdram_cyc_o,
                          wbd_spim_cyc_o}      ), 
    .wbd_err_slave       (3'b0                ),
    .wbd_rty_slave       (3'b0                )
         );



endmodule : digital_core
