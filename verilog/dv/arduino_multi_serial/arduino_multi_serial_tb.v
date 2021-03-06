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
////  http://www.opencores.org/cores/yifive/                      ////
////                                                              ////
////  Description                                                 ////
////   This is a standalone test bench to validate the            ////
////   Digital core.                                              ////
////   1. User Risc core is booted using  compiled code of        ////
////      user_risc_boot.c                                        ////
////   2. User Risc core uses Serial Flash and SDRAM to boot      ////
////   3. After successful boot, Risc core will  write signature  ////
////      in to  user register from 0x1003_0058 to 0x1003_006C    ////
////   4. Through the External Wishbone Interface we read back    ////
////       from 0x3003_0058 to 0x3003_006C                        ////
////       and validate the user register to declared pass fail   ////
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
`include "uart_agent.v"

module arduino_multi_serial_tb;
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
        reg [7:0]      uart0_write_data [0:39];
        reg [7:0]      uart1_write_data [0:39];
        reg 	       uart_fifo_enable     ;	// fifo mode disable
	reg            flag                 ;

	reg [31:0]     check_sum            ;
        
	integer    d_risc_id;

         integer i,j,k,l;




	// 50Mhz CLock
	always #10 clock <= (clock === 1'b0);

	initial begin
		clock = 0;
	        flag  = 0;
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
	   	$dumpvars(3, arduino_multi_serial_tb);
	   	//$dumpvars(0, arduino_multi_serial_tb.u_top.u_riscv_top.i_core_top_0);
	   	//$dumpvars(0, arduino_multi_serial_tb.u_top.u_riscv_top.u_connect);
	   	//$dumpvars(0, arduino_multi_serial_tb.u_top.u_riscv_top.u_intf);
	   	$dumpvars(0, arduino_multi_serial_tb.u_top.u_uart_i2c_usb_spi.u_uart0_core);
	   	$dumpvars(0, arduino_multi_serial_tb.u_top.u_uart_i2c_usb_spi.u_uart1_core);
	   end
       `endif

       /*************************************************************************
       * This is Baud Rate to clock divider conversion for Test Bench
       * Note: DUT uses 16x baud clock, where are test bench uses directly
       * baud clock, Due to 16x Baud clock requirement at RTL, there will be
       * some resolution loss, we expect at lower baud rate this resolution
       * loss will be less. For Quick simulation perpose higher baud rate used
       * *************************************************************************/
       task tb_set_uart_baud;
       input [31:0] ref_clk;
       input [31:0] baud_rate;
       output [31:0] baud_div;
       reg   [31:0] baud_div;
       begin
	  // for 230400 Baud = (50Mhz/230400) = 216.7
	  baud_div = ref_clk/baud_rate; // Get the Bit Baud rate
	  // Baud 16x = 216/16 = 13
          baud_div = baud_div/16; // To find the RTL baud 16x div value to find similar resolution loss in test bench
	  // Test bench baud clock , 16x of above value
	  // 13 * 16 = 208,  
	  // (Note if you see original value was 216, now it's 208 )
          baud_div = baud_div * 16;
	  // Test bench half cycle counter to toggle it 
	  // 208/2 = 104
           baud_div = baud_div/2;
	  //As counter run's from 0 , substract from 1
	   baud_div = baud_div-1;
       end
       endtask
       

	initial begin
               uart_data_bit           = 2'b11;
               uart_stop_bits          = 0; // 0: 1 stop bit; 1: 2 stop bit;
               uart_stick_parity       = 0; // 1: force even parity
               uart_parity_en          = 0; // parity enable
               uart_even_odd_parity    = 1; // 0: odd parity; 1: even parity
	       tb_set_uart_baud(50000000,288000,uart_divisor);// 50Mhz Ref clock, Baud Rate: 230400
               uart_timeout            = 2000;// wait time limit
               uart_fifo_enable        = 0;	// fifo mode disable

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
                     wb_user_core_write(`ADDR_SPACE_PINMUX+`PINMUX_GBL_CFG0,'h11F);
                end else if(d_risc_id == 1) begin
                     $display("STATUS: Working with Risc core 1");
                     wb_user_core_write(`ADDR_SPACE_PINMUX+`PINMUX_GBL_CFG0,'h21F);
                end else if(d_risc_id == 2) begin
                     $display("STATUS: Working with Risc core 2");
                     wb_user_core_write(`ADDR_SPACE_PINMUX+`PINMUX_GBL_CFG0,'h41F);
                end else if(d_risc_id == 3) begin
                     $display("STATUS: Working with Risc core 3");
                     wb_user_core_write(`ADDR_SPACE_PINMUX+`PINMUX_GBL_CFG0,'h81F);
                end

                repeat (100) @(posedge clock);  // wait for Processor Get Ready

	        tb_uart0.debug_mode = 1; // enable debug display
                tb_uart0.uart_init;
                tb_uart0.control_setup (uart_data_bit, uart_stop_bits, uart_parity_en, uart_even_odd_parity, 
                                               uart_stick_parity, uart_timeout, uart_divisor);
	        
		tb_uart1.debug_mode = 1; // enable debug display
                tb_uart1.uart_init;
                tb_uart1.control_setup (uart_data_bit, uart_stop_bits, uart_parity_en, uart_even_odd_parity, 
                                               uart_stick_parity, uart_timeout, uart_divisor);

                repeat (60000) @(posedge clock);  // wait for Processor Get Ready
	        flag  = 0;
		check_sum = 0;
                
                for (i=0; i<40; i=i+1)
                    uart0_write_data[i] = $random;
                
	       for (i=0; i<40; i=i+1)
                    uart1_write_data[i] = $random;
                
                fork
		   //Drive UART-0
                   begin
                      for (i=0; i<40; i=i+1)
                      begin
                        $display ("\n... UART-0 Agent Writing char %x ...", uart0_write_data[i]);
                         tb_uart0.write_char (uart0_write_data[i]);
                      end
                   end
                   
		   //Drive UART-1
		   begin
                      for (j=0; j<40; j=j+1)
                      begin
                        $display ("\n... UART-1 Agent Writing char %x ...", uart1_write_data[j]);
                         tb_uart1.write_char (uart1_write_data[j]);
                      end
                   end
		   
		   //Receive UART-0
                   begin
                      for (k=0; k<40; k=k+1)
                      begin
                        tb_uart0.read_char_chk(uart1_write_data[k]);
                      end
                   end
		   
		   //Receive UART-1
                   begin
                      for (l=0; l<40; l=l+1)
                      begin
                        tb_uart1.read_char_chk(uart0_write_data[l]);
                      end
                   end
                   join
                
                   test_fail = 0;
                   #100
                   tb_uart0.report_status(uart_rx_nu, uart_tx_nu);
                   if(uart_tx_nu != 40) test_fail = 1;
                   if(uart_rx_nu != 40) test_fail = 1;

                   tb_uart1.report_status(uart_rx_nu, uart_tx_nu);
                   if(uart_tx_nu != 40) test_fail = 1;
                   if(uart_rx_nu != 40) test_fail = 1;
                
	   
	    	$display("###################################################");
          	if(test_fail == 0) begin
		   `ifdef GL
	    	       $display("Monitor: Standalone Multi Serial (GL) Passed");
		   `else
		       $display("Monitor: Standalone Multi Serial (RTL) Passed");
		   `endif
	        end else begin
		    `ifdef GL
	    	        $display("Monitor: Standalone Multi Serial (GL) Failed");
		    `else
		        $display("Monitor: Standalone Multi Serial (RTL) Failed");
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

`ifndef GL // Drive Power for Hold Fix Buf
    // All standard cell need power hook-up for functionality work
    initial begin

    end
`endif    

//------------------------------------------------------
//  Integrate the Serial flash with qurd support to
//  user core using the gpio pads
//  ----------------------------------------------------

   wire flash_clk = io_out[24];
   wire flash_csb = io_out[25];
   // Creating Pad Delay
   wire #1 io_oeb_29 = io_oeb[29];
   wire #1 io_oeb_30 = io_oeb[30];
   wire #1 io_oeb_31 = io_oeb[31];
   wire #1 io_oeb_32 = io_oeb[32];
   tri  #1 flash_io0 = (io_oeb_29== 1'b0) ? io_out[29] : 1'bz;
   tri  #1 flash_io1 = (io_oeb_30== 1'b0) ? io_out[30] : 1'bz;
   tri  #1 flash_io2 = (io_oeb_31== 1'b0) ? io_out[31] : 1'bz;
   tri  #1 flash_io3 = (io_oeb_32== 1'b0) ? io_out[32] : 1'bz;

   assign io_in[29] = flash_io0;
   assign io_in[30] = flash_io1;
   assign io_in[31] = flash_io2;
   assign io_in[32] = flash_io3;

   // Quard flash
     s25fl256s #(.mem_file_name("arduino_multi_serial.ino.hex"),
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


//---------------------------
//  UART-0 Agent integration
// --------------------------
wire uart0_txd,uart0_rxd;

assign uart0_txd   = io_out[2];
assign io_in[1]  = uart0_rxd ;
 
uart_agent tb_uart0(
	.mclk                (clock              ),
	.txd                 (uart0_rxd          ),
	.rxd                 (uart0_txd          )
	);

//---------------------------
//  UART Agent integration
// --------------------------
wire uart1_txd,uart1_rxd;

assign uart1_txd   = io_out[5];
assign io_in[3]  = uart1_rxd ;
 
uart_agent tb_uart1(
	.mclk                (clock              ),
	.txd                 (uart1_rxd          ),
	.rxd                 (uart1_txd          )
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
