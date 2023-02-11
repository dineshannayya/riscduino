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
////   pwm interfaface through External WB i/F.                  ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 01 Oct 2021, Dinesh A                               ////
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

`timescale 1 ns / 1 ps


`define TB_GLBL    user_pwm_tb

`include "sram_macros/sky130_sram_2kbyte_1rw1r_32x512_8.v"


module user_pwm_tb;
parameter real CLK1_PERIOD  = 20; // 50Mhz
parameter real CLK2_PERIOD = 2.5;
parameter real IPLL_PERIOD = 5.008;
parameter real XTAL_PERIOD = 6;

`include "user_tasks.sv"



	reg [31:0] pwm0_period;
	reg [31:0] pwm1_period;
	reg [31:0] pwm2_period;
	reg [31:0] pwm3_period;
	reg [31:0] pwm4_period;
	reg [31:0] pwm5_period;

    reg [15:0] check_sum;
    integer    test_step,i;
    wire       clock_mon;



	`ifdef WFDUMP
	   initial begin
	   	$dumpfile("simx.vcd");
	   	$dumpvars(1, `TB_GLBL);
	   	$dumpvars(1, `TB_GLBL.pwm_monitor);
	   	$dumpvars(1, `TB_GLBL.check_clock_period);
	   	$dumpvars(1, `TB_GLBL.u_top.u_wb_host);
	   	$dumpvars(0, `TB_GLBL.u_top.u_pinmux);
	   	$dumpvars(1, `TB_GLBL.u_top.u_intercon);
	   end
       `endif

	initial begin
		$dumpon;
        init();

		#200; // Wait for reset removal
	        repeat (10) @(posedge clock);
		$display("Monitor: Standalone User Risc Boot Test Started");

		// Remove Wb Reset
		//wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,'h1);

        // Enable PWM Multi Functional Ports
        wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_MUTI_FUNC,'h03F);

	    repeat (2) @(posedge clock);
		#1;

		test_fail = 0;
        check_sum = 0;
	    repeat (200) @(posedge clock);
        wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 1000

	    $display("########################################");
	    $display("Step-1, PWM Square Waveform");
	    test_step = 1;
        pwm0_period = 20*256;
        pwm1_period = 20*2*256;
        pwm2_period = 20*4*256;
        pwm3_period = 20*256; // pwm3 is connected to pwm0
        pwm4_period = 20*2*256; // pwm4 is connected to pwm1
        pwm5_period = 20*4*256; // pwm5 is conneted to pwm2
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG0,'h0000_8000); // No Scale 
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG1,'h0000_00FF); // Period 0xFFFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG2,'h0000_007F); // COMP0 = 0xFF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG0,'h0000_8001); // Scale 2^1 = 2
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG1,'h0000_00FF); // Period 0xFFFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG2,'h0000_007F); // COMP0 = 0xFF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG0,'h0000_8002); // Scale 2^2 = 4
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG1,'h0000_00FF); // Period 0xFFFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG2,'h0000_007F); // COMP0 = 0xFF

        // PWm3 to 5 Removed
        //wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK3_CFG0,'h0000_8003); // Scale 2^3 = 8
        //wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK3_CFG1,'h0000_00FF); // Period 0xFFFF
        //wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK3_CFG2,'h0000_007F); // COMP0 = 0xFF

        //wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK4_CFG0,'h0000_8004); // Scale 2^4 = 16
        //wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK4_CFG1,'h0000_00FF); // Period 0xFFFF
        //wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK4_CFG2,'h0000_007F); // COMP0 = 0xFF

        //wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK5_CFG0,'h0000_8005); // Scale 2^5 = 32
        //wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK5_CFG1,'h0000_00FF); // Period 0xFFFF
        //wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK5_CFG2,'h0000_007F); // COMP0 = 0xFF
        
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_MASK,'h0000_0007); // Enable PWM Interrupt
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0707); // Enable PWM + RUN
	    pwm_monitor(pwm0_period,pwm1_period,pwm2_period,pwm3_period,pwm4_period,pwm5_period);
        wb_user_core_read_check(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data,'h0000_0007); // Check Interrupt Status
        wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,read_data,'h0000_0020); // Check Global Interrupt Status
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0000); // Disable PWM
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,'h0000_0007); // Clear Interrupt
        wb_user_core_read_check(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data,'h0000_0000); // Check Interrupt Status
        wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,'h0000_0020); // Check Global Interrupt Status
        wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,read_data,'h0000_0000); // Check Global Interrupt Status

       if(test_fail == 1) begin
          $display("ERROR: Step-1, PWM Square Waveform - FAILED");
       end else begin
          $display("STATUS: Step-1, PWM Square Waveform - PASSED");
       end
	    $display("########################################");
	    $display("Step-2, PWM One Shot");
	    test_step = 2;
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG0,'h0000_8010); // No Scale 
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG1,'h0000_00FF); // Period 0xFFFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG2,'h0000_007F); // COMP0 = 0xFF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG0,'h0000_8011); // Scale 2^1 = 2
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG1,'h0000_00FF); // Period 0xFFFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG2,'h0000_007F); // COMP0 = 0xFF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG0,'h0000_8012); // Scale 2^2 = 4
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG1,'h0000_00FF); // Period 0xFFFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG2,'h0000_007F); // COMP0 = 0xFF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_MASK,'h0000_0007); // Enable PWM Interrupt
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0707); // Enable PWM + Run
        read_data[15:8] = 8'h7;
        fork
        begin
           while(read_data[15:8]  != 8'h00) begin // Wait for De-assertion on Run
               wb_user_core_read(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,read_data);
               check_sum = check_sum + pwm_wfm;
                repeat (100) @(posedge clock);
           end
        end
        begin
           while(1) begin
              check_sum = check_sum + pwm_wfm;
              repeat (100) @(posedge clock);
          end
        end
        join_any

        wb_user_core_read_check(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data,'h0000_0007); // Check Interrupt Status
        wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,read_data,'h0000_0020); // Check Global Interrupt Status
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0000); // Disable PWM
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,'h0000_0007); // Clear Interrupt
        wb_user_core_read_check(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data,'h0000_0000); // Check Interrupt Status
        wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,'h0000_0020); // Check Global Interrupt Status
        wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,read_data,'h0000_0000); // Check Global Interrupt Status

       if(test_fail == 1) begin
          $display("ERROR: Step-2, PWM One Shot - FAILED");
       end else begin
          $display("STATUS: Step-2, PWM One Shot - PASSED");
       end

	    $display("########################################");
	    $display("Step-3, PWM One Shot + Hold last data ");
	    test_step = 3;
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0007_0000); // Disable Cfg Update
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG0,'h0000_8810); // No Scale 
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG1,'h0000_00FF); // Period 0xFFFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG2,'h0000_007F); // COMP0 = 0xFF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG0,'h0000_8811); // Scale 2^1 = 2
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG1,'h0000_00FF); // Period 0xFFFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG2,'h0000_007F); // COMP0 = 0xFF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG0,'h0000_8812); // Scale 2^2 = 4
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG1,'h0000_00FF); // Period 0xFFFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG2,'h0000_007F); // COMP0 = 0xFF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_MASK,'h0000_0007); // Enable PWM Interrupt
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0707); // Enable PWM + Run
        read_data[15:8] = 8'h7;
        fork
        begin
           while(read_data[15:8]  != 8'h00) begin // Wait for De-assertion on Run
               wb_user_core_read(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,read_data);
               check_sum = check_sum + pwm_wfm;
                repeat (100) @(posedge clock);
           end
        end
        begin
           while(1) begin
              check_sum = check_sum + pwm_wfm;
              repeat (100) @(posedge clock);
          end
        end
        join_any

        wb_user_core_read_check(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data,'h0000_0007); // Check Interrupt Status
        wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,read_data,'h0000_0020); // Check Global Interrupt Status
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0000); // Disable PWM
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,'h0000_0007); // Clear Interrupt
        wb_user_core_read_check(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data,'h0000_0000); // Check Interrupt Status
        wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,'h0000_0020); // Check Global Interrupt Status
        wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,read_data,'h0000_0000); // Check Global Interrupt Status

       if(test_fail == 1) begin
          $display("ERROR: Step-3, PWM One Shot + Hold last data - FAILED");
       end else begin
          $display("STATUS: Step-3, PWM One Shot + Hold last data - PASSED");
       end

	    $display("########################################");
	    $display("Step-4, PWM One Shot + mode:1 ");
	    test_step = 4;
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0007_0000); // Disable Cfg Update
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG0,'h0000_9010); // No Scale + One Shot + Mode:1
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG1,'h0000_00FF); // Period 0xFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG2,'h008F_006F); // COMP0 = 0x6F, COMP1= 0x8F
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG3,'h0000_0000); // COMP2 = 0x00, COMP3= 0x00

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG0,'h0000_9011); // Scale 2^1 = 2 + One Shot + Mode:1
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG1,'h0000_00FF); // Period 0xFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG2,'h008F_006F); // COMP0 = 0x6F, COMP1= 0x8F
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG3,'h0000_0000); // COMP2 = 0x00, COMP3= 0x00

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG0,'h0000_9012); // Scale 2^2 = 4 + One Shot + Mode:1
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG1,'h0000_00FF); // Period 0xFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG2,'h008F_006F); // COMP0 = 0x6F, COMP1= 0x8F
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG3,'h0000_0000); // COMP2 = 0x00, COMP3= 0x00

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_MASK,'h0000_0007); // Enable PWM Interrupt
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0000); // Remove config update block 
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0707); // Enable PWM + Run
        read_data[15:8] = 8'h7;
        fork
        begin
           while(read_data[15:8]  != 8'h00) begin // Wait for De-assertion on Run
               wb_user_core_read(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,read_data);
               check_sum = check_sum + pwm_wfm;
                repeat (100) @(posedge clock);
           end
        end
        begin
           while(1) begin
              check_sum = check_sum + pwm_wfm;
              repeat (100) @(posedge clock);
          end
        end
        join_any

        wb_user_core_read_check(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data,'h0000_0007); // Check Interrupt Status
        wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,read_data,'h0000_0020); // Check Global Interrupt Status
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0000); // Disable PWM
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,'h0000_0007); // Clear Interrupt
        wb_user_core_read_check(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data,'h0000_0000); // Check Interrupt Status
        wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,'h0000_0020); // Check Global Interrupt Status
        wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,read_data,'h0000_0000); // Check Global Interrupt Status

       if(test_fail == 1) begin
          $display("ERROR: Step-4, PWM One Shot + mode:1 - FAILED");
       end else begin
          $display("STATUS: Step-4, PWM One Shot + mode:1 - PASSED");
       end
	    
        $display("########################################");
	    $display("Step-5, PWM One Shot + mode:2 ");
	    test_step = 5;
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0007_0000); // Disable Cfg Update
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG0,'h0000_A010); // No Scale + One Shot + Mode:2
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG1,'h0000_00FF); // Period 0xFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG2,'h008F_006F); // COMP0 = 0x6F, COMP1= 0x8F
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG3,'h0000_00AF); // COMP2 = 0xAF, COMP3= 0x00

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG0,'h0000_A011); // Scale 2^1 = 2 + One Shot + Mode:2
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG1,'h0000_00FF); // Period 0xFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG2,'h008F_006F); // COMP0 = 0x6F, COMP1= 0x8F
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG3,'h0000_00AF); // COMP2 = 0xAF, COMP3= 0x00

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG0,'h0000_A012); // Scale 2^2 = 4 + One Shot + Mode:2
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG1,'h0000_00FF); // Period 0xFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG2,'h008F_006F); // COMP0 = 0x6F, COMP1= 0x8F
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG3,'h0000_00AF); // COMP2 = 0xAF, COMP3= 0x00

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_MASK,'h0000_0007); // Enable PWM Interrupt
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0000); // Remove config update block 
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0707); // Enable PWM + Run
        read_data[15:8] = 8'h7;
        fork
        begin
           while(read_data[15:8]  != 8'h00) begin // Wait for De-assertion on Run
               wb_user_core_read(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,read_data);
               check_sum = check_sum + pwm_wfm;
                repeat (100) @(posedge clock);
           end
        end
        begin
           while(1) begin
              check_sum = check_sum + pwm_wfm;
              repeat (100) @(posedge clock);
          end
        end
        join_any

        wb_user_core_read_check(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data,'h0000_0007); // Check Interrupt Status
        wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,read_data,'h0000_0020); // Check Global Interrupt Status
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0000); // Disable PWM
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,'h0000_0007); // Clear Interrupt
        wb_user_core_read_check(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data,'h0000_0000); // Check Interrupt Status
        wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,'h0000_0020); // Check Global Interrupt Status
        wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,read_data,'h0000_0000); // Check Global Interrupt Status

       if(test_fail == 1) begin
          $display("ERROR: Step-5, PWM One Shot + mode:2 - FAILED");
       end else begin
          $display("STATUS: Step-5, PWM One Shot + mode:2 - PASSED");
       end
        $display("########################################");
	    $display("Step-6, PWM One Shot + mode:3 ");
	    test_step = 6;
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0007_0000); // Disable Cfg Update
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG0,'h0000_B010); // No Scale + One Shot + Mode:3
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG1,'h0000_00FF); // Period 0xFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG2,'h008F_006F); // COMP0 = 0x6F, COMP1= 0x8F
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG3,'h00CF_00AF); // COMP2 = 0xAF, COMP3= 0xCF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG0,'h0000_B011); // Scale 2^1 = 2 + One Shot + Mode:3
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG1,'h0000_00FF); // Period 0xFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG2,'h008F_006F); // COMP0 = 0x6F, COMP1= 0x8F
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG3,'h00CF_00AF); // COMP2 = 0xAF, COMP3= 0xCF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG0,'h0000_B012); // Scale 2^2 = 4 + One Shot + Mode:3
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG1,'h0000_00FF); // Period 0xFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG2,'h008F_006F); // COMP0 = 0x6F, COMP1= 0x8F
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG3,'h00CF_00AF); // COMP2 = 0xAF, COMP3= 0xCF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_MASK,'h0000_0007); // Enable PWM Interrupt
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0000); // Remove config update block 
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0707); // Enable PWM+Run
        read_data[15:8] = 8'h7;
        fork
        begin
           while(read_data[15:8]  != 8'h00) begin // Wait for De-assertion on Run
               wb_user_core_read(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,read_data);
               check_sum = check_sum + pwm_wfm;
                repeat (100) @(posedge clock);
           end
        end
        begin
           while(1) begin
              check_sum = check_sum + pwm_wfm;
              repeat (100) @(posedge clock);
          end
        end
        join_any

        wb_user_core_read_check(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data,'h0000_0007); // Check Interrupt Status
        wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,read_data,'h0000_0020); // Check Global Interrupt Status
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0000); // Disable PWM
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,'h0000_0007); // Clear Interrupt
        wb_user_core_read_check(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data,'h0000_0000); // Check Interrupt Status
        wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,'h0000_0020); // Check Global Interrupt Status
        wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,read_data,'h0000_0000); // Check Global Interrupt Status

       if(test_fail == 1) begin
          $display("ERROR: Step-6, PWM One Shot + mode:3 - FAILED");
       end else begin
          $display("STATUS: Step-6, PWM One Shot + mode:3 - PASSED");
       end
        $display("########################################");
	    $display("Step-7, PWM Free Running + mode:3 ");
	    test_step = 7;
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0007_0000); // Disable Cfg Update
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG0,'h0000_B000); // No Scale + Free Run + Mode:3
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG1,'h0000_00FF); // Period 0xFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG2,'h008F_006F); // COMP0 = 0x6F, COMP1= 0x8F
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG3,'h00CF_00AF); // COMP2 = 0xAF, COMP3= 0xCF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG0,'h0000_B001); // Scale 2^1 = 2 + Free Run + Mode:3
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG1,'h0000_00FF); // Period 0xFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG2,'h008F_006F); // COMP0 = 0x6F, COMP1= 0x8F
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG3,'h00CF_00AF); // COMP2 = 0xAF, COMP3= 0xCF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG0,'h0000_B002); // Scale 2^2 = 4 + Free Run + Mode:3
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG1,'h0000_00FF); // Period 0xFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG2,'h008F_006F); // COMP0 = 0x6F, COMP1= 0x8F
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG3,'h00CF_00AF); // COMP2 = 0xAF, COMP3= 0xCF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_MASK,'h0000_0007); // Enable PWM Interrupt
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0000); // Remove config update block 
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0707); // Enable PWM+Run
        read_data = 8'h0;
        fork
        begin
           while(read_data  != 8'h07) begin // Wait for Overflow Interrupt
               wb_user_core_read(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data);
               check_sum = check_sum + pwm_wfm;
                repeat (100) @(posedge clock);
           end
        end
        begin
           while(1) begin
              check_sum = check_sum + pwm_wfm;
              repeat (100) @(posedge clock);
          end
        end
        join_any

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0000); // Disable PWM
        wb_user_core_read_check(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data,'h0000_0007); // Check Interrupt Status
        wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,read_data,'h0000_0020); // Check Global Interrupt Status
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,'h0000_0007); // Clear Interrupt
        wb_user_core_read_check(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data,'h0000_0000); // Check Interrupt Status
        wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,'h0000_0020); // Check Global Interrupt Status
        wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,read_data,'h0000_0000); // Check Global Interrupt Status

       if(test_fail == 1) begin
          $display("ERROR: Step-7, PWM Free Run + mode:3 - FAILED");
       end else begin
          $display("STATUS: Step-7, PWM Free Run + mode:3 - PASSED");
       end
        $display("########################################");
	    $display("Step-8, PWM Gpio: 0x3 Pos Edge , One Shot  + mode:3 ");
	    test_step = 8;
        // Pin-26   17   PC3/usb_dn/ADC3   digital_io[25]/analog_io[14]

        force u_top.io_in[25] = 1'b0; // force PC3 to 0

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0007_0000); // Disable Cfg Update
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG0,'h0000_B350); // No Scale + One Shot + GPIO: 0x3, Posedge + Mode:3
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG1,'h0000_00FF); // Period 0xFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG2,'h008F_006F); // COMP0 = 0x6F, COMP1= 0x8F
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG3,'h00CF_00AF); // COMP2 = 0xAF, COMP3= 0xCF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG0,'h0000_B351); // Scale 2^1 = 2 + One Shot + GPIO: 0x3, Posedge + Mode:3
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG1,'h0000_00FF); // Period 0xFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG2,'h008F_006F); // COMP0 = 0x6F, COMP1= 0x8F
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG3,'h00CF_00AF); // COMP2 = 0xAF, COMP3= 0xCF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG0,'h0000_B352); // Scale 2^2 = 4 + One Shot + GPIO: 0x3, Posedge + Mode:3
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG1,'h0000_00FF); // Period 0xFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG2,'h008F_006F); // COMP0 = 0x6F, COMP1= 0x8F
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG3,'h00CF_00AF); // COMP2 = 0xAF, COMP3= 0xCF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_MASK,'h0000_0007); // Interrupt Enable
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0000); // Remove config update block 
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0007); //  PWM Enable + No Run (Expect GPIO generate Run)

        // Generate 4 GPIO Edge Sequence
        for(i=0; i < 4; i=i+1) begin
           read_data = 8'h0;
           // Generate Pos Egde
           force u_top.io_in[25] = 1'b1; // force PC3 to 1
           repeat (10) @(posedge clock);
           force u_top.io_in[25] = 1'b0; // force PC3 to 0

           fork
           begin
              while(read_data  != 8'h07) begin // Wait for Overflow Interrupt
                  wb_user_core_read(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data);
                  check_sum = check_sum + pwm_wfm;
                   repeat (100) @(posedge clock);
              end
           end
           begin
              while(1) begin
                 check_sum = check_sum + pwm_wfm;
                 repeat (100) @(posedge clock);
             end
           end
           join_any
           if(i < 3) begin
                  wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data);
           end
         end

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0000); // Disable PWM
        wb_user_core_read_check(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data,'h0000_0007); // Check Interrupt Status
        wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,read_data,'h0000_0020); // Check Global Interrupt Status
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,'h0000_0007); // Clear Interrupt
        wb_user_core_read_check(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data,'h0000_0000); // Check Interrupt Status
        wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,'h0000_0020); // Check Global Interrupt Status
        wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,read_data,'h0000_0000); // Check Global Interrupt Status

       if(test_fail == 1) begin
          $display("ERROR: Step-8, PWM Gpio: 0x3 Pos Edge , One Shot  + mode:3 - FAILED");
       end else begin
          $display("STATUS: Step-8, PWM Gpio: 0x3 Pos Edge , One Shot  + mode:3 - PASSED");
       end
        $display("########################################");
	    $display("Step-9, PWM Gpio: 0x3 Neg Edge , One Shot  + mode:3 ");
	    test_step = 9;
        // Pin-26   17   PC3/usb_dn/ADC3   digital_io[25]/analog_io[14]

        force u_top.io_in[25] = 1'b1; // force PC3 to 1

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0007_0000); // Disable Cfg Update
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG0,'h0000_B3D0); // No Scale + One Shot + GPIO: 0x3, Neg Edge + Mode:3
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG1,'h0000_00FF); // Period 0xFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG2,'h008F_006F); // COMP0 = 0x6F, COMP1= 0x8F
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG3,'h00CF_00AF); // COMP2 = 0xAF, COMP3= 0xCF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG0,'h0000_B3D1); // Scale 2^1 = 2 + One Shot + GPIO: 0x3, Neg Edge + Mode:3
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG1,'h0000_00FF); // Period 0xFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG2,'h008F_006F); // COMP0 = 0x6F, COMP1= 0x8F
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG3,'h00CF_00AF); // COMP2 = 0xAF, COMP3= 0xCF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG0,'h0000_B3D2); // Scale 2^2 = 4 + One Shot + GPIO: 0x3, Neg Edge + Mode:3
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG1,'h0000_00FF); // Period 0xFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG2,'h008F_006F); // COMP0 = 0x6F, COMP1= 0x8F
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG3,'h00CF_00AF); // COMP2 = 0xAF, COMP3= 0xCF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_MASK,'h0000_0007); // Interrupt Enable
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0000); // Remove config update block 
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0007); //  PWM Enable + No Run (Expect GPIO generate Run)

        repeat (100) @(posedge clock); // Wait for PWM enable command propagaton
        // Generate 4 GPIO Edge Sequence
        for(i=0; i < 4; i=i+1) begin
           read_data = 8'h0;
           // Generate Neg Egde
           force u_top.io_in[25] = 1'b0; // force PC3 to 0
           repeat (10) @(posedge clock);
           force u_top.io_in[25] = 1'b1; // force PC3 to 1

           fork
           begin
              while(read_data  != 8'h07) begin // Wait for Overflow Interrupt
                  wb_user_core_read(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data);
                  check_sum = check_sum + pwm_wfm;
                   repeat (100) @(posedge clock);
              end
           end
           begin
              while(1) begin
                 check_sum = check_sum + pwm_wfm;
                 repeat (100) @(posedge clock);
             end
           end
           join_any
           if(i < 3) begin
                  wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data);
           end
         end

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0000); // Disable PWM
        wb_user_core_read_check(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data,'h0000_0007); // Check Interrupt Status
        wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,read_data,'h0000_0020); // Check Global Interrupt Status
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,'h0000_0007); // Clear Interrupt
        wb_user_core_read_check(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data,'h0000_0000); // Check Interrupt Status
        wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,'h0000_0020); // Check Global Interrupt Status
        wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,read_data,'h0000_0000); // Check Global Interrupt Status

       if(test_fail == 1) begin
          $display("ERROR: Step-9, PWM Gpio: 0x3 Neg Edge , One Shot  + mode:3 - FAILED");
       end else begin
          $display("STATUS: Step-9, PWM Gpio: 0x3 Neg Edge , One Shot  + mode:3 - PASSED");
       end
        $display("########################################");
	    $display("Step-10, PWM Gpio: 0x3 Neg Edge , One Shot  + mode:3 + Waveform Invert ");
	    test_step = 10;
        // Pin-26   17   PC3/usb_dn/ADC3   digital_io[25]/analog_io[14]

        force u_top.io_in[25] = 1'b1; // force PC3 to 1

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0007_0000); // Disable Cfg Update
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG0,'h0000_F3D0); // No Scale + One Shot + Clk Inv + GPIO: 0x3, Neg Edge + Mode:3
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG1,'h0000_00FF); // Period 0xFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG2,'h008F_006F); // COMP0 = 0x6F, COMP1= 0x8F
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG3,'h00CF_00AF); // COMP2 = 0xAF, COMP3= 0xCF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG0,'h0000_F3D1); // Scale 2^1 = 2 + One Shot + Clk Inv + GPIO: 0x3, Neg Edge + Mode:3
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG1,'h0000_00FF); // Period 0xFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG2,'h008F_006F); // COMP0 = 0x6F, COMP1= 0x8F
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG3,'h00CF_00AF); // COMP2 = 0xAF, COMP3= 0xCF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG0,'h0000_F3D2); // Scale 2^2 = 4 + One Shot + Clk Inv + GPIO: 0x3, Neg Edge + Mode:3
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG1,'h0000_00FF); // Period 0xFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG2,'h008F_006F); // COMP0 = 0x6F, COMP1= 0x8F
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG3,'h00CF_00AF); // COMP2 = 0xAF, COMP3= 0xCF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_MASK,'h0000_0007); // Interrupt Enable
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0000); // Remove config update block 
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0007); //  PWM Enable + No Run (Expect GPIO generate Run)

        repeat (100) @(posedge clock); // Wait for PWM enable command propagaton
        // Generate 4 GPIO Edge Sequence
        for(i=0; i < 4; i=i+1) begin
           read_data = 8'h0;
           // Generate Neg Egde
           force u_top.io_in[25] = 1'b0; // force PC3 to 0
           repeat (10) @(posedge clock);
           force u_top.io_in[25] = 1'b1; // force PC3 to 1

           fork
           begin
              while(read_data  != 8'h07) begin // Wait for Overflow Interrupt
                  wb_user_core_read(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data);
                  check_sum = check_sum + pwm_wfm;
                   repeat (100) @(posedge clock);
              end
           end
           begin
              while(1) begin
                 check_sum = check_sum + pwm_wfm;
                 repeat (100) @(posedge clock);
             end
           end
           join_any
           if(i < 3) begin
                  wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data);
           end
         end

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0000); // Disable PWM
        wb_user_core_read_check(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data,'h0000_0007); // Check Interrupt Status
        wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,read_data,'h0000_0020); // Check Global Interrupt Status
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,'h0000_0007); // Clear Interrupt
        wb_user_core_read_check(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data,'h0000_0000); // Check Interrupt Status
        wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,'h0000_0020); // Check Global Interrupt Status
        wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,read_data,'h0000_0000); // Check Global Interrupt Status

       if(test_fail == 1) begin
          $display("ERROR: Step-9, PWM Gpio: 0x3 Neg Edge , One Shot  + mode:3 - FAILED");
       end else begin
          $display("STATUS: Step-9, PWM Gpio: 0x3 Neg Edge , One Shot  + mode:3 - PASSED");
       end
        $display("########################################");
	    $display("Step-10, PWM One Shot + mode:3 + Comparator Center ");
	    test_step = 10;
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0007_0000); // Disable Cfg Update
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG0,'h000F_B010); // No Scale + One Shot + Mode:3 + Comparator Center
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG1,'h0000_FFFF); // Period 0xFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG2,'h008F_006F); // COMP0 = 0x6F, COMP1= 0x8F
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK0_CFG3,'h00CF_00AF); // COMP2 = 0xAF, COMP3= 0xCF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG0,'h000F_B010); // No Scale + One Shot + Mode:3 + Comparator Center
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG1,'h0000_FFFF); // Period 0xFF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG2,'h008F_006F); // COMP0 = 0x6F, COMP1= 0x8F
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK1_CFG3,'h00CF_00AF); // COMP2 = 0xAF, COMP3= 0xCF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG0,'h000F_B010); // No Scale + One Shot + Mode:3 + Comparator Center
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG1,'h0000_FFFF); // Period 0x80FF
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG2,'h008F_0F6F); // COMP0 = 0x6F, COMP1= 0x8F
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_BLK2_CFG3,'h00CF_00AF); // COMP2 = 0xAF, COMP3= 0xCF

        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_MASK,'h0000_0007); // Enable PWM Interrupt
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0000); // Remove config update block 
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0707); // Enable PWM+Run
        read_data[15:8] = 8'h7;
        fork
        begin
           while(read_data[15:8]  != 8'h00) begin // Wait for De-assertion on Run
               wb_user_core_read(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,read_data);
               check_sum = check_sum + pwm_wfm;
                repeat (100) @(posedge clock);
           end
        end
        begin
           while(1) begin
              check_sum = check_sum + pwm_wfm;
              repeat (100) @(posedge clock);
          end
        end
        join_any

        wb_user_core_read_check(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data,'h0000_0007); // Check Interrupt Status
        wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,read_data,'h0000_0020); // Check Global Interrupt Status
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_CFG0,'h0000_0000); // Disable PWM
        wb_user_core_write(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,'h0000_0007); // Clear Interrupt
        wb_user_core_read_check(`ADDR_SPACE_PWM+`PWM_GLBL_INTR_STAT,read_data,'h0000_0000); // Check Interrupt Status
        wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,'h0000_0020); // Check Global Interrupt Status
        wb_user_core_read_check(`ADDR_SPACE_GLBL+`GLBL_CFG_INTR_STAT,read_data,'h0000_0000); // Check Global Interrupt Status

       if(test_fail == 1) begin
          $display("ERROR: Step-10, PWM One Shot + mode:3 + Comparator Center - FAILED");
       end else begin
          $display("STATUS: Step-10, PWM One Shot + mode:3 + Comparator Center - PASSED");
       end
       $display("Check Sum: %x ",check_sum);
       if(check_sum != 16'hc557) test_fail = 1;

		repeat (100) @(posedge clock);
			// $display("+1000 cycles");

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

wire [5:0] pwm_wfm = {(io_oeb[19] == 1'b0) ? io_out[19]: 1'b0 ,
                      (io_oeb[18] == 1'b0) ? io_out[18]: 1'b0 ,
                      (io_oeb[17] == 1'b0) ? io_out[17]: 1'b0 ,
                      (io_oeb[14] == 1'b0) ? io_out[14]: 1'b0 ,
                      (io_oeb[13] == 1'b0) ? io_out[13]: 1'b0 ,
                      (io_oeb[9]  == 1'b0) ? io_out[9] : 1'b0  };

wire pwm0 = pwm_wfm[0];
wire pwm1 = pwm_wfm[1];
wire pwm2 = pwm_wfm[2];
wire pwm3 = pwm_wfm[3];
wire pwm4 = pwm_wfm[4];
wire pwm5 = pwm_wfm[5];


reg [2:0] pwm_sel;

assign clock_mon = (pwm_sel == 0) ? pwm0 :
                   (pwm_sel == 1) ? pwm1 :
                   (pwm_sel == 2) ? pwm2 :
                   (pwm_sel == 3) ? pwm3 :
                   (pwm_sel == 4) ? pwm4 : pwm5;

                   
task pwm_monitor;
input [31:0] pwm0_period;
input [31:0] pwm1_period;
input [31:0] pwm2_period;
input [31:0] pwm3_period;
input [31:0] pwm4_period;
input [31:0] pwm5_period;
begin
   pwm_sel = 3'h0;
   repeat (100) @(posedge clock);
   check_clock_period("PWM0 Clock",pwm0_period);

   pwm_sel = 3'h1;
   repeat (100) @(posedge clock);
   check_clock_period("PWM1 Clock",pwm1_period);

   pwm_sel = 3'h2;
   repeat (100) @(posedge clock);
   check_clock_period("PWM2 Clock",pwm2_period);

   pwm_sel = 3'h3;
   repeat (100) @(posedge clock);
   check_clock_period("PWM3 Clock",pwm3_period);

   pwm_sel = 3'h4;
   repeat (100) @(posedge clock);
   check_clock_period("PWM4 Clock",pwm4_period);

   pwm_sel = 3'h5;
   repeat (100) @(posedge clock);
   check_clock_period("PWM5 Clock",pwm5_period);
end
endtask


//----------------------------------
// Check the clock period
//----------------------------------
task check_clock_period;
input [127:0] clk_name;
input [31:0] clk_period; // in NS
time prev_t, next_t, periodd;
begin
    $timeformat(-12,3,"ns",10);
   repeat(2) @(posedge clock_mon);
   repeat(1) @(posedge clock_mon);
   prev_t  = $realtime;
   repeat(2) @(posedge clock_mon);
   next_t  = $realtime;
   periodd = (next_t-prev_t)/2;
   periodd = (periodd);
   if(clk_period != periodd) begin
       $display("STATUS: FAIL => %s Exp Period: %d ns Rxd: %d ns",clk_name,clk_period,periodd);
       test_fail = 1;
   end else begin
       $display("STATUS: PASS => %s  Period: %d ns ",clk_name,clk_period);
   end
end
endtask

// SSPI Slave I/F
assign io_in[5]  = 1'b1; // RESET




//----------------------------------------------------
//  Task
// --------------------------------------------------
task test_err;
begin
     test_fail = 1;
end
endtask

endmodule
`default_nettype wire
