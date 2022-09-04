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
`include "user_params.svh"

module user_basic_tb;
parameter CLK1_PERIOD = 10;
parameter CLK2_PERIOD = 2.5;
parameter IPLL_PERIOD = 5.008;
parameter XTAL_PERIOD = 6;

reg            clock         ;
reg            clock2        ;
reg            xtal_clk      ;
reg            wb_rst_i      ;
reg            power1, power2;
reg            power3, power4;

reg            wbd_ext_cyc_i;  // strobe/request
reg            wbd_ext_stb_i;  // strobe/request
reg [31:0]     wbd_ext_adr_i;  // address
reg            wbd_ext_we_i;  // write
reg [31:0]     wbd_ext_dat_i;  // data output
reg [3:0]      wbd_ext_sel_i;  // byte enable

wire [31:0]    wbd_ext_dat_o;  // data input
wire           wbd_ext_ack_o;  // acknowlegement
wire           wbd_ext_err_o;  // error

// User I/O
wire [37:0]    io_oeb        ;
wire [37:0]    io_out        ;
wire [37:0]    io_in         ;

wire [37:0]    mprj_io       ;
wire [7:0]     mprj_io_0     ;
reg            test_fail     ;
reg [31:0]     write_data     ;
reg [31:0]     read_data     ;
//----------------------------------
// Uart Configuration
// ---------------------------------
reg [1:0]      uart_data_bit        ;
reg	       uart_stop_bits       ; // 0: 1 stop bit; 1: 2 stop bit;
reg	       uart_stick_parity    ; // 1: force even parity
reg	       uart_parity_en       ; // parity enable
reg	       uart_even_odd_parity ; // 0: odd parity; 1: even parity

reg [7:0]      uart_data            ;
reg [15:0]     uart_divisor         ;	// divided by n * 16
reg [15:0]     uart_timeout         ;// wait time limit

reg [15:0]     uart_rx_nu           ;
reg [15:0]     uart_tx_nu           ;
reg [7:0]      uart_write_data [0:39];
reg 	       uart_fifo_enable     ;	// fifo mode disable

wire           clock_mon;
integer        test_step;
reg  [15:0]    strap_in;
wire [31:0]    strap_sticky;
reg  [7:0]     test_id;

assign io_in = {26'h0,xtal_clk,11'h0};

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

assign skew_config[3:0]   =   (strap_skew == 2'b00) ?  SKEW_RESET_VAL[3:0] :
                              (strap_skew == 2'b01) ?  SKEW_RESET_VAL[3:0] + 2 :
                              (strap_skew == 2'b10) ?  SKEW_RESET_VAL[3:0] + 4 : SKEW_RESET_VAL[3:0]-4;

assign skew_config[7:4]   =   (strap_skew == 2'b00) ?  SKEW_RESET_VAL[7:4]  :
                              (strap_skew == 2'b01) ?  SKEW_RESET_VAL[7:4] + 2 :
                              (strap_skew == 2'b10) ?  SKEW_RESET_VAL[7:4] + 4 : SKEW_RESET_VAL[7:4]-4;

assign skew_config[11:8]  =   (strap_skew == 2'b00) ?  SKEW_RESET_VAL[11:8]  :
                              (strap_skew == 2'b01) ?  SKEW_RESET_VAL[11:8] + 2 :
                              (strap_skew == 2'b10) ?  SKEW_RESET_VAL[11:8] + 4 : SKEW_RESET_VAL[11:8]-4;

assign skew_config[15:12] =   (strap_skew == 2'b00) ?  SKEW_RESET_VAL[15:12]  :
                              (strap_skew == 2'b01) ?  SKEW_RESET_VAL[15:12] + 2 :
                              (strap_skew == 2'b10) ?  SKEW_RESET_VAL[15:12] + 4 : SKEW_RESET_VAL[15:12]-4;

assign skew_config[19:16] =   (strap_skew == 2'b00) ?  SKEW_RESET_VAL[19:16]  :
                              (strap_skew == 2'b01) ?  SKEW_RESET_VAL[19:16] + 2 :
                              (strap_skew == 2'b10) ?  SKEW_RESET_VAL[19:16] + 4 : SKEW_RESET_VAL[19:16]-4;

assign skew_config[23:20] =   (strap_skew == 2'b00) ?  SKEW_RESET_VAL[23:20]  :
                              (strap_skew == 2'b01) ?  SKEW_RESET_VAL[23:20] + 2 :
                              (strap_skew == 2'b10) ?  SKEW_RESET_VAL[23:20] + 4 : SKEW_RESET_VAL[23:20]-4;

assign skew_config[27:24] =   (strap_skew == 2'b00) ?  SKEW_RESET_VAL[27:24] :
                              (strap_skew == 2'b01) ?  SKEW_RESET_VAL[27:24] + 2 :
                              (strap_skew == 2'b10) ?  SKEW_RESET_VAL[27:24] + 4 : SKEW_RESET_VAL[27:24]-4;

assign skew_config[31:28] = 4'b0;

//----------------------------------------------------------
reg [3:0] cpu_clk_cfg,wbs_clk_cfg;
wire [7:0] clk_ctrl2 = {cpu_clk_cfg,wbs_clk_cfg};



//-----------------------------------------------------------


integer i,j;

	// External clock is used by default.  Make this artificially fast for the
	// simulation.  Normally this would be a slow clock and the digital PLL
	// would be the fast clock.

	always #(CLK1_PERIOD/2) clock  <= (clock === 1'b0);
	always #(CLK2_PERIOD/2) clock2 <= (clock2 === 1'b0);
	always #(XTAL_PERIOD/2) xtal_clk <= (xtal_clk === 1'b0);

	initial begin
		test_step = 0;
		clock = 0;
		clock2 = 0;
                wbd_ext_cyc_i ='h0;  // strobe/request
                wbd_ext_stb_i ='h0;  // strobe/request
                wbd_ext_adr_i ='h0;  // address
                wbd_ext_we_i  ='h0;  // write
                wbd_ext_dat_i ='h0;  // data output
                wbd_ext_sel_i ='h0;  // byte enable
	end

	`ifdef WFDUMP
	   initial begin
	   	$dumpfile("simx.vcd");
	   	$dumpvars(1, user_basic_tb);
	   	$dumpvars(1, user_basic_tb.u_top);
	   	//$dumpvars(0, user_basic_tb.u_top.u_pll);
	   	$dumpvars(0, user_basic_tb.u_top.u_wb_host);
	   	//$dumpvars(0, user_basic_tb.u_top.u_intercon);
	   	//$dumpvars(1, user_basic_tb.u_top.u_intercon);
	   	$dumpvars(0, user_basic_tb.u_top.u_pinmux);
	   end
       `endif

	initial begin
		wb_rst_i <= 1'b0;
		#1000;
		wb_rst_i <= 1'b1;
		#1000;
		wb_rst_i <= 1'b0;	    	// Release reset
	end


initial
begin

   #200; // Wait for reset removal
   repeat (10) @(posedge clock);
   $display("Monitor: Standalone User Basic Test Started");
   
   repeat (2) @(posedge clock);

   test_fail=0;

   fork
   begin
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
              wb_user_core_read_check(`ADDR_SPACE_WBHOST+`WBHOST_CLK_CTRL2,read_data,clk_ctrl2);
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
       /****
       $display("Step-5, Checking the uart Master baud-16x clock is 9600* 16");
       test_id = 5;

       apply_strap(16'h10); // [4] -  // uart master config control - constant value based on system clock selection

       uartm_clock_monitor(6510); // 1/(9600*16) = 6510 ns

       if(test_fail == 1) begin
          $display("ERROR: Step-5,  Checking the uart Master baud-16x clock - FAILED");
       end else begin
          $display("STATUS: Step-5,  Checking the uart Master baud-16x clock - PASSED");
       end
       $display("##########################################################");
       ***/
       /*** 
       `ifndef GL  
       $display("###################################################");
       $display("Step-5,Monitor: Checking the PLL:");
       $display("###################################################");
       test_id = 5;
       // Set PLL enable, no DCO mode ; Set PLL output divider to 0x03
       wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,{16'h0,1'b1,3'b100,4'b0000,8'h2});
       wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_PLL_CTRL,{1'b0,5'h3,26'h00000});
       repeat (100) @(posedge clock);
       pll_clock_monitor(5.101);

       test_step = 12;
       // Set PLL enable, DCO mode ; Set PLL output divider to 0x01
       wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,{16'h0,1'b1,3'b000,4'b0000,8'h2});
       wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_PLL_CTRL,{1'b1,5'h0,26'h0000});
       repeat (100) @(posedge clock);
       pll_clock_monitor(4.080);

       if(test_fail == 1) begin
          $display("ERROR: Step-5, Checking the PLL - FAILED");
       end else begin
          $display("STATUS: Step-5, Checking the PLL - PASSED");
       end
       $display("##########################################################");

       $display("###################################################");
       $display("Step-6,Monitor: PLL Monitor Clock output:");
       $display("###################################################");
       $display("Monitor: CPU: CLOCK2/(2+3), USB: CLOCK2/(2+9), RTC: CLOCK2/(2+255), WBS:CLOCK2/(2+4)");
       test_id = 6;
       test_step = 13;
       wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_CLK_CTRL2,{8'h63,8'h69,8'hFF,8'h64});

       // Set PLL enable, DCO mode ; Set PLL output divider to 0x01
       wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,{16'h0,1'b1,3'b000,4'b0000,8'h2});
       wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_PLL_CTRL,{1'b1,5'h0,26'h0000});
       dbg_clk_monitor(79,60,5*CLK2_PERIOD,11*CLK2_PERIOD,257*CLK2_PERIOD,6*CLK2_PERIOD);
       `endif
          
       if(test_fail == 1) begin
          $display("ERROR: Step-6, PLL Monitor Clock output - FAILED");
       end else begin
          $display("STATUS: Step-6, PLL Monitor Clock output - PASSED");
       end
      ****/
       $display("##########################################################");
        $display("Step-7,Monitor: Checking the chip signature :");
        $display("###################################################");
       test_id = 7;
        test_step = 14;
        // Remove Wb/PinMux Reset
        wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,'h1);

         wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_0,read_data,32'h8273_8343);
         wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_1,read_data,32'h0309_2022);
         wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_2,read_data,32'h0005_3000);
         if(test_fail == 1) begin
            $display("ERROR: Step-7,Monitor: Checking the chip signature - FAILED");
         end else begin
            $display("STATUS: Step-7,Monitor: Checking the chip signature - PASSED");

         $display("##########################################################");

          end
      end
      begin
         repeat (30000) @(posedge clock);
   	       // $display("+1000 cycles");
         test_fail = 1;
      end
      join_any
      disable fork; //disable pending fork activity

   
      $display("###################################################");
      if(test_fail == 0) begin
         `ifdef GL
             $display("Monitor: Standalone User UART Test (GL) Passed");
         `else
             $display("Monitor: Standalone User UART Test (RTL) Passed");
         `endif
      end else begin
          `ifdef GL
              $display("Monitor: Standalone User UART Test (GL) Failed");
          `else
              $display("Monitor: Standalone User UART Test (RTL) Failed");
          `endif
       end
      $display("###################################################");
      #100
      $finish;
end


wire USER_VDD1V8 = 1'b1;
wire VSS = 1'b0;


user_project_wrapper u_top(
`ifdef USE_POWER_PINS
    .vccd1(USER_VDD1V8),	// User area 1 1.8V supply
    .vssd1(VSS),	// User area 1 digital ground
`endif
    .wb_clk_i        (clock),  // System clock
    .user_clock2     (clock2),  // Real-time clock
    .wb_rst_i        (wb_rst_i),  // Regular Reset signal

    .wbs_cyc_i   (wbd_ext_cyc_i),  // strobe/request
    .wbs_stb_i   (wbd_ext_stb_i),  // strobe/request
    .wbs_adr_i   (wbd_ext_adr_i),  // address
    .wbs_we_i    (wbd_ext_we_i),  // write
    .wbs_dat_i   (wbd_ext_dat_i),  // data output
    .wbs_sel_i   (wbd_ext_sel_i),  // byte enable

    .wbs_dat_o   (wbd_ext_dat_o),  // data input
    .wbs_ack_o   (wbd_ext_ack_o),  // acknowlegement

 
    // Logic Analyzer Signals
    .la_data_in      ('1) ,
    .la_data_out     (),
    .la_oenb         ('0),
 

    // IOs
    .io_in          (io_in )  ,
    .io_out         (io_out) ,
    .io_oeb         (io_oeb) ,

    .user_irq       () 

);


`ifndef GL // Drive Power for Hold Fix Buf
    // All standard cell need power hook-up for functionality work
    initial begin


    end
`endif    

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
      force clock_mon = u_top.u_wb_host.pll_clk_out[0];
    `else
      force clock_mon = u_top.u_wb_host.u_clkbuf_pll.X;
    `endif
   check_clock_period("PLL CLock",exp_period);
   release clock_mon;
end
endtask

task uartm_clock_monitor;
input real exp_period;
begin
   force clock_mon = u_top.u_wb_host.u_uart2wb.u_core.line_clk_16x;
   check_clock_period("UART CLock",exp_period);
   release clock_mon;
end
endtask


wire dbg_clk_mon = io_out[33];

task dbg_clk_monitor;
input [15:0] exp_pll_div16_period;
input [15:0] exp_pll_ref_period;
input [15:0] exp_cpu_period;
input [15:0] exp_usb_period;
input [15:0] exp_rtc_period;
input [15:0] exp_wbs_period;
begin
   force clock_mon = dbg_clk_mon;

   wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,{16'h0,1'b1,3'b100,4'b0000,8'h2});
   check_clock_period("PLL CLock",exp_pll_div16_period);

   wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,{16'h0,1'b1,3'b100,4'b0001,8'h2});
   check_clock_period("PLL REF Clock",exp_pll_ref_period);

   wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,{16'h0,1'b1,3'b100,4'b0010,8'h2});
   check_clock_period("WBS Clock",exp_wbs_period);

   wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,{16'h0,1'b1,3'b100,4'b0011,8'h2});
   check_clock_period("CPU CLock",exp_cpu_period);

   wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,{16'h0,1'b1,3'b100,4'b0100,8'h2});
   check_clock_period("RTC Clock",exp_rtc_period);

   wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,{16'h0,1'b1,3'b100,4'b0101,8'h2});
   check_clock_period("USB Clock",exp_usb_period);
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
   repeat(100) @(posedge clock_mon);
   edge2  = $realtime;
   clock_period = (edge2-edge1)/100;

   if ( clock_period > max_period ) begin
       $display("STATUS: FAIL => %s clock is too fast => Exp: %.3fns Rxd: %.3fns",clk_name,clock_period,max_period);
       test_fail = 1;
   end else if ( clock_period < min_period ) begin
       $display("STATUS: FAIL => %s clock is too slow => Exp: %.3fns Rxd: %.3fns",clk_name,clock_period,min_period);
       test_fail = 1;
   end else begin
       $display("STATUS: PASS => %s  Period: %.3fns ",clk_name,period);
   end
end
endtask






task wb_user_core_write;
input [31:0] address;
input [31:0] data;
begin
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_adr_i =address;  // address
  wbd_ext_we_i  ='h1;  // write
  wbd_ext_dat_i =data;  // data output
  wbd_ext_sel_i ='hF;  // byte enable
  wbd_ext_cyc_i ='h1;  // strobe/request
  wbd_ext_stb_i ='h1;  // strobe/request
  wait(wbd_ext_ack_o == 1);
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_cyc_i ='h0;  // strobe/request
  wbd_ext_stb_i ='h0;  // strobe/request
  wbd_ext_adr_i ='h0;  // address
  wbd_ext_we_i  ='h0;  // write
  wbd_ext_dat_i ='h0;  // data output
  wbd_ext_sel_i ='h0;  // byte enable
  $display("DEBUG WB USER ACCESS WRITE Address : %x, Data : %x",address,data);
  repeat (2) @(posedge clock);
end
endtask

task  wb_user_core_read;
input [31:0] address;
output [31:0] data;
reg    [31:0] data;
begin
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_adr_i =address;  // address
  wbd_ext_we_i  ='h0;  // write
  wbd_ext_dat_i ='0;  // data output
  wbd_ext_sel_i ='hF;  // byte enable
  wbd_ext_cyc_i ='h1;  // strobe/request
  wbd_ext_stb_i ='h1;  // strobe/request
  wait(wbd_ext_ack_o == 1);
  repeat (1) @(negedge clock);
  data  = wbd_ext_dat_o;  
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_cyc_i ='h0;  // strobe/request
  wbd_ext_stb_i ='h0;  // strobe/request
  wbd_ext_adr_i ='h0;  // address
  wbd_ext_we_i  ='h0;  // write
  wbd_ext_dat_i ='h0;  // data output
  wbd_ext_sel_i ='h0;  // byte enable
  $display("DEBUG WB USER ACCESS READ Address : %x, Data : %x",address,data);
  repeat (2) @(posedge clock);
end
endtask

task  wb_user_core_read_check;
input [31:0] address;
output [31:0] data;
input [31:0] cmp_data;
reg    [31:0] data;
begin
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_adr_i =address;  // address
  wbd_ext_we_i  ='h0;  // write
  wbd_ext_dat_i ='0;  // data output
  wbd_ext_sel_i ='hF;  // byte enable
  wbd_ext_cyc_i ='h1;  // strobe/request
  wbd_ext_stb_i ='h1;  // strobe/request
  wait(wbd_ext_ack_o == 1);
  repeat (1) @(negedge clock);
  data  = wbd_ext_dat_o;  
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_cyc_i ='h0;  // strobe/request
  wbd_ext_stb_i ='h0;  // strobe/request
  wbd_ext_adr_i ='h0;  // address
  wbd_ext_we_i  ='h0;  // write
  wbd_ext_dat_i ='h0;  // data output
  wbd_ext_sel_i ='h0;  // byte enable
  if(data !== cmp_data) begin
     $display("ERROR : WB USER ACCESS READ  Address : 0x%x, Exd: 0x%x Rxd: 0x%x ",address,cmp_data,data);
     test_fail = 1;
  end else begin
     $display("STATUS: WB USER ACCESS READ  Address : 0x%x, Data : 0x%x",address,data);
  end
  repeat (2) @(posedge clock);
end
endtask

`ifdef GL

wire        wbd_spi_stb_i   = u_top.u_qspi_master.wbd_stb_i;
wire        wbd_spi_ack_o   = u_top.u_qspi_master.wbd_ack_o;
wire        wbd_spi_we_i    = u_top.u_qspi_master.wbd_we_i;
wire [31:0] wbd_spi_adr_i   = u_top.u_qspi_master.wbd_adr_i;
wire [31:0] wbd_spi_dat_i   = u_top.u_qspi_master.wbd_dat_i;
wire [31:0] wbd_spi_dat_o   = u_top.u_qspi_master.wbd_dat_o;
wire [3:0]  wbd_spi_sel_i   = u_top.u_qspi_master.wbd_sel_i;

wire        wbd_uart_stb_i  = u_top.u_uart_i2c_usb_spi.reg_cs;
wire        wbd_uart_ack_o  = u_top.u_uart_i2c_usb_spi.reg_ack;
wire        wbd_uart_we_i   = u_top.u_uart_i2c_usb_spi.reg_wr;
wire [8:0]  wbd_uart_adr_i  = u_top.u_uart_i2c_usb_spi.reg_addr;
wire [7:0]  wbd_uart_dat_i  = u_top.u_uart_i2c_usb_spi.reg_wdata;
wire [7:0]  wbd_uart_dat_o  = u_top.u_uart_i2c_usb_spi.reg_rdata;
wire        wbd_uart_sel_i  = u_top.u_uart_i2c_usb_spi.reg_be;

`endif

/**
`ifdef GL
//-----------------------------------------------------------------------------
// RISC IMEM amd DMEM Monitoring TASK
//-----------------------------------------------------------------------------

`define RISC_CORE  user_uart_tb.u_top.u_core.u_riscv_top

always@(posedge `RISC_CORE.wb_clk) begin
    if(`RISC_CORE.wbd_imem_ack_i)
          $display("RISCV-DEBUG => IMEM ADDRESS: %x Read Data : %x", `RISC_CORE.wbd_imem_adr_o,`RISC_CORE.wbd_imem_dat_i);
    if(`RISC_CORE.wbd_dmem_ack_i && `RISC_CORE.wbd_dmem_we_o)
          $display("RISCV-DEBUG => DMEM ADDRESS: %x Write Data: %x Resonse: %x", `RISC_CORE.wbd_dmem_adr_o,`RISC_CORE.wbd_dmem_dat_o);
    if(`RISC_CORE.wbd_dmem_ack_i && !`RISC_CORE.wbd_dmem_we_o)
          $display("RISCV-DEBUG => DMEM ADDRESS: %x READ Data : %x Resonse: %x", `RISC_CORE.wbd_dmem_adr_o,`RISC_CORE.wbd_dmem_dat_i);
end

`endif
**/
`include "user_tasks.sv"
endmodule
`default_nettype wire
