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
////  User Risc Core Boot Validation                              ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  https://github.com/dineshannayya/yifive_r0.git              ////
////  http://www.opencores.org/cores/yifive/                      ////
////                                                              ////
////  Description                                                 ////
////     1. User Risc core is booted using  compiled code of      ////
////        user_risc_boot.hex                                    ////
////     2. User Risc core uses Serial Flash and SDRAM to boot    ////
////     3. After successful boot, Risc core will  write signature////
////        in to  user register from 0x3000_0018 to 0x3000_002C  ////
////     4. Through the External Wishbone Interface we read back  ////
////         and validate the user register to declared pass fail ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 12th June 2021, Dinesh A                            ////
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

`default_nettype none

`timescale 1 ns / 1 ps

`define FULL_CHIP_SIM

`include "s25fl256s.sv"
`include "uprj_netlists.v"
`include "caravel_netlists.v"
`include "spiflash.v"
`include "mt48lc8m8a2.v"
`include "uart_agent.v"

module risc_boot_tb;
	reg clock;
	reg RSTB;
	reg CSB;
	reg power1, power2;
	reg power3, power4;

	wire gpio;
	wire [37:0] mprj_io;
	wire [7:0] mprj_io_0;
	wire [15:0] checkbits;

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
	reg            test_fail            ;
        
        integer i,j;
	//---------------------------------
	
	assign checkbits = mprj_io[31:16];

	assign mprj_io[3] = (CSB == 1'b1) ? 1'b1 : 1'bz;

	// External clock is used by default.  Make this artificially fast for the
	// simulation.  Normally this would be a slow clock and the digital PLL
	// would be the fast clock.

	always #12.5 clock <= (clock === 1'b0);

	initial begin
		clock = 0;
	end

	`ifdef WFDUMP
        initial
        begin
           $dumpfile("simx.vcd");
           $dumpvars(1,risc_boot_tb);
           $dumpvars(1,risc_boot_tb.u_spi_flash_256mb);
           //$dumpvars(2,risc_boot_tb.uut);
           $dumpvars(4,risc_boot_tb.uut.mprj);
           $dumpvars(0,risc_boot_tb.tb_uart);
           //$dumpvars(0,risc_boot_tb.u_user_spiflash);
	   $display("Waveform Dump started");
        end
        `endif


        initial
        begin
           uart_data_bit           = 2'b11;
           uart_stop_bits          = 0; // 0: 1 stop bit; 1: 2 stop bit;
           uart_stick_parity       = 0; // 1: force even parity
           uart_parity_en          = 0; // parity enable
           uart_even_odd_parity    = 1; // 0: odd parity; 1: even parity
           uart_divisor            = 15;// divided by n * 16
           uart_timeout            = 500;// wait time limit
           uart_fifo_enable        = 0;	// fifo mode disable
        
           #200; // Wait for reset removal

           fork
	   begin
          
	      // Wait for Managment core to boot up 
	      wait(checkbits == 16'h AB60);
	      $display("Monitor: Test User Risc Boot Started");
       
	      // Wait for user risc core to boot up 
              repeat (30000) @(posedge clock);  
              tb_uart.uart_init;
              tb_uart.control_setup (uart_data_bit, uart_stop_bits, uart_parity_en, uart_even_odd_parity, 
                                             uart_stick_parity, uart_timeout, uart_divisor);
              
              for (i=0; i<40; i=i+1)
              	uart_write_data[i] = $random;
              
              
              
              fork
                 begin
                    for (i=0; i<40; i=i+1)
                    begin
                      $display ("\n... UART Agent Writing char %x ...", uart_write_data[i]);
                       tb_uart.write_char (uart_write_data[i]);
                    end
                 end
              
                 begin
                    for (j=0; j<40; j=j+1)
                    begin
                      tb_uart.read_char_chk(uart_write_data[j]);
                    end
                 end
                 join
              
                 #100
                 tb_uart.report_status(uart_rx_nu, uart_tx_nu);
              
                 test_fail = 0;
        
                 // Check 
                 // if all the 40 byte transmitted
                 // if all the 40 byte received
                 // if no error 
                 if(uart_tx_nu != 40) test_fail = 1;
                 if(uart_rx_nu != 40) test_fail = 1;
                 if(tb_uart.err_cnt != 0) test_fail = 1;
        
	      end
	      begin
                   // Loop for TimeOut
                   repeat (60000) @(posedge clock);
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


	initial begin
		RSTB <= 1'b0;
		CSB  <= 1'b1;		// Force CSB high
		#2000;
		RSTB <= 1'b1;	    	// Release reset
		#170000;
		CSB = 1'b0;		// CSB can be released
	end

	initial begin		// Power-up sequence
		power1 <= 1'b0;
		power2 <= 1'b0;
		power3 <= 1'b0;
		power4 <= 1'b0;
		#100;
		power1 <= 1'b1;
		#100;
		power2 <= 1'b1;
		#100;
		power3 <= 1'b1;
		#100;
		power4 <= 1'b1;
	end

	//always @(mprj_io) begin
	//	#1 $display("MPRJ-IO state = %b ", mprj_io[7:0]);
	//end

	wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;

	wire VDD3V3 = power1;
	wire VDD1V8 = power2;
	wire USER_VDD3V3 = power3;
	wire USER_VDD1V8 = power4;
	wire VSS = 1'b0;

	caravel uut (
		.vddio	  (VDD3V3),
		.vssio	  (VSS),
		.vdda	  (VDD3V3),
		.vssa	  (VSS),
		.vccd	  (VDD1V8),
		.vssd	  (VSS),
		.vdda1    (USER_VDD3V3),
		.vdda2    (USER_VDD3V3),
		.vssa1	  (VSS),
		.vssa2	  (VSS),
		.vccd1	  (USER_VDD1V8),
		.vccd2	  (USER_VDD1V8),
		.vssd1	  (VSS),
		.vssd2	  (VSS),
		.clock	  (clock),
		.gpio     (gpio),
        .mprj_io  (mprj_io),
		.flash_csb(flash_csb),
		.flash_clk(flash_clk),
		.flash_io0(flash_io0),
		.flash_io1(flash_io1),
		.resetb	  (RSTB)
	);

	spiflash #(
		.FILENAME("risc_boot.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),			// not used
		.io3()			// not used
	);

//-----------------------------------------
// Connect Quad Flash to for usr Risc Core
//-----------------------------------------

   wire user_flash_clk = mprj_io[24];
   wire user_flash_csb = mprj_io[25];
   //tri  user_flash_io0 = mprj_io[26];
   //tri  user_flash_io1 = mprj_io[27];
   //tri  user_flash_io2 = mprj_io[28];
   //tri  user_flash_io3 = mprj_io[29];


   // Quard flash
     s25fl256s #(.mem_file_name("user_uart.hex"),
	         .otp_file_name("none"), 
                 .TimingModel("S25FL512SAGMFI010_F_30pF")) 
		 u_spi_flash_256mb (
           // Data Inputs/Outputs
       .SI      (mprj_io[29]),
       .SO      (mprj_io[30]),
       // Controls
       .SCK     (user_flash_clk),
       .CSNeg   (user_flash_csb),
       .WPNeg   (mprj_io[31]),
       .HOLDNeg (mprj_io[32]),
       .RSTNeg  (RSTB)

       );

//---------------------------
//  UART Agent integration
// --------------------------
wire uart_txd,uart_rxd;

assign uart_txd   = mprj_io[2];
assign mprj_io[1]  = uart_rxd ;
 
uart_agent tb_uart(
	.mclk                (clock              ),
	.txd                 (uart_rxd           ),
	.rxd                 (uart_txd           )
	);


`ifndef GL // Drive Power for Hold Fix Buf
    // All standard cell need power hook-up for functionality work
initial begin
end
`endif    


/**
//-----------------------------------------------------------------------------
// RISC IMEM amd DMEM Monitoring TASK
//-----------------------------------------------------------------------------
logic [`SCR1_DMEM_AWIDTH-1:0]           core2imem_addr_o_r;           // DMEM address
logic [`SCR1_DMEM_AWIDTH-1:0]           core2dmem_addr_o_r;           // DMEM address
logic                                   core2dmem_cmd_o_r;

`define RISC_CORE  test_tb.uut.mprj.u_core.u_riscv_top.i_core_top

always@(posedge `RISC_CORE.clk) begin
    if(`RISC_CORE.imem2core_req_ack_i && `RISC_CORE.core2imem_req_o)
          core2imem_addr_o_r <= `RISC_CORE.core2imem_addr_o;

    if(`RISC_CORE.dmem2core_req_ack_i && `RISC_CORE.core2dmem_req_o) begin
          core2dmem_addr_o_r <= `RISC_CORE.core2dmem_addr_o;
          core2dmem_cmd_o_r  <= `RISC_CORE.core2dmem_cmd_o;
    end

    if(`RISC_CORE.imem2core_resp_i !=0)
          $display("RISCV-DEBUG => IMEM ADDRESS: %x Read Data : %x Resonse: %x", core2imem_addr_o_r,`RISC_CORE.imem2core_rdata_i,`RISC_CORE.imem2core_resp_i);
    if((`RISC_CORE.dmem2core_resp_i !=0) && core2dmem_cmd_o_r)
          $display("RISCV-DEBUG => DMEM ADDRESS: %x Write Data: %x Resonse: %x", core2dmem_addr_o_r,`RISC_CORE.core2dmem_wdata_o,`RISC_CORE.dmem2core_resp_i);
    if((`RISC_CORE.dmem2core_resp_i !=0) && !core2dmem_cmd_o_r)
          $display("RISCV-DEBUG => DMEM ADDRESS: %x READ Data : %x Resonse: %x", core2dmem_addr_o_r,`RISC_CORE.dmem2core_rdata_i,`RISC_CORE.dmem2core_resp_i);
end
*/
endmodule
`default_nettype wire
