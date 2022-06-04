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
////   i2c Master .                                               ////
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

`timescale 1 ns / 1 ns

`include "sram_macros/sky130_sram_2kbyte_1rw1r_32x512_8.v"
`include "i2c_slave_model.v"

module tb_top;

reg            clock         ;
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
reg [31:0]     read_data     ;
//----------------------------------
// Uart Configuration
// ---------------------------------

integer i,j;

	// External clock is used by default.  Make this artificially fast for the
	// simulation.  Normally this would be a slow clock and the digital PLL
	// would be the fast clock.

	always #12.5 clock <= (clock === 1'b0);

	initial begin
		clock = 0;
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
	   	$dumpvars(0, tb_top);
	   end
       `endif

	initial begin
		wb_rst_i <= 1'b1;
		#100;
		wb_rst_i <= 1'b0;	    	// Release reset
	end
initial
begin
   test_fail = 0;

   #200; // Wait for reset removal
   repeat (10) @(posedge clock);
   $display("############################################");
   $display("   Testing I2CM Read/Write Access           ");
   $display("############################################");
   

   repeat (10) @(posedge clock);
   #1;
   // Enable I2M Block & WB Reset and Enable I2CM Mux Select
   wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,'h01);

   // Enable I2C Multi Functional Ports
   wb_user_core_write(`ADDR_SPACE_PINMUX+`PINMUX_GPIO_MULTI_FUNC,'h4000);

   // Remove i2m reset
   wb_user_core_write(`ADDR_SPACE_PINMUX+`PINMUX_GBL_CFG0,'h010);

   repeat (100) @(posedge clock);  

    @(posedge  clock);
    $display("---------- Initialize I2C Master ----------"); 

    //Wrire Prescale registers
     wb_user_core_write(`ADDR_SPACE_I2CM+(8'h0<<2),8'hC7);  
     wb_user_core_write(`ADDR_SPACE_I2CM+(8'h1<<2),8'h00);  
    // Core Enable
     wb_user_core_write(`ADDR_SPACE_I2CM+(8'h2<<2),8'h80);  
    
    // Writing Data

    $display("---------- Writing Data ----------"); 
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h3<<2),8'h20); // Slave Addr + WR  
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4<<2),8'h90);  
    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4<<2),read_data);  
     
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h3<<2),8'h66);  
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4<<2),8'h10);  

    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4<<2),read_data);  
   
   /* Byte1: 12 */ 
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h3<<2),8'h12);  
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4<<2),8'h10); // No Stop + Write  

    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4<<2),read_data);  
   
   /* Byte1: 34 */ 
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h3<<2),8'h34);  
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4<<2),8'h10); // No Stop + Write 

    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4<<2),read_data);  

   /* Byte1: 56 */ 
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h3<<2),8'h56);  
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4<<2),8'h10); // No Stop + Write 

    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4<<2),read_data);  

   /* Byte1: 78 */ 
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h3<<2),8'h78);  
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4<<2),8'h50); // Stop + Write 

    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4<<2),read_data);  

    //Reading Data
    
    //Wrire Address
    $display("---------- Writing Data ----------"); 
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h3<<2),8'h20);  
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4<<2),8'h90);  
    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4<<2),read_data);  
     
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h3<<2),8'h66);  
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4<<2),8'h50);  

    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4<<2),read_data);  

    //Generate Read
    $display("---------- Writing Data ----------"); 
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h3<<2),8'h21); // Slave Addr + RD  
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4<<2),8'h90);  
    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4<<2),read_data);  

    /* BYTE-1 : 0x12  */ 
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4<<2),8'h20);  // RD + ACK

    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4<<2),read_data);  

    //Compare received data
    wb_user_core_read_cmp(`ADDR_SPACE_I2CM+(8'h3<<2),8'h12);  
     
    /* BYTE-2 : 0x34  */ 
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4<<2),8'h20);  // RD + ACK

    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4<<2),read_data);  

    //Compare received data
    wb_user_core_read_cmp(`ADDR_SPACE_I2CM+(8'h3<<2),8'h34);  

    /* BYTE-3 : 0x56  */ 
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4 <<2),8'h20);  // RD + ACK

    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4<<2),read_data);  

    //Compare received data
    wb_user_core_read_cmp(`ADDR_SPACE_I2CM+(8'h3<<2),8'h56);  

    /* BYTE-4 : 0x78  */ 
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4<<2),8'h68);  // STOP + RD + NACK 

    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4 <<2),read_data);  

    //Compare received data
    wb_user_core_read_cmp(`ADDR_SPACE_I2CM+(8'h3 <<2),8'h78);  

    repeat(100)@(posedge clock);



     $display("###################################################");
     if(test_fail == 0) begin
        `ifdef GL
            $display("Monitor: Standalone User I2M Test (GL) Passed");
        `else
            $display("Monitor: Standalone User I2M Test (RTL) Passed");
        `endif
     end else begin
         `ifdef GL
             $display("Monitor: Standalone User I2M Test (GL) Failed");
         `else
             $display("Monitor: Standalone User I2M Test (RTL) Failed");
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

`ifndef GL // Drive Power for Hold Fix Buf
    // All standard cell need power hook-up for functionality work
    initial begin

    end
`endif    

//---------------------------
// I2C
// --------------------------
tri scl,sda;

assign sda  =  (io_oeb[22] == 1'b0) ? io_out[22] : 1'bz;
assign scl   = (io_oeb[23] == 1'b0) ? io_out[23]: 1'bz;
assign io_in[22]  =  sda;
assign io_in[23]  =  scl;

pullup p1(scl); // pullup scl line
pullup p2(sda); // pullup sda line

 
i2c_slave_model u_i2c_slave (
	.scl   (scl), 
	.sda   (sda)
       );


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
  //$display("DEBUG WB USER ACCESS READ Address : %x, Data : %x",address,data);
  repeat (2) @(posedge clock);
end
endtask

task  wb_user_core_read_cmp;
input [31:0] address;
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
`default_nettype wire
