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
////  Digital core                                                ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
////      This is digital core and integrate all the main block   ////
////      here.  Following block are integrated here              ////
////      1. Risc V Core                                          ////
////      2. Quad SPI Master                                      ////
////      3. Wishbone Cross Bar                                   ////
////      4. UART                                                 ////
////      5, USB 1.1                                              ////
////      6. SPI Master (Single)                                  ////
////      7. TCM SRAM 2KB                                         ////
////      8. 2KB icache and 2KB dcache                            ////
////      8. 6 Channel ADC                                        ////
////      9. Pinmux with GPIO and 6 PWM                           ////
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
////           verilog/rtl/digital_core/src/glbl_cfg.sv           ////
////           verilog/rtl/lib/wb_stagging.sv                     ////
////           verilog/rtl/syntacore/scr1/src/top/scr1_dmem_wb.sv ////
////           verilog/rtl/syntacore/scr1/src/top/scr1_imem_wb.sv ////
////           verilog/rtl/syntacore/scr1/src/top/scr1_top_wb.sv  ////
////           verilog/rtl/user_project_wrapper.v                 ////
////           verilog/rtl/wb_interconnect/src/wb_interconnect.sv ////
////           verilog/rtl/spi_master/src/spim_clkgen.sv          ////
////           verilog/rtl/spi_master/src/spim_ctrl.sv            ////
////    0.3 - 20th June 2021, Dinesh A                            ////
////           1. uart core is integrated                         ////
////           2. 3rd Slave ported added to wishbone interconnect ////
////    0.4 - 25th June 2021, Dinesh A                            ////
////          Moved the pad logic inside sdram,spi,uart block to  ////
////          avoid logic at digital core level                   ////
////    0.5 - 25th June 2021, Dinesh A                            ////
////          Since carvel gives only 16MB address space for user ////
////          space, we have implemented indirect address select  ////
////          with 8 bit bank select given inside wb_host         ////
////          core Address = {Bank_Sel[7:0], Wb_Address[23:0]     ////
////          caravel user address space is                       ////
////          0x3000_0000 to 0x30FF_FFFF                          ////
////    0.6 - 27th June 2021, Dinesh A                            ////
////          Digital core level tie are moved inside IP to avoid ////
////          power hook up at core level                         ////
////          u_risc_top - test_mode & test_rst_n                 ////
////          u_intercon - s*_wbd_err_i                           ////
////          unused wb_cti_i is removed from u_sdram_ctrl        ////
////    0.7 - 28th June 2021, Dinesh A                            ////
////          wb_interconnect master port are interchanged for    ////
////          better physical placement.                          ////
////          m0 - External HOST                                  ////
////          m1 - RISC IMEM                                      ////
////          m2 - RISC DMEM                                      ////
////    0.8 - 6th July 2021, Dinesh A                             ////
////          For Better SDRAM Interface timing we have taping    ////
////          sdram_clock goint to io_out[29] directly from       ////
////          global register block, this help in better SDRAM    ////
////          interface timing control                            ////
////    0.9 - 7th July 2021, Dinesh A                             ////
////          Removed 2 Unused port connection io_in[31:30] to    ////
////          spi_master to avoid lvs issue                       ////
////    1.0 - 28th July 2021, Dinesh A                            ////
////          i2cm integrated part of uart_i2cm module,           ////
////          due to number of IO pin limitation,                 ////
////          Only UART OR I2C selected based on config mode      ////
////    1.1 - 1st Aug 2021, Dinesh A                              ////
////          usb1.1 host integrated part of uart_i2cm_usb module,////
////          due to number of IO pin limitation,                 ////
////          Only UART/I2C/USB selected based on config mode     ////
////    1.2 - 29th Sept 2021, Dinesh.A                            ////
////          1. copied the repo from yifive and renames as       ////
////             riscdunino                                       ////
////          2. Removed the SDRAM controlled                     ////
////          3. Added PinMux                                     ////
////          4. Added SAR ADC for 6 channel                      ////
////    1.3 - 30th Sept 2021, Dinesh.A                            ////
////          2KB SRAM Interface added to RISC Core               ////
////    1.4 - 13th Oct 2021, Dinesh A                             ////
////          Basic verification and Synthesis cleanup            ////
////    1.5 - 6th Nov 2021, Dinesh A                              ////
////          Clock Skew block moved inside respective block due  ////
////          to top-level power hook-up challenges for small IP  ////
////    1.6   Nov 14, 2021, Dinesh A                              ////
////          Major bug, clock divider inside the wb_host reset   ////
////          connectivity open is fixed                          ////
////    1.7   Nov 15, 2021, Dinesh A                              ////
////           Bug fix in clk_ctrl High/Low counter width         ////
////           Removed sram_clock                                 ////
////    1.8  Nov 23, 2021, Dinesh A                               ////
////          Three Chip Specific Signature added at PinMux Reg   ////
////          reg_22,reg_23,reg_24                                ////
////    1.9  Dec 11, 2021, Dinesh A                               ////
////         2 x 2K SRAM added into Wishbone Interface            ////
////         Temporary ADC block removed                          ////
////    2.0  Dec 14, 2021, Dinesh A                               ////
////         Added two more 2K SRAM added into Wishbone Interface ////
////    2.1  Dec 16, 2021, Dinesh A                               ////
////      1.4 MBIST controller changed to single one              ////
////      2.Added one more SRAM to TCM memory                     ////
////      3.WishBone Interconnect chang to take care mbist changes////
////      4.Pinmux change to take care of mbist changes           ////
////    2.2  Dec 20, 2021, Dinesh A                               ////
////      1. MBIST design issue fix for yosys                     ////
////      2. Full chip Timing and Transition clean-up             ////                   
////    2.3  Dec 24, 2021, Dinesh A                               ////
////      UART Master added with message handler at wb_host       ////
////    2.4  Jan 01, 2022, Dinesh A                               ////
////       LA[0] is added as soft reset option at wb_port         ////
////    2.5  Jan 06, 2022, Dinesh A                               ////
////       TCM RAM Bug fix inside syntacore                       ////
////    2.6  Jan 08, 2022, Dinesh A                               ////
////        Pinmux Interrupt Logic change                         ////
////    3.0  Jan 14, 2022, Dinesh A                               ////
////        Moving from riscv core from syntacore/scr1 to         ////
////        yfive/ycr1 on sankranti 2022 (A Hindu New Year)       ////
////    3.1  Jan 15, 2022, Dinesh A                               ////
////         Major changes in qspim logic to handle special mode  ////
////    3.2  Feb 02, 2022, Dinesh A                               ////
////         Bug fix around icache/dcache and wishbone burst      ////
////         access clean-up                                      ////
////    3.3  Feb 08, 2022, Dinesh A                               ////
////         support added spisram support in qspim ip            ////
////         There are 4 chip select available in qspim           ////
////         CS#0/CS#1 targeted for SPI FLASH                     ////
////         CS#2/CS#3 targeted for SPI SRAM                      ////
////    3.4  Feb 14, 2022, Dinesh A                               ////
////         burst mode supported added in imem buffer inside     ////
////         riscv core                                           ////
////    We have created seperate repo from this onwards           ////
////      SRAM based SOC is spin-out to                           ////
////      dineshannayya/riscduino_sram.git                        ////
////    This repo will remove mbist + SRAM and RISC SRAM will be  ////
////    replaced with DFRAM                                       ////
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


module user_project_wrapper (
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
    input   wire                       wb_clk_i        ,  // System clock
    input   wire                       user_clock2     ,  // user Clock
    input   wire                       wb_rst_i        ,  // Regular Reset signal

    input   wire                       wbs_cyc_i       ,  // strobe/request
    input   wire                       wbs_stb_i       ,  // strobe/request
    input   wire [WB_WIDTH-1:0]        wbs_adr_i       ,  // address
    input   wire                       wbs_we_i        ,  // write
    input   wire [WB_WIDTH-1:0]        wbs_dat_i       ,  // data output
    input   wire [3:0]                 wbs_sel_i       ,  // byte enable
    output  wire [WB_WIDTH-1:0]        wbs_dat_o       ,  // data input
    output  wire                       wbs_ack_o       ,  // acknowlegement

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
    inout [28:0] analog_io,
 
    // Logic Analyzer Signals
    input  wire [127:0]                la_data_in      ,
    output wire [127:0]                la_data_out     ,
    input  wire [127:0]                la_oenb         ,
 

    // IOs
    input  wire  [37:0]                io_in           ,
    output wire  [37:0]                io_out          ,
    output wire  [37:0]                io_oeb          ,

    output wire  [2:0]                 user_irq             

);

//---------------------------------------------------
// Local Parameter Declaration
// --------------------------------------------------

parameter     BIST_NO_SRAM  = 4; // NO of MBIST MEMORY
parameter     SDR_DW        = 8;  // SDR Data Width 
parameter     SDR_BW        = 1;  // SDR Byte Width
parameter     WB_WIDTH      = 32; // WB ADDRESS/DARA WIDTH
parameter     BIST1_ADDR_WD = 11; // 512x32 SRAM
parameter     BIST_DATA_WD  = 32;

//---------------------------------------------------------------------
// Wishbone Risc V Dcache Memory Interface
//---------------------------------------------------------------------
wire                           wbd_riscv_dcache_stb_i                 ; // strobe/request
wire   [WB_WIDTH-1:0]          wbd_riscv_dcache_adr_i                 ; // address
wire                           wbd_riscv_dcache_we_i                  ; // write
wire   [WB_WIDTH-1:0]          wbd_riscv_dcache_dat_i                 ; // data output
wire   [3:0]                   wbd_riscv_dcache_sel_i                 ; // byte enable
wire   [9:0]                   wbd_riscv_dcache_bl_i                  ; // burst length
wire                           wbd_riscv_dcache_bry_i                 ; // burst ready
wire   [WB_WIDTH-1:0]          wbd_riscv_dcache_dat_o                 ; // data input
wire                           wbd_riscv_dcache_ack_o                 ; // acknowlegement
wire                           wbd_riscv_dcache_lack_o                ; // last burst acknowlegement
wire                           wbd_riscv_dcache_err_o                 ; // error

// CACHE SRAM Memory I/F
wire                           dcache_mem_clk0                        ; // CLK
wire                           dcache_mem_csb0                        ; // CS#
wire                           dcache_mem_web0                        ; // WE#
wire   [8:0]                   dcache_mem_addr0                       ; // Address
wire   [3:0]                   dcache_mem_wmask0                      ; // WMASK#
wire   [31:0]                  dcache_mem_din0                        ; // Write Data
wire   [31:0]                  dcache_mem_dout0                       ; // Read Data
   
// SRAM-0 PORT-1, IMEM I/F
wire                           dcache_mem_clk1                        ; // CLK
wire                           dcache_mem_csb1                        ; // CS#
wire  [8:0]                    dcache_mem_addr1                       ; // Address
wire  [31:0]                   dcache_mem_dout1                       ; // Read Data
//---------------------------------------------------------------------
// Wishbone Risc V Icache Memory Interface
//---------------------------------------------------------------------
wire                           wbd_riscv_icache_stb_i                 ; // strobe/request
wire   [WB_WIDTH-1:0]          wbd_riscv_icache_adr_i                 ; // address
wire                           wbd_riscv_icache_we_i                  ; // write
wire   [3:0]                   wbd_riscv_icache_sel_i                 ; // byte enable
wire   [9:0]                   wbd_riscv_icache_bl_i                  ; // burst length
wire                           wbd_riscv_icache_bry_i                 ; // burst ready
wire   [WB_WIDTH-1:0]          wbd_riscv_icache_dat_o                 ; // data input
wire                           wbd_riscv_icache_ack_o                 ; // acknowlegement
wire                           wbd_riscv_icache_lack_o                ; // last burst acknowlegement
wire                           wbd_riscv_icache_err_o                 ; // error

// CACHE SRAM Memory I/F
wire                           icache_mem_clk0                        ; // CLK
wire                           icache_mem_csb0                        ; // CS#
wire                           icache_mem_web0                        ; // WE#
wire   [8:0]                   icache_mem_addr0                       ; // Address
wire   [3:0]                   icache_mem_wmask0                      ; // WMASK#
wire   [31:0]                  icache_mem_din0                        ; // Write Data
// wire   [31:0]               icache_mem_dout0                       ; // Read Data
   
// SRAM-0 PORT-1, IMEM I/F
wire                           icache_mem_clk1                        ; // CLK
wire                           icache_mem_csb1                        ; // CS#
wire  [8:0]                    icache_mem_addr1                       ; // Address
wire  [31:0]                   icache_mem_dout1                       ; // Read Data

//---------------------------------------------------------------------
// RISC V Wishbone Data Memory Interface
//---------------------------------------------------------------------
wire                           wbd_riscv_dmem_stb_i                   ; // strobe/request
wire   [WB_WIDTH-1:0]          wbd_riscv_dmem_adr_i                   ; // address
wire                           wbd_riscv_dmem_we_i                    ; // write
wire   [WB_WIDTH-1:0]          wbd_riscv_dmem_dat_i                   ; // data output
wire   [3:0]                   wbd_riscv_dmem_sel_i                   ; // byte enable
wire   [WB_WIDTH-1:0]          wbd_riscv_dmem_dat_o                   ; // data input
wire                           wbd_riscv_dmem_ack_o                   ; // acknowlegement
wire                           wbd_riscv_dmem_err_o                   ; // error

//---------------------------------------------------------------------
// WB HOST Interface
//---------------------------------------------------------------------
wire                           wbd_int_cyc_i                          ; // strobe/request
wire                           wbd_int_stb_i                          ; // strobe/request
wire   [WB_WIDTH-1:0]          wbd_int_adr_i                          ; // address
wire                           wbd_int_we_i                           ; // write
wire   [WB_WIDTH-1:0]          wbd_int_dat_i                          ; // data output
wire   [3:0]                   wbd_int_sel_i                          ; // byte enable
wire   [WB_WIDTH-1:0]          wbd_int_dat_o                          ; // data input
wire                           wbd_int_ack_o                          ; // acknowlegement
wire                           wbd_int_err_o                          ; // error
//---------------------------------------------------------------------
//    SPI Master Wishbone Interface
//---------------------------------------------------------------------
wire                           wbd_spim_stb_o                         ; // strobe/request
wire   [WB_WIDTH-1:0]          wbd_spim_adr_o                         ; // address
wire                           wbd_spim_we_o                          ; // write
wire   [WB_WIDTH-1:0]          wbd_spim_dat_o                         ; // data output
wire   [3:0]                   wbd_spim_sel_o                         ; // byte enable
wire   [9:0]                   wbd_spim_bl_o                          ; // Burst count
wire                           wbd_spim_bry_o                         ; // Busrt Ready
wire                           wbd_spim_cyc_o                         ;
wire   [WB_WIDTH-1:0]          wbd_spim_dat_i                         ; // data input
wire                           wbd_spim_ack_i                         ; // acknowlegement
wire                           wbd_spim_lack_i                        ; // Last acknowlegement
wire                           wbd_spim_err_i                         ; // error

//---------------------------------------------------------------------
//    SPI Master Wishbone Interface
//---------------------------------------------------------------------
wire                           wbd_adc_stb_o                          ;
wire [7:0]                     wbd_adc_adr_o                          ;
wire                           wbd_adc_we_o                           ; // 1 - Write, 0 - Read
wire [WB_WIDTH-1:0]            wbd_adc_dat_o                          ;
wire [WB_WIDTH/8-1:0]          wbd_adc_sel_o                          ; // Byte enable
wire                           wbd_adc_cyc_o                          ;
wire  [2:0]                    wbd_adc_cti_o                          ;
wire  [WB_WIDTH-1:0]           wbd_adc_dat_i                          ;
wire                           wbd_adc_ack_i                          ;

//---------------------------------------------------------------------
//    Global Register Wishbone Interface
//---------------------------------------------------------------------
wire                           wbd_glbl_stb_o                         ; // strobe/request
wire   [7:0]                   wbd_glbl_adr_o                         ; // address
wire                           wbd_glbl_we_o                          ; // write
wire   [WB_WIDTH-1:0]          wbd_glbl_dat_o                         ; // data output
wire   [3:0]                   wbd_glbl_sel_o                         ; // byte enable
wire                           wbd_glbl_cyc_o                         ;
wire   [WB_WIDTH-1:0]          wbd_glbl_dat_i                         ; // data input
wire                           wbd_glbl_ack_i                         ; // acknowlegement
wire                           wbd_glbl_err_i                         ; // error

//---------------------------------------------------------------------
//    Global Register Wishbone Interface
//---------------------------------------------------------------------
wire                           wbd_uart_stb_o                         ; // strobe/request
wire   [7:0]                   wbd_uart_adr_o                         ; // address
wire                           wbd_uart_we_o                          ; // write
wire   [31:0]                  wbd_uart_dat_o                         ; // data output
wire   [3:0]                   wbd_uart_sel_o                         ; // byte enable
wire                           wbd_uart_cyc_o                         ;
wire   [31:0]                  wbd_uart_dat_i                         ; // data input
wire                           wbd_uart_ack_i                         ; // acknowlegement
wire                           wbd_uart_err_i                         ;  // error

//---------------------------------------------------------------------
//  MBIST1  
//---------------------------------------------------------------------
wire                           wbd_mbist_stb_o                        ; // strobe/request
wire   [12:0]                  wbd_mbist_adr_o                        ; // address
wire                           wbd_mbist_we_o                         ; // write
wire   [WB_WIDTH-1:0]          wbd_mbist_dat_o                        ; // data output
wire   [3:0]                   wbd_mbist_sel_o                        ; // byte enable
wire   [9:0]                   wbd_mbist_bl_o                         ; // byte enable
wire                           wbd_mbist_bry_o                        ; // byte enable
wire                           wbd_mbist_cyc_o                        ;
wire   [WB_WIDTH-1:0]          wbd_mbist_dat_i                        ; // data input
wire                           wbd_mbist_ack_i                        ; // acknowlegement
wire                           wbd_mbist_lack_i                       ; // acknowlegement
wire                           wbd_mbist_err_i                        ; // error

//----------------------------------------------------
//  CPU Configuration
//----------------------------------------------------
wire                           cpu_rst_n                              ;
wire                           qspim_rst_n                            ;
wire                           sspim_rst_n                            ;
wire                           uart_rst_n                             ; // uart reset
wire                           i2c_rst_n                              ; // i2c reset
wire                           usb_rst_n                              ; // i2c reset
wire   [3:0]                   boot_remap                             ; // Boot Remap
wire   [3:0]                   dcache_remap                           ; // Remap the dcache address
wire                           cpu_clk                                ;
wire                           rtc_clk                                ;
wire                           usb_clk                                ;
wire                           wbd_clk_int                            ;

wire                           wbd_clk_pinmux                         ;
//wire                           wbd_clk_int1                         ;
//wire                           wbd_clk_int2                         ;
wire                           wbd_int_rst_n                          ;
//wire                           wbd_int1_rst_n                       ;
//wire                           wbd_int2_rst_n                       ;

wire [31:0]                    fuse_mhartid                           ;
wire [15:0]                    irq_lines                              ;
wire                           soft_irq                               ;


wire [7:0]                     cfg_glb_ctrl                           ;
wire [31:0]                    cfg_clk_ctrl1                          ;
wire [31:0]                    cfg_clk_ctrl2                          ;
wire [3:0]                     cfg_cska_wi                            ; // clock skew adjust for wishbone interconnect
wire [3:0]                     cfg_cska_wh                            ; // clock skew adjust for web host

wire [3:0]                     cfg_cska_riscv                         ; // clock skew adjust for riscv
wire [3:0]                     cfg_cska_uart                          ; // clock skew adjust for uart
wire [3:0]                     cfg_cska_qspi                          ; // clock skew adjust for spi
wire [3:0]                     cfg_cska_pinmux                        ; // clock skew adjust for pinmux
wire [3:0]                     cfg_cska_qspi_co                       ; // clock skew adjust for global reg
wire [3:0]                     cfg_cska_mbist1                        ;
wire [3:0]                     cfg_cska_mbist2                        ;
wire [3:0]                     cfg_cska_mbist3                        ;
wire [3:0]                     cfg_cska_mbist4                        ;

// Bus Repeater Signals  output from Wishbone Interface
wire [3:0]                     cfg_cska_riscv_rp                      ; // clock skew adjust for riscv
wire [3:0]                     cfg_cska_uart_rp                       ; // clock skew adjust for uart
wire [3:0]                     cfg_cska_qspi_rp                       ; // clock skew adjust for spi
wire [3:0]                     cfg_cska_pinmux_rp                     ; // clock skew adjust for pinmux
wire [3:0]                     cfg_cska_qspi_co_rp                    ; // clock skew adjust for global reg
wire [3:0]                     cfg_cska_mbist1_rp                     ;
wire [3:0]                     cfg_cska_mbist2_rp                     ;
wire [3:0]                     cfg_cska_mbist3_rp                     ;
wire [3:0]                     cfg_cska_mbist4_rp                     ;

wire [31:0]                    fuse_mhartid_rp                        ; // Repeater
wire [15:0]                    irq_lines_rp                           ; // Repeater
wire                           soft_irq_rp                            ; // Repeater

wire                           wbd_clk_risc_rp                        ;
wire                           wbd_clk_qspi_rp                        ;
wire                           wbd_clk_uart_rp                        ;
wire                           wbd_clk_pinmux_rp                      ;
wire                           wbd_clk_mbist1_rp                      ;
wire                           wbd_clk_mbist2_rp                      ;
wire                           wbd_clk_mbist3_rp                      ;
wire                           wbd_clk_mbist4_rp                      ;

// Progammable Clock Skew inserted signals
wire                           wbd_clk_wi_skew                        ; // clock for wishbone interconnect with clock skew
wire                           wbd_clk_riscv_skew                     ; // clock for riscv with clock skew
wire                           wbd_clk_uart_skew                      ; // clock for uart with clock skew
wire                           wbd_clk_spi_skew                       ; // clock for spi with clock skew
wire                           wbd_clk_glbl_skew                      ; // clock for global reg with clock skew
wire                           wbd_clk_wh_skew                        ; // clock for global reg
wire                           wbd_clk_mbist_skew                     ; // clock for global reg
wire                           wbd_clk_mbist2_skew                    ; // clock for global reg
wire                           wbd_clk_mbist3_skew                    ; // clock for global reg
wire                           wbd_clk_mbist4_skew                    ; // clock for global reg



wire [31:0]                    spi_debug                              ;
wire [31:0]                    pinmux_debug                           ;
wire [63:0]                    riscv_debug                            ;

// SFLASH I/F
wire                           sflash_sck                             ;
wire [3:0]                     sflash_ss                              ;
wire [3:0]                     sflash_oen                             ;
wire [3:0]                     sflash_do                              ;
wire [3:0]                     sflash_di                              ;

// SSRAM I/F
//wire                         ssram_sck                              ;
//wire                         ssram_ss                               ;
//wire                         ssram_oen                              ;
//wire [3:0]                   ssram_do                               ;
//wire [3:0]                   ssram_di                               ;

// USB I/F
wire                           usb_dp_o                               ;
wire                           usb_dn_o                               ;
wire                           usb_oen                                ;
wire                           usb_dp_i                               ;
wire                           usb_dn_i                               ;

// UART I/F
wire                           uart_txd                               ;
wire                           uart_rxd                               ;

// I2CM I/F
wire                           i2cm_clk_o                             ;
wire                           i2cm_clk_i                             ;
wire                           i2cm_clk_oen                           ;
wire                           i2cm_data_oen                          ;
wire                           i2cm_data_o                            ;
wire                           i2cm_data_i                            ;

// SPI MASTER
wire                           spim_sck                               ;
wire                           spim_ss                                ;
wire                           spim_miso                              ;
wire                           spim_mosi                              ;

wire [7:0]                     sar2dac                                ;
wire                           analog_dac_out                         ;
wire                           pulse1m_mclk                           ;
wire                           h_reset_n                              ;

`ifndef SCR1_TCM_MEM
// SRAM-0 PORT-0 - DMEM I/F
wire                           sram0_clk0                             ; // CLK
wire                           sram0_csb0                             ; // CS#
wire                           sram0_web0                             ; // WE#
wire   [8:0]                   sram0_addr0                            ; // Address
wire   [3:0]                   sram0_wmask0                           ; // WMASK#
wire   [31:0]                  sram0_din0                             ; // Write Data
wire   [31:0]                  sram0_dout0                            ; // Read Data

// SRAM-0 PORT-1, IMEM I/F
wire                           sram0_clk1                             ; // CLK
wire                           sram0_csb1                             ; // CS#
wire  [8:0]                    sram0_addr1                            ; // Address
wire  [31:0]                   sram0_dout1                            ; // Read Data

// SRAM-1 PORT-0 - DMEM I/F
wire                           sram1_clk0                             ; // CLK
wire                           sram1_csb0                             ; // CS#
wire                           sram1_web0                             ; // WE#
wire   [8:0]                   sram1_addr0                            ; // Address
wire   [3:0]                   sram1_wmask0                           ; // WMASK#
wire   [31:0]                  sram1_din0                             ; // Write Data
wire   [31:0]                  sram1_dout0                            ; // Read Data

// SRAM-1 PORT-1, IMEM I/F
wire                           sram1_clk1                             ; // CLK
wire                           sram1_csb1                             ; // CS#
wire  [8:0]                    sram1_addr1                            ; // Address
wire  [31:0]                   sram1_dout1                            ; // Read Data

`endif

// SPIM I/F
wire                           sspim_sck                              ; // clock out
wire                           sspim_so                               ; // serial data out
wire                           sspim_si                               ; // serial data in
wire                           sspim_ssn                              ; // cs_n


wire                           usb_intr_o                             ;
wire                           i2cm_intr_o                            ;

//----------------------------------------------------------------
//  UART Master I/F
//  -------------------------------------------------------------
wire                           uartm_rxd                              ;
wire                           uartm_txd                              ;

//----------------------------------------------------------
// BIST I/F
// ---------------------------------------------------------
wire                           bist_en                                ;
wire                           bist_run                               ;
wire                           bist_load                              ;

wire                           bist_sdi                               ;
wire                           bist_shift                             ;
wire                           bist_sdo                               ;

wire                           bist_done                              ;
wire [3:0]                     bist_error                             ;
wire [3:0]                     bist_correct                           ;
wire [3:0]                     bist_error_cnt0                        ;
wire [3:0]                     bist_error_cnt1                        ;
wire [3:0]                     bist_error_cnt2                        ;
wire [3:0]                     bist_error_cnt3                        ;

// With Repeater Buffer
wire                           bist_en_rp                             ;
wire                           bist_run_rp                            ;
wire                           bist_load_rp                           ;

wire                           bist_sdi_rp                            ;
wire                           bist_shift_rp                          ;
wire                           bist_sdo_rp                            ;

wire                           bist_done_rp                           ;
wire [3:0]                     bist_error_rp                          ;
wire [3:0]                     bist_correct_rp                        ;
wire [3:0]                     bist_error_cnt0_rp                     ;
wire [3:0]                     bist_error_cnt1_rp                     ;
wire [3:0]                     bist_error_cnt2_rp                     ;
wire [3:0]                     bist_error_cnt3_rp                     ;

// towards memory MBIST1
// PORT-A
wire   [BIST_NO_SRAM-1:0]      mem_clk_a                              ;
wire   [BIST1_ADDR_WD-1:2]     mem0_addr_a                            ;
wire   [BIST1_ADDR_WD-1:2]     mem1_addr_a                            ;
wire   [BIST1_ADDR_WD-1:2]     mem2_addr_a                            ;
wire   [BIST1_ADDR_WD-1:2]     mem3_addr_a                            ;
wire   [BIST_NO_SRAM-1:0]      mem_cen_a                              ;
wire   [BIST_NO_SRAM-1:0]      mem_web_a                              ;
wire [BIST_DATA_WD/8-1:0]      mem0_mask_a                            ;
wire [BIST_DATA_WD/8-1:0]      mem1_mask_a                            ;
wire [BIST_DATA_WD/8-1:0]      mem2_mask_a                            ;
wire [BIST_DATA_WD/8-1:0]      mem3_mask_a                            ;
wire   [BIST_DATA_WD-1:0]      mem0_din_a                             ;
wire   [BIST_DATA_WD-1:0]      mem1_din_a                             ;
wire   [BIST_DATA_WD-1:0]      mem2_din_a                             ;
wire   [BIST_DATA_WD-1:0]      mem3_din_a                             ;
wire   [BIST_DATA_WD-1:0]      mem0_dout_a                            ;
wire   [BIST_DATA_WD-1:0]      mem1_dout_a                            ;
wire   [BIST_DATA_WD-1:0]      mem2_dout_a                            ;
wire   [BIST_DATA_WD-1:0]      mem3_dout_a                            ;

// PORT-B
wire [BIST_NO_SRAM-1:0]        mem_clk_b                              ;
wire [BIST_NO_SRAM-1:0]        mem_cen_b                              ;
wire [BIST1_ADDR_WD-1:2]       mem0_addr_b                            ;
wire [BIST1_ADDR_WD-1:2]       mem1_addr_b                            ;
wire [BIST1_ADDR_WD-1:2]       mem2_addr_b                            ;
wire [BIST1_ADDR_WD-1:2]       mem3_addr_b                            ;

wire [3:0]                     spi_csn                                ;

/////////////////////////////////////////////////////////
// Clock Skew Ctrl
////////////////////////////////////////////////////////

assign cfg_cska_wi     = cfg_clk_ctrl1[3:0];
assign cfg_cska_wh     = cfg_clk_ctrl1[7:4];
assign cfg_cska_riscv  = cfg_clk_ctrl1[11:8];
assign cfg_cska_qspi    = cfg_clk_ctrl1[15:12];
assign cfg_cska_uart   = cfg_clk_ctrl1[19:16];
assign cfg_cska_pinmux = cfg_clk_ctrl1[23:20];
assign cfg_cska_qspi_co  = cfg_clk_ctrl1[27:24];

assign  cfg_cska_mbist1   = cfg_clk_ctrl2[3:0];
assign  cfg_cska_mbist2   = cfg_clk_ctrl2[7:4];
assign  cfg_cska_mbist3   = cfg_clk_ctrl2[11:8];
assign  cfg_cska_mbist4   = cfg_clk_ctrl2[15:12];
assign  dcache_remap      = cfg_clk_ctrl2[27:24];
assign  boot_remap        = cfg_clk_ctrl2[31:28];

//assign la_data_out    = {riscv_debug,spi_debug,sdram_debug};
assign la_data_out[127:0]    = {pinmux_debug,spi_debug,riscv_debug};

//clk_buf u_buf1_wb_rstn  (.clk_i(wbd_int_rst_n),.clk_o(wbd_int1_rst_n));
//clk_buf u_buf2_wb_rstn  (.clk_i(wbd_int1_rst_n),.clk_o(wbd_int2_rst_n));
//
//clk_buf u_buf1_wbclk    (.clk_i(wbd_clk_int),.clk_o(wbd_clk_int1));
//clk_buf u_buf2_wbclk    (.clk_i(wbd_clk_int1),.clk_o(wbd_clk_int2));

wb_host u_wb_host(
`ifdef USE_POWER_PINS
          .vccd1              (vccd1                        ),// User area 1 1.8V supply
          .vssd1              (vssd1                        ),// User area 1 digital ground
`endif
          .user_clock1        (wb_clk_i                     ),
          .user_clock2        (user_clock2                  ),

          .cpu_clk            (cpu_clk                      ),
          .rtc_clk            (rtc_clk                      ),
          .usb_clk            (usb_clk                      ),

          .wbd_int_rst_n      (wbd_int_rst_n                ),
          .cpu_rst_n          (cpu_rst_n                    ),
          .qspim_rst_n        (qspim_rst_n                  ),
          .sspim_rst_n        (sspim_rst_n                  ), // spi reset
          .uart_rst_n         (uart_rst_n                   ), // uart reset
          .i2cm_rst_n         (i2c_rst_n                    ), // i2c reset
          .usb_rst_n          (usb_rst_n                    ), // usb reset
          .bist_rst_n         (bist_rst_n                   ), // BIST Reset  

    // Master Port
          .wbm_rst_i          (wb_rst_i                     ),  
          .wbm_clk_i          (wb_clk_i                     ),  
          .wbm_cyc_i          (wbs_cyc_i                    ),  
          .wbm_stb_i          (wbs_stb_i                    ),  
          .wbm_adr_i          (wbs_adr_i                    ),  
          .wbm_we_i           (wbs_we_i                     ),  
          .wbm_dat_i          (wbs_dat_i                    ),  
          .wbm_sel_i          (wbs_sel_i                    ),  
          .wbm_dat_o          (wbs_dat_o                    ),  
          .wbm_ack_o          (wbs_ack_o                    ),  
          .wbm_err_o          (                             ),  

    // Clock Skeq Adjust
          .wbd_clk_int        (wbd_clk_int                  ),
          .wbd_clk_wh         (wbd_clk_wh                   ),  
          .cfg_cska_wh        (cfg_cska_wh                  ),

    // Slave Port
          .wbs_clk_out        (wbd_clk_int                  ),
          .wbs_clk_i          (wbd_clk_wh                   ),  
          .wbs_cyc_o          (wbd_int_cyc_i                ),  
          .wbs_stb_o          (wbd_int_stb_i                ),  
          .wbs_adr_o          (wbd_int_adr_i                ),  
          .wbs_we_o           (wbd_int_we_i                 ),  
          .wbs_dat_o          (wbd_int_dat_i                ),  
          .wbs_sel_o          (wbd_int_sel_i                ),  
          .wbs_dat_i          (wbd_int_dat_o                ),  
          .wbs_ack_i          (wbd_int_ack_o                ),  
          .wbs_err_i          (wbd_int_err_o                ),  

          .cfg_clk_ctrl1      (cfg_clk_ctrl1                ),
          .cfg_clk_ctrl2      (cfg_clk_ctrl2                ),

          .la_data_in         (la_data_in[17:0]             ),

          .uartm_rxd          (uartm_rxd                    ),
          .uartm_txd          (uartm_txd                    )


    );




//------------------------------------------------------------------------------
// RISC V Core instance
//------------------------------------------------------------------------------
ycr1_top_wb u_riscv_top (
`ifdef USE_POWER_PINS
          .vccd1              (vccd1                        ),// User area 1 1.8V supply
          .vssd1              (vssd1                        ),// User area 1 digital ground
`endif
          .wbd_clk_int        (wbd_clk_risc_rp              ), 
          .cfg_cska_riscv     (cfg_cska_riscv_rp            ), 
          .wbd_clk_riscv      (wbd_clk_riscv_skew           ),

    // Reset
          .pwrup_rst_n        (wbd_int_rst_n                ),
          .rst_n              (wbd_int_rst_n                ),
          .cpu_rst_n          (cpu_rst_n                    ),
          .riscv_debug        (riscv_debug                  ),

    // Clock
          .core_clk           (cpu_clk                      ),
          .rtc_clk            (rtc_clk                      ),

    // Fuses
          .fuse_mhartid       (fuse_mhartid_rp              ),

    // IRQ
          .irq_lines          (irq_lines_rp                 ), 
          .soft_irq           (soft_irq_rp                  ), // TODO - Interrupts

    // DFT
    //    .test_mode          (1'b0                         ), // Moved inside IP
    //    .test_rst_n         (1'b1                         ), // Moved inside IP

`ifndef SCR1_TCM_MEM
    // SRAM-0 PORT-0
          .sram0_clk0         (sram0_clk0                   ),
          .sram0_csb0         (sram0_csb0                   ),
          .sram0_web0         (sram0_web0                   ),
          .sram0_addr0        (sram0_addr0                  ),
          .sram0_wmask0       (sram0_wmask0                 ),
          .sram0_din0         (sram0_din0                   ),
          .sram0_dout0        (sram0_dout0                  ),
    
    // SRAM-0 PORT-0
          .sram0_clk1         (sram0_clk1                   ),
          .sram0_csb1         (sram0_csb1                   ),
          .sram0_addr1        (sram0_addr1                  ),
          .sram0_dout1        (sram0_dout1                  ),

  //  // SRAM-1 PORT-0
  //      .sram1_clk0         (sram1_clk0                   ),
  //      .sram1_csb0         (sram1_csb0                   ),
  //      .sram1_web0         (sram1_web0                   ),
  //      .sram1_addr0        (sram1_addr0                  ),
  //      .sram1_wmask0       (sram1_wmask0                 ),
  //      .sram1_din0         (sram1_din0                   ),
  //      .sram1_dout0        (sram1_dout0                  ),
  //  
  //  // SRAM PORT-0
  //      .sram1_clk1         (sram1_clk1                   ),
  //      .sram1_csb1         (sram1_csb1                   ),
  //      .sram1_addr1        (sram1_addr1                  ),
  //      .sram1_dout1        (sram1_dout1                  ),
`endif
    
          .wb_rst_n           (wbd_int_rst_n                ),
          .wb_clk             (wbd_clk_riscv_skew           ),

    // Instruction cache memory interface
          .wb_icache_stb_o    (wbd_riscv_icache_stb_i       ),
          .wb_icache_adr_o    (wbd_riscv_icache_adr_i       ),
          .wb_icache_we_o     (wbd_riscv_icache_we_i        ), 
          .wb_icache_sel_o    (wbd_riscv_icache_sel_i       ),
          .wb_icache_bl_o     (wbd_riscv_icache_bl_i        ),
          .wb_icache_bry_o    (wbd_riscv_icache_bry_i       ),
          .wb_icache_dat_i    (wbd_riscv_icache_dat_o       ),
          .wb_icache_ack_i    (wbd_riscv_icache_ack_o       ),
          .wb_icache_lack_i   (wbd_riscv_icache_lack_o      ),
          .wb_icache_err_i    (wbd_riscv_icache_err_o       ),

          .icache_mem_clk0    (icache_mem_clk0              ), // CLK
          .icache_mem_csb0    (icache_mem_csb0              ), // CS#
          .icache_mem_web0    (icache_mem_web0              ), // WE#
          .icache_mem_addr0   (icache_mem_addr0             ), // Address
          .icache_mem_wmask0  (icache_mem_wmask0            ), // WMASK#
          .icache_mem_din0    (icache_mem_din0              ), // Write Data
//        .icache_mem_dout0   (icache_mem_dout0             ), // Read Data
                                
                                
          .icache_mem_clk1    (icache_mem_clk1              ), // CLK
          .icache_mem_csb1    (icache_mem_csb1              ), // CS#
          .icache_mem_addr1   (icache_mem_addr1             ), // Address
          .icache_mem_dout1   (icache_mem_dout1             ), // Read Data

    // Data cache memory interface
          .wb_dcache_stb_o    (wbd_riscv_dcache_stb_i       ),
          .wb_dcache_adr_o    (wbd_riscv_dcache_adr_i       ),
          .wb_dcache_we_o     (wbd_riscv_dcache_we_i        ), 
          .wb_dcache_dat_o    (wbd_riscv_dcache_dat_i       ),
          .wb_dcache_sel_o    (wbd_riscv_dcache_sel_i       ),
          .wb_dcache_bl_o     (wbd_riscv_dcache_bl_i        ),
          .wb_dcache_bry_o    (wbd_riscv_dcache_bry_i       ),
          .wb_dcache_dat_i    (wbd_riscv_dcache_dat_o       ),
          .wb_dcache_ack_i    (wbd_riscv_dcache_ack_o       ),
          .wb_dcache_lack_i   (wbd_riscv_dcache_lack_o      ),
          .wb_dcache_err_i    (wbd_riscv_dcache_err_o       ),

          .dcache_mem_clk0    (dcache_mem_clk0              ), // CLK
          .dcache_mem_csb0    (dcache_mem_csb0              ), // CS#
          .dcache_mem_web0    (dcache_mem_web0              ), // WE#
          .dcache_mem_addr0   (dcache_mem_addr0             ), // Address
          .dcache_mem_wmask0  (dcache_mem_wmask0            ), // WMASK#
          .dcache_mem_din0    (dcache_mem_din0              ), // Write Data
          .dcache_mem_dout0   (dcache_mem_dout0             ), // Read Data
                                
                                
          .dcache_mem_clk1    (dcache_mem_clk1              ), // CLK
          .dcache_mem_csb1    (dcache_mem_csb1              ), // CS#
          .dcache_mem_addr1   (dcache_mem_addr1             ), // Address
          .dcache_mem_dout1   (dcache_mem_dout1             ), // Read Data


    // Data memory interface
          .wbd_dmem_stb_o     (wbd_riscv_dmem_stb_i         ),
          .wbd_dmem_adr_o     (wbd_riscv_dmem_adr_i         ),
          .wbd_dmem_we_o      (wbd_riscv_dmem_we_i          ), 
          .wbd_dmem_dat_o     (wbd_riscv_dmem_dat_i         ),
          .wbd_dmem_sel_o     (wbd_riscv_dmem_sel_i         ),
          .wbd_dmem_dat_i     (wbd_riscv_dmem_dat_o         ),
          .wbd_dmem_ack_i     (wbd_riscv_dmem_ack_o         ),
          .wbd_dmem_err_i     (wbd_riscv_dmem_err_o         ) 
);

`ifndef SCR1_TCM_MEM
sky130_sram_2kbyte_1rw1r_32x512_8 u_tsram0_2kb(
`ifdef USE_POWER_PINS
          .vccd1              (vccd1                        ),// area 1 1.8V supply
          .vssd1              (vssd1                        ),// area 1 digital ground
`endif
// Port 0: RW
          .clk0               (sram0_clk0                   ),
          .csb0               (sram0_csb0                   ),
          .web0               (sram0_web0                   ),
          .wmask0             (sram0_wmask0                 ),
          .addr0              (sram0_addr0                  ),
          .din0               (sram0_din0                   ),
          .dout0              (sram0_dout0                  ),
// Port 1: R
          .clk1               (sram0_clk1                   ),
          .csb1               (sram0_csb1                   ),
          .addr1              (sram0_addr1                  ),
          .dout1              (sram0_dout1                  )
  );

/***
sky130_sram_2kbyte_1rw1r_32x512_8 u_tsram1_2kb(
`ifdef USE_POWER_PINS
          .vccd1              (vccd1                        ),// User area 1 1.8V supply
          .vssd1              (vssd1                        ),// User area 1 digital ground
`endif
// Port 0: RW
          .clk0               (sram1_clk0                   ),
          .csb0               (sram1_csb0                   ),
          .web0               (sram1_web0                   ),
          .wmask0             (sram1_wmask0                 ),
          .addr0              (sram1_addr0                  ),
          .din0               (sram1_din0                   ),
          .dout0              (sram1_dout0                  ),
// Port 1: R
          .clk1               (sram1_clk1                   ),
          .csb1               (sram1_csb1                   ),
          .addr1              (sram1_addr1                  ),
          .dout1              (sram1_dout1                  )
  );
***/
`endif


sky130_sram_2kbyte_1rw1r_32x512_8 u_icache_2kb(
`ifdef USE_POWER_PINS
          .vccd1              (vccd1                        ),// User area 1 1.8V supply
          .vssd1              (vssd1                        ),// User area 1 digital ground
`endif
// Port 0: RW
          .clk0               (icache_mem_clk0              ),
          .csb0               (icache_mem_csb0              ),
          .web0               (icache_mem_web0              ),
          .wmask0             (icache_mem_wmask0            ),
          .addr0              (icache_mem_addr0             ),
          .din0               (icache_mem_din0              ),
          .dout0              (                             ),
// Port 1: R
          .clk1               (icache_mem_clk1              ),
          .csb1               (icache_mem_csb1              ),
          .addr1              (icache_mem_addr1             ),
          .dout1              (icache_mem_dout1             )
  );

sky130_sram_2kbyte_1rw1r_32x512_8 u_dcache_2kb(
`ifdef USE_POWER_PINS
          .vccd1              (vccd1                        ),// User area 1 1.8V supply
          .vssd1              (vssd1                        ),// User area 1 digital ground
`endif
// Port 0: RW
          .clk0               (dcache_mem_clk0              ),
          .csb0               (dcache_mem_csb0              ),
          .web0               (dcache_mem_web0              ),
          .wmask0             (dcache_mem_wmask0            ),
          .addr0              (dcache_mem_addr0             ),
          .din0               (dcache_mem_din0              ),
          .dout0              (dcache_mem_dout0             ),
// Port 1: R
          .clk1               (dcache_mem_clk1              ),
          .csb1               (dcache_mem_csb1              ),
          .addr1              (dcache_mem_addr1             ),
          .dout1              (dcache_mem_dout1             )
  );


/*********************************************************
* SPI Master
* This is implementation of an SPI master that is controlled via an AXI bus                                                  . 
* It has FIFOs for transmitting and receiving data. 
* It supports both the normal SPI mode and QPI mode with 4 data lines.
* *******************************************************/

qspim_top
#                             (
`ifndef SYNTHESIS
    .WB_WIDTH  (WB_WIDTH                                    )
`endif
) u_qspi_master
(
`ifdef USE_POWER_PINS
          .vccd1              (vccd1                        ),// User area 1 1.8V supply
          .vssd1              (vssd1                        ),// User area 1 digital ground
`endif
          .mclk               (wbd_clk_spi                  ),
          .rst_n              (qspim_rst_n                  ),

    // Clock Skew Adjust
          .cfg_cska_sp_co     (cfg_cska_qspi_co_rp          ),
          .cfg_cska_spi       (cfg_cska_qspi_rp             ),
          .wbd_clk_int        (wbd_clk_qspi_rp              ),
          .wbd_clk_spi        (wbd_clk_spi                  ),

          .wbd_stb_i          (wbd_spim_stb_o               ),
          .wbd_adr_i          (wbd_spim_adr_o               ),
          .wbd_we_i           (wbd_spim_we_o                ), 
          .wbd_dat_i          (wbd_spim_dat_o               ),
          .wbd_sel_i          (wbd_spim_sel_o               ),
          .wbd_bl_i           (wbd_spim_bl_o                ),
          .wbd_bry_i          (wbd_spim_bry_o               ),
          .wbd_dat_o          (wbd_spim_dat_i               ),
          .wbd_ack_o          (wbd_spim_ack_i               ),
          .wbd_lack_o         (wbd_spim_lack_i              ),
          .wbd_err_o          (wbd_spim_err_i               ),

          .spi_debug          (spi_debug                    ),

    // Pad Interface
          .spi_sdi            (sflash_di                    ),
          .spi_clk            (sflash_sck                   ),
          .spi_csn            (spi_csn                      ),
          .spi_sdo            (sflash_do                    ),
          .spi_oen            (sflash_oen                   )

);



wb_interconnect  #(
	`ifndef SYNTHESIS
	         .CH_CLK_WD          (8                            ),
	         .CH_DATA_WD         (116                          )
        `endif
	) u_intercon (
`ifdef USE_POWER_PINS
          .vccd1              (vccd1                        ),// User area 1 1.8V supply
          .vssd1              (vssd1                        ),// User area 1 digital ground
`endif
	   .ch_clk_in          ({
                          wbd_clk_int, 
                          wbd_clk_int, 
                          wbd_clk_int, 
                          wbd_clk_int, 
                          wbd_clk_int, 
                          wbd_clk_int, 
                          wbd_clk_int, 
                          wbd_clk_int}                      ),
	   .ch_clk_out         ({
                          wbd_clk_mbist4_rp, 
                          wbd_clk_mbist3_rp, 
                          wbd_clk_mbist2_rp, 
                          wbd_clk_mbist1_rp, 
                          wbd_clk_pinmux_rp, 
                          wbd_clk_uart_rp, 
                          wbd_clk_qspi_rp, 
                          wbd_clk_risc_rp}                  ),
	   .ch_data_in    ({
	                 bist_error_cnt3[3:0],
			 bist_correct[3],
			 bist_error[3],

	                 bist_error_cnt2[3:0],
			 bist_correct[2],
			 bist_error[2],

	                 bist_error_cnt1[3:0],
			 bist_correct[1],
			 bist_error[1],

	                 bist_error_cnt0[3:0],
			 bist_correct[0],
			 bist_error[0],
			 bist_done,
			 bist_sdo,
			 bist_shift,
			 bist_sdi,
			 bist_load,
			 bist_run,
			 bist_en,
			 

	                 soft_irq,
			 irq_lines[15:0],
			 fuse_mhartid[31:0],

		         cfg_cska_mbist4[3:0],
		         cfg_cska_mbist3[3:0],
		         cfg_cska_mbist2[3:0],
		         cfg_cska_mbist1[3:0],
			 cfg_cska_qspi_co[3:0],
		         cfg_cska_pinmux[3:0],
			 cfg_cska_uart[3:0],
		         cfg_cska_qspi[3:0],
                         cfg_cska_riscv[3:0]
			 } ),
	    .ch_data_out   ({
	                 bist_error_cnt3_rp[3:0],
			 bist_correct_rp[3],
			 bist_error_rp[3],

	                 bist_error_cnt2_rp[3:0],
			 bist_correct_rp[2],
			 bist_error_rp[2],

	                 bist_error_cnt1_rp[3:0],
			 bist_correct_rp[1],
			 bist_error_rp[1],

	                 bist_error_cnt0_rp[3:0],
			 bist_correct_rp[0],
			 bist_error_rp[0],
			 bist_done_rp,
			 bist_sdo_rp,
			 bist_shift_rp,
			 bist_sdi_rp,
			 bist_load_rp,
			 bist_run_rp,
			 bist_en_rp,

	                 soft_irq_rp,
			 irq_lines_rp[15:0],
			 fuse_mhartid_rp[31:0],

		         cfg_cska_mbist4_rp[3:0],
		         cfg_cska_mbist3_rp[3:0],
		         cfg_cska_mbist2_rp[3:0],
		         cfg_cska_mbist1_rp[3:0],
			 cfg_cska_qspi_co_rp[3:0],
		         cfg_cska_pinmux_rp[3:0],
			 cfg_cska_uart_rp[3:0],
		         cfg_cska_qspi_rp[3:0],
                         cfg_cska_riscv_rp[3:0]
                         }),
     // Clock Skew adjust
	         .wbd_clk_int        (wbd_clk_int                  ), 
	         .cfg_cska_wi        (cfg_cska_wi                  ), 
	         .wbd_clk_wi         (wbd_clk_wi_skew              ),

                 .clk_i              (wbd_clk_wi_skew              ), 
                 .rst_n              (wbd_int_rst_n                ),
                 .dcache_remap       (dcache_remap                 ),
                 .boot_remap         (boot_remap                   ),

         // Master 0 Interface
          .m0_wbd_dat_i       (wbd_int_dat_i                ),
          .m0_wbd_adr_i       (wbd_int_adr_i                ),
          .m0_wbd_sel_i       (wbd_int_sel_i                ),
          .m0_wbd_we_i        (wbd_int_we_i                 ),
          .m0_wbd_cyc_i       (wbd_int_cyc_i                ),
          .m0_wbd_stb_i       (wbd_int_stb_i                ),
          .m0_wbd_dat_o       (wbd_int_dat_o                ),
          .m0_wbd_ack_o       (wbd_int_ack_o                ),
          .m0_wbd_err_o       (wbd_int_err_o                ),
         
         // Master 1 Interface
          .m1_wbd_dat_i       (wbd_riscv_dmem_dat_i         ),
          .m1_wbd_adr_i       (wbd_riscv_dmem_adr_i         ),
          .m1_wbd_sel_i       (wbd_riscv_dmem_sel_i         ),
          .m1_wbd_we_i        (wbd_riscv_dmem_we_i          ),
          .m1_wbd_cyc_i       (wbd_riscv_dmem_stb_i         ),
          .m1_wbd_stb_i       (wbd_riscv_dmem_stb_i         ),
          .m1_wbd_dat_o       (wbd_riscv_dmem_dat_o         ),
          .m1_wbd_ack_o       (wbd_riscv_dmem_ack_o         ),
          .m1_wbd_err_o       (wbd_riscv_dmem_err_o         ),
         
         // Master 2 Interface
          .m2_wbd_dat_i       (wbd_riscv_dcache_dat_i       ),
          .m2_wbd_adr_i       (wbd_riscv_dcache_adr_i       ),
          .m2_wbd_sel_i       (wbd_riscv_dcache_sel_i       ),
          .m2_wbd_bl_i        (wbd_riscv_dcache_bl_i        ),
          .m2_wbd_bry_i       (wbd_riscv_dcache_bry_i       ),
          .m2_wbd_we_i        (wbd_riscv_dcache_we_i        ),
          .m2_wbd_cyc_i       (wbd_riscv_dcache_stb_i       ),
          .m2_wbd_stb_i       (wbd_riscv_dcache_stb_i       ),
          .m2_wbd_dat_o       (wbd_riscv_dcache_dat_o       ),
          .m2_wbd_ack_o       (wbd_riscv_dcache_ack_o       ),
          .m2_wbd_lack_o      (wbd_riscv_dcache_lack_o      ),
          .m2_wbd_err_o       (wbd_riscv_dcache_err_o       ),

         // Master 3 Interface
          .m3_wbd_adr_i       (wbd_riscv_icache_adr_i       ),
          .m3_wbd_sel_i       (wbd_riscv_icache_sel_i       ),
          .m3_wbd_bl_i        (wbd_riscv_icache_bl_i        ),
          .m3_wbd_bry_i       (wbd_riscv_icache_bry_i       ),
          .m3_wbd_we_i        (wbd_riscv_icache_we_i        ),
          .m3_wbd_cyc_i       (wbd_riscv_icache_stb_i       ),
          .m3_wbd_stb_i       (wbd_riscv_icache_stb_i       ),
          .m3_wbd_dat_o       (wbd_riscv_icache_dat_o       ),
          .m3_wbd_ack_o       (wbd_riscv_icache_ack_o       ),
          .m3_wbd_lack_o      (wbd_riscv_icache_lack_o      ),
          .m3_wbd_err_o       (wbd_riscv_icache_err_o       ),
         
         
         // Slave 0 Interface
         // .s0_wbd_err_i  (1'b0           ), - Moved inside IP
          .s0_wbd_dat_i       (wbd_spim_dat_i               ),
          .s0_wbd_ack_i       (wbd_spim_ack_i               ),
          .s0_wbd_lack_i      (wbd_spim_lack_i              ),
          .s0_wbd_dat_o       (wbd_spim_dat_o               ),
          .s0_wbd_adr_o       (wbd_spim_adr_o               ),
          .s0_wbd_bry_o       (wbd_spim_bry_o               ),
          .s0_wbd_bl_o        (wbd_spim_bl_o                ),
          .s0_wbd_sel_o       (wbd_spim_sel_o               ),
          .s0_wbd_we_o        (wbd_spim_we_o                ),  
          .s0_wbd_cyc_o       (wbd_spim_cyc_o               ),
          .s0_wbd_stb_o       (wbd_spim_stb_o               ),
         
         // Slave 1 Interface
         // .s1_wbd_err_i  (1'b0           ), - Moved inside IP
          .s1_wbd_dat_i       (wbd_uart_dat_i               ),
          .s1_wbd_ack_i       (wbd_uart_ack_i               ),
          .s1_wbd_dat_o       (wbd_uart_dat_o               ),
          .s1_wbd_adr_o       (wbd_uart_adr_o               ),
          .s1_wbd_sel_o       (wbd_uart_sel_o               ),
          .s1_wbd_we_o        (wbd_uart_we_o                ),  
          .s1_wbd_cyc_o       (wbd_uart_cyc_o               ),
          .s1_wbd_stb_o       (wbd_uart_stb_o               ),
         
         // Slave 2 Interface
         // .s2_wbd_err_i  (1'b0           ), - Moved inside IP
          .s2_wbd_dat_i       (wbd_glbl_dat_i               ),
          .s2_wbd_ack_i       (wbd_glbl_ack_i               ),
          .s2_wbd_dat_o       (wbd_glbl_dat_o               ),
          .s2_wbd_adr_o       (wbd_glbl_adr_o               ),
          .s2_wbd_sel_o       (wbd_glbl_sel_o               ),
          .s2_wbd_we_o        (wbd_glbl_we_o                ),  
          .s2_wbd_cyc_o       (wbd_glbl_cyc_o               ),
          .s2_wbd_stb_o       (wbd_glbl_stb_o               ),

         // Slave 3 Interface
         // .s3_wbd_err_i  (1'b0          ), - Moved inside IP
          .s3_wbd_dat_i       (wbd_mbist_dat_i              ),
          .s3_wbd_ack_i       (wbd_mbist_ack_i              ),
          .s3_wbd_lack_i      (wbd_mbist_lack_i             ),
          .s3_wbd_dat_o       (wbd_mbist_dat_o              ),
          .s3_wbd_adr_o       (wbd_mbist_adr_o              ),
          .s3_wbd_sel_o       (wbd_mbist_sel_o              ),
          .s3_wbd_bry_o       (wbd_mbist_bry_o              ),
          .s3_wbd_bl_o        (wbd_mbist_bl_o               ),
          .s3_wbd_we_o        (wbd_mbist_we_o               ),  
          .s3_wbd_cyc_o       (wbd_mbist_cyc_o              ),
          .s3_wbd_stb_o       (wbd_mbist_stb_o              )

	);


uart_i2c_usb_spi_top   u_uart_i2c_usb_spi (
`ifdef USE_POWER_PINS
         .vccd1                 (vccd1                    ),// User area 1 1.8V supply
         .vssd1                 (vssd1                    ),// User area 1 digital ground
`endif
	.wbd_clk_int            (wbd_clk_uart_rp          ), 
	.cfg_cska_uart          (cfg_cska_uart_rp         ), 
	.wbd_clk_uart           (wbd_clk_uart_skew        ),

        .uart_rstn              (uart_rst_n               ), // uart reset
        .i2c_rstn               (i2c_rst_n                ), // i2c reset
        .usb_rstn               (usb_rst_n                ), // USB reset
        .spi_rstn               (sspim_rst_n              ), // SPI reset
        .app_clk                (wbd_clk_uart_skew        ),
	.usb_clk                (usb_clk                  ),

        // Reg Bus Interface Signal
       .reg_cs                  (wbd_uart_stb_o           ),
       .reg_wr                  (wbd_uart_we_o            ),
       .reg_addr                (wbd_uart_adr_o[7:0]      ),
       .reg_wdata               (wbd_uart_dat_o           ),
       .reg_be                  (wbd_uart_sel_o           ),

       // Outputs
       .reg_rdata               (wbd_uart_dat_i           ),
       .reg_ack                 (wbd_uart_ack_i           ),

       // Pad interface
       .scl_pad_i               (i2cm_clk_i               ),
       .scl_pad_o               (i2cm_clk_o               ),
       .scl_pad_oen_o           (i2cm_clk_oen             ),

       .sda_pad_i               (i2cm_data_i              ),
       .sda_pad_o               (i2cm_data_o              ),
       .sda_padoen_o            (i2cm_data_oen            ),
     
       .i2cm_intr_o             (i2cm_intr_o              ),

       .uart_rxd                (uart_rxd                 ),
       .uart_txd                (uart_txd                 ),

       .usb_in_dp               (usb_dp_i                 ),
       .usb_in_dn               (usb_dn_i                 ),

       .usb_out_dp              (usb_dp_o                 ),
       .usb_out_dn              (usb_dn_o                 ),
       .usb_out_tx_oen          (usb_oen                  ),
       
       .usb_intr_o              (usb_intr_o               ),

      // SPIM Master
       .sspim_sck               (sspim_sck                ), 
       .sspim_so                (sspim_so                 ),  
       .sspim_si                (sspim_si                 ),  
       .sspim_ssn               (sspim_ssn                )  

     );


pinmux u_pinmux(
`ifdef USE_POWER_PINS
         .vccd1         (vccd1                 ),// User area 1 1.8V supply
         .vssd1         (vssd1                 ),// User area 1 digital ground
`endif
        //clk skew adjust
        .cfg_cska_pinmux        (cfg_cska_pinmux_rp        ),
        .wbd_clk_int            (wbd_clk_pinmux_rp         ),
        .wbd_clk_pinmux         (wbd_clk_pinmux_skew       ),

        // System Signals
        // Inputs
	.mclk                   (wbd_clk_pinmux_skew       ),
        .h_reset_n              (wbd_int_rst_n             ),

        // Reg Bus Interface Signal
        .reg_cs                 (wbd_glbl_stb_o            ),
        .reg_wr                 (wbd_glbl_we_o             ),
        .reg_addr               (wbd_glbl_adr_o            ),
        .reg_wdata              (wbd_glbl_dat_o            ),
        .reg_be                 (wbd_glbl_sel_o            ),

       // Outputs
        .reg_rdata              (wbd_glbl_dat_i            ),
        .reg_ack                (wbd_glbl_ack_i            ),


       // Risc configuration
        .fuse_mhartid           (fuse_mhartid              ),
        .irq_lines              (irq_lines                 ),
        .soft_irq               (soft_irq                  ),
        .user_irq               (user_irq                  ),
        .usb_intr               (usb_intr_o                ),
        .i2cm_intr              (i2cm_intr_o               ),

       // Digital IO
        .digital_io_out         (io_out                    ),
        .digital_io_oen         (io_oeb                    ),
        .digital_io_in          (io_in                     ),

       // SFLASH I/F
        .sflash_sck             (sflash_sck                ),
        .sflash_ss              (spi_csn                   ),
        .sflash_oen             (sflash_oen                ),
        .sflash_do              (sflash_do                 ),
        .sflash_di              (sflash_di                 ),


       // USB I/F
        .usb_dp_o               (usb_dp_o                  ),
        .usb_dn_o               (usb_dn_o                  ),
        .usb_oen                (usb_oen                   ),
        .usb_dp_i               (usb_dp_i                  ),
        .usb_dn_i               (usb_dn_i                  ),

       // UART I/F
        .uart_txd               (uart_txd                  ),
        .uart_rxd               (uart_rxd                  ),

       // I2CM I/F
        .i2cm_clk_o             (i2cm_clk_o                ),
        .i2cm_clk_i             (i2cm_clk_i                ),
        .i2cm_clk_oen           (i2cm_clk_oen              ),
        .i2cm_data_oen          (i2cm_data_oen             ),
        .i2cm_data_o            (i2cm_data_o               ),
        .i2cm_data_i            (i2cm_data_i               ),

       // SPI MASTER
        .spim_sck               (sspim_sck                 ),
        .spim_ss                (sspim_ssn                 ),
        .spim_miso              (sspim_so                  ),
        .spim_mosi              (sspim_si                  ),

      // UART MASTER I/F
        .uartm_rxd              (uartm_rxd                 ),
        .uartm_txd              (uartm_txd                 ),


	.pulse1m_mclk           (pulse1m_mclk              ),

	.pinmux_debug           (pinmux_debug              ),

       // BIST I/F
        .bist_en                (bist_en                   ),
        .bist_run               (bist_run                  ),
        .bist_load              (bist_load                 ),
        
        .bist_sdi               (bist_sdi                  ),
        .bist_shift             (bist_shift                ),
        .bist_sdo               (bist_sdo_rp               ),
        
        .bist_done              (bist_done_rp              ),
        .bist_error             (bist_error_rp             ),
        .bist_correct           (bist_correct_rp           ),
        .bist_error_cnt0        (bist_error_cnt0_rp        ),
        .bist_error_cnt1        (bist_error_cnt1_rp        ),
        .bist_error_cnt2        (bist_error_cnt2_rp        ),
        .bist_error_cnt3        (bist_error_cnt3_rp        )


   ); 
//------------- MBIST - 512x32             ----

mbist_wrapper  #(
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
          .vccd1              (vccd1                        ),// User area 1 1.8V supply
          .vssd1              (vssd1                        ),// User area 1 digital ground
`endif

     // Clock Skew adjust
	         .wbd_clk_int        (wbd_clk_mbist1_rp            ), 
	         .cfg_cska_mbist     (cfg_cska_mbist1_rp           ), 
	         .wbd_clk_mbist      (wbd_clk_mbist_skew           ),

	// WB I/F
                  .wb_clk2_i         (wbd_clk_mbist_skew  ),  
                  .wb_clk_i          (wbd_clk_mbist_skew  ),  
                  .wb_stb_i          (wbd_mbist_stb_o),  
	          .wb_cs_i           (wbd_mbist_adr_o[12:11]),
                  .wb_adr_i          (wbd_mbist_adr_o[BIST1_ADDR_WD-1:2]),  
                  .wb_we_i           (wbd_mbist_we_o ),  
                  .wb_dat_i          (wbd_mbist_dat_o),  
                  .wb_sel_i          (wbd_mbist_sel_o),  
                  .wb_bl_i           (wbd_mbist_bl_o),  
                  .wb_bry_i          (wbd_mbist_bry_o),  
                  .wb_dat_o          (wbd_mbist_dat_i),  
                  .wb_ack_o          (wbd_mbist_ack_i),  
                  .wb_lack_o         (wbd_mbist_lack_i),  
                  .wb_err_o          (                 ), 

	         .rst_n              (bist_rst_n                   ),

	
	         .bist_en            (bist_en_rp                   ),
	         .bist_run           (bist_run_rp                  ),
	         .bist_shift         (bist_shift_rp                ),
	         .bist_load          (bist_load_rp                 ),
	         .bist_sdi           (bist_sdi_rp                  ),

	         .bist_error_cnt3    (bist_error_cnt3              ),
	         .bist_error_cnt2    (bist_error_cnt2              ),
	         .bist_error_cnt1    (bist_error_cnt1              ),
	         .bist_error_cnt0    (bist_error_cnt0              ),
	         .bist_correct       (bist_correct                 ),
	         .bist_error         (bist_error                   ),
	         .bist_done          (bist_done                    ),
	         .bist_sdo           (bist_sdo                     ),

    // towards memory
    // PORT-A
          .mem_clk_a          (mem_clk_a                    ),
          .mem_addr_a0        (mem0_addr_a                  ),
          .mem_addr_a1        (mem1_addr_a                  ),
          .mem_addr_a2        (mem2_addr_a                  ),
          .mem_addr_a3        (mem3_addr_a                  ),
          .mem_cen_a          (mem_cen_a                    ),
          .mem_web_a          (mem_web_a                    ),
          .mem_mask_a0        (mem0_mask_a                  ),
          .mem_mask_a1        (mem1_mask_a                  ),
          .mem_mask_a2        (mem2_mask_a                  ),
          .mem_mask_a3        (mem3_mask_a                  ),
          .mem_din_a0         (mem0_din_a                   ),
          .mem_din_a1         (mem1_din_a                   ),
          .mem_din_a2         (mem2_din_a                   ),
          .mem_din_a3         (mem3_din_a                   ),
          .mem_dout_a0        (mem0_dout_a                  ),
          .mem_dout_a1        (mem1_dout_a                  ),
          .mem_dout_a2        (mem2_dout_a                  ),
          .mem_dout_a3        (mem3_dout_a                  ),
    // PORT-B
          .mem_clk_b          (mem_clk_b                    ),
          .mem_cen_b          (mem_cen_b                    ),
          .mem_addr_b0        (mem0_addr_b                  ),
          .mem_addr_b1        (mem1_addr_b                  ),
          .mem_addr_b2        (mem2_addr_b                  ),
          .mem_addr_b3        (mem3_addr_b                  )


);

sky130_sram_2kbyte_1rw1r_32x512_8 u_sram0_2kb(
`ifdef USE_POWER_PINS
          .vccd1              (vccd1                        ),// User area 1 1.8V supply
          .vssd1              (vssd1                        ),// User area 1 digital ground
`endif
// Port 0: RW
          .clk0               (mem_clk_a[0]                 ),
          .csb0               (mem_cen_a[0]                 ),
          .web0               (mem_web_a[0]                 ),
          .wmask0             (mem0_mask_a                  ),
          .addr0              (mem0_addr_a                  ),
          .din0               (mem0_din_a                   ),
          .dout0              (mem0_dout_a                  ),
// Port 1: R
          .clk1               (mem_clk_b[0]                 ),
          .csb1               (mem_cen_b[0]                 ),
          .addr1              (mem0_addr_b                  ),
          .dout1              (                             )
  );

sky130_sram_2kbyte_1rw1r_32x512_8 u_sram1_2kb(
`ifdef USE_POWER_PINS
          .vccd1              (vccd1                        ),// User area 1 1.8V supply
          .vssd1              (vssd1                        ),// User area 1 digital ground
`endif
// Port 0: RW
          .clk0               (mem_clk_a[1]                 ),
          .csb0               (mem_cen_a[1]                 ),
          .web0               (mem_web_a[1]                 ),
          .wmask0             (mem1_mask_a                  ),
          .addr0              (mem1_addr_a                  ),
          .din0               (mem1_din_a                   ),
          .dout0              (mem1_dout_a                  ),
// Port 1: R
          .clk1               (mem_clk_b[1]                 ),
          .csb1               (mem_cen_b[1]                 ),
          .addr1              (mem1_addr_b                  ),
          .dout1              (                             )
  );

sky130_sram_2kbyte_1rw1r_32x512_8 u_sram2_2kb(
`ifdef USE_POWER_PINS
          .vccd1              (vccd1                        ),// User area 1 1.8V supply
          .vssd1              (vssd1                        ),// User area 1 digital ground
`endif
// Port 0: RW
          .clk0               (mem_clk_a[2]                 ),
          .csb0               (mem_cen_a[2]                 ),
          .web0               (mem_web_a[2]                 ),
          .wmask0             (mem2_mask_a                  ),
          .addr0              (mem2_addr_a                  ),
          .din0               (mem2_din_a                   ),
          .dout0              (mem2_dout_a                  ),
// Port 1: R
          .clk1               (mem_clk_b[2]                 ),
          .csb1               (mem_cen_b[2]                 ),
          .addr1              (mem2_addr_b                  ),
          .dout1              (                             )
  );


sky130_sram_2kbyte_1rw1r_32x512_8 u_sram3_2kb(
`ifdef USE_POWER_PINS
          .vccd1              (vccd1                        ),// User area 1 1.8V supply
          .vssd1              (vssd1                        ),// User area 1 digital ground
`endif
// Port 0: RW
          .clk0               (mem_clk_a[3]                 ),
          .csb0               (mem_cen_a[3]                 ),
          .web0               (mem_web_a[3]                 ),
          .wmask0             (mem3_mask_a                  ),
          .addr0              (mem3_addr_a                  ),
          .din0               (mem3_din_a                   ),
          .dout0              (mem3_dout_a                  ),
// Port 1: R
          .clk1               (mem_clk_b[3]                 ),
          .csb1               (mem_cen_b[3]                 ),
          .addr1              (mem3_addr_b                  ),
          .dout1              (                             )
  );


/***
sar_adc  u_adc (
`ifdef USE_POWER_PINS
        .vccd1 (vccd1),// User area 1 1.8V supply
        .vssd1 (vssd1),// User area 1 digital ground
        .vccd2 (vccd1), // (vccd2),// User area 2 1.8V supply (analog) - DOTO: Need Fix
        .vssd2 (vssd1), // (vssd2),// User area 2 ground      (analog) - DOTO: Need Fix
`endif

    
        .clk           (wbd_clk_adc_rp ),// The clock (digital)
        .reset_n       (wbd_int_rst_n   ),// Active low reset (digital)

    // Reg Bus Interface Signal
        .reg_cs        (wbd_adc_stb_o   ),
        .reg_wr        (wbd_adc_we_o    ),
        .reg_addr      (wbd_adc_adr_o[7:0] ),
        .reg_wdata     (wbd_adc_dat_o   ),
        .reg_be        (wbd_adc_sel_o   ),

    // Outputs
        .reg_rdata     (wbd_adc_dat_i   ),
        .reg_ack       (wbd_adc_ack_i   ),

        .pulse1m_mclk  (pulse1m_mclk),


	// DAC I/F
        .sar2dac         (sar2dac       ), 
        //.analog_dac_out  (analog_dac_out) ,  // TODO: Need to connect to DAC O/P
        .analog_dac_out  (analog_io[6]) , 

        // ADC Input 
        .analog_din(analog_io[5:0])    // (Analog)

);
***/

/****
* TODO: Need to uncomment the DAC
DAC_8BIT u_dac (
     `ifdef USE_POWER_PINS
        .vdd(vccd2),
        .gnd(vssd2),
    `endif 
        .d0(sar2dac[0]),
        .d1(sar2dac[1]),
        .d2(sar2dac[2]),
        .d3(sar2dac[3]),
        .d4(sar2dac[4]),
        .d5(sar2dac[5]),
        .d6(sar2dac[6]),
        .d7(sar2dac[7]),
        .inp1(analog_io[6]),
        .out_v(analog_dac_out)
    );

**/

endmodule : user_project_wrapper
