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
////   This test bench to validate Arduino Interrupt              ////
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
`include "user_params.svh"
`include "uart_agent.v"

`define TB_HEX "arduino_gpio_intr.hex"
`define TB_TOP arduino_gpio_intr_tb

module `TB_TOP;

parameter real CLK1_PERIOD  = 20; // 50MHz
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
    reg            compare_start        ; // User Need to make sure that compare start match with RiscV core completing initial booting

	reg [31:0]     check_sum            ;
        

         integer i,j;




	initial begin
	    flag  = 0;
        compare_start = 0;
	end

	`ifdef WFDUMP
	   initial begin
	   	$dumpfile("simx.vcd");
	   	$dumpvars(3, `TB_TOP);
	   	$dumpvars(0, `TB_TOP.u_top.u_riscv_top);
	   	$dumpvars(0, `TB_TOP.u_top.u_pinmux);
	   end
       `endif


	wire [15:0] irq_lines = u_top.u_pinmux.u_glbl_reg.irq_lines;


/**********************************************************************
    Arduino Digital PinMapping
              ATMGA328 Pin No 	Functionality 	      Arduino Pin 	       Carvel Pin Mapping
              Pin-2 	        PD0/RXD[0] 	                0 	           digital_io[6]
              Pin-3 	        PD1/TXD[0] 	                1 	           digital_io[7]
              Pin-4 	        PD2/RXD[1]/INT0 	        2 	           digital_io[8]
              Pin-5 	        PD3/INT1/OC2B(PWM0)         3 	           digital_io[9] 
              Pin-6 	        PD4/TXD[1] 	                4 	           digital_io[10] 
              Pin-11 	        PD5/SS[3]/OC0B(PWM1)/T1 	5 	           digital_io[13]
              Pin-12 	        PD6/SS[2]/OC0A(PWM2)/AIN0 	6 	           digital_io[14]/analog_io[2]
              Pin-13 	        PD7/A1N1 	                7 	           digital_io[15]/analog_io[3]
              Pin-14 	        PB0/CLKO/ICP1 	            8 	           digital_io[11]
              Pin-15 	        PB1/SS[1]OC1A(PWM3) 	    9 	           digital_io[12]
              Pin-16 	        PB2/SS[0]/OC1B(PWM4) 	    10 	           digital_io[13]
              Pin-17 	        PB3/MOSI/OC2A(PWM5) 	    11 	           digital_io[14]
              Pin-18 	        PB4/MISO 	                12 	           digital_io[15]
              Pin-19 	        PB5/SCK 	                13 	           digital_io[16] 

              Pin-23 	        ADC0 	                    14 	           digital_io[22] 
              Pin-24 	        ADC1 	                    15 	           digital_io[23] 
              Pin-25 	        ADC2 	                    16 	           digital_io[24] 
              Pin-26 	        ADC3 	                    17 	           digital_io[25] 
              Pin-27 	        SDA 	                    18 	           digital_io[26] 
              Pin-28 	        SCL 	                    19 	           digital_io[27] 

              Pin-9             XTAL1                       20             digital_io[11]
              Pin-10            XTAL2                       21             digital_io[12]
              Pin-1             RESET                       22             digital_io[5] 
*****************************************************************************/

// Exclude UART TXD/RXD and RESET
reg [21:2] arduino_din;
assign  {  
           //io_in[0], - Exclude RESET
           io_in[12] ,
           io_in[11] ,
           io_in[27] ,
           io_in[26] ,
           io_in[25] ,
           io_in[24] ,
           io_in[23] ,
           io_in[22] ,
           io_in[21] ,
           io_in[20] ,
           io_in[19] ,
           io_in[18] ,
           io_in[17] ,
           io_in[16] ,
           io_in[15] ,
           io_in[14] ,
           io_in[13] ,
           io_in[10] ,
           io_in[9]  ,
           io_in[8]  
           // Uart pins io_in[2], io_in[1] are excluded
          } = (u_top.p_reset_n == 0) ? 23'hZZ_ZZZZ: (&io_oeb[27:8]) ? arduino_din: 'h0; // Tri-state untill Strap pull completed
                    
    reg[7:0] pinmap[0:22]; //ardiono to gpio pinmaping

	initial begin
        arduino_din[22:2]  = 23'b010_1010_1010_1010_1010_10; // Initialise based on test case edge
        pinmap[0]   = 24;    // PD0 - GPIO-24 
	    pinmap[1]   = 25;    // PD1 - GPIO-25
	    pinmap[2]   = 26;    // PD2 - GPIO-26
	    pinmap[3]   = 27;    // PD3 - GPIO-27
	    pinmap[4]   = 28;    // PD4 - GPIO-28
	    pinmap[5]   = 29;    // PD5 - GPIO-29
	    pinmap[6]   = 30;    // PD6 - GPIO-30
	    pinmap[7]   = 31;    // PD7 - GPIO-31
	    pinmap[8]   = 8;     // PB0 - GPIO-8
	    pinmap[9]   = 9;     // PB1 - GPIO-9
	    pinmap[10]  = 10;    // PB2 - GPIO-10
	    pinmap[11]  = 11;    // PB3 - GPIO-11
	    pinmap[12]  = 12;    // PB4 - GPIO-12
	    pinmap[13]  = 13;    // PB5 - GPIO-13
	    pinmap[14]  = 16;    // PC0 - GPIO-16
	    pinmap[15]  = 17;    // PC1 - GPIO-17
	    pinmap[16]  = 18;    // PC2 - GPIO-18
	    pinmap[17]  = 19;    // PC3 - GPIO-19
	    pinmap[18]  = 20;    // PC4 - GPIO-20
	    pinmap[19]  = 21;    // PC5 - GPIO-21
	    pinmap[20]  = 14;    // PB6 - GPIO-14
	    pinmap[21]  = 15;    // PB7 - GPIO-15
	    pinmap[22]  = 22;    // PC6 - GPIO-22


        uart_data_bit           = 2'b11;
        uart_stop_bits          = 0; // 0: 1 stop bit; 1: 2 stop bit;
        uart_stick_parity       = 0; // 1: force even parity
        uart_parity_en          = 0; // parity enable
        uart_even_odd_parity    = 1; // 0: odd parity; 1: even parity
	    tb_set_uart_baud(50000000,1152000,uart_divisor);// 50Mhz Ref clock, Baud Rate: 230400
        uart_timeout            = 1000;// wait time limit
        uart_fifo_enable        = 0;	// fifo mode disable

		$value$plusargs("risc_core_id=%d", d_risc_id);
 
	    init();
       	wait_riscv_boot();

		#200; // Wait for reset removal
	    repeat (10) @(posedge clock);
		$display("Monitor: Standalone User Risc Boot Test Started");

		// Remove Wb Reset
		//wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,'h1);

	    repeat (2) @(posedge clock);
		#1;
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

        repeat (100) @(posedge clock);  // wait for Processor Get Ready

	    tb_uart.debug_mode = 0; // disable debug display
        tb_uart.uart_init;
        tb_uart.control_setup (uart_data_bit, uart_stop_bits, uart_parity_en, uart_even_odd_parity, 
                                       uart_stick_parity, uart_timeout, uart_divisor);

        repeat (40000) @(posedge clock);  // wait for Processor Get Ready
	    flag  = 0;
		check_sum = 0;
        compare_start = 1;
        
        fork

           begin
		      $display("Start : Processing One Interrupt At a Time ");
              // Interrupt- One After One
              for(i =2; i < 22; i = i+1) begin
                  arduino_din[i] = !arduino_din[i]; // Invert the edge to create interrupt;
                  repeat (10) @(posedge clock);  
                  arduino_din[i] = !arduino_din[i]; // Invert the edge to remove the interrupt
                  repeat (10) @(posedge clock);  
                  wait(u_top.u_riscv_top.irq_lines[pinmap[i]] == 1'b1); // Wait for Interrupt assertion
                  wait(u_top.u_riscv_top.irq_lines[pinmap[i]] == 1'b0); // Wait for Interrupt De-assertion

              end
              repeat (10000) @(posedge clock);  // Wait for flush our uart message
		      $display("End : Processing One Interrupt At a Time ");

              // Generate all interrupt and Wait for all interrupt clearing
		      $display("Start: Processing All Interrupt ");
              for(i =2; i < 22; i = i+1) begin
                  arduino_din[i] = !arduino_din[i]; // Invert the edge to create interrupt;
                  repeat (5) @(posedge clock);  
                  arduino_din[i] = !arduino_din[i]; // Invert the edge to remove the interrupt
                  repeat (5) @(posedge clock);  
                  wait(u_top.u_riscv_top.irq_lines[pinmap[i]] == 1'b1); // Wait for Interrupt assertion

              end
              wait(u_top.u_riscv_top.irq_lines == 'h0); // Wait for All Interrupt De-assertion
              repeat (10000) @(posedge clock);  // Wait for flush our uart message
		      $display("End: Processing All Interrupt ");
           end
           begin
              while(flag == 0)
              begin
                 tb_uart.read_char(read_data,flag);
		         if(flag == 0)  begin
		            $write ("%c",read_data);
		            check_sum = check_sum+read_data;
		         end
              end
           end
           begin
              repeat (900000) @(posedge clock);  // wait for Processor Get Ready
           end
           join_any
        
           #1000
           tb_uart.report_status(uart_rx_nu, uart_tx_nu);
        
           test_fail = 0;

		   $display("Total Rx Char: %d Check Sum : %x ",uart_rx_nu, check_sum);
           // Check 
           // if all the 102 byte received
           // if no error 
           if(uart_rx_nu != 1063) test_fail = 1;
           if(check_sum != 32'h143de) test_fail = 1;
           if(tb_uart.err_cnt != 0) test_fail = 1;

	   
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
//assign io_in[21] = 1'b0; // CLOCK

`ifndef GL // Drive Power for Hold Fix Buf
    // All standard cell need power hook-up for functionality work
    initial begin

    end
`endif    

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
assign io_in[6]   = (io_oeb[6] == 1'b1) ? uart_rxd  : 1'b0;
 
uart_agent tb_uart(
	.mclk                (clock              ),
	.txd                 (uart_rxd           ),
	.rxd                 (uart_txd           )
	);


endmodule
`include "s25fl256s.sv"
`default_nettype wire
