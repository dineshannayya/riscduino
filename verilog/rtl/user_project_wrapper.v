/////////////////////////////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2021 , Dinesh Annayya                                                 ////
//                                                                                               ////
// Licensed under the Apache License, Version 2.0 (the "License");                               ////
// you may not use this file except in compliance with the License.                              ////
// You may obtain a copy of the License at                                                       ////
//                                                                                               ////
//      http://www.apache.org/licenses/LICENSE-2.0                                               ////
//                                                                                               ////
// Unless required by applicable law or agreed to in writing, software                           ////
// distributed under the License is distributed on an "AS IS" BASIS,                             ////
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.                      ////
// See the License for the specific language governing permissions and                           ////
// limitations under the License.                                                                ////
// SPDX-License-Identifier: Apache-2.0                                                           ////
// SPDX-FileContributor: Created by Dinesh Annayya <dinesh.annayya@gmail.com>                    ////
//                                                                                               ////
/////////////////////////////////////////////////////////////////////////////////////////////////////
////                                                                                             ////
////  Digital core                                                                               ////
////                                                                                             ////
////  This file is part of the riscduino cores project                                           ////
////  https://github.com/dineshannayya/riscduino.git                                             ////
////                                                                                             ////
////  Description                                                                                ////
////      This is digital core and integrate all the main block                                  ////
////      here.  Following block are integrated here                                             ////
////      1.  32 bit Risc V Core                                                                 ////
////      2.  Quad SPI Master(SPI Flash/SRAM)                                                    ////
////      3.  Wishbone Cross Bar                                                                 ////
////      4.  2 x UART                                                                           ////
////      5,  USB 1.1 Host                                                                       ////
////      6.  SPI Master (Single)                                                                ////
////      7.  TCM SRAM 2KB                                                                       ////
////      8.  2KB icache and 2KB dcache                                                          ////
////      9.  6 Channel ADC (Pending)                                                            ////
////      10. Pinmux with GPIO and 6 PWM                                                         ////
////      11. 15 x hardware Semaphore                                                            ////
////      12. 4 x ws281x driver                                                                  //// 
////      13. 3 x Hardware Timer                                                                 ////
////      14. UART Master                                                                        ////
////      15. SPI Slave (As Arduino ISP)                                                         ////
////      16. AES 126 Encription/Decryption                                                      ////
////      17. FPU (Single Precision)                                                             ////
////      18. RTC                                                                                ////
////      19. Random Generator                                                                   ////
////      20. NEC IR Receiver                                                                    ////
////      21. NEC IR Transmitter                                                                 ////
////                                                                                             ////
////  To Do:                                                                                     ////
////    nothing                                                                                  ////
////                                                                                             ////
////  Author(s):                                                                                 ////
////      - Dinesh Annayya, dinesh.annayya@gmail.com                                             ////
////                                                                                             ////
////  Revision :                                                                                 ////
////    0.1 - 16th Feb 2021, Dinesh A                                                            ////
////          Initial integration with Risc-V core +                                             ////
////          Wishbone Cross Bar + SPI  Master                                                   ////
////    0.2 - 17th June 2021, Dinesh A                                                           ////
////        1. In risc core, wishbone and core domain is                                         ////
////           created                                                                           ////
////        2. cpu and rtc clock are generated in glbl reg block                                 ////
////        3. in wishbone interconnect:- Stagging flop are added                                ////
////           at interface to break wishbone timing path                                        ////
////        4. buswidth warning are fixed inside spi_master                                      ////
////        modified rtl files are                                                               ////
////           verilog/rtl/digital_core/src/digital_core.sv                                      ////
////           verilog/rtl/digital_core/src/glbl_cfg.sv                                          ////
////           verilog/rtl/lib/wb_stagging.sv                                                    ////
////           verilog/rtl/syntacore/scr1/src/top/scr1_dmem_wb.sv                                ////
////           verilog/rtl/syntacore/scr1/src/top/scr1_imem_wb.sv                                ////
////           verilog/rtl/syntacore/scr1/src/top/scr1_top_wb.sv                                 ////
////           verilog/rtl/user_project_wrapper.v                                                ////
////           verilog/rtl/wb_interconnect/src/wb_interconnect.sv                                ////
////           verilog/rtl/spi_master/src/spim_clkgen.sv                                         ////
////           verilog/rtl/spi_master/src/spim_ctrl.sv                                           ////
////    0.3 - 20th June 2021, Dinesh A                                                           ////
////           1. uart core is integrated                                                        ////
////           2. 3rd Slave ported added to wishbone interconnect                                ////
////    0.4 - 25th June 2021, Dinesh A                                                           ////
////          Moved the pad logic inside sdram,spi,uart block to                                 ////
////          avoid logic at digital core level                                                  ////
////    0.5 - 25th June 2021, Dinesh A                                                           ////
////          Since carvel gives only 16MB address space for user                                ////
////          space, we have implemented indirect address select                                 ////
////          with 8 bit bank select given inside wb_host                                        ////
////          core Address = {Bank_Sel[7:0], Wb_Address[23:0]                                    ////
////          caravel user address space is                                                      ////
////          0x3000_0000 to 0x30FF_FFFF                                                         ////
////    0.6 - 27th June 2021, Dinesh A                                                           ////
////          Digital core level tie are moved inside IP to avoid                                ////
////          power hook up at core level                                                        ////
////          u_risc_top - test_mode & test_rst_n                                                ////
////          u_intercon - s*_wbd_err_i                                                          ////
////          unused wb_cti_i is removed from u_sdram_ctrl                                       ////
////    0.7 - 28th June 2021, Dinesh A                                                           ////
////          wb_interconnect master port are interchanged for                                   ////
////          better physical placement.                                                         ////
////          m0 - External HOST                                                                 ////
////          m1 - RISC IMEM                                                                     ////
////          m2 - RISC DMEM                                                                     ////
////    0.8 - 6th July 2021, Dinesh A                                                            ////
////          For Better SDRAM Interface timing we have taping                                   ////
////          sdram_clock goint to io_out[29] directly from                                      ////
////          global register block, this help in better SDRAM                                   ////
////          interface timing control                                                           ////
////    0.9 - 7th July 2021, Dinesh A                                                            ////
////          Removed 2 Unused port connection io_in[31:30] to                                   ////
////          spi_master to avoid lvs issue                                                      ////
////    1.0 - 28th July 2021, Dinesh A                                                           ////
////          i2cm integrated part of uart_i2cm module,                                          ////
////          due to number of IO pin limitation,                                                ////
////          Only UART OR I2C selected based on config mode                                     ////
////    1.1 - 1st Aug 2021, Dinesh A                                                             ////
////          usb1.1 host integrated part of uart_i2cm_usb module,                               ////
////          due to number of IO pin limitation,                                                ////
////          Only UART/I2C/USB selected based on config mode                                    ////
////    1.2 - 29th Sept 2021, Dinesh.A                                                           ////
////          1. copied the repo from yifive and renames as                                      ////
////             riscdunino                                                                      ////
////          2. Removed the SDRAM controlled                                                    ////
////          3. Added PinMux                                                                    ////
////          4. Added SAR ADC for 6 channel                                                     ////
////    1.3 - 30th Sept 2021, Dinesh.A                                                           ////
////          2KB SRAM Interface added to RISC Core                                              ////
////    1.4 - 13th Oct 2021, Dinesh A                                                            ////
////          Basic verification and Synthesis cleanup                                           ////
////    1.5 - 6th Nov 2021, Dinesh A                                                             ////
////          Clock Skew block moved inside respective block due                                 ////
////          to top-level power hook-up challenges for small IP                                 ////
////    1.6   Nov 14, 2021, Dinesh A                                                             ////
////          Major bug, clock divider inside the wb_host reset                                  ////
////          connectivity open is fixed                                                         ////
////    1.7   Nov 15, 2021, Dinesh A                                                             ////
////           Bug fix in clk_ctrl High/Low counter width                                        ////
////           Removed sram_clock                                                                ////
////    1.8  Nov 23, 2021, Dinesh A                                                              ////
////          Three Chip Specific Signature added at PinMux Reg                                  ////
////          reg_22,reg_23,reg_24                                                               ////
////    1.9  Dec 11, 2021, Dinesh A                                                              ////
////         2 x 2K SRAM added into Wishbone Interface                                           ////
////         Temporary ADC block removed                                                         ////
////    2.0  Dec 14, 2021, Dinesh A                                                              ////
////         Added two more 2K SRAM added into Wishbone Interface                                ////
////    2.1  Dec 16, 2021, Dinesh A                                                              ////
////      1.4 MBIST controller changed to single one                                             ////
////      2.Added one more SRAM to TCM memory                                                    ////
////      3.WishBone Interconnect chang to take care mbist changes                               ////
////      4.Pinmux change to take care of mbist changes                                          ////
////    2.2  Dec 20, 2021, Dinesh A                                                              ////
////      1. MBIST design issue fix for yosys                                                    ////
////      2. Full chip Timing and Transition clean-up                                            ////                   
////    2.3  Dec 24, 2021, Dinesh A                                                              ////
////      UART Master added with message handler at wb_host                                      ////
////    2.4  Jan 01, 2022, Dinesh A                                                              ////
////       LA[0] is added as soft reset option at wb_port                                        ////
////    2.5  Jan 06, 2022, Dinesh A                                                              ////
////       TCM RAM Bug fix inside syntacore                                                      ////
////    2.6  Jan 08, 2022, Dinesh A                                                              ////
////        Pinmux Interrupt Logic change                                                        ////
////    3.0  Jan 14, 2022, Dinesh A                                                              ////
////        Moving from riscv core from syntacore/scr1 to                                        ////
////        yfive/ycr1 on sankranti 2022 (A Hindu New Year)                                      ////
////    3.1  Jan 15, 2022, Dinesh A                                                              ////
////         Major changes in qspim logic to handle special mode                                 ////
////    3.2  Feb 02, 2022, Dinesh A                                                              ////
////         Bug fix around icache/dcache and wishbone burst                                     ////
////         access clean-up                                                                     ////
////    3.3  Feb 08, 2022, Dinesh A                                                              ////
////         support added spisram support in qspim ip                                           ////
////         There are 4 chip select available in qspim                                          ////
////         CS#0/CS#1 targeted for SPI FLASH                                                    ////
////         CS#2/CS#3 targeted for SPI SRAM                                                     ////
////    3.4  Feb 14, 2022, Dinesh A                                                              ////
////         burst mode supported added in imem buffer inside                                    ////
////         riscv core                                                                          ////
////    We have created seperate repo from this onwards                                          ////
////      SRAM based SOC is spin-out to                                                          ////
////      dineshannayya/riscduino_sram.git                                                       ////
////    This repo will remove mbist + SRAM and RISC SRAM will be                                 ////
////    replaced with DFRAM                                                                      ////
////    3.5  Feb 16, Dinesh A                                                                    ////
////       As SRAM from sky130A is not yet qualified,                                            ////
////       Following changes are done                                                            ////
////       A. riscv core cache and tcm interface changed to dffram                               ////  
////       B. removed the mbist controller + 4 SRAM                                              ////
////       C. mbist controller slave port in wb_intern removed                                   ////
////       D. Pinmux mbist port are removed                                                      ////
////       E. mbist related buffering are removed at wb_inter                                    ////
////    3.6  Feb 19, Dinesh A                                                                    ////
////       A.  Changed Module: wb_host                                                           ////
////       wishbone slave clock generation config increase from                                  ////
////       3 to 4 bit support clock source selection                                             ////
////       B.  Changed Module: qspim                                                             ////
////        1. Bug fix in spi rise and fall pulse relation w.r.t                                 ////
////           spi_clk. Note: Previous version work only with                                    ////
////           spi clock config = 0x2                                                            ////
////        2. spi_oen generation fix for different spi mode                                     ////
////        3. spi_csn de-assertion fix for different spi clk div                                ////
////    3.7  Mar 2 2022, Dinesh A                                                                ////
////       1. qspi cs# port mapping changed from io 28:25 to 25:28                               ////
////       2. sspi, bug fix in reg access and endian support added                               ////
////       3. Wishbone interconnect now support cross-connect                                    ////
////          feature                                                                            ////
////    3.8  Mar 10 2022, Dinesh A                                                               ////
////         1. usb chip select bug inside uart_* wrapper                                        ////
////         2. in wb_host, increased usb clk ctrl to 4 to 8 bit                                 ////
////    3.9  Mar 16 2022, Dinesh A                                                               ////
////         1. 3 Timer added                                                                    ////
////         2. Pinmux Register address movement                                                 ////
////         3. Risc fuse_mhartid is removed and internal tied                                   ////
////            inside risc core                                                                 ////
////         4. caravel wb addressing issue restrict to 0x300FFFFF                               ////
////    4.2  April 6 2022, Dinesh A                                                              ////
////         1. SSPI CS# increased from 1 to 4                                                   ////
////         2. uart port increase to two                                                        ////
////    4.3  May 24 2022, Dinesh A                                                               ////
////         Re targetted the design to mpw-6 tools set and risc                                 ////
////         core logic are timing optimized to 100mhz                                           ////
////    4.4  May 29 2022, Dinesh A                                                               ////
////         1. Digital PLL integrated and clock debug signal add                                ////
////           @digitial io [33] port                                                            ////
////    4.5  June 2 2022, Dinesh A                                                               ////
////         1. DFFRAM Replaced by SRAM                                                          ////
////    4.6  June 13 2022, Dinesh A                                                              ////
////         1. icache and dcache bypass config addded                                           ////
////    4.7  July 08 2022, Dinesh A                                                              ////
////          Pinmux changes to support SPI CS port matching to                                  ////
////          arduino                                                                            ////
////    4.8  July 20 2022, Dinesh A                                                              ////
////         SPI ISP boot option added in wb_host, spi slave uses                                ////
////         same spi master interface, but will be active only                                  ////
////         when internal SPI config disabled + RESET PIN = 0                                   ////
////    4.9  Aug 5 2022, Dinesh A                                                                ////
////         changes in sspim                                                                    ////
////           A. SPI Mode 0 to 3 support added,                                                 ////
////           B. SPI Duplex mode TX-RX Mode added                                               ////
////    5.0  Aug 15 2022, Dinesh A                                                               ////
////          A. 15 Hardware Semahore added                                                      ////
////          B. Pinmux Address Space are Split as                                               ////
////             `define ADDR_SPACE_PINMUX  32'h1002_0000                                        ////
////             `define ADDR_SPACE_GLBL    32'h1002_0000                                        ////
////             `define ADDR_SPACE_GPIO    32'h1002_0040                                        ////
////             `define ADDR_SPACE_PWM     32'h1002_0080                                        ////
////             `define ADDR_SPACE_TIMER   32'h1002_00C0                                        ////
////             `define ADDR_SPACE_SEMA    32'h1002_0100                                        ////
////    5.1  Aug 24 2022, Dinesh A                                                               ////
////          A. GPIO interrupt generation changed from 1 to 32                                  ////
////          B. Total interrupt to Riscv changed from 16 to 32                                  ////
////          C. uart_master disable option added at pinmux                                      ////
////          D. Timer interrupt related clean-up                                                ////
////          E. 4x ws281x driver logic added                                                    ////
////          F. 4x ws281x driver are mux with 16x gpio                                          ////
////          G. gpio type select the normal gpio vs ws281x                                      ////
////    5.2  Aug 26 2022, Dinesh A                                                               ////
////          A. We have copied the user_defines.h from caravel                                  ////
////          and configured all the GPIO from 5 onwards as                                      ////
////          GPIO_MODE_USER_STD_BIDIRECTIONAL                                                   ////
////                                                                                             ////
////          As digitial-io[0-5] reserved at power up.                                          ////
////          B. to keep at least one uart access,                                               ////
////              we have moved UART_RXD[1] from io[3] to io[6]                                  ////
////          C. SPI Slave SSN move from io[0] to [7]                                            ////
////    5.3  Sept 2 2022, Dinesh A                                                               ////
////          A. System Strap implementation                                                     ////
////          B. Arduino pins are moved to take care of caravel                                  ////
////            digital-io[0-4] resevred                                                         ////
////          C. global register space increased from 16 to 32                                   ////
////          D. reset fsm is implementation with soft reboot                                    ////
////             option                                                                          ////
////          E. strap based booting option added for qspi                                       ////
////    5.4  Sept 7 2022, Dinesh A                                                               ////
////          A. PLL configuration are moved from wb_host to                                     ////
////          pinmux to help risc core to do pll config and reboot                               ////
////          B. PLL configuration are kept in p_reset_n to avoid                                ////
////           initialized on soft reboot.                                                       ////
////          C. Master Uart has two strap bit to control the                                    ////
////          boot up config                                                                     ////
////          2'b00 - 50Mhz, 2'b01 - 40Mhz, 2'b10 - 50Mhz,                                       ////
////          2'b11 - LA control                                                                 ////
////    5.5  Sept 14 2022, Dinesh A                                                              ////
////          A. Auto Baud detection added in uart master as                                     ////
////          power on user_clock1 is not decided, strap def                                     ////
////          changed                                                                            ////
////          2'b00 - Auto, 2'b01 - 50Mhz, 2'b10 - 4Mhz,                                         ////
////          2'b11 - LA control                                                                 ////
////          B. digital_pll is re-synth with maual placement                                    ////
////    5.6  Sept 29 2022, Dinesh A                                                              ////
////         A. 4x 8bit DAC Integration                                                          ////
////         B. clock skew control added for core clock                                          ////
////    5.7  Nov 7, 2022, Dinesh A                                                               ////
////         A. AES 128 Bit Encription and Decryption integration                                ////
////         B. FPU Integration                                                                  ////
////    5.8  Nov 20, 2022, Dinesh A                                                              ////
////         A. Pinmux - Double Sync added for usb & i2c inter                                   ////
////    5.9  Nov 25, 2022, Dinesh A                                                              ////
////         cpu_clk will be feed through wb_interconnect for                                    ////
////         buffering purpose                                                                   ////
////    6.0  Nov 27, 2022, Dinesh A                                                              ////
////         MPW-7 Timing clean setup                                                            ////
////    6.1  Nov 28, 2022, Dinesh A                                                              ////
////        Power Hook up connectivity issue for                                                 ////
////        aes,fpu,bus repeater is fixed                                                        ////
////    6.2  Dec 4, 2022, Dinesh A                                                               ////
////         Bus repeater north/south/east/west added for better                                 ////
////         global buffering                                                                    ////
////    6.3  Dec 7, 2022, Dinesh A                                                               ////
////         A. peripheral block integration                                                     ////
////         B. RTC Integration                                                                  ////
////    6.4  Dec 13, 2022, Dinesh A                                                              ////
////         A. Random Generator Integration                                                     ////
////         B. NEC IR Receiver Integration                                                      ////
////         C. NEC IR Transmitter Integration                                                   ////
////      Bug Fix In Pinmux                                                                      ////
////         WS281x IO direction fix                                                             //// 
////    6.5  Dec 24, 2022, Dinesh A                                                              ////
////         A. uart_core async fifo mode set to fast access                                     ////
////         B. CTS buffering enabled in all blocks                                              ////
////    6.6  Jan 6, 2023, Dinesh A                                                               ////
////         A. Move to MPW-9 Openlane Tool Chain                                                ////
////         B. Stepper Motor Integration                                                        ////
////    6.7 Jan 29, 2023, Dinesh A                                                               ////
////        block qspi:                                                                          ////
////          A. As part of MPW-2 Silicon Bug-Fx:-                                               ////
////             SPI Flash Power Up command (0xAB) need 3 us delay before the next command       ////
////          B. FAST SIM connected to PORT for better GateSim control                           ////
////    6.8 Feb 11, 2023, Dinesh A                                                               ////
////         A. Centrialized Source Clock gating logic added at wishbone inter connect           ////
////         B. QSpim Modified to generate Idle indication                                       ////
////         C. Register Space Allocated for Wishbone Interconnect                               ////
////    6.9 Mar 5, 2023, Dinesh A                                                                ////
////         A. Risc core Tap access enabled                                                     ////
////         B. all the cpu clk are routed from ycr_iconnect                                     ////
////                                                                                             ////
/////////////////////////////////////////////////////////////////////////////////////////////////////
////                                                                                             ////
////          Copyright (C) 2000 Authors and OPENCORES.ORG                                       ////
////                                                                                             ////
////          This source file may be used and distributed without                               ////
////          restriction provided that this copyright statement is not                          ////
////          removed from the file and that any derivative work contains                        ////
////          the original copyright notice and the associated disclaimer.                       ////
////                                                                                             ////
////          This source file is free software; you can redistribute it                         ////
////          and/or modify it under the terms of the GNU Lesser General                         ////
////          Public License as published by the Free Software Foundation;                       ////
////          either version 2.1 of the License, or (at your option) any                         ////
////          later version.                                                                     ////
////                                                                                             ////
////          This source is distributed in the hope that it will be                             ////
////          useful, but WITHOUT ANY WARRANTY; without even the implied                         ////
////          warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR                            ////
////          PURPOSE.  See the GNU Lesser General Public License for more                       ////
////          details.                                                                           ////
////                                                                                             ////
////          You should have received a copy of the GNU Lesser General                          ////
////          Public License along with this source; if not, download it                         ////
////          from http://www.opencores.org/lgpl.shtml                                           ////
////                                                                                             ////
/////////////////////////////////////////////////////////////////////////////////////////////////////

/*********************************************************************
    Memory Map:                                               
                                                              
       SOC Memory Map                                         
       0x0000_0000 to 0x0FFF_FFFF  - QSPIM MEMORY             
       0x1000_0000 to 0x1000_00FF  - QSPIM REG
       0x1001_0000 to 0x1001_003F  - UART0
       0x1001_0040 to 0x1001_007F  - I2
       0x1001_0080 to 0x1001_00BF  - USB
       0x1001_00C0 to 0x1001_00FF  - SSPIM
       0x1001_0100 to 0x1001_013F  - UART1
       0x1002_0000 to 0x1002_00FF  - PINMUX

       Caravel Memory Map:
-----------------------------------------------------------------------
      caravel user space is 0x3000_0000 to 0x300F_FFFF
      So we have allocated 
      0x3008_0000 - 0x3008_00FF - Assigned to WB Host Address Space
      Since We need more than 16MB Address space to access SDRAM/SPI we have
      added indirect MSB 13 bit address select option
      So Address will be {Bank_Sel[15:3], wbm_adr_i[18:0]}
 ---------------------------------------------------------------------
       0x3080_0000 to 0x3080_00FF  - WB HOST 
       0x3000_0000 to 0x307F_FFFF  - Indirect Address
                                     {Bank_Sel[15:3],WB ADDR[18:0]}
***********************************************************************/
/***********************************************************************
 * Caravel I/O mapping 
 *
 * mprj_io[37]  io_in/out/oeb/in_3v3[26]  ---                    ---
 * mprj_io[36]  io_in/out/oeb/in_3v3[25]  ---                    ---
 * mprj_io[35]  io_in/out/oeb/in_3v3[24]  gpio_analog/noesd[17]  ---
 * mprj_io[34]  io_in/out/oeb/in_3v3[23]  gpio_analog/noesd[16]  ---
 * mprj_io[33]  io_in/out/oeb/in_3v3[22]  gpio_analog/noesd[15]  ---
 * mprj_io[32]  io_in/out/oeb/in_3v3[21]  gpio_analog/noesd[14]  ---
 * mprj_io[31]  io_in/out/oeb/in_3v3[20]  gpio_analog/noesd[13]  ---
 * mprj_io[30]  io_in/out/oeb/in_3v3[19]  gpio_analog/noesd[12]  ---
 * mprj_io[29]  io_in/out/oeb/in_3v3[18]  gpio_analog/noesd[11]  ---
 * mprj_io[28]  io_in/out/oeb/in_3v3[17]  gpio_analog/noesd[10]  ---
 * mprj_io[27]  io_in/out/oeb/in_3v3[16]  gpio_analog/noesd[9]   ---
 * mprj_io[26]  io_in/out/oeb/in_3v3[15]  gpio_analog/noesd[8]   ---
 * mprj_io[25]  io_in/out/oeb/in_3v3[14]  gpio_analog/noesd[7]   ---
 * mprj_io[24]  ---                       ---                    user_analog[10]
 * mprj_io[23]  ---                       ---                    user_analog[9]
 * mprj_io[22]  ---                       ---                    user_analog[8]
 * mprj_io[21]  ---                       ---                    user_analog[7]
 * mprj_io[20]  ---                       ---                    user_analog[6]  clamp[2]
 * mprj_io[19]  ---                       ---                    user_analog[5]  clamp[1]
 * mprj_io[18]  ---                       ---                    user_analog[4]  clamp[0]
 * mprj_io[17]  ---                       ---                    user_analog[3]
 * mprj_io[16]  ---                       ---                    user_analog[2]
 * mprj_io[15]  ---                       ---                    user_analog[1]
 * mprj_io[14]  ---                       ---                    user_analog[0]
 * mprj_io[13]  io_in/out/oeb/in_3v3[13]  gpio_analog/noesd[6]   ---
 * mprj_io[12]  io_in/out/oeb/in_3v3[12]  gpio_analog/noesd[5]   ---
 * mprj_io[11]  io_in/out/oeb/in_3v3[11]  gpio_analog/noesd[4]   ---
 * mprj_io[10]  io_in/out/oeb/in_3v3[10]  gpio_analog/noesd[3]   ---
 * mprj_io[9]   io_in/out/oeb/in_3v3[9]   gpio_analog/noesd[2]   ---
 * mprj_io[8]   io_in/out/oeb/in_3v3[8]   gpio_analog/noesd[1]   ---
 * mprj_io[7]   io_in/out/oeb/in_3v3[7]   gpio_analog/noesd[0]   ---
 * mprj_io[6]   io_in/out/oeb/in_3v3[6]   ---                    ---
 * mprj_io[5]   io_in/out/oeb/in_3v3[5]   ---                    ---
 * mprj_io[4]   io_in/out/oeb/in_3v3[4]   ---                    ---
 * mprj_io[3]   io_in/out/oeb/in_3v3[3]   ---                    ---
 * mprj_io[2]   io_in/out/oeb/in_3v3[2]   ---                    ---
 * mprj_io[1]   io_in/out/oeb/in_3v3[1]   ---                    ---
 * mprj_io[0]   io_in/out/oeb/in_3v3[0]   ---                    ---


************************************************************************/

`include "user_params.svh"

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
wire   [2:0]                   wbd_riscv_dmem_bl_i                    ; // byte enable
wire                           wbd_riscv_dmem_bry_i                   ; // burst access ready
wire   [WB_WIDTH-1:0]          wbd_riscv_dmem_dat_o                   ; // data input
wire                           wbd_riscv_dmem_ack_o                   ; // acknowlegement
wire                           wbd_riscv_dmem_lack_o                  ; // acknowlegement
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
wire                           wbd_pinmux_stb_o                       ; // strobe/request
wire   [10:0]                  wbd_pinmux_adr_o                       ; // address
wire                           wbd_pinmux_we_o                        ; // write
wire   [WB_WIDTH-1:0]          wbd_pinmux_dat_o                       ; // data output
wire   [3:0]                   wbd_pinmux_sel_o                       ; // byte enable
wire                           wbd_pinmux_cyc_o                       ;
wire   [WB_WIDTH-1:0]          wbd_pinmux_dat_i                       ; // data input
wire                           wbd_pinmux_ack_i                       ; // acknowlegement
wire                           wbd_pinmux_err_i                       ; // error

//---------------------------------------------------------------------
//    Global Register Wishbone Interface
//---------------------------------------------------------------------
wire                           wbd_uart_stb_o                         ; // strobe/request
wire   [8:0]                   wbd_uart_adr_o                         ; // address
wire                           wbd_uart_we_o                          ; // write
wire   [31:0]                  wbd_uart_dat_o                         ; // data output
wire   [3:0]                   wbd_uart_sel_o                         ; // byte enable
wire                           wbd_uart_cyc_o                         ;
wire   [31:0]                  wbd_uart_dat_i                         ; // data input
wire                           wbd_uart_ack_i                         ; // acknowlegement
wire                           wbd_uart_err_i                         ;  // error


//----------------------------------------------------
//  CPU Configuration
//----------------------------------------------------
wire                           cpu_intf_rst_n                         ;
wire  [3:0]                    cpu_core_rst_n                         ;
wire                           qspim_rst_n                            ;
wire                           sspim_rst_n                            ;
wire [1:0]                     uart_rst_n                             ; // uart reset
wire                           i2c_rst_n                              ; // i2c reset
wire                           usb_rst_n                              ; // i2c reset
wire                           bist_rst_n                             ; // i2c reset
wire                           cpu_clk                                ;
wire                           rtc_clk                                ;
wire                           usb_clk                                ;
wire                           wbd_clk_int                            ;
wire                           wbd_clk_wh                             ;

wire                           wbd_clk_spi                            ;
wire                           wbd_clk_pinmux                         ;
wire                           wbd_int_rst_n                          ;
wire                           wbd_pll_rst_n                          ;

wire [31:0]                    irq_lines                              ;
wire                           soft_irq                               ;


wire [7:0]                     cfg_glb_ctrl                           ;
wire [31:0]                    cfg_clk_skew_ctrl1                     ;
wire [31:0]                    cfg_clk_skew_ctrl2                     ;
wire [3:0]                     cfg_wcska_wi                           ; // clock skew adjust for wishbone interconnect
wire [3:0]                     cfg_wcska_wh                           ; // clock skew adjust for web host
wire [3:0]                     cfg_wcska_peri                         ; // clock skew adjust for peripheral

wire [3:0]                     cfg_wcska_riscv                        ; // clock skew adjust for riscv
wire [3:0]                     cfg_wcska_uart                         ; // clock skew adjust for uart
wire [3:0]                     cfg_wcska_qspi                         ; // clock skew adjust for spi
wire [3:0]                     cfg_wcska_pinmux                       ; // clock skew adjust for pinmux
wire [3:0]                     cfg_wcska_qspi_co                      ; // clock skew adjust for global reg

// Bus Repeater Signals  output from Wishbone Interface
wire [3:0]                     cfg_wcska_riscv_rp                      ; // clock skew adjust for riscv
wire [3:0]                     cfg_wcska_uart_rp                       ; // clock skew adjust for uart
wire [3:0]                     cfg_wcska_qspi_rp                       ; // clock skew adjust for spi
wire [3:0]                     cfg_wcska_pinmux_rp                     ; // clock skew adjust for pinmux
wire [3:0]                     cfg_wcska_qspi_co_rp                    ; // clock skew adjust for global reg
wire [3:0]                     cfg_wcska_peri_rp                       ; // clock skew adjust for peripheral 

wire [31:0]                    irq_lines_rp                           ; // Repeater
wire                           soft_irq_rp                            ; // Repeater


// Progammable Clock Skew inserted signals
wire                           wbd_clk_wi_skew                        ; // clock for wishbone interconnect with clock skew
wire                           wbd_clk_riscv_skew                     ; // clock for riscv with clock skew
wire                           wbd_clk_uart_skew                      ; // clock for uart with clock skew
wire                           wbd_clk_spi_skew                       ; // clock for spi with clock skew
wire                           wbd_clk_glbl_skew                      ; // clock for global reg with clock skew
wire                           wbd_clk_wh_skew                        ; // clock for global reg

wire                           peri_wbclk                             ;


wire [31:0]                    spi_debug                              ;
wire [31:0]                    pinmux_debug                           ;
wire                           dbg_clk_mon                            ; // clock monitoring port
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
wire       [1:0]               uart_txd                               ;
wire       [1:0]               uart_rxd                               ;

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
wire    [3:0]                  sspim_ssn                              ; // cs_n

// SPIS I/F
wire                           sspis_sck                              ; // clock out
wire                           sspis_so                               ; // serial data out
wire                           sspis_si                               ; // serial data in
wire                           sspis_ssn                              ; // cs_n


wire                           usb_intr_o                             ;
wire                           i2cm_intr_o                            ;

wire                           qspim_mclk                             ;
wire                           uart_mclk                              ;
wire                           pinmux_mclk                            ;

wire                           qspim_idle                             ;

//------------------------------------------------------------
// AES Integration local decleration
//------------------------------------------------------------
wire                           cpu_clk_aes                            ;
wire                           cpu_clk_aes_skew                       ;
wire [3:0]                     cfg_ccska_aes                          ;
wire [3:0]                     cfg_ccska_aes_rp                       ;
wire                           aes_dmem_req                           ;
wire                           aes_dmem_cmd                           ;
wire [1:0]                     aes_dmem_width                         ;
wire [6:0]                     aes_dmem_addr                          ;
wire [31:0]                    aes_dmem_wdata                         ;
wire                           aes_dmem_req_ack                       ;
wire [31:0]                    aes_dmem_rdata                         ;
wire [1:0]                     aes_dmem_resp                          ;

//------------------------------------------------------------
// FPU Integration local decleration
//------------------------------------------------------------
wire                           cpu_clk_fpu                           ;
wire                           cpu_clk_fpu_skew                       ;
wire [3:0]                     cfg_ccska_fpu                          ;
wire [3:0]                     cfg_ccska_fpu_rp                       ;
wire                           fpu_dmem_req                           ;
wire                           fpu_dmem_cmd                           ;
wire [1:0]                     fpu_dmem_width                         ;
wire [4:0]                     fpu_dmem_addr                          ;
wire [31:0]                    fpu_dmem_wdata                         ;
wire                           fpu_dmem_req_ack                       ;
wire [31:0]                    fpu_dmem_rdata                         ;
wire [1:0]                     fpu_dmem_resp                          ;

//----------------------------------------------------------------
//  UART Master I/F
//  -------------------------------------------------------------
wire                           uartm_rxd                              ;
wire                           uartm_txd                              ;

//----------------------------------------------------------------
//  Digital PLL I/F
//  -------------------------------------------------------------
wire                           cfg_pll_enb                            ; // Enable PLL
wire [4:0]                     cfg_pll_fed_div                        ; // PLL feedback division ratio
wire                           cfg_dco_mode                           ; // Run PLL in DCO mode
wire [25:0]                    cfg_dc_trim                            ; // External trim for DCO mode
wire                           pll_ref_clk                            ; // Input oscillator to match
wire [1:0]                     pll_clk_out                            ; // Two 90 degree clock phases

wire [3:0]                     spi_csn                                ;
wire                           xtal_clk                               ;
wire                           e_reset_n                              ;
wire                           p_reset_n                              ;
wire                           s_reset_n                              ;
wire                           cfg_strap_pad_ctrl                     ;

wire                           e_reset_n_rp                           ;
wire                           p_reset_n_rp                           ;
wire                           s_reset_n_rp                           ;
wire                           cfg_strap_pad_ctrl_rp                  ;
//----------------------------------------------------------------------
// DAC Config
//----------------------------------------------------------------------
wire [7:0]                     cfg_dac0_mux_sel                       ;
wire [7:0]                     cfg_dac1_mux_sel                       ;
wire [7:0]                     cfg_dac2_mux_sel                       ;
wire [7:0]                     cfg_dac3_mux_sel                       ;

//---------------------------------------------------------------------
// Peripheral Reg I/F
//---------------------------------------------------------------------
wire                           reg_peri_cs                            ;
wire                           reg_peri_wr                            ;
wire [10:0]                    reg_peri_addr                          ;
wire [31:0]                    reg_peri_wdata                         ;
wire [3:0]                     reg_peri_be                            ;

wire [31:0]                    reg_peri_rdata                         ;
wire                           reg_peri_ack                           ;

wire                           rtc_intr                               ; // RTC interrupt

//---------------------------------------------------------------------
// IR Receiver
//---------------------------------------------------------------------
wire                           ir_rx                                 ; // IR Receiver Input from pad
wire                           ir_tx                                 ; // IR Transmitter
wire                           ir_intr                               ; // IR Interrupt
`ifdef YCR_DBG_EN
    // -- JTAG I/F
wire                           riscv_trst_n                          ;
wire                           riscv_tck                             ;
wire                           riscv_tms                             ;
wire                           riscv_tdi                             ;
wire                           riscv_tdo                             ;
wire                           riscv_tdo_en                          ;
`endif // YCR_DBG_EN
//---------------------------------------------------------------------
// Strap
//---------------------------------------------------------------------
wire [31:0]                    system_strap                           ;
wire [31:0]                    strap_sticky                           ;
wire [1:0]                     strap_uartm                            ;

wire [31:0]                    system_strap_rp                        ;
wire [31:0]                    strap_sticky_rp                        ;
wire [1:0]                     strap_uartm_rp                         ;

wire [1:0]  strap_qspi_flash       = system_strap[`STRAP_QSPI_FLASH];
wire        strap_qspi_sram        = system_strap[`STRAP_QSPI_SRAM];
wire        strap_qspi_pre_sram    = system_strap[`STRAP_QSPI_PRE_SRAM];
wire        strap_qspi_init_bypass = system_strap[`STRAP_QSPI_INIT_BYPASS];


//--------------------------------------------------------------------------
// Pinmux Risc core config
// -------------------------------------------------------------------------
wire [15:0]                    cfg_riscv_ctrl;
wire [3:0]                     cfg_riscv_sram_lphase   = cfg_riscv_ctrl[3:0];
wire [2:0]                     cfg_riscv_cache_ctrl    = cfg_riscv_ctrl[6:4];
wire [1:0]                     cfg_riscv_debug_sel     = cfg_riscv_ctrl[9:8];
wire                           cfg_bypass_icache       = cfg_riscv_ctrl[10];
wire                           cfg_bypass_dcache       = cfg_riscv_ctrl[11];

/////////////////////////////////////////////////////////
// System/WB Clock Skew Ctrl
////////////////////////////////////////////////////////

assign cfg_wcska_wi          = cfg_clk_skew_ctrl1[3:0];
assign cfg_wcska_wh          = cfg_clk_skew_ctrl1[7:4];
assign cfg_wcska_riscv       = cfg_clk_skew_ctrl1[11:8];
assign cfg_wcska_qspi        = cfg_clk_skew_ctrl1[15:12];
assign cfg_wcska_uart        = cfg_clk_skew_ctrl1[19:16];
assign cfg_wcska_pinmux      = cfg_clk_skew_ctrl1[23:20];
assign cfg_wcska_qspi_co     = cfg_clk_skew_ctrl1[27:24];
assign cfg_wcska_peri        = cfg_clk_skew_ctrl1[31:28];

/////////////////////////////////////////////////////////
// RISCV Clock skew control
/////////////////////////////////////////////////////////
wire [3:0] cfg_ccska_riscv_intf_rp  ;
wire [3:0] cfg_ccska_riscv_icon_rp  ;
wire [3:0] cfg_ccska_riscv_core0_rp ;
wire [3:0] cfg_ccska_riscv_core1_rp ;
wire [3:0] cfg_ccska_riscv_core2_rp ;
wire [3:0] cfg_ccska_riscv_core3_rp ;

wire [3:0]   cfg_ccska_riscv_intf   = cfg_clk_skew_ctrl2[3:0];
wire [3:0]   cfg_ccska_riscv_icon   = cfg_clk_skew_ctrl2[7:4];
wire [3:0]   cfg_ccska_riscv_core0  = cfg_clk_skew_ctrl2[11:8];
wire [3:0]   cfg_ccska_riscv_core1  = cfg_clk_skew_ctrl2[15:12];
wire [3:0]   cfg_ccska_riscv_core2  = cfg_clk_skew_ctrl2[19:16];
wire [3:0]   cfg_ccska_riscv_core3  = cfg_clk_skew_ctrl2[23:20];
assign       cfg_ccska_aes          = cfg_clk_skew_ctrl2[27:24];
assign       cfg_ccska_fpu          = cfg_clk_skew_ctrl2[31:28];

wire [127:0] la_data_out_int    = {pinmux_debug,spi_debug,riscv_debug};

wire   int_pll_clock       = pll_clk_out[0];

//-------------------------------------
// cpu clock repeater mapping
//-------------------------------------
wire [2:0] cpu_clk_rp;

wire       cpu_clk_rp_risc   = cpu_clk_rp[0];
wire       cpu_clk_rp_pinmux = cpu_clk_rp[2];

//----------------------------------------------------------
// Bus Repeater Initiatiation
//----------------------------------------------------------
wire  [37:0]                io_in_rp           ;
wire  [37:0]                io_in_rp1          ;
wire  [37:0]                io_in_rp2          ;
wire  [37:0]                io_out_int         ;
wire  [37:0]                io_oeb_int         ;
wire  [37:0]                io_out_rp1         ;
wire  [37:0]                io_oeb_rp1         ;
wire                        user_clock2_rp     ;

`include "bus_repeater.sv"

/***********************************************
 Wishbone HOST
*************************************************/

wb_host u_wb_host(
`ifdef USE_POWER_PINS
          .vccd1                   (vccd1                   ),// User area 1 1.8V supply
          .vssd1                   (vssd1                   ),// User area 1 digital ground
`endif

          .cfg_fast_sim            (cfg_fast_sim            ),
          .user_clock1             (wb_clk_i_rp             ),
          .user_clock2             (user_clock2_rp          ),
          .int_pll_clock           (int_pll_clock           ),

          .cpu_clk                 (cpu_clk                 ),

       // to/from Pinmux
          .xtal_clk                (xtal_clk                ),
	      .e_reset_n               (e_reset_n               ),  // external reset
	      .p_reset_n               (p_reset_n               ),  // power-on reset
          .s_reset_n               (s_reset_n               ),  // soft reset
          .cfg_strap_pad_ctrl      (cfg_strap_pad_ctrl      ),
	      .system_strap            (system_strap            ),
	      .strap_sticky            (strap_sticky_rp         ),
	      .strap_uartm             (strap_uartm_rp          ),

          .wbd_int_rst_n           (wbd_int_rst_n           ),
          .wbd_pll_rst_n           (wbd_pll_rst_n           ),

    // Master Port
          .wbm_rst_i               (wb_rst_i_rp             ),  
          .wbm_clk_i               (wb_clk_i_rp             ),  
          .wbm_cyc_i               (wbs_cyc_i_rp            ),  
          .wbm_stb_i               (wbs_stb_i_rp            ),  
          .wbm_adr_i               (wbs_adr_i_rp            ),  
          .wbm_we_i                (wbs_we_i_rp             ),  
          .wbm_dat_i               (wbs_dat_i_rp            ),  
          .wbm_sel_i               (wbs_sel_i_rp            ),  
          .wbm_dat_o               (wbs_dat_int_o           ),  
          .wbm_ack_o               (wbs_ack_int_o           ),  
          .wbm_err_o               (                        ),  

    // Clock Skeq Adjust
          .wbd_clk_int             (wbd_clk_int             ),
          .wbd_clk_wh              (wbd_clk_wh              ),  
          .cfg_cska_wh             (cfg_wcska_wh             ),

    // Slave Port
          .wbs_clk_out             (wbd_clk_int             ),
          .wbs_clk_i               (wbd_clk_wh              ),  
          .wbs_cyc_o               (wbd_int_cyc_i           ),  
          .wbs_stb_o               (wbd_int_stb_i           ),  
          .wbs_adr_o               (wbd_int_adr_i           ),  
          .wbs_we_o                (wbd_int_we_i            ),  
          .wbs_dat_o               (wbd_int_dat_i           ),  
          .wbs_sel_o               (wbd_int_sel_i           ),  
          .wbs_dat_i               (wbd_int_dat_o           ),  
          .wbs_ack_i               (wbd_int_ack_o           ),  
          .wbs_err_i               (wbd_int_err_o           ),  

          .cfg_clk_skew_ctrl1      (cfg_clk_skew_ctrl1      ),
          .cfg_clk_skew_ctrl2      (cfg_clk_skew_ctrl2      ),

          .la_data_in              (la_data_in_rp[17:0]     ),

          .uartm_rxd               (uartm_rxd               ),
          .uartm_txd               (uartm_txd               ),

          .sclk                    (sspis_sck               ),
          .ssn                     (sspis_ssn               ),
          .sdin                    (sspis_si                ),
          .sdout                   (sspis_so                ),
          .sdout_oen               (                        )



    );

/****************************************************************
  Digital PLL
*****************************************************************/

// This rtl/gds picked from efabless caravel project 
dg_pll   u_pll(
`ifdef USE_POWER_PINS
    .VPWR                           (vccd1                  ),
    .VGND                           (vssd1                  ),
`endif
    .resetb                         (wbd_pll_rst_n          ), 
    .enable                         (cfg_pll_enb            ), 
    .div                            (cfg_pll_fed_div        ), 
    .dco                            (cfg_dco_mode           ), 
    .ext_trim                       (cfg_dc_trim            ),
    .osc                            (pll_ref_clk            ), 
    .clockp                         (pll_clk_out            ) 
    );



//------------------------------------------------------------------------------
// RISC V Core instance
//------------------------------------------------------------------------------
ycr_top_wb u_riscv_top (
`ifdef USE_POWER_PINS
          .vccd1                   (vccd1                      ),// User area 1 1.8V supply
          .vssd1                   (vssd1                      ),// User area 1 digital ground
`endif
          .wbd_clk_int             (riscv_wbclk                ), 
          .cfg_wcska_riscv_intf    (cfg_wcska_riscv_rp         ), 
          .wbd_clk_skew            (wbd_clk_riscv_skew         ),


           `ifdef YCR_DBG_EN
               // -- JTAG I/F
            .trst_n                (riscv_trst_n               ),
            .tck                   (riscv_tck                  ),
            .tms                   (riscv_tms                  ),
            .tdi                   (riscv_tdi                  ),
            .tdo                   (riscv_tdo                  ),
            .tdo_en                (riscv_tdo_en               ),
           `endif // YCR_DBG_EN

    // Reset
          .pwrup_rst_n             (wbd_int_rst_n              ),
          .rst_n                   (wbd_int_rst_n              ),
          .cpu_intf_rst_n          (cpu_intf_rst_n             ),
          .cpu_core_rst_n          (cpu_core_rst_n[0]          ),
          .riscv_debug             (riscv_debug                ),
	      .cfg_sram_lphase         (cfg_riscv_sram_lphase      ),
	      .cfg_cache_ctrl          (cfg_riscv_cache_ctrl       ),
	      .cfg_bypass_icache       (cfg_bypass_icache          ),
	      .cfg_bypass_dcache       (cfg_bypass_dcache          ),

    // Clock
          .core_clk_int            (cpu_clk_rp_risc            ),
          .cfg_ccska_riscv_intf    (cfg_ccska_riscv_intf_rp    ),
          .cfg_ccska_riscv_icon    (cfg_ccska_riscv_icon_rp    ),
          .cfg_ccska_riscv_core0   (cfg_ccska_riscv_core0_rp   ),

          .rtc_clk                 (rtc_clk                    ),


    // IRQ
          .irq_lines               (irq_lines_rp               ), 
          .soft_irq                (soft_irq_rp                ), // TODO - Interrupts

    // DFT
    //    .test_mode               (1'b0                       ), // Moved inside IP
    //    .test_rst_n              (1'b1                       ), // Moved inside IP

`ifndef SCR1_TCM_MEM
    // SRAM-0 PORT-0
          .sram0_clk0             (sram0_clk0                  ),
          .sram0_csb0             (sram0_csb0                  ),
          .sram0_web0             (sram0_web0                  ),
          .sram0_addr0            (sram0_addr0                 ),
          .sram0_wmask0           (sram0_wmask0                ),
          .sram0_din0             (sram0_din0                  ),
          .sram0_dout0            (sram0_dout0                 ),
    
    // SRAM-0 PORT-0
          .sram0_clk1             (sram0_clk1                   ),
          .sram0_csb1             (sram0_csb1                   ),
          .sram0_addr1            (sram0_addr1                  ),
          .sram0_dout1            (sram0_dout1                  ),

  //  // SRAM-1 PORT-0
  //      .sram1_clk0             (sram1_clk0                   ),
  //      .sram1_csb0             (sram1_csb0                   ),
  //      .sram1_web0             (sram1_web0                   ),
  //      .sram1_addr0            (sram1_addr0                  ),
  //      .sram1_wmask0           (sram1_wmask0                 ),
  //      .sram1_din0             (sram1_din0                   ),
  //      .sram1_dout0            (sram1_dout0                  ),
  //  
  //  // SRAM PORT-0
  //      .sram1_clk1             (sram1_clk1                   ),
  //      .sram1_csb1             (sram1_csb1                   ),
  //      .sram1_addr1            (sram1_addr1                  ),
  //      .sram1_dout1            (sram1_dout1                  ),
`endif
    
          .wb_rst_n                (wbd_int_rst_n           ),
          .wb_clk                  (wbd_clk_riscv_skew      ),

    // Instruction cache memory interface
          .wb_icache_stb_o         (wbd_riscv_icache_stb_i  ),
          .wb_icache_adr_o         (wbd_riscv_icache_adr_i  ),
          .wb_icache_we_o          (wbd_riscv_icache_we_i   ), 
          .wb_icache_sel_o         (wbd_riscv_icache_sel_i  ),
          .wb_icache_bl_o          (wbd_riscv_icache_bl_i   ),
          .wb_icache_bry_o         (wbd_riscv_icache_bry_i  ),
          .wb_icache_dat_i         (wbd_riscv_icache_dat_o  ),
          .wb_icache_ack_i         (wbd_riscv_icache_ack_o  ),
          .wb_icache_lack_i        (wbd_riscv_icache_lack_o ),
          .wb_icache_err_i         (wbd_riscv_icache_err_o  ),

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
          .wb_dcache_stb_o         (wbd_riscv_dcache_stb_i  ),
          .wb_dcache_adr_o         (wbd_riscv_dcache_adr_i  ),
          .wb_dcache_we_o          (wbd_riscv_dcache_we_i   ), 
          .wb_dcache_dat_o         (wbd_riscv_dcache_dat_i  ),
          .wb_dcache_sel_o         (wbd_riscv_dcache_sel_i  ),
          .wb_dcache_bl_o          (wbd_riscv_dcache_bl_i   ),
          .wb_dcache_bry_o         (wbd_riscv_dcache_bry_i  ),
          .wb_dcache_dat_i         (wbd_riscv_dcache_dat_o  ),
          .wb_dcache_ack_i         (wbd_riscv_dcache_ack_o  ),
          .wb_dcache_lack_i        (wbd_riscv_dcache_lack_o ),
          .wb_dcache_err_i         (wbd_riscv_dcache_err_o  ),

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
          .wbd_dmem_stb_o          (wbd_riscv_dmem_stb_i    ),
          .wbd_dmem_adr_o          (wbd_riscv_dmem_adr_i    ),
          .wbd_dmem_we_o           (wbd_riscv_dmem_we_i     ), 
          .wbd_dmem_dat_o          (wbd_riscv_dmem_dat_i    ),
          .wbd_dmem_sel_o          (wbd_riscv_dmem_sel_i    ),
          .wbd_dmem_bl_o           (wbd_riscv_dmem_bl_i     ),
          .wbd_dmem_bry_o          (wbd_riscv_dmem_bry_i    ),
          .wbd_dmem_dat_i          (wbd_riscv_dmem_dat_o    ),
          .wbd_dmem_ack_i          (wbd_riscv_dmem_ack_o    ),
          .wbd_dmem_lack_i         (wbd_riscv_dmem_lack_o   ),
          .wbd_dmem_err_i          (wbd_riscv_dmem_err_o    ),

          .cpu_clk_aes             (cpu_clk_aes             ),
          .aes_dmem_req            (aes_dmem_req            ),
          .aes_dmem_cmd            (aes_dmem_cmd            ),
          .aes_dmem_width          (aes_dmem_width          ),
          .aes_dmem_addr           (aes_dmem_addr           ),
          .aes_dmem_wdata          (aes_dmem_wdata          ),
          .aes_dmem_req_ack        (aes_dmem_req_ack        ),
          .aes_dmem_rdata          (aes_dmem_rdata          ),
          .aes_dmem_resp           (aes_dmem_resp           ),

          .cpu_clk_fpu             (cpu_clk_fpu             ),
          .fpu_dmem_req            (fpu_dmem_req            ),
          .fpu_dmem_cmd            (fpu_dmem_cmd            ),
          .fpu_dmem_width          (fpu_dmem_width          ),
          .fpu_dmem_addr           (fpu_dmem_addr           ),
          .fpu_dmem_wdata          (fpu_dmem_wdata          ),
          .fpu_dmem_req_ack        (fpu_dmem_req_ack        ),
          .fpu_dmem_rdata          (fpu_dmem_rdata          ),
          .fpu_dmem_resp           (fpu_dmem_resp           )
);

//----------------------------------------------
// TCM
//----------------------------------------------

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

//------------------------------------------------
// icache
//------------------------------------------------

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

//----------------------------------------------------------
// dcache
//----------------------------------------------------------

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

/***********************************************
  AES 128 Bit 
*************************************************/
aes_top u_aes (
`ifdef USE_POWER_PINS
    .vccd1                 (vccd1            ),
    .vssd1                 (vssd1            ),
`endif

    .mclk                  (cpu_clk_aes_skew ),
    .rst_n                 (cpu_intf_rst_n   ),

    .cfg_cska              (cfg_ccska_aes_rp ),
    .wbd_clk_int           (cpu_clk_aes      ),
    .wbd_clk_out           (cpu_clk_aes_skew ),

    .dmem_req              (aes_dmem_req     ),
    .dmem_cmd              (aes_dmem_cmd     ),
    .dmem_width            (aes_dmem_width   ),
    .dmem_addr             (aes_dmem_addr    ),
    .dmem_wdata            (aes_dmem_wdata   ),
    .dmem_req_ack          (aes_dmem_req_ack ),
    .dmem_rdata            (aes_dmem_rdata   ),
    .dmem_resp             (aes_dmem_resp    )
);

/***********************************************
  FPU
*************************************************/
fpu_wrapper u_fpu (
`ifdef USE_POWER_PINS
    .vccd1                 (vccd1            ),
    .vssd1                 (vssd1            ),
`endif

          .mclk               (cpu_clk_fpu_skew             ),
          .rst_n              (cpu_intf_rst_n               ),

          .cfg_cska           (cfg_ccska_fpu_rp             ),
          .wbd_clk_int        (cpu_clk_fpu                  ),
          .wbd_clk_out        (cpu_clk_fpu_skew             ),

          .dmem_req           (fpu_dmem_req                 ),
          .dmem_cmd           (fpu_dmem_cmd                 ),
          .dmem_width         (fpu_dmem_width               ),
          .dmem_addr          (fpu_dmem_addr                ),
          .dmem_wdata         (fpu_dmem_wdata               ),
          .dmem_req_ack       (fpu_dmem_req_ack             ),
          .dmem_rdata         (fpu_dmem_rdata               ),
          .dmem_resp          (fpu_dmem_resp                )
);

/*********************************************************
* SPI Master
* This is implementation of an SPI master that is controlled via an AXI bus                                                  . 
* It has FIFOs for transmitting and receiving data. 
* It supports both the normal SPI mode and QPI mode with 4 data lines.
* *******************************************************/

qspim_top
#(
`ifndef SYNTHESIS
    .WB_WIDTH  (WB_WIDTH                                    )
`endif
) u_qspi_master
(
`ifdef USE_POWER_PINS
          .vccd1                   (vccd1                   ),// User area 1 1.8V supply
          .vssd1                   (vssd1                   ),// User area 1 digital ground
`endif
          .mclk                    (wbd_clk_spi             ),
          .rst_n                   (qspim_rst_n             ),
          .cfg_fast_sim            (cfg_fast_sim            ),

          .strap_flash             (strap_qspi_flash        ),
          .strap_pre_sram          (strap_qspi_pre_sram     ),
          .strap_sram              (strap_qspi_sram         ),
          .cfg_init_bypass         (strap_qspi_init_bypass  ),

    // Clock Skew Adjust
          .cfg_cska_sp_co          (cfg_wcska_qspi_co_rp     ),
          .cfg_cska_spi            (cfg_wcska_qspi_rp        ),
          .wbd_clk_int             (qspim_mclk               ),
          .wbd_clk_spi             (wbd_clk_spi              ),

          .qspim_idle              (qspim_idle               ),

          .wbd_stb_i               (wbd_spim_stb_o          ),
          .wbd_adr_i               (wbd_spim_adr_o          ),
          .wbd_we_i                (wbd_spim_we_o           ), 
          .wbd_dat_i               (wbd_spim_dat_o          ),
          .wbd_sel_i               (wbd_spim_sel_o          ),
          .wbd_bl_i                (wbd_spim_bl_o           ),
          .wbd_bry_i               (wbd_spim_bry_o          ),
          .wbd_dat_o               (wbd_spim_dat_i          ),
          .wbd_ack_o               (wbd_spim_ack_i          ),
          .wbd_lack_o              (wbd_spim_lack_i         ),
          .wbd_err_o               (wbd_spim_err_i          ),

          .spi_debug               (spi_debug               ),

    // Pad Interface
          .spi_sdi                 (sflash_di               ),
          .spi_clk                 (sflash_sck              ),
          .spi_csn                 (spi_csn                 ),
          .spi_sdo                 (sflash_do               ),
          .spi_oen                 (sflash_oen              )

);


//---------------------------------------------------
// wb_interconnect
//---------------------------------------------------

wb_interconnect  #(
	`ifndef SYNTHESIS
          .CH_CLK_WD          (3                            ),
          .CH_DATA_WD         (158                          )
        `endif
	) u_intercon (
`ifdef USE_POWER_PINS
       .vccd1              (vccd1                        ),// User area 1 1.8V supply
       .vssd1              (vssd1                        ),// User area 1 digital ground
`endif

      .peri_wbclk             (peri_wbclk                   ),
      .riscv_wbclk            (riscv_wbclk                  ),
	  .ch_clk_in              ({
                                     cpu_clk,
                                     cpu_clk,
                                     cpu_clk }                  ),
	  .ch_clk_out             ( cpu_clk_rp                         ),
	  .ch_data_in             ({
			                      cfg_wcska_peri[3:0],
                                  cfg_ccska_fpu[3:0],
                                  cfg_ccska_aes[3:0],
                                  strap_sticky[31:0],
                                  strap_uartm[1:0],
                                  system_strap[31:0],
                                  p_reset_n,
                                  e_reset_n,
                                  cfg_strap_pad_ctrl,
			 
	                              soft_irq,
			                      irq_lines[31:0],

			                      cfg_ccska_riscv_core3[3:0],
			                      cfg_ccska_riscv_core2[3:0],
			                      cfg_ccska_riscv_core1[3:0],
			                      cfg_ccska_riscv_core0[3:0],
			                      cfg_ccska_riscv_icon[3:0],
			                      cfg_ccska_riscv_intf[3:0],

			                      cfg_wcska_qspi_co[3:0],
		                          cfg_wcska_pinmux[3:0],
			                      cfg_wcska_uart[3:0],
		                          cfg_wcska_qspi[3:0],
                                  cfg_wcska_riscv[3:0]
			             }                             ),
	  .ch_data_out            ({
		                          cfg_wcska_peri_rp[3:0],
			                      cfg_ccska_fpu_rp[3:0],
			                      cfg_ccska_aes_rp[3:0],
                                  strap_sticky_rp[31:0],
                                  strap_uartm_rp[1:0],
                                  system_strap_rp[31:0],
                                  p_reset_n_rp,
                                  e_reset_n_rp,
                                  cfg_strap_pad_ctrl_rp,

	                              soft_irq_rp,
			                      irq_lines_rp[31:0],

			                      cfg_ccska_riscv_core3_rp[3:0],
			                      cfg_ccska_riscv_core2_rp[3:0],
			                      cfg_ccska_riscv_core1_rp[3:0],
			                      cfg_ccska_riscv_core0_rp[3:0],
			                      cfg_ccska_riscv_icon_rp[3:0],
			                      cfg_ccska_riscv_intf_rp[3:0],

			                      cfg_wcska_qspi_co_rp[3:0],
		                          cfg_wcska_pinmux_rp[3:0],
			                      cfg_wcska_uart_rp[3:0],
		                          cfg_wcska_qspi_rp[3:0],
                                  cfg_wcska_riscv_rp[3:0]
                               } ),
     // Clock Skew adjust
          .wbd_clk_int        (wbd_clk_int                  ),// wb clock without skew 
          .cfg_cska_wi        (cfg_wcska_wi                 ), 
          .wbd_clk_wi         (wbd_clk_wi_skew              ),// wb clock with skew

          .mclk_raw           (wbd_clk_int                  ), // wb clock without skew
          .clk_i              (wbd_clk_wi_skew              ), // wb clock with skew
          .rst_n              (wbd_int_rst_n                ),

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
          .m1_wbd_bl_i        (wbd_riscv_dmem_bl_i          ),
          .m1_wbd_bry_i       (wbd_riscv_dmem_bry_i         ),
          .m1_wbd_we_i        (wbd_riscv_dmem_we_i          ),
          .m1_wbd_cyc_i       (wbd_riscv_dmem_stb_i         ),
          .m1_wbd_stb_i       (wbd_riscv_dmem_stb_i         ),
          .m1_wbd_dat_o       (wbd_riscv_dmem_dat_o         ),
          .m1_wbd_ack_o       (wbd_riscv_dmem_ack_o         ),
          .m1_wbd_lack_o      (wbd_riscv_dmem_lack_o        ),
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
       // .s0_wbd_err_i       (1'b0                         ), - Moved inside IP
          .s0_mclk            (qspim_mclk                   ),
          .s0_idle            (qspim_idle                   ),
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
       // .s1_wbd_err_i       (1'b0                         ), - Moved inside IP
          .s1_mclk            (uart_mclk                    ),
          .s1_wbd_dat_i       (wbd_uart_dat_i               ),
          .s1_wbd_ack_i       (wbd_uart_ack_i               ),
          .s1_wbd_dat_o       (wbd_uart_dat_o               ),
          .s1_wbd_adr_o       (wbd_uart_adr_o               ),
          .s1_wbd_sel_o       (wbd_uart_sel_o               ),
          .s1_wbd_we_o        (wbd_uart_we_o                ),  
          .s1_wbd_cyc_o       (wbd_uart_cyc_o               ),
          .s1_wbd_stb_o       (wbd_uart_stb_o               ),
         
         // Slave 2 Interface
       // .s2_wbd_err_i       (1'b0                         ), - Moved inside IP
          .s2_mclk            (pinmux_mclk                  ),
          .s2_wbd_dat_i       (wbd_pinmux_dat_i             ),
          .s2_wbd_ack_i       (wbd_pinmux_ack_i             ),
          .s2_wbd_dat_o       (wbd_pinmux_dat_o             ),
          .s2_wbd_adr_o       (wbd_pinmux_adr_o             ),
          .s2_wbd_sel_o       (wbd_pinmux_sel_o             ),
          .s2_wbd_we_o        (wbd_pinmux_we_o              ),  
          .s2_wbd_cyc_o       (wbd_pinmux_cyc_o             ),
          .s2_wbd_stb_o       (wbd_pinmux_stb_o             )


	);

//-----------------------------------------------
// uart+i2c+usb+spi
//-----------------------------------------------

uart_i2c_usb_spi_top   u_uart_i2c_usb_spi (
`ifdef USE_POWER_PINS
          .vccd1              (vccd1                        ),// User area 1 1.8V supply
          .vssd1              (vssd1                        ),// User area 1 digital ground
`endif
          .wbd_clk_int        (uart_mclk                    ), 
          .cfg_cska_uart      (cfg_wcska_uart_rp            ), 
          .wbd_clk_uart       (wbd_clk_uart_skew            ),

          .uart_rstn          (uart_rst_n                   ), // uart reset
          .i2c_rstn           (i2c_rst_n                    ), // i2c reset
          .usb_rstn           (usb_rst_n                    ), // USB reset
          .spi_rstn           (sspim_rst_n                  ), // SPI reset
          .app_clk            (wbd_clk_uart_skew            ),
          .usb_clk            (usb_clk                      ),

        // Reg Bus Interface Signal
          .reg_cs             (wbd_uart_stb_o               ),
          .reg_wr             (wbd_uart_we_o                ),
          .reg_addr           (wbd_uart_adr_o[8:0]          ),
          .reg_wdata          (wbd_uart_dat_o               ),
          .reg_be             (wbd_uart_sel_o               ),

       // Outputs
          .reg_rdata          (wbd_uart_dat_i               ),
          .reg_ack            (wbd_uart_ack_i               ),

       // Pad interface
          .scl_pad_i          (i2cm_clk_i                   ),
          .scl_pad_o          (i2cm_clk_o                   ),
          .scl_pad_oen_o      (i2cm_clk_oen                 ),

          .sda_pad_i          (i2cm_data_i                  ),
          .sda_pad_o          (i2cm_data_o                  ),
          .sda_padoen_o       (i2cm_data_oen                ),
     
          .i2cm_intr_o        (i2cm_intr_o                  ),

          .uart_rxd           (uart_rxd                     ),
          .uart_txd           (uart_txd                     ),

          .usb_in_dp          (usb_dp_i                     ),
          .usb_in_dn          (usb_dn_i                     ),

          .usb_out_dp         (usb_dp_o                     ),
          .usb_out_dn         (usb_dn_o                     ),
          .usb_out_tx_oen     (usb_oen                      ),
       
          .usb_intr_o         (usb_intr_o                   ),

      // SPIM Master
          .sspim_sck          (sspim_sck                    ), 
          .sspim_so           (sspim_so                     ),  
          .sspim_si           (sspim_si                     ),  
          .sspim_ssn          (sspim_ssn                    )  

     );

//---------------------------------------
// Pinmux
//---------------------------------------

pinmux_top u_pinmux(
`ifdef USE_POWER_PINS
          .vccd1              (vccd1                        ),// User area 1 1.8V supply
          .vssd1              (vssd1                        ),// User area 1 digital ground
`endif
        //clk skew adjust
          .cfg_cska_pinmux    (cfg_wcska_pinmux_rp          ),
          .wbd_clk_int        (pinmux_mclk                  ),
          .wbd_clk_pinmux     (wbd_clk_pinmux_skew          ),

        // System Signals
        // Inputs
          .mclk               (wbd_clk_pinmux_skew          ),
          .e_reset_n          (e_reset_n_rp                 ),
          .p_reset_n          (p_reset_n_rp                 ),
          .s_reset_n          (wbd_int_rst_n                ),

       `ifdef YCR_DBG_EN
           // -- JTAG I/F
          .riscv_trst_n       (riscv_trst_n                 ),
          .riscv_tck          (riscv_tck                    ),
          .riscv_tms          (riscv_tms                    ),
          .riscv_tdi          (riscv_tdi                    ),
          .riscv_tdo          (riscv_tdo                    ),
          .riscv_tdo_en       (riscv_tdo_en                 ),
       `endif // YCR_DBG_EN

          .cfg_strap_pad_ctrl (cfg_strap_pad_ctrl_rp        ),
          .system_strap       (system_strap_rp              ),
          .strap_sticky       (strap_sticky                 ),
          .strap_uartm        (strap_uartm                  ),

          .user_clock1        (wb_clk_i_rp                  ),
          .user_clock2        (user_clock2_rp               ),
          .int_pll_clock      (int_pll_clock                ),
          .xtal_clk           (xtal_clk                     ),
          .cpu_clk            (cpu_clk_rp_pinmux            ),


          .rtc_clk            (rtc_clk                      ),
          .usb_clk            (usb_clk                      ),
	// Reset Control
          .cpu_core_rst_n     (cpu_core_rst_n               ),
          .cpu_intf_rst_n     (cpu_intf_rst_n               ),
          .qspim_rst_n        (qspim_rst_n                  ),
          .sspim_rst_n        (sspim_rst_n                  ),
          .uart_rst_n         (uart_rst_n                   ),
          .i2cm_rst_n         (i2c_rst_n                    ),
          .usb_rst_n          (usb_rst_n                    ),

          .cfg_riscv_ctrl     (cfg_riscv_ctrl               ),

        // Reg Bus Interface Signal
          .reg_cs             (wbd_pinmux_stb_o             ),
          .reg_wr             (wbd_pinmux_we_o              ),
          .reg_addr           (wbd_pinmux_adr_o             ),
          .reg_wdata          (wbd_pinmux_dat_o             ),
          .reg_be             (wbd_pinmux_sel_o             ),

       // Outputs
          .reg_rdata          (wbd_pinmux_dat_i             ),
          .reg_ack            (wbd_pinmux_ack_i             ),


       // Risc configuration
          .irq_lines          (irq_lines                    ),
          .soft_irq           (soft_irq                     ),
          .user_irq           (user_irq                     ),
          .usb_intr           (usb_intr_o                   ),
          .i2cm_intr          (i2cm_intr_o                  ),

       // Digital IO
          .digital_io_out     (io_out_int                   ),
          .digital_io_oen     (io_oeb_int                   ),
          .digital_io_in      (io_in_rp                     ),

       // SFLASH I/F
          .sflash_sck         (sflash_sck                   ),
          .sflash_ss          (spi_csn                      ),
          .sflash_oen         (sflash_oen                   ),
          .sflash_do          (sflash_do                    ),
          .sflash_di          (sflash_di                    ),


       // USB I/F
          .usb_dp_o           (usb_dp_o                     ),
          .usb_dn_o           (usb_dn_o                     ),
          .usb_oen            (usb_oen                      ),
          .usb_dp_i           (usb_dp_i                     ),
          .usb_dn_i           (usb_dn_i                     ),

       // UART I/F
          .uart_txd           (uart_txd                     ),
          .uart_rxd           (uart_rxd                     ),

       // I2CM I/F
          .i2cm_clk_o         (i2cm_clk_o                   ),
          .i2cm_clk_i         (i2cm_clk_i                   ),
          .i2cm_clk_oen       (i2cm_clk_oen                 ),
          .i2cm_data_oen      (i2cm_data_oen                ),
          .i2cm_data_o        (i2cm_data_o                  ),
          .i2cm_data_i        (i2cm_data_i                  ),

       // SPI MASTER
          .spim_sck           (sspim_sck                    ),
          .spim_ssn           (sspim_ssn                    ),
          .spim_miso          (sspim_so                     ),
          .spim_mosi          (sspim_si                     ),
       
       // SPI SLAVE
          .spis_sck           (sspis_sck                    ),
          .spis_ssn           (sspis_ssn                    ),
          .spis_miso          (sspis_so                     ),
          .spis_mosi          (sspis_si                     ),

      // UART MASTER I/F
          .uartm_rxd          (uartm_rxd                    ),
          .uartm_txd          (uartm_txd                    ),


          .pulse1m_mclk       (pulse1m_mclk                 ),
     
          .pinmux_debug       (pinmux_debug                 ),
     
     
          .cfg_pll_enb        (cfg_pll_enb                  ), 
          .cfg_pll_fed_div    (cfg_pll_fed_div              ), 
          .cfg_dco_mode       (cfg_dco_mode                 ), 
          .cfg_dc_trim        (cfg_dc_trim                  ),
          .pll_ref_clk        (pll_ref_clk                  ),
     
        // Peripheral Reg Bus Interface Signal
          .reg_peri_cs        (reg_peri_cs                  ),
          .reg_peri_wr        (reg_peri_wr                  ),
          .reg_peri_addr      (reg_peri_addr                ),
          .reg_peri_wdata     (reg_peri_wdata               ),
          .reg_peri_be        (reg_peri_be                  ),

       // Outputs
          .reg_peri_rdata     (reg_peri_rdata               ),
          .reg_peri_ack       (reg_peri_ack                 ),

          .rtc_intr           (rtc_intr                     ),

          .ir_rx              (ir_rx                        ),
          .ir_tx              (ir_tx                        ),
          .ir_intr            (ir_intr                      )

   ); 

//---------------------------------------------------------
// Peripheral block
//----------------------------------------------------------

peri_top u_peri(
`ifdef USE_POWER_PINS
          .vccd1              (vccd1                        ),// User area 1 1.8V supply
          .vssd1              (vssd1                        ),// User area 1 digital ground
`endif
        //clk skew adjust
          .cfg_cska_peri           (cfg_wcska_peri_rp       ),
          .wbd_clk_int             (peri_wbclk              ),
          .wbd_clk_peri            (wbd_clk_peri_skew       ),

        // System Signals
        // Inputs
          .mclk                    (wbd_clk_peri_skew       ),
          .s_reset_n               (wbd_int_rst_n           ),

        // Peripheral Reg Bus Interface Signal
          .reg_cs                  (reg_peri_cs             ),
          .reg_wr                  (reg_peri_wr             ),
          .reg_addr                (reg_peri_addr           ),
          .reg_wdata               (reg_peri_wdata          ),
          .reg_be                  (reg_peri_be             ),

       // Outputs
          .reg_rdata               (reg_peri_rdata          ),
          .reg_ack                 (reg_peri_ack            ),

          // RTC clock domain
          .rtc_clk                 (rtc_clk                 ),
          .rtc_intr                (rtc_intr                ),

          .inc_time_s              (                        ),
          .inc_date_d              (                        ),

          .ir_rx                   (ir_rx                   ),
          .ir_tx                   (ir_tx                   ),
          .ir_intr                 (ir_intr                 ),

          .cfg_dac0_mux_sel        (cfg_dac0_mux_sel        ),
          .cfg_dac1_mux_sel        (cfg_dac1_mux_sel        ),
          .cfg_dac2_mux_sel        (cfg_dac2_mux_sel        ),
          .cfg_dac3_mux_sel        (cfg_dac3_mux_sel        )

   ); 



//------------------------------------------
// 4 x 8 bit DAC
//------------------------------------------


dac_top  u_4x8bit_dac(
`ifdef USE_POWER_PINS
          .vccd1              (vdda1                        ),
          .vssd1              (vssa1                        ),
`endif
          .Vref               (analog_io[23]                ),
          .DIn0               (cfg_dac0_mux_sel             ),
          .DIn1               (cfg_dac1_mux_sel             ),
          .DIn2               (cfg_dac2_mux_sel             ),
          .DIn3               (cfg_dac3_mux_sel             ),
          .Vout0              (analog_io[15]                ),
          .Vout1              (analog_io[16]                ),
          .Vout2              (analog_io[17]                ),
          .Vout3              (analog_io[18]                )
   );


endmodule : user_project_wrapper
