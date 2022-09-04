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
////  This file is part of the riscdunio cores project            ////
////  https://github.com/dineshannayya/riscdunio.git              ////
////                                                              ////
////  Description                                                 ////
////   This is a standalone test bench to validate the            ////
////   Digital core.                                              ////
////   This test bench to validate ws281x driver                  ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesh.annayya@gmail.com              ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 29th July 2022, Dinesh A                            ////
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

`timescale 1 ns / 1 ns

`include "sram_macros/sky130_sram_2kbyte_1rw1r_32x512_8.v"
`include "is62wvs1288.v"
`include "uart_agent.v"
`include "bfm_ws281x.sv"

`define TB_HEX "arduino_ws281x.hex"
`define TB_TOP arduino_ws281x_tb

module `TB_TOP;
	reg clock;
	reg wb_rst_i;
	reg power1, power2;
	reg power3, power4;

        reg        wbd_ext_cyc_i;  // strobe/request
        reg        wbd_ext_stb_i;  // strobe/request
        reg [31:0] wbd_ext_adr_i;  // address
        reg        wbd_ext_we_i;  // write
        reg [31:0] wbd_ext_dat_i;  // data output
        reg [3:0]  wbd_ext_sel_i;  // byte enable

        wire [31:0] wbd_ext_dat_o;  // data input
        wire        wbd_ext_ack_o;  // acknowlegement
        wire        wbd_ext_err_o;  // error

	// User I/O
	wire [37:0] io_oeb;
	wire [37:0] io_out;
	wire [37:0] io_in;

	wire gpio;
	wire [37:0] mprj_io;
	wire [7:0] mprj_io_0;
	reg         test_fail;
	reg [31:0] read_data;
	reg            flag                 ;
    reg            compare_start        ; // User Need to make sure that compare start match with RiscV core completing initial booting

	reg [31:0]     rx_wcnt              ;
	reg [31:0]     check_sum            ;
        
	integer    d_risc_id;

         integer i,j;

//-----------------------------------------------
// WS281X BFM integration
//----------------------------------------------
parameter WS2811_LS  = 0;
parameter WS2811_HS  = 1;
parameter WS2812_HS  = 2;
parameter WS2812S_HS = 3;
parameter WS2812B_HS = 4;

wire [3:0] ws281x_port ;
reg        ws281x_enb ;



	// 50Mhz CLock
	always #10 clock <= (clock === 1'b0);

	initial begin
		clock = 0;
	    flag  = 0;
        compare_start = 0;
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
	   	$dumpvars(3, `TB_TOP);
	   	$dumpvars(0, `TB_TOP.u_top.u_riscv_top);
	   	$dumpvars(0, `TB_TOP.u_top.u_pinmux);
	   	$dumpvars(0, `TB_TOP.u_top.u_uart_i2c_usb_spi);
	   end
       `endif




/**********************************************************************
    Arduino Digital PinMapping
* Pin Mapping    Arduino              ATMGE CONFIG
*   ATMEGA328     Port                                        caravel Pin Mapping
*   Pin-1         22            PC6/WS[0]/RESET*                digital_io[5]
*   Pin-2         0             PD0/WS[0]/RXD[0]                digital_io[6]
*   Pin-3         1             PD1/WS[0]/TXD[0]                digital_io[7]
*   Pin-4         2             PD2/WS[0]/RXD[1]/INT0           digital_io[8]
*   Pin-5         3             PD3/WS[1]INT1/OC2B(PWM0)        digital_io[9]
*   Pin-6         4             PD4/WS[1]TXD[1]                 digital_io[10]
*   Pin-7                       VCC                  -
*   Pin-8                       GND                  -
*   Pin-9         20            PB6/WS[1]/XTAL1/TOSC1           digital_io[11]
*   Pin-10        21            PB7/WS[1]/XTAL2/TOSC2           digital_io[12]
*   Pin-11        5             PD5/WS[2]/SS[3]/OC0B(PWM1)/T1   digital_io[13]
*   Pin-12        6             PD6/WS[2]/SS[2]/OC0A(PWM2)/AIN0 digital_io[14]/analog_io[2]
*   Pin-13        7             PD7/WS[2]/A1N1                  digital_io[15]/analog_io[3]
*   Pin-14        8             PB0/WS[2]/CLKO/ICP1             digital_io[16]
*   Pin-15        9             PB1/WS[3]/SS[1]OC1A(PWM3)       digital_io[17]
*   Pin-16        10            PB2/WS[3]/SS[0]/OC1B(PWM4)      digital_io[18]
*   Pin-17        11            PB3/WS[3]/MOSI/OC2A(PWM5)       digital_io[19]
*   Pin-18        12            PB4/WS[3]/MISO                  digital_io[20]
*   Pin-19        13            PB5/SCK                         digital_io[21]
*   Pin-20                      AVCC                -
*   Pin-21                      AREF                            analog_io[10]
*   Pin-22                      GND                 -
*   Pin-23        14            PC0/ADC0                        digital_io[22]/analog_io[11]
*   Pin-24        15            PC1/ADC1                        digital_io[23]/analog_io[12]
*   Pin-25        16            PC2/ADC2                        digital_io[24]/analog_io[13]
*   Pin-26        17            PC3/ADC3                        digital_io[25]/analog_io[14]
*   Pin-27        18            PC4/ADC4/SDA                    digital_io[26]/analog_io[15]
*   Pin-28        19            PC5/ADC5/SCL                    digital_io[27]/analog_io[16]
*****************************************************************************/


	initial begin

        ws281x_enb              = 0;

		$value$plusargs("risc_core_id=%d", d_risc_id);

		#200; // Wait for reset removal
	    repeat (10) @(posedge clock);
		$display("Monitor: Standalone User Risc Boot Test Started");

		// Remove Wb Reset
		wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,'h1);

	    repeat (2) @(posedge clock);
		#1;
        // Remove all the reset
        if(d_risc_id == 0) begin
             $display("STATUS: Working with Risc core 0");
             wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG0,'h11F);
        end else if(d_risc_id == 1) begin
             $display("STATUS: Working with Risc core 1");
             wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG0,'h21F);
        end else if(d_risc_id == 2) begin
             $display("STATUS: Working with Risc core 2");
             wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG0,'h41F);
        end else if(d_risc_id == 3) begin
             $display("STATUS: Working with Risc core 3");
             wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG0,'h81F);
        end

        repeat (100) @(posedge clock);  // wait for Processor Get Ready


        repeat (40000) @(posedge clock);  // wait for Processor Get Ready
        ws281x_enb = 1;
	    flag  = 0;
		check_sum = 0;
        compare_start = 1;
        
        fork
           begin
              wait(u_ws281x_port0.rx_wcnt == 16);
              wait(u_ws281x_port1.rx_wcnt == 16);
              wait(u_ws281x_port2.rx_wcnt == 16);
              wait(u_ws281x_port3.rx_wcnt == 16);
           end
           begin
              repeat (300000) @(posedge clock);  // wait for Processor Get Ready
           end
           join_any
        
           #1000
        
           test_fail = 0;
           rx_wcnt = u_ws281x_port0.rx_wcnt + u_ws281x_port1.rx_wcnt + u_ws281x_port2.rx_wcnt + u_ws281x_port3.rx_wcnt;
           check_sum = u_ws281x_port0.check_sum + u_ws281x_port1.check_sum + u_ws281x_port2.check_sum + u_ws281x_port3.check_sum;

		   $display("Total Rx Cnt: %d Check Sum : %x ",rx_wcnt, check_sum);
           // Check 
           // if all the 102 byte received
           // if no error 
           if(rx_wcnt != 64) test_fail = 1;
           if(check_sum != 32'h2ffe8) test_fail = 1;

	   
	    	$display("###################################################");
          	if(test_fail == 0) begin
		   `ifdef GL
	    	       $display("Monitor: Standalone String (GL) Passed");
		   `else
		       $display("Monitor: Standalone String (RTL) Passed");
		   `endif
	        end else begin
		    `ifdef GL
	    	        $display("Monitor: Standalone String (GL) Failed");
		    `else
		        $display("Monitor: Standalone String (RTL) Failed");
		    `endif
		 end
	    	$display("###################################################");
	    $finish;
	end

	initial begin
		wb_rst_i <= 1'b1;
		#100;
		wb_rst_i <= 1'b0;	    	// Release reset
	end
wire USER_VDD1V8 = 1'b1;
wire VSS = 1'b0;

user_project_wrapper u_top(
`ifdef USE_POWER_PINS
    .vccd1(USER_VDD1V8),	// User area 1 1.8V supply
    .vssd1(VSS),	// User area 1 digital ground
`endif
    .wb_clk_i        (clock),  // System clock
    .user_clock2     (1'b1),  // Real-time clock
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
    .io_in          (io_in)  ,
    .io_out         (io_out) ,
    .io_oeb         (io_oeb) ,

    .user_irq       () 

);
// SSPI Slave I/F
assign io_in[0]  = 1'b1; // RESET
//assign io_in[16] = 1'b0 ; // SPIS SCK 

`ifndef GL // Drive Power for Hold Fix Buf
    // All standard cell need power hook-up for functionality work
    initial begin

    end
`endif    

//------------------------------------------------------
//  Integrate the Serial flash with qurd support to
//  user core using the gpio pads
//  ----------------------------------------------------

   wire flash_clk = io_out[28];
   wire flash_csb = io_out[29];
   // Creating Pad Delay
   wire #1 io_oeb_29 = io_oeb[33];
   wire #1 io_oeb_30 = io_oeb[34];
   wire #1 io_oeb_31 = io_oeb[35];
   wire #1 io_oeb_32 = io_oeb[36];
   tri  #1 flash_io0 = (io_oeb_29== 1'b0) ? io_out[33] : 1'bz;
   tri  #1 flash_io1 = (io_oeb_30== 1'b0) ? io_out[34] : 1'bz;
   tri  #1 flash_io2 = (io_oeb_31== 1'b0) ? io_out[35] : 1'bz;
   tri  #1 flash_io3 = (io_oeb_32== 1'b0) ? io_out[36] : 1'bz;

   assign io_in[33] = flash_io0;
   assign io_in[34] = flash_io1;
   assign io_in[35] = flash_io2;
   assign io_in[36] = flash_io3;

   // Quard flash
     s25fl256s #(.mem_file_name(`TB_HEX),
	         .otp_file_name("none"),
                 .TimingModel("S25FL512SAGMFI010_F_30pF")) 
		 u_spi_flash_256mb (
           // Data Inputs/Outputs
       .SI      (flash_io0),
       .SO      (flash_io1),
       // Controls
       .SCK     (flash_clk),
       .CSNeg   (flash_csb),
       .WPNeg   (flash_io2),
       .HOLDNeg (flash_io3),
       .RSTNeg  (!wb_rst_i)

       );

   wire spiram_csb = io_out[31];

   is62wvs1288 #(.mem_file_name("none"))
	u_sram (
         // Data Inputs/Outputs
           .io0     (flash_io0),
           .io1     (flash_io1),
           // Controls
           .clk    (flash_clk),
           .csb    (spiram_csb),
           .io2    (flash_io2),
           .io3    (flash_io3)
    );

//-----------------------------------------------
// WS281X BFM integration
//----------------------------------------------
assign ws281x_port[0] = io_out[8];

bfm_ws281x #(
              .PORT_ID(0),
              .MODE(WS2811_HS)) u_ws281x_port0(
                  .reset_n   (!wb_rst_i     ),
                  .clk       (clock         ),
                  .enb       (ws281x_enb    ),
                  .rxd       (ws281x_port[0])
               );

//-----------------------------------------------
// WS281X BFM integration
//----------------------------------------------
assign ws281x_port[1] = io_out[9];

bfm_ws281x #(
              .PORT_ID(1),
              .MODE(WS2811_HS)) u_ws281x_port1(
                  .reset_n   (!wb_rst_i     ),
                  .clk       (clock         ),
                  .enb       (ws281x_enb    ),
                  .rxd       (ws281x_port[1])
               );

//-----------------------------------------------
// WS281X BFM integration
//----------------------------------------------
assign ws281x_port[2] = io_out[13];

bfm_ws281x #(
              .PORT_ID(2),
              .MODE(WS2811_HS)) u_ws281x_port2(
                  .reset_n   (!wb_rst_i     ),
                  .clk       (clock         ),
                  .enb       (ws281x_enb    ),
                  .rxd       (ws281x_port[2])
               );

//-----------------------------------------------
// WS281X BFM integration
//----------------------------------------------
assign ws281x_port[3] = io_out[17];

bfm_ws281x #(
              .PORT_ID(3),
              .MODE(WS2811_HS)) u_ws281x_port3(
                  .reset_n   (!wb_rst_i     ),
                  .clk       (clock         ),
                  .enb       (ws281x_enb    ),
                  .rxd       (ws281x_port[3])
               );
//----------------------------
// All the task are defined here
//----------------------------



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
endmodule
`include "s25fl256s.sv"
`default_nettype wire
