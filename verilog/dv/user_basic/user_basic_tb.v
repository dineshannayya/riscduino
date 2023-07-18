////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText:  2021 , Dinesh Annayya
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
// SPDX-FileContributor: Modified by Dinesh Annayya <dinesha@opencores.org>
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Standalone User validation Test bench                       ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  https://github.com/dineshannayya/yifive_r0.git              ////
////                                                              ////
////  Description                                                 ////
////   This is a standalone test bench to validate the            ////
////   Digital core.                                              ////
////   1. User Risc core is booted using  compiled code of        ////
////      user_risc_boot.c                                        ////
////   2. User Risc core uses Serial Flash and SDRAM to boot      ////
////   3. After successful boot, Risc core will check the UART    ////
////      RX Data, If it's available then it loop back the same   ////
////      data in uart tx                                         ////
////   4. Test bench send random 40 character towards User uart   ////
////      and expect same data to return back                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 16th Feb 2021, Dinesh A                             ////
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

`default_nettype wire

`timescale 1 ns/1 ps

`include "sram_macros/sky130_sram_2kbyte_1rw1r_32x512_8.v"
`include "uart_agent.v"
`include "user_params.svh"

`define TB_TOP user_basic_tb

module `TB_TOP;
parameter real CLK1_PERIOD  = 20; // 50Mhz
parameter real CLK2_PERIOD = 2.5;
parameter real IPLL_PERIOD = 5.008;
parameter real XTAL_PERIOD = 6;

`include "user_tasks.sv"
//----------------------------------
// Uart Configuration
// ---------------------------------
reg [1:0]      uart_data_bit        ;
reg	           uart_stop_bits       ; // 0: 1 stop bit; 1: 2 stop bit;
reg	           uart_stick_parity    ; // 1: force even parity
reg	           uart_parity_en       ; // parity enable
reg	           uart_even_odd_parity ; // 0: odd parity; 1: even parity

reg [7:0]      uart_data            ;
reg [15:0]     uart_divisor         ;	// divided by n * 16
reg [15:0]     uart_timeout         ;// wait time limit

reg [15:0]     uart_rx_nu           ;
reg [15:0]     uart_tx_nu           ;
reg 	       uart_fifo_enable     ;	// fifo mode disable

wire           clock_mon;
integer        test_step;
reg  [15:0]    strap_in;
wire [31:0]    strap_sticky;
reg  [7:0]     test_id;
reg  [25:0]    bcount;
wire uart_txd,uart_rxd;
reg            flag;

assign io_in = {26'h0,xtal_clk,4'h0,uart_rxd,6'h0};

wire [14:0] pstrap_select;

assign pstrap_select = (strap_in[15] == 1'b1) ?  PSTRAP_DEFAULT_VALUE : strap_in[14:0];


assign strap_sticky = {
                   2'b0            , // bit[31:30]   - reserved
                   pstrap_select[12:11] , // bit[29:28]   - cfg_cska_qspi_co Skew selection
                   pstrap_select[12:11] , // bit[27:26]   - cfg_cska_pinmux Skew selection
                   pstrap_select[12:11] , // bit[25:24]   - cfg_cska_uart  Skew selection
                   pstrap_select[12:11] , // bit[23:22]   - cfg_cska_qspi  Skew selection
                   pstrap_select[12:11] , // bit[21:20]   - cfg_cska_riscv Skew selection
                   pstrap_select[12:11] , // bit[19:18]   - cfg_cska_wh Skew selection
                   pstrap_select[12:11] , // bit[17:16]   - cfg_cska_wi Skew selection
                   1'b0               , // bit[15]      - Soft Reboot Request - Need to double sync to local clock
                   pstrap_select[10]    , // bit[14]      - Riscv SRAM clock edge selection
                   pstrap_select[9]     , // bit[13]      - Riscv Cache Bypass
                   pstrap_select[8]     , // bit[12]      - Riscv Reset control
                   pstrap_select[7:6]   , // bit[11:10]   - QSPI FLASH Mode Selection CS#0
                   pstrap_select[5]     , // bit[9]       - QSPI SRAM Mode Selection CS#2
                   pstrap_select[4]     , // bit[8]       - uart master config control
                   pstrap_select[3:2]   , // bit[7:6]     - riscv clock div
                   pstrap_select[1:0]   , // bit[5:4]     - riscv clock source sel
                   pstrap_select[3:2]   , // bit[3:2]     - wbs clock division
                   pstrap_select[1:0]     // bit[1:0]     - wbs clock source sel
                   };


reg [1:0]  strap_skew;
wire [31:0] skew_config;

assign skew_config[3:0]   =   (strap_skew == 2'b00) ?  CLK_SKEW1_RESET_VAL[3:0] :
                              (strap_skew == 2'b01) ?  CLK_SKEW1_RESET_VAL[3:0] + 2 :
                              (strap_skew == 2'b10) ?  CLK_SKEW1_RESET_VAL[3:0] + 4 : CLK_SKEW1_RESET_VAL[3:0]-4;

assign skew_config[7:4]   =   (strap_skew == 2'b00) ?  CLK_SKEW1_RESET_VAL[7:4]  :
                              (strap_skew == 2'b01) ?  CLK_SKEW1_RESET_VAL[7:4] + 2 :
                              (strap_skew == 2'b10) ?  CLK_SKEW1_RESET_VAL[7:4] + 4 : CLK_SKEW1_RESET_VAL[7:4]-4;

assign skew_config[11:8]  =   (strap_skew == 2'b00) ?  CLK_SKEW1_RESET_VAL[11:8]  :
                              (strap_skew == 2'b01) ?  CLK_SKEW1_RESET_VAL[11:8] + 2 :
                              (strap_skew == 2'b10) ?  CLK_SKEW1_RESET_VAL[11:8] + 4 : CLK_SKEW1_RESET_VAL[11:8]-4;

assign skew_config[15:12] =   (strap_skew == 2'b00) ?  CLK_SKEW1_RESET_VAL[15:12]  :
                              (strap_skew == 2'b01) ?  CLK_SKEW1_RESET_VAL[15:12] + 2 :
                              (strap_skew == 2'b10) ?  CLK_SKEW1_RESET_VAL[15:12] + 4 : CLK_SKEW1_RESET_VAL[15:12]-4;

assign skew_config[19:16] =   (strap_skew == 2'b00) ?  CLK_SKEW1_RESET_VAL[19:16]  :
                              (strap_skew == 2'b01) ?  CLK_SKEW1_RESET_VAL[19:16] + 2 :
                              (strap_skew == 2'b10) ?  CLK_SKEW1_RESET_VAL[19:16] + 4 : CLK_SKEW1_RESET_VAL[19:16]-4;

assign skew_config[23:20] =   (strap_skew == 2'b00) ?  CLK_SKEW1_RESET_VAL[23:20]  :
                              (strap_skew == 2'b01) ?  CLK_SKEW1_RESET_VAL[23:20] + 2 :
                              (strap_skew == 2'b10) ?  CLK_SKEW1_RESET_VAL[23:20] + 4 : CLK_SKEW1_RESET_VAL[23:20]-4;

assign skew_config[27:24] =   (strap_skew == 2'b00) ?  CLK_SKEW1_RESET_VAL[27:24] :
                              (strap_skew == 2'b01) ?  CLK_SKEW1_RESET_VAL[27:24] + 2 :
                              (strap_skew == 2'b10) ?  CLK_SKEW1_RESET_VAL[27:24] + 4 : CLK_SKEW1_RESET_VAL[27:24]-4;

assign skew_config[31:28] = CLK_SKEW1_RESET_VAL[31:28];

//----------------------------------------------------------
reg [3:0] cpu_clk_cfg,wbs_clk_cfg;
wire [7:0] clk_ctrl2 = {cpu_clk_cfg,wbs_clk_cfg};



//-----------------------------------------------------------


integer i,j;


initial begin
   test_step = 0;
end

	`ifdef WFDUMP
	   initial begin
	   	$dumpfile("simx.vcd");
	   	$dumpvars(1, `TB_TOP);
	   	$dumpvars(1, `TB_TOP.u_top);
	   	//$dumpvars(0, `TB_TOP.u_top.u_pll);
	   	$dumpvars(0, `TB_TOP.u_top.u_wb_host);
	   	$dumpvars(0, `TB_TOP.u_top.u_intercon);
	   	//$dumpvars(1, `TB_TOP.u_top.u_intercon);
	   	$dumpvars(0, `TB_TOP.u_top.u_pinmux);
	   	$dumpvars(0, `TB_TOP.u_top.u_rp_south);
	   end
       `endif

initial
begin

   init();

   #200; // Wait for reset removal
   repeat (10) @(posedge clock);
   $display("Monitor: Standalone User Basic Test Started");
   
   repeat (2) @(posedge clock);

   test_fail=0;
   fork
   begin
       $display("##########################################################");
       $display("Step-0,Monitor: Checking the chip signature :");
       $display("###################################################");
       test_id = 0;
       test_step = 0;
       // Remove Wb/PinMux Reset
       wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,'h1);

       wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_0,read_data,CHIP_SIGNATURE);
       wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_1,read_data,CHIP_RELEASE_DATE);
       wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_2,read_data,CHIP_REVISION);
       if(test_fail == 1) begin
          $display("ERROR: Step-0,Monitor: Checking the chip signature - FAILED");
       end else begin
          $display("STATUS: Step-0,Monitor: Checking the chip signature - PASSED");
          $display("##########################################################");
       end

       $display("##########################################################");
       $display("Step-1, Checking the Strap Loading");
       test_id = 1;
       for(i = 0; i < 16; i = i+1) begin
          strap_in = 0;
          strap_in = 1 << i;
          apply_strap(strap_in);
     
          //#7 - Check the strap reg value
          wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_PAD_STRAP,read_data,strap_in);
          wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_STRAP_STICKY,read_data,strap_sticky);
          wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_SYSTEM_STRAP,read_data,strap_sticky);
          test_step = 7;
       end
 
       
       if(test_fail == 1) begin
          $display("ERROR: Step-1, Checking the Strap Loading - FAILED");
       end else begin
          $display("STATUS: Step-1, Checking the Strap Loading - PASSED");
       end
       $display("##########################################################");
       $display("Step-2, Checking the Clock Skew Configuration");
       test_id = 2;
       for(i = 0; i < 4; i = i+1) begin
          strap_in = 0;
          strap_in[12:11] = i;
          strap_skew = i;
          apply_strap(strap_in);

          //#7 - Check the strap reg value
          wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_PAD_STRAP,read_data,strap_in);
          wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_STRAP_STICKY,read_data,strap_sticky);
          wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_SYSTEM_STRAP,read_data,strap_sticky);
          wb_user_core_read_check(`ADDR_SPACE_WBHOST+`WBHOST_CLK_CTRL1,read_data,skew_config);
       end
       if(test_fail == 1) begin
          $display("ERROR: Step-2, Checking the Clock Skew Configuration - FAILED");
       end else begin
          $display("STATUS: Step-2, Checking the Clock Skew Configuration - PASSED");
       end
       $display("##########################################################");
       $display("Step-3, Checking the riscv/wbs clock Selection though Strap");
       test_id = 3;
       for(i = 0; i < 4; i = i+1) begin
          for(j = 0; j < 4; j = j+1) begin
              strap_in = 0;
              strap_in[1:0] = i;
              cpu_clk_cfg[1:0]=i;
              wbs_clk_cfg[1:0]=i;
              strap_in[3:2] = j;
              cpu_clk_cfg[3:2]=j;
              wbs_clk_cfg[3:2]=j;
              strap_in[3:2] = j;
 
              apply_strap(strap_in);

              //#7 - Check the strap reg value
              wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_PAD_STRAP,read_data,strap_in);
              wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_STRAP_STICKY,read_data,strap_sticky);
              wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_SYSTEM_STRAP,read_data,strap_sticky);
              wb_user_core_read(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,read_data);
              if(read_data[23:16] != clk_ctrl2) test_fail = 1;
              clock_monitor2(cpu_clk_cfg,wbs_clk_cfg);
          end
       end
       if(test_fail == 1) begin
          $display("ERROR: Step-3, Checking the riscv/wbs clock Selection though Strap - FAILED");
       end else begin
          $display("STATUS: Step-3, Checking the riscv/wbs clock Selection though Strap - PASSED");
       end
       $display("##########################################################");

       $display("##########################################################");
       $display("Step-4, Checking the soft reboot sequence");
       test_id = 4;
       for(i = 0; i < 31; i = i+1) begin
         // #1 - Write Data to Sticky bit and Set Reboot Request
          wait(u_top.s_reset_n == 1);          // Wait for system reset removal
         write_data = (1<< i) ; // bit[31] = 1 in soft reboot request
         write_data = write_data + (1 << `STRAP_SOFT_REBOOT_REQ); // bit[STRAP_SOFT_REBOOT_REQ] = 1 in soft reboot request
         wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_STRAP_STICKY,write_data);


          // #3 - Wait for system reset removal
          wait(u_top.s_reset_n == 1);          // Wait for system reset removal
          wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_STRAP_STICKY,read_data,{1'b0,write_data[30:0]});
          wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_SYSTEM_STRAP,read_data,write_data);
          repeat (10) @(posedge clock);

       end

       if(test_fail == 1) begin
          $display("ERROR: Step-4, Checking the soft reboot sequence - FAILED");
       end else begin
          $display("STATUS: Step-4, Checking the soft reboot sequence - PASSED");
       end

       $display("##########################################################");
       $display("Step-5, Checking the uart Master baud-16x clock is 9600* 16");
       test_id = 5;

       strap_in = 0;
       strap_in[`PSTRAP_UARTM_CFG] = 2'b01; // constant value based on system clock-50Mhz
       apply_strap(strap_in); 

       repeat (10) @(posedge clock);
       uartm_clock_monitor(6510); // 1/(9600*16) = 6510 ns, Assumption is user_clock1 = 40Mhz

       if(test_fail == 1) begin
          $display("ERROR: Step-5,  Checking the uart Master baud-16x clock - FAILED");
       end else begin
          $display("STATUS: Step-5,  Checking the uart Master baud-16x clock - PASSED");
       end
       $display("##########################################################");

       $display("##########################################################");
       $display("Step-6, Checking the uart Master Auto Detect Mode");
       test_id = 6;

       strap_in = 0;
       strap_in[`PSTRAP_UARTM_CFG] = 2'b00; // Auto Detect Mode
       apply_strap(strap_in); 

       tb_master_uart.uart_init;
       uart_data_bit           = 2'b11;
       uart_stop_bits          = 1; // 0: 1 stop bit; 1: 2 stop bit;
       uart_stick_parity       = 0; // 1: force even parity
       uart_parity_en          = 0; // parity enable
       uart_even_odd_parity    = 1; // 0: odd parity; 1: even parity
       uart_divisor            = 15;// divided by n * 16
       uart_timeout            = 600;// wait time limit
       uart_fifo_enable        = 0;	// fifo mode disable
       tb_master_uart.debug_mode = 0; // disable debug display
	   tb_set_uart_baud(50000000,288000,uart_divisor);// 50Mhz Ref clock, Baud Rate: 288000
       tb_master_uart.control_setup (uart_data_bit, uart_stop_bits, uart_parity_en, uart_even_odd_parity, uart_stick_parity, uart_timeout, uart_divisor);

       repeat (10) @(posedge clock);
       tb_master_uart.write_char(8'hA); // New line for auto detect

       repeat (10) @(posedge clock);
       uartm_clock_monitor(200); // 1/(28800*16) = 217 ns - Adjusting 20ns (50Mhz) boundary => 200 

       // Wait for Initial command from uart master
       flag = 0;
       while(flag == 0)
       begin
            tb_master_uart.read_char(read_data,flag);
            $write ("%c",read_data);
       end
       uartm_reg_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_0,CHIP_SIGNATURE);

       if(test_fail == 1) begin
          $display("ERROR: Step-6,  Checking the uart Master Auto Detect baud-28800 - FAILED");
       end else begin
          $display("STATUS: Step-6,  Checking the uart Master Auto Detect baud-28800  - PASSED");
       end
       $display("##########################################################");

       $display("##########################################################");
       $display("Step-7, Checking the uart Master Auto Detect Mode");
       test_id = 7;

       strap_in = 0;
       strap_in[`PSTRAP_UARTM_CFG] = 2'b00; // Auto Detect Mode
       apply_strap(strap_in); 

       tb_master_uart.uart_init;
       uart_data_bit           = 2'b11;
       uart_stop_bits          = 1; // 0: 1 stop bit; 1: 2 stop bit;
       uart_stick_parity       = 0; // 1: force even parity
       uart_parity_en          = 0; // parity enable
       uart_even_odd_parity    = 1; // 0: odd parity; 1: even parity
       uart_divisor            = 15;// divided by n * 16
       uart_timeout            = 600;// wait time limit
       uart_fifo_enable        = 0;	// fifo mode disable
       tb_master_uart.debug_mode = 0; // disable debug display
	   tb_set_uart_baud(50000000,38400,uart_divisor);// 50Mhz Ref clock, Baud Rate: 38400
       tb_master_uart.control_setup (uart_data_bit, uart_stop_bits, uart_parity_en, uart_even_odd_parity, uart_stick_parity, uart_timeout, uart_divisor);

       repeat (10) @(posedge clock);
       tb_master_uart.write_char(8'hA); // New line for auto detect

       repeat (10) @(posedge clock);
       uartm_clock_monitor(1620); // 1/(38400*16) = 1627.6 ns, Adjusting to 20ns boundary => 1620
   
       // Wait for Initial command from uart master
       flag = 0;
       while(flag == 0)
       begin
            tb_master_uart.read_char(read_data,flag);
            $write ("%c",read_data);
       end
       uartm_reg_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_0,CHIP_SIGNATURE);

       if(test_fail == 1) begin
          $display("ERROR: Step-7,  Checking the uart Master Auto Detect baud-38400 - FAILED");
       end else begin
          $display("STATUS: Step-7,  Checking the uart Master Auto Detect baud-38400  - PASSED");
       end
       $display("##########################################################");
        
       `ifndef GL  
       $display("###################################################");
       $display("Step-8,Monitor: Checking the PLL:");
       $display("###################################################");
       test_id = 8;
       // Set PLL enable, no DCO mode ; Set PLL output divider to 0x03
       // Checking the expression
       //   Internal PLL delay = 1.168 + 0.012 * $itor(bcount)
       //   Actual PLL Clock Period = delay * 4
            
       wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_PLL_CTRL1,{24'h0,1'b1,3'b000});
       bcount =0; 
       for(i = 0; i < 26; i = i+1) begin
           wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_PLL_CTRL2,{1'b1,5'h0,bcount[25:0]});
           repeat (10) @(posedge clock);
           pll_clock_monitor((1.168 + (0.012 *i)) * 4);
           //$display("i: %d bcount: %x Clk Period : %f",i,bcount,(1.168 + (0.012 *i)) * 4);
           bcount = bcount | (1 << i ); 
        end
       /***
       test_step = 12;
       // Set PLL enable, DCO mode ; Set PLL output divider to 0x05
       // Input Ref Clock Divider - 0 , Means Div-2, So Osc clock = 40Mhz/2 = 20Mhz = 50ns
       // Since PLL has divider by 4, Efectivly PLL Output Fequency = 20Mhz * 5 = 100Mhz
       wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,{16'h0,1'b1,3'b010,4'b0000,8'h3});
       wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_PLL_CTRL,{1'b0,5'd10,26'h0000});
       repeat (10000) @(posedge clock);
       pll_clock_monitor(5);
       */
       if(test_fail == 1) begin
          $display("ERROR: Step-8, Checking the PLL - FAILED");
       end else begin
          $display("STATUS: Step-8, Checking the PLL - PASSED");
       end
       $display("##########################################################");
       
       
       $display("###################################################");
       $display("Step-9,Monitor: PLL Monitor Clock output:");
       $display("###################################################");
       $display("Monitor: CPU: CLOCK2/(2+3), USB: CLOCK2/(2+9), RTC: CLOCK2/(2+255), WBS:CLOCK2/(2+4)");
       test_id = 9;
       test_step = 13;
       init();
       repeat (10) @(posedge clock);
       // Configured the PLL to highest frequency, 5.008ns
       //wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_PLL_CTRL1,{24'h0,1'b1,3'b000});
       //wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_PLL_CTRL2,{1'b1,5'h0,26'h0});

       // Monitor user_clock1 at debug Mon
       dbg_clk_monitor();
          
       if(test_fail == 1) begin
          $display("ERROR: Step-9, PLL Monitor Clock output - FAILED");
       end else begin
          $display("STATUS: Step-9, PLL Monitor Clock output - PASSED");
       end
      
       `endif
       $display("##########################################################");
       $display("Step-10,Monitor: Analog Config checks                     ");
       $display("##########################################################");
       test_id = 10;
       test_step = 14;

        // Remove Wb/PinMux Reset
        wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,'h1);

        wb_user_core_write(`ADDR_SPACE_ANALOG+`ANALOG_CFG_DAC0,'h11);
        wb_user_core_write(`ADDR_SPACE_ANALOG+`ANALOG_CFG_DAC1,'h22);
        wb_user_core_write(`ADDR_SPACE_ANALOG+`ANALOG_CFG_DAC2,'h33);
        wb_user_core_write(`ADDR_SPACE_ANALOG+`ANALOG_CFG_DAC3,'h44);
        wb_user_core_read_check(`ADDR_SPACE_ANALOG+`ANALOG_CFG_DAC0,read_data,'h11);
        wb_user_core_read_check(`ADDR_SPACE_ANALOG+`ANALOG_CFG_DAC1,read_data,'h22);
        wb_user_core_read_check(`ADDR_SPACE_ANALOG+`ANALOG_CFG_DAC2,read_data,'h33);
        wb_user_core_read_check(`ADDR_SPACE_ANALOG+`ANALOG_CFG_DAC3,read_data,'h44);
        repeat (10) @(posedge clock);
        if((u_top.u_4x8bit_dac.Din0 != 'h11) || (u_top.u_4x8bit_dac.Din1 != 'h22) ||
           (u_top.u_4x8bit_dac.Din2 != 'h33) || (u_top.u_4x8bit_dac.Din3 != 'h44)) begin
           test_fail = 1;
        end

        if(test_fail == 1) begin
           $display("ERROR: Step-10,Monitor: Analog Config check - FAILED");
        end else begin
           $display("STATUS: Step-10,Monitor: Ananlog Config check - PASSED");

        $display("##########################################################");

          end
      end
      begin
         repeat (500000) @(posedge clock);
   	       // $display("+1000 cycles");
         test_fail = 1;
      end
      join_any
      disable fork; //disable pending fork activity

   
      $display("###################################################");
      if(test_fail == 0) begin
         `ifdef GL
             $display("Monitor: %m (GL) Passed");
         `else
             $display("Monitor: %m (RTL) Passed");
         `endif
      end else begin
          `ifdef GL
              $display("Monitor: %m (GL) Failed");
          `else
              $display("Monitor: %m (RTL) Failed");
          `endif
       end
      $display("###################################################");
      #100
      $finish;
end

//---------------------------
//  UART Agent integration
// --------------------------

assign uart_txd   = (io_oeb[7] == 1'b0) ? io_out[7] : 1'b0;
//assign io_in[6]  = uart_rxd ; // Assigned at top-level
 
uart_agent tb_master_uart(
	.mclk                (clock              ),
	.txd                 (uart_rxd           ),
	.rxd                 (uart_txd           )
	);



task clock_monitor2;
input [3:0] cpu_cfg;
input [3:0] wbs_cfg;
real        exp_cpu_period; // ns
real        exp_wbs_period; // ns
begin
   force clock_mon = u_top.u_wb_host.cpu_clk;
   case(cpu_cfg)
   4'b0000: exp_cpu_period = CLK1_PERIOD;
   4'b0001: exp_cpu_period = CLK2_PERIOD;
   4'b0010: exp_cpu_period = IPLL_PERIOD;
   4'b0011: exp_cpu_period = XTAL_PERIOD;
   4'b0100: exp_cpu_period = CLK1_PERIOD*2;
   4'b0101: exp_cpu_period = CLK2_PERIOD*2;
   4'b0110: exp_cpu_period = IPLL_PERIOD*2;
   4'b0111: exp_cpu_period = XTAL_PERIOD*2;
   4'b1000: exp_cpu_period = CLK1_PERIOD*4;
   4'b1001: exp_cpu_period = CLK2_PERIOD*4;
   4'b1010: exp_cpu_period = IPLL_PERIOD*4;
   4'b1011: exp_cpu_period = XTAL_PERIOD*4;
   4'b1100: exp_cpu_period = CLK1_PERIOD*8;
   4'b1101: exp_cpu_period = CLK2_PERIOD*8;
   4'b1110: exp_cpu_period = IPLL_PERIOD*8;
   4'b1111: exp_cpu_period = XTAL_PERIOD*8;
   endcase 
   check_clock_period("CPU CLock",exp_cpu_period);
   release clock_mon;

   force clock_mon = u_top.u_wb_host.wbs_clk_out;
   case(wbs_cfg)
   4'b0000: exp_wbs_period = CLK1_PERIOD;
   4'b0001: exp_wbs_period = CLK2_PERIOD;
   4'b0010: exp_wbs_period = IPLL_PERIOD;
   4'b0011: exp_wbs_period = XTAL_PERIOD;
   4'b0100: exp_wbs_period = CLK1_PERIOD*2;
   4'b0101: exp_wbs_period = CLK2_PERIOD*2;
   4'b0110: exp_wbs_period = IPLL_PERIOD*2;
   4'b0111: exp_wbs_period = XTAL_PERIOD*2;
   4'b1000: exp_wbs_period = CLK1_PERIOD*4;
   4'b1001: exp_wbs_period = CLK2_PERIOD*4;
   4'b1010: exp_wbs_period = IPLL_PERIOD*4;
   4'b1011: exp_wbs_period = XTAL_PERIOD*4;
   4'b1100: exp_wbs_period = CLK1_PERIOD*8;
   4'b1101: exp_wbs_period = CLK2_PERIOD*8;
   4'b1110: exp_wbs_period = IPLL_PERIOD*8;
   4'b1111: exp_wbs_period = XTAL_PERIOD*8;
   endcase 
   check_clock_period("WBS Clock",exp_wbs_period);
   release clock_mon;
end
endtask

task clock_monitor;
input [15:0] exp_cpu_period;
input [15:0] exp_usb_period;
input [15:0] exp_rtc_period;
input [15:0] exp_wbs_period;
begin
   force clock_mon = u_top.u_wb_host.cpu_clk;
   check_clock_period("CPU CLock",exp_cpu_period);
   release clock_mon;

   force clock_mon = u_top.u_pinmux.usb_clk;
   check_clock_period("USB Clock",exp_usb_period);
   release clock_mon;

   force clock_mon = u_top.u_pinmux.rtc_clk;
   check_clock_period("RTC Clock",exp_rtc_period);
   release clock_mon;

   force clock_mon = u_top.u_wb_host.wbs_clk_out;
   check_clock_period("WBS Clock",exp_wbs_period);
   release clock_mon;
end
endtask

task pll_clock_monitor;
input real exp_period;
begin
   //force clock_mon = u_top.u_wb_host.pll_clk_out[0];
   `ifdef GL
      force clock_mon = u_top.u_wb_host.int_pll_clock;
    `else
      force clock_mon = u_top.u_wb_host.int_pll_clock;

    `endif
   check_clock_period("PLL CLock",exp_period);
   release clock_mon;
end
endtask

task uartm_clock_monitor;
input real exp_period;
begin
   `ifdef GL
   force clock_mon = u_top.u_wb_host._10372_.Q;
    `else
   force clock_mon = u_top.u_wb_host.u_uart2wb.u_core.line_clk_16x;
    `endif
   check_clock_period("UART CLock",exp_period);
   release clock_mon;
end
endtask


wire dbg_clk_mon = (io_oeb[37] == 1'b0) ? io_out[37]: 1'b0;

//assign dbg_clk_ref  =    (cfg_mon_sel == 4'b000) ? user_clock1    :
//	                       (cfg_mon_sel == 4'b001) ? user_clock2    :
//	                       (cfg_mon_sel == 4'b010) ? xtal_clk     :
//	                       (cfg_mon_sel == 4'b011) ? int_pll_clock: 
//	                       (cfg_mon_sel == 4'b100) ? mclk         : 
//	                       (cfg_mon_sel == 4'b101) ? cpu_clk      : 
//	                       (cfg_mon_sel == 4'b110) ? usb_clk      : 
//	                       (cfg_mon_sel == 4'b111) ? rtc_clk      : 1'b0;

task dbg_clk_monitor;
begin
   force clock_mon = dbg_clk_mon;

   wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG1,{16'h0,4'b0000,4'b0000});
   check_clock_period("USER CLOCK1",CLK1_PERIOD*16);

   wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG1,{16'h0,4'b0001,4'b0000});
   check_clock_period("USER CLOCK2",CLK2_PERIOD*16);

   wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG1,{16'h0,4'b0010,4'b0000});
   check_clock_period("XTAL CLOCK2",XTAL_PERIOD*16);

   wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG1,{16'h0,4'b0011,4'b0000});
   check_clock_period("INTERNAL PLL",IPLL_PERIOD*16);
   
   wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG1,{16'h0,4'b0100,4'b0000});
   check_clock_period("WBS CLOCK",CLK1_PERIOD*16);

   wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG1,{16'h0,4'b0101,4'b0000});
   check_clock_period("CPU CLOCK",CLK1_PERIOD*16);
   release clock_mon;
end
endtask

//----------------------------------
// Check the clock period
//----------------------------------
task check_clock_period;
input [127:0] clk_name;
input real    period; 
real edge2, edge1, clock_period;
real tolerance,min_period,max_period;
begin

  tolerance = 0.01;

   min_period = period * (1-tolerance);
   max_period = period * (1+tolerance);

   //$timeformat(-12,2,"ps",10);
   repeat(1) @(posedge clock_mon);
   repeat(1) @(posedge clock_mon);
   edge1  = $realtime;
   repeat(10) @(posedge clock_mon);
   edge2  = $realtime;
   clock_period = (edge2-edge1)/10;

   if ( clock_period > max_period ) begin
       $display("STATUS: FAIL => %s clock is too fast => Rxp: %.3fns Exd: %.3fns",clk_name,clock_period,max_period);
       test_fail = 1;
   end else if ( clock_period < min_period ) begin
       $display("STATUS: FAIL => %s clock is too slow => Rxp: %.3fns Exd: %.3fns",clk_name,clock_period,min_period);
       test_fail = 1;
   end else begin
       $display("STATUS: PASS => %s  Period: %.3fns ",clk_name,period);
   end
end
endtask




`include "uart_master_tasks.sv"
endmodule
`default_nettype wire
