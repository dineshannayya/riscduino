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
`include "is62wvs1288.v"

`define TB_HEX "arduino_switchCase2.hex"
`define TB_TOP  arduino_switchCase2_tb
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
	reg            flag                 ;

	reg [31:0]     check_sum            ;
        

         integer i,j;

parameter P_FSM_C      = 4'b0000; // Command Phase Only
parameter P_FSM_CW     = 4'b0001; // Command + Write DATA Phase Only
parameter P_FSM_CA     = 4'b0010; // Command -> Address Phase Only

parameter P_FSM_CAR    = 4'b0011; // Command -> Address -> Read Data
parameter P_FSM_CADR   = 4'b0100; // Command -> Address -> Dummy -> Read Data
parameter P_FSM_CAMR   = 4'b0101; // Command -> Address -> Mode -> Read Data
parameter P_FSM_CAMDR  = 4'b0110; // Command -> Address -> Mode -> Dummy -> Read Data

parameter P_FSM_CAW    = 4'b0111; // Command -> Address ->Write Data
parameter P_FSM_CADW   = 4'b1000; // Command -> Address -> DUMMY + Write Data
parameter P_FSM_CAMW   = 4'b1001; // Command -> Address -> MODE + Write Data

parameter P_FSM_CDR    = 4'b1010; // COMMAND -> DUMMY -> READ
parameter P_FSM_CDW    = 4'b1011; // COMMAND -> DUMMY -> WRITE
parameter P_FSM_CR     = 4'b1100;  // COMMAND -> READ

parameter P_MODE_SWITCH_IDLE     = 2'b00;
parameter P_MODE_SWITCH_AT_ADDR  = 2'b01;
parameter P_MODE_SWITCH_AT_DATA  = 2'b10;

parameter P_SINGLE = 2'b00;
parameter P_DOUBLE = 2'b01;
parameter P_QUAD   = 2'b10;
parameter P_QDDR   = 2'b11;




	initial begin
	        flag  = 0;
	end

	`ifdef WFDUMP
	   initial begin
	   	$dumpfile("simx.vcd");
	   	$dumpvars(3, `TB_TOP);
	   	$dumpvars(0, `TB_TOP.u_top.u_riscv_top.i_core_top_0);
	   	$dumpvars(0, `TB_TOP.u_top.u_riscv_top.u_connect);
	   	$dumpvars(0, `TB_TOP.u_top.u_riscv_top.u_intf);
	   	$dumpvars(0, `TB_TOP.u_top.u_uart_i2c_usb_spi.u_uart0_core);
	   end
       `endif

     /************* Port-D Mapping **********************************
      *             Arduino-No
      *   Pin-2        0         PD0/RXD[0]                digital_io[6]
      *   Pin-3        1         PD1/TXD[0]                digital_io[7]
      *   Pin-4        2         PD2/RXD[1]/INT0           digital_io[8]
      *   Pin-5        3         PD3/INT1/OC2B(PWM0)       digital_io[9]
      *   Pin-6        4         PD4/TXD[1]                digital_io[10]
      *   Pin-11       5         PD5/SS[3]/OC0B(PWM1)/T1   digital_io[13]
      *   Pin-12       6         PD6/SS[2]/OC0A(PWM2)/AIN0 digital_io[14]/analog_io[2]
      *   Pin-13       7         PD7/A1N1                  digital_io[15]/analog_io[3]
      *   ********************************************************/

     wire [7:0]  port_d_in = {  io_out[15],
		                        io_out[14],
		                        io_out[13],
		                        io_out[10],
			                    io_out[9],
			                    io_out[8],
		                        io_out[7],
		                        io_out[6]
			                };
	initial begin
               uart_data_bit           = 2'b11;
               uart_stop_bits          = 0; // 0: 1 stop bit; 1: 2 stop bit;
               uart_stick_parity       = 0; // 1: force even parity
               uart_parity_en          = 0; // parity enable
               uart_even_odd_parity    = 1; // 0: odd parity; 1: even parity
	       tb_set_uart_baud(50000000,1152000,uart_divisor);// 50Mhz Ref clock, Baud Rate: 230400
               uart_timeout            = 2000;// wait time limit
               uart_fifo_enable        = 0;	// fifo mode disable

		$value$plusargs("risc_core_id=%d", d_risc_id);
        init();

		#200; // Wait for reset removal
	        repeat (10) @(posedge clock);
		$display("Monitor: Standalone User Risc Boot Test Started");

		// Remove Wb Reset
		//wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,'h1);

	    repeat (2) @(posedge clock);
		#1;
        // Remove WB and SPI Reset, Keep SDARM and CORE under Reset
        //wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG0,'h01F);

		//// QSPI SRAM:CS#2 Switch to QSPI Mode
        ////wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 1000
		//wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0000,P_MODE_SWITCH_IDLE,P_SINGLE,P_SINGLE,4'b0100});
		//wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'h0,2'b00,2'b00,P_FSM_C,8'h00,8'h38});
		//wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h0);

        // Remove all the reset
        if(d_risc_id == 0) begin
           $display("STATUS: Working with Risc core 0");
           //wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG0,'h11F);
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

        wait_riscv_boot();

        repeat (100) @(posedge clock);  // wait for Processor Get Ready

	    tb_uart.debug_mode = 0; // disable debug display
        tb_uart.uart_init;
        tb_uart.control_setup (uart_data_bit, uart_stop_bits, uart_parity_en, uart_even_odd_parity, 
                               uart_stick_parity, uart_timeout, uart_divisor);

        repeat (10000) @(posedge clock);  // wait for Processor Get Ready
	    flag  = 1;
		check_sum = 0;
        fork
        begin 
            fork
            begin
               tb_uart.write_char ("a");
               tb_uart.write_char ("b");
               tb_uart.write_char ("c");
               tb_uart.write_char ("d");
               tb_uart.write_char ("e");
            end
            begin
               wait(port_d_in[2] == 1'b1);
               $display("PORT-D Pin-2 High Detected");
               wait(port_d_in[3] == 1'b1);
               $display("PORT-D Pin-3 High Detected");
               wait(port_d_in[4] == 1'b1);
               $display("PORT-D Pin-4 High Detected");
               wait(port_d_in[5] == 1'b1);
               $display("PORT-D Pin-5 High Detected");
               wait(port_d_in[6] == 1'b1);
               $display("PORT-D Pin-6 High Detected");
               test_fail =0;
            end
            join
        end
        begin
           repeat (3000000) @(posedge clock);  // wait for Processor Get Ready
           test_fail =1;
        end
        join_any
        
           #100
           tb_uart.report_status(uart_rx_nu, uart_tx_nu);
        

	   
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
	    $finish;
	end


// SSPI Slave I/F
assign io_in[5]  = 1'b1; // RESET
assign io_in[21] = 1'b0 ; // SPIS SCK 


//------------------------------------------------------
//  Integrate the Serial flash with qurd support to
//  user core using the gpio pads
//  ----------------------------------------------------

   wire flash_clk = (io_oeb[28] == 1'b0) ? io_out[28]: 1'b0;
   wire flash_csb = (io_oeb[29] == 1'b0) ? io_out[29]: 1'b0;
   // Creating Pad Delay
   wire #1 io_oeb_33 = io_oeb[33];
   wire #1 io_oeb_34 = io_oeb[34];
   wire #1 io_oeb_35 = io_oeb[35];
   wire #1 io_oeb_36 = io_oeb[36];
   tri  #1 flash_io0 = (io_oeb_33== 1'b0) ? io_out[33] : 1'bz;
   tri  #1 flash_io1 = (io_oeb_34== 1'b0) ? io_out[34] : 1'bz;
   tri  #1 flash_io2 = (io_oeb_35== 1'b0) ? io_out[35] : 1'bz;
   tri  #1 flash_io3 = (io_oeb_36== 1'b0) ? io_out[36] : 1'bz;

   assign io_in[33] = (io_oeb[33] == 1'b1) ? flash_io0: 1'b0;
   assign io_in[34] = (io_oeb[34] == 1'b1) ? flash_io1: 1'b0;
   assign io_in[35] = (io_oeb[35] == 1'b1) ? flash_io2: 1'b0;
   assign io_in[36] = (io_oeb[36] == 1'b1) ? flash_io3: 1'b0;

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

   wire spiram_csb = (io_oeb[31] == 1'b0) ? io_out[31] : 1'b0;

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
//---------------------------
//  UART Agent integration
// --------------------------
wire uart_txd,uart_rxd;

assign uart_txd   = (io_oeb[7] == 1'b0) ? io_out[7] : 1'b0;
assign io_in[6]   = (io_oeb[6] == 1'b1) ? uart_rxd  : 1'b0 ;
 
uart_agent tb_uart(
	.mclk                (clock              ),
	.txd                 (uart_rxd           ),
	.rxd                 (uart_txd           )
	);

endmodule
`include "s25fl256s.sv"
`default_nettype wire
