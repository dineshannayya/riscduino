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
////                                                              ////
////  Description                                                 ////
////   This is a standalone test bench to validate the            ////
////   Digital core MBIST logic through External WB i/F.          ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 18 Oct 2021, Dinesh A                               ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`default_nettype wire

`timescale 1 ns / 1 ns

`include "uprj_netlists.v"

`define WB_MAP           `30080_0000
`define GLBL_FUNC_MAP    'h3002_0000
`define MBIST1_FUNC_MAP  'h3003_0000  // 0x3003_0000 to 0x3003_07FF
`define MBIST2_FUNC_MAP  'h3003_0800  // 0x3003_0800 to 0x3003_0FFF
`define MBIST3_FUNC_MAP  'h3003_1000  // 0x3003_1000 to 0x3003_17FF
`define MBIST4_FUNC_MAP  'h3003_1800  // 0x3003_1800 to 0x3003_1FFF

`define GLBL_BIST_CTRL1  'h3002_0070    
`define GLBL_BIST_STAT1  'h3002_0074
`define GLBL_BIST_SWDATA 'h3002_0078
`define GLBL_BIST_SRDATA 'h3002_007C
`define GLBL_BIST_SPDATA 'h3002_0078  #

`define WB_GLBL_CTRL     'h3080_0000

`define NO_SRAM          4 // 8



module user_mbist_test1_tb;
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
	reg        test_fail;
	reg [31:0] read_data;
        reg [31:0] writemem [0:511];
        reg [8:0]  faultaddr [0:7];
        integer i;
        event      error_insert;


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
	   	$dumpvars(2, user_mbist_test1_tb);
	   	$dumpvars(0, user_mbist_test1_tb.u_top.u_mbist);
	   	$dumpvars(0, user_mbist_test1_tb.u_top.u_intercon);
		$dumpoff;
	   end
       `endif

	initial begin
		wb_rst_i <= 1'b1;
		#100;
		wb_rst_i <= 1'b0;	    	// Release reset

		#200; // Wait for reset removal
	        repeat (10) @(posedge clock);
		$display("Monitor: Standalone User Test Started");

		test_fail = 0;
		// Remove Wb Reset
		wb_user_core_write(`WB_GLBL_CTRL,'h1);

		$dumpoff;
	    	$display("###################################################");
	    	$display(" MBIST Test with Without Address Failure");
	    	$display("###################################################");

		// Check Is there is any BIST Error
		// [0]   - Bist Done      - 1
		// [1]   - Bist Error     - 0
		// [2]   - Bist Correct   - 0
		// [3]   - Reserved       - 0
		// [7:4] - Bist Error Cnt - 4'h0
		insert_fault(0,0,0,0,0,32'h01010101);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-1: BIST Test without any Memory Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-1: BIST Test without any Memory Error insertion test Failed");
		end
	    	$display("###################################################");
	    	
		$display("#########################################################");
	    	$display(" MBIST Test with With Single Address Failure for MEM-0");
	    	$display("#########################################################");

		// Check Is there is any BIST Error
		// [0]   - Bist Done      - 1
		// [1]   - Bist Error     - 0
		// [2]   - Bist Correct   - 1
		// [3]   - Reserved       - 0
		// [7:4] - Bist Error Cnt - 4'h1
		faultaddr[0] = 9'h10;
		faultaddr[1] = 9'h20;
		faultaddr[2] = 9'h30;
		faultaddr[3] = 9'h40;
		insert_fault(1,0,0,0,0,32'h01010115);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-2.1: BIST Test with Single Address Failure at MEM0 Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-2.1: BIST Test with Single Address Failure at MEM0 Error insertion test Failed");
		end
		$display("##########################################################");
	    	$display(" MBIST Test with With Single Address Failure for MEM-0/1");
	    	$display("##########################################################");

		// Check Is there is any BIST Error
		// [0]   - Bist Done      - 1
		// [1]   - Bist Error     - 0
		// [2]   - Bist Correct   - 1
		// [3]   - Reserved       - 0
		// [7:4] - Bist Error Cnt - 4'h1
		faultaddr[0] = 9'h10;
		faultaddr[1] = 9'h20;
		faultaddr[2] = 9'h30;
		faultaddr[3] = 9'h40;
		insert_fault(1,1,0,0,0,32'h01011515);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-2.2: BIST Test with Single Address Failure at MEM0/1 Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-2.2: BIST Test with Single Address Failure at MEM0/1 Error insertion test Failed");
		end
		$display("##########################################################");
	    	$display(" MBIST Test with With Single Address Failure for MEM-0/1/2");
	    	$display("##########################################################");

		// Check Is there is any BIST Error
		// [0]   - Bist Done      - 1
		// [1]   - Bist Error     - 0
		// [2]   - Bist Correct   - 1
		// [3]   - Reserved       - 0
		// [7:4] - Bist Error Cnt - 4'h1
		faultaddr[0] = 9'h10;
		faultaddr[1] = 9'h20;
		faultaddr[2] = 9'h30;
		faultaddr[3] = 9'h40;
		insert_fault(1,1,1,0,0,32'h01151515);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-2.3: BIST Test with Single Address Failure at MEM0/1/2 Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-2.3: BIST Test with Single Address Failure at MEM0/1/2 Error insertion test Failed");
		end

	    	$display("###################################################");
	    	$display(" MBIST Test with Single Address Failure to All Memory");
	    	$display("###################################################");
		   // Check Is there is any BIST Error
		   // [0]   - Bist Done      - 1
		   // [1]   - Bist Error     - 0
		   // [2]   - Bist Correct   - 1
		   // [3]   - Reserved       - 0
		   // [7:4] - Bist Error Cnt - 4'h1
		   //if(read_data[6:0]  != 7'b0001101) test_fail = 1; // Bist correct = 1 and Bist Err Cnt - 0x1
		faultaddr[0] = 9'h10;
		faultaddr[1] = 9'h20;
		faultaddr[2] = 9'h30;
		faultaddr[3] = 9'h40;
		insert_fault(1,1,1,1,1,32'h15151515);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-2.4: BIST Test with One Memory Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-2.4: BIST Test with One Memory Error insertion test Failed");
		end
	    	$display("###################################################");

		$display("#########################################################");
	    	$display(" MBIST Test with With Two Address Failure for MEM-0");
	    	$display("#########################################################");

		// Check Is there is any BIST Error
		// [0]   - Bist Done      - 1
		// [1]   - Bist Error     - 0
		// [2]   - Bist Correct   - 1
		// [3]   - Reserved       - 0
		// [7:4] - Bist Error Cnt - 4'h2
		faultaddr[0] = 9'h10;
		faultaddr[1] = 9'h20;
		faultaddr[2] = 9'h30;
		faultaddr[3] = 9'h40;
		insert_fault(2,0,0,0,0,32'h01010125);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-3.1: BIST Test with Two Address Failure at MEM0 Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-3.1: BIST Test with Two Address Failure at MEM0 Error insertion test Failed");
		end
		$display("##########################################################");
	    	$display(" MBIST Test with With Two Address Failure for MEM-0/1");
	    	$display("##########################################################");

		// Check Is there is any BIST Error
		// [0]   - Bist Done      - 1
		// [1]   - Bist Error     - 0
		// [2]   - Bist Correct   - 1
		// [3]   - Reserved       - 0
		// [7:4] - Bist Error Cnt - 4'h2
		faultaddr[0] = 9'h10;
		faultaddr[1] = 9'h20;
		faultaddr[2] = 9'h30;
		faultaddr[3] = 9'h40;
		insert_fault(2,2,0,0,0,32'h01012525);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-3.2: BIST Test with Two Address Failure at MEM0/1 Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-3.2: BIST Test with Two Address Failure at MEM0/1 Error insertion test Failed");
		end
		$display("##########################################################");
	    	$display(" MBIST Test with With Two Address Failure for MEM-0/1/2");
	    	$display("##########################################################");

		// Check Is there is any BIST Error
		// [0]   - Bist Done      - 1
		// [1]   - Bist Error     - 0
		// [2]   - Bist Correct   - 1
		// [3]   - Reserved       - 0
		// [7:4] - Bist Error Cnt - 4'h2
		faultaddr[0] = 9'h10;
		faultaddr[1] = 9'h20;
		faultaddr[2] = 9'h30;
		faultaddr[3] = 9'h40;
		insert_fault(2,2,2,0,0,32'h01252525);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-3.3: BIST Test with Two Address Failure at MEM0/1/2 Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-3.3: BIST Test with Two Address Failure at MEM0/1/2 Error insertion test Failed");
		end

	    	$display("###################################################");
	    	$display(" MBIST Test with Two Address Failure to All Memory");
	    	$display("###################################################");
		// Check Is there is any BIST Error
		// [0]   - Bist Done      - 1
		// [1]   - Bist Error     - 0
		// [2]   - Bist Correct   - 1
		// [3]   - Reserved       - 0
		// [7:4] - Bist Error Cnt - 4'h2
		   //if(read_data[6:0]  != 7'b0001101) test_fail = 1; // Bist correct = 1 and Bist Err Cnt - 0x1
		faultaddr[0] = 9'h10;
		faultaddr[1] = 9'h20;
		faultaddr[2] = 9'h30;
		faultaddr[3] = 9'h40;
		insert_fault(2,2,2,2,1,32'h25252525);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-3.4: BIST Test with Two Memory Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-3.4: BIST Test with Two Memory Error insertion test Failed");
		end
	    	$display("###################################################");

		$display("#########################################################");
	    	$display(" MBIST Test with With Three Address Failure for MEM-0");
	    	$display("#########################################################");

		// Check Is there is any BIST Error
		// [0]   - Bist Done      - 1
		// [1]   - Bist Error     - 0
		// [2]   - Bist Correct   - 1
		// [3]   - Reserved       - 0
		// [7:4] - Bist Error Cnt - 4'h3
		faultaddr[0] = 9'h10;
		faultaddr[1] = 9'h20;
		faultaddr[2] = 9'h30;
		faultaddr[3] = 9'h40;
		insert_fault(3,0,0,0,0,32'h01010135);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-4.1: BIST Test with Three Address Failure at MEM0 Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-4.1: BIST Test with Three Address Failure at MEM0 Error insertion test Failed");
		end
		$display("##########################################################");
	    	$display(" MBIST Test with With Three Address Failure for MEM-0/1");
	    	$display("##########################################################");

		// Check Is there is any BIST Error
		// [0]   - Bist Done      - 1
		// [1]   - Bist Error     - 0
		// [2]   - Bist Correct   - 1
		// [3]   - Reserved       - 0
		// [7:4] - Bist Error Cnt - 4'h3
		faultaddr[0] = 9'h10;
		faultaddr[1] = 9'h20;
		faultaddr[2] = 9'h30;
		faultaddr[3] = 9'h40;
		insert_fault(3,3,0,0,0,32'h01013535);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-4.2: BIST Test with Three Address Failure at MEM0/1 Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-4.2: BIST Test with Three Address Failure at MEM0/1 Error insertion test Failed");
		end
		$display("##########################################################");
	    	$display(" MBIST Test with With Three Address Failure for MEM-0/1/2");
	    	$display("##########################################################");

		// Check Is there is any BIST Error
		// [0]   - Bist Done      - 1
		// [1]   - Bist Error     - 0
		// [2]   - Bist Correct   - 1
		// [3]   - Reserved       - 0
		// [7:4] - Bist Error Cnt - 4'h3
		faultaddr[0] = 9'h10;
		faultaddr[1] = 9'h20;
		faultaddr[2] = 9'h30;
		faultaddr[3] = 9'h40;
		insert_fault(3,3,3,0,0,32'h01353535);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-4.3: BIST Test with Three Address Failure at MEM0/1/2 Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-4.3: BIST Test with Three Address Failure at MEM0/1/2 Error insertion test Failed");
		end

	    	$display("###################################################");
	    	$display(" MBIST Test with Three Address Failure to All Memory");
	    	$display("###################################################");
		   // Check Is there is any BIST Error
		   // [0]   - Bist Done      - 1
		   // [1]   - Bist Error     - 0
		   // [2]   - Bist Correct   - 1
		   // [3]   - Reserved       - 0
		   // [7:4] - Bist Error Cnt - 4'h3
		   //if(read_data[6:0]  != 7'b0001101) test_fail = 1; // Bist correct = 1 and Bist Err Cnt - 0x1
		faultaddr[0] = 9'h10;
		faultaddr[1] = 9'h20;
		faultaddr[2] = 9'h30;
		faultaddr[3] = 9'h40;
		insert_fault(3,3,3,3,1,32'h35353535);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-4.4: BIST Test with Three Memory Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-4.4: BIST Test with Three Memory Error insertion test Failed");
		end
	    	$display("###################################################");

		$display("#########################################################");
	    	$display(" MBIST Test with With Four Address Failure for MEM-0");
	    	$display("#########################################################");

		// Check Is there is any BIST Error
		// [0]   - Bist Done      - 1
		// [1]   - Bist Error     - 0
		// [2]   - Bist Correct   - 1
		// [3]   - Reserved       - 0
		// [7:4] - Bist Error Cnt - 4'h4
		faultaddr[0] = 9'h10;
		faultaddr[1] = 9'h20;
		faultaddr[2] = 9'h30;
		faultaddr[3] = 9'h40;
		insert_fault(4,0,0,0,0,32'h01010145);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-4.1: BIST Test with Four Address Failure at MEM0 Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-4.1: BIST Test with Four Address Failure at MEM0 Error insertion test Failed");
		end
		$display("##########################################################");
	    	$display(" MBIST Test with With Four Address Failure for MEM-0/1");
	    	$display("##########################################################");

		// Check Is there is any BIST Error
		// [0]   - Bist Done      - 1
		// [1]   - Bist Error     - 0
		// [2]   - Bist Correct   - 1
		// [3]   - Reserved       - 0
		// [7:4] - Bist Error Cnt - 4'h4
		faultaddr[0] = 9'h10;
		faultaddr[1] = 9'h20;
		faultaddr[2] = 9'h30;
		faultaddr[3] = 9'h40;
		insert_fault(4,4,0,0,0,32'h01014545);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-4.2: BIST Test with Four Address Failure at MEM0/1 Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-4.2: BIST Test with Four Address Failure at MEM0/1 Error insertion test Failed");
		end
		$display("##########################################################");
	    	$display(" MBIST Test with With Four Address Failure for MEM-0/1/2");
	    	$display("##########################################################");

		// Check Is there is any BIST Error
		// [0]   - Bist Done      - 1
		// [1]   - Bist Error     - 0
		// [2]   - Bist Correct   - 1
		// [3]   - Reserved       - 0
		// [7:4] - Bist Error Cnt - 4'h3
		faultaddr[0] = 9'h10;
		faultaddr[1] = 9'h20;
		faultaddr[2] = 9'h30;
		faultaddr[3] = 9'h40;
		insert_fault(4,4,4,0,0,32'h01454545);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-4.3: BIST Test with Four Address Failure at MEM0/1/2 Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-4.3: BIST Test with Four Address Failure at MEM0/1/2 Error insertion test Failed");
		end

	    	$display("###################################################");
	    	$display(" MBIST Test with Four Address Failure to All Memory");
	    	$display("###################################################");
		   // Check Is there is any BIST Error
		   // [0]   - Bist Done      - 1
		   // [1]   - Bist Error     - 0
		   // [2]   - Bist Correct   - 1
		   // [3]   - Reserved       - 0
		   // [7:4] - Bist Error Cnt - 4'h3
		   //if(read_data[6:0]  != 7'b0001101) test_fail = 1; // Bist correct = 1 and Bist Err Cnt - 0x1
		faultaddr[0] = 9'h10;
		faultaddr[1] = 9'h20;
		faultaddr[2] = 9'h30;
		faultaddr[3] = 9'h40;
		insert_fault(4,4,4,4,1,32'h45454545);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-4.4: BIST Test with Four Memory Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-4.4: BIST Test with Four Memory Error insertion test Failed");
		end
	    	$display("###################################################");


	    	$display("###################################################");
	    	$display(" MBIST Test with Fours Address(Continous Starting Addrsess) Failure");
	    	$display("###################################################");
		// Check Is there is any BIST Error
		// [0]   - Bist Done      - 1
		// [1]   - Bist Error     - 0
		// [2]   - Bist Correct   - 1
		// [3]   - Reserved       - 0
		// [7:4] - Bist Error Cnt - 4'h4
		//if(read_data[6:0]  != 7'b0100101) test_fail = 1; // Bist correct = 1 and Bist Err Cnt - 0x4
		faultaddr[0] = 9'h0;
		faultaddr[1] = 9'h1;
		faultaddr[2] = 9'h2;
		faultaddr[3] = 9'h3;
		insert_fault(4,4,4,4,0,32'h45454545);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-5.1: BIST Test with Four Memory Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-5.1: BIST Test with Four Memory Error insertion test Failed");
		end

	    	$display("###################################################");
	    	$display(" MBIST Test with Fours Address(Last Addrsess) Failure");
	    	$display("###################################################");
		// Check Is there is any BIST Error
		// [0]   - Bist Done      - 1
		// [1]   - Bist Error     - 0
		// [2]   - Bist Correct   - 1
		// [3]   - Reserved       - 0
		// [7:4] - Bist Error Cnt - 4'h4
		//if(read_data[6:0]  != 7'b0100101) test_fail = 1; // Bist correct = 1 and Bist Err Cnt - 0x4
		faultaddr[0] = 9'hF0;
		faultaddr[1] = 9'hF1;
		faultaddr[2] = 9'hF2;
		faultaddr[3] = 9'hF3;
		insert_fault(4,4,4,4,0,32'h45454545);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-5.2: BIST Test with Four Memory Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-5.2: BIST Test with Four Memory Error insertion test Failed");
		end
	    	
		$display("###################################################");
	    	$display(" MBIST Test with Five Address Failure for MEM0");
	    	$display("###################################################");
		// Check Is there is any BIST Error
		// [0]   - Bist Done      - 1
		// [1]   - Bist Error     - 1
		// [2]   - Bist Correct   - 1
		// [3]   - Reserved       - 0
		// [7:4] - Bist Error Cnt - 4'h4
		//if(read_data[6:0]  != 7'b0100101) test_fail = 1; // Bist correct = 1 and Bist Err Cnt - 0x4
		faultaddr[0] = 9'h10;
		faultaddr[1] = 9'h20;
		faultaddr[2] = 9'h30;
		faultaddr[3] = 9'h40;
		faultaddr[4] = 9'h50;
		insert_fault(5,0,0,0,1,32'h01010147);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-6.1: BIST Test with Five Memory Error insertion for MEM0 test Passed");
	        end else begin
	    	    $display("Monitor: Step-6.1: BIST Test with Five Memory Error insertion for MEM0 test Failed");
		 end

		$display("###################################################");
	    	$display(" MBIST Test with Five Address Failure for MEM0/1");
	    	$display("###################################################");
		// Check Is there is any BIST Error
		// [0]   - Bist Done      - 1
		// [1]   - Bist Error     - 1
		// [2]   - Bist Correct   - 1
		// [3]   - Reserved       - 0
		// [7:4] - Bist Error Cnt - 4'h4
		//if(read_data[6:0]  != 7'b0100101) test_fail = 1; // Bist correct = 1 and Bist Err Cnt - 0x4
		faultaddr[0] = 9'h10;
		faultaddr[1] = 9'h20;
		faultaddr[2] = 9'h30;
		faultaddr[3] = 9'h40;
		faultaddr[4] = 9'h50;
		insert_fault(5,5,0,0,1,32'h01014747);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-6.2: BIST Test with Five Memory Error insertion for MEM0/1 test Passed");
	        end else begin
	    	    $display("Monitor: Step-6.2: BIST Test with Five Memory Error insertion for MEM0/1 test Failed");
		 end

        	$display("###################################################");
	    	$display(" MBIST Test with Five Address Failure for MEM0/1/2");
	    	$display("###################################################");
		// Check Is there is any BIST Error
		// [0]   - Bist Done      - 1
		// [1]   - Bist Error     - 1
		// [2]   - Bist Correct   - 1
		// [3]   - Reserved       - 0
		// [7:4] - Bist Error Cnt - 4'h4
		//if(read_data[6:0]  != 7'b0100101) test_fail = 1; // Bist correct = 1 and Bist Err Cnt - 0x4
		faultaddr[0] = 9'h10;
		faultaddr[1] = 9'h20;
		faultaddr[2] = 9'h30;
		faultaddr[3] = 9'h40;
		faultaddr[4] = 9'h50;
		insert_fault(5,5,5,0,1,32'h01474747);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-6.3: BIST Test with Five Memory Error insertion for MEM0/1/2 test Passed");
	        end else begin
	    	    $display("Monitor: Step-6.3: BIST Test with Five Memory Error insertion for MEM0/1/2 test Failed");
		 end

	    	$display("###################################################");
	    	$display(" MBIST Test with Five Address Failure for All Memory");
	    	$display("###################################################");
		// Check Is there is any BIST Error
		// [0]   - Bist Done      - 1
		// [1]   - Bist Error     - 1
		// [2]   - Bist Correct   - 1
		// [3]   - Reserved       - 0
		// [7:4] - Bist Error Cnt - 4'h4
		//if(read_data[6:0]  != 7'b0100101) test_fail = 1; // Bist correct = 1 and Bist Err Cnt - 0x4
		faultaddr[0] = 9'h10;
		faultaddr[1] = 9'h20;
		faultaddr[2] = 9'h30;
		faultaddr[3] = 9'h40;
		faultaddr[4] = 9'h50;
		insert_fault(5,5,5,5,1,32'h47474747);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-6.4: BIST Test with Five Memory Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-6.4: BIST Test with Five Memory Error insertion test Failed");
		 end
		$dumpon;
	    	$display("###################################################");
	    	$display(" MBIST Test with Functional Access, continuation of previous MBIST Signature");
	    	$display("###################################################");
		fork
		begin
		    // Remove the Bist Enable and Bist Run
                    wb_user_core_write(`GLBL_BIST_CTRL1,'h000);
                    // Remove WB and BIST RESET
                    wb_user_core_write(`WB_GLBL_CTRL,'h081);
  
	            // Fill Random Data	
		    for (i=0; i< 9'h1FC; i=i+1) begin
   	                writemem[i] = $random;
                        wb_user_core_write(`MBIST1_FUNC_MAP+(i*4),writemem[i]);
                        wb_user_core_write(`MBIST2_FUNC_MAP+(i*4),writemem[i]);
                        wb_user_core_write(`MBIST3_FUNC_MAP+(i*4),writemem[i]);
                        wb_user_core_write(`MBIST4_FUNC_MAP+(i*4),writemem[i]);
		        //if(i < 9'h0FC) begin // SRAM5-SRAM8 are 1KB
                        //   wb_user_core_write(`MBIST5_FUNC_MAP+(i*4),writemem[i]);
                        //   wb_user_core_write(`MBIST6_FUNC_MAP+(i*4),writemem[i]);
                        //   wb_user_core_write(`MBIST7_FUNC_MAP+(i*4),writemem[i]);
                        //   wb_user_core_write(`MBIST8_FUNC_MAP+(i*4),writemem[i]);
	                //end
		    end
		    // Read back data
		    for (i=0; i< 9'h1FC; i=i+1) begin
                        wb_user_core_read_check(`MBIST1_FUNC_MAP+(i*4),read_data,writemem[i],32'hFFFFFFFF);
                        wb_user_core_read_check(`MBIST2_FUNC_MAP+(i*4),read_data,writemem[i],32'hFFFFFFFF);
                        wb_user_core_read_check(`MBIST3_FUNC_MAP+(i*4),read_data,writemem[i],32'hFFFFFFFF);
                        wb_user_core_read_check(`MBIST4_FUNC_MAP+(i*4),read_data,writemem[i],32'hFFFFFFFF);
		        //if(i < 9'h0FC) begin // SRAM5 - SRAM8 are 1KB
                        //   wb_user_core_read_check(`MBIST5_FUNC_MAP+(i*4),read_data,writemem[i],32'hFFFFFFFF);
                        //   wb_user_core_read_check(`MBIST6_FUNC_MAP+(i*4),read_data,writemem[i],32'hFFFFFFFF);
                        //   wb_user_core_read_check(`MBIST7_FUNC_MAP+(i*4),read_data,writemem[i],32'hFFFFFFFF);
                        //   wb_user_core_read_check(`MBIST8_FUNC_MAP+(i*4),read_data,writemem[i],32'hFFFFFFFF);
	                //end
		    end

		    // Cross-check Reducency address hold the failure address data
		    // Is last Error inserted address are 0x10,0x20,0x30,0x40
		    // So Address 0x1FC = Data[0x10], 0x1FD = Data[0x20]
		    //    Address 0x1FE = Data[0x30], 0x1FF = Data[0x40]
		    // Check 2kb SRAM1
                    wb_user_core_read_check(`MBIST1_FUNC_MAP + (9'h1FC *4),read_data,writemem[9'h10],32'hFFFFFFFF);
                    wb_user_core_read_check(`MBIST1_FUNC_MAP + (9'h1FD *4),read_data,writemem[9'h20],32'hFFFFFFFF);
                    wb_user_core_read_check(`MBIST1_FUNC_MAP + (9'h1FE *4),read_data,writemem[9'h30],32'hFFFFFFFF);
                    wb_user_core_read_check(`MBIST1_FUNC_MAP + (9'h1FF *4),read_data,writemem[9'h40],32'hFFFFFFFF);

		    // Check 2kb SRAM2
                    wb_user_core_read_check(`MBIST2_FUNC_MAP + (9'h1FC *4),read_data,writemem[9'h11],32'hFFFFFFFF);
                    wb_user_core_read_check(`MBIST2_FUNC_MAP + (9'h1FD *4),read_data,writemem[9'h21],32'hFFFFFFFF);
                    wb_user_core_read_check(`MBIST2_FUNC_MAP + (9'h1FE *4),read_data,writemem[9'h31],32'hFFFFFFFF);
                    wb_user_core_read_check(`MBIST2_FUNC_MAP + (9'h1FF *4),read_data,writemem[9'h41],32'hFFFFFFFF);

		    //// Check 2kb SRAM3
                    wb_user_core_read_check(`MBIST3_FUNC_MAP + (9'h1FC *4),read_data,writemem[9'h12],32'hFFFFFFFF);
                    wb_user_core_read_check(`MBIST3_FUNC_MAP + (9'h1FD *4),read_data,writemem[9'h22],32'hFFFFFFFF);
                    wb_user_core_read_check(`MBIST3_FUNC_MAP + (9'h1FE *4),read_data,writemem[9'h32],32'hFFFFFFFF);
                    wb_user_core_read_check(`MBIST3_FUNC_MAP + (9'h1FF *4),read_data,writemem[9'h42],32'hFFFFFFFF);

		    //// Check 2kb SRAM4
                    wb_user_core_read_check(`MBIST4_FUNC_MAP + (9'h1FC *4),read_data,writemem[9'h13],32'hFFFFFFFF);
                    wb_user_core_read_check(`MBIST4_FUNC_MAP + (9'h1FD *4),read_data,writemem[9'h23],32'hFFFFFFFF);
                    wb_user_core_read_check(`MBIST4_FUNC_MAP + (9'h1FE *4),read_data,writemem[9'h33],32'hFFFFFFFF);
                    wb_user_core_read_check(`MBIST4_FUNC_MAP + (9'h1FF *4),read_data,writemem[9'h43],32'hFFFFFFFF);

		    //// Check 1kb SRAM5
                    //wb_user_core_read_check(`MBIST5_FUNC_MAP + (8'hFC *4),read_data,writemem[9'h14],32'hFFFFFFFF);
                    //wb_user_core_read_check(`MBIST5_FUNC_MAP + (8'hFD *4),read_data,writemem[9'h24],32'hFFFFFFFF);
                    //wb_user_core_read_check(`MBIST5_FUNC_MAP + (8'hFE *4),read_data,writemem[9'h34],32'hFFFFFFFF);
                    //wb_user_core_read_check(`MBIST5_FUNC_MAP + (8'hFF *4),read_data,writemem[9'h44],32'hFFFFFFFF);

		    //// Check 1kb SRAM6
                    //wb_user_core_read_check(`MBIST6_FUNC_MAP + (8'hFC *4),read_data,writemem[9'h15],32'hFFFFFFFF);
                    //wb_user_core_read_check(`MBIST6_FUNC_MAP + (8'hFD *4),read_data,writemem[9'h25],32'hFFFFFFFF);
                    //wb_user_core_read_check(`MBIST6_FUNC_MAP + (8'hFE *4),read_data,writemem[9'h35],32'hFFFFFFFF);
                    //wb_user_core_read_check(`MBIST6_FUNC_MAP + (8'hFF *4),read_data,writemem[9'h45],32'hFFFFFFFF);

		    //// Check 1kb SRAM7
                    //wb_user_core_read_check(`MBIST7_FUNC_MAP + (8'hFC *4),read_data,writemem[9'h16],32'hFFFFFFFF);
                    //wb_user_core_read_check(`MBIST7_FUNC_MAP + (8'hFD *4),read_data,writemem[9'h26],32'hFFFFFFFF);
                    //wb_user_core_read_check(`MBIST7_FUNC_MAP + (8'hFE *4),read_data,writemem[9'h36],32'hFFFFFFFF);
                    //wb_user_core_read_check(`MBIST7_FUNC_MAP + (8'hFF *4),read_data,writemem[9'h46],32'hFFFFFFFF);

		    //// Check 1kb SRAM8
                    //wb_user_core_read_check(`MBIST8_FUNC_MAP + (8'hFC *4),read_data,writemem[9'h17],32'hFFFFFFFF);
                    //wb_user_core_read_check(`MBIST8_FUNC_MAP + (8'hFD *4),read_data,writemem[9'h27],32'hFFFFFFFF);
                    //wb_user_core_read_check(`MBIST8_FUNC_MAP + (8'hFE *4),read_data,writemem[9'h37],32'hFFFFFFFF);
                    //wb_user_core_read_check(`MBIST8_FUNC_MAP + (8'hFF *4),read_data,writemem[9'h47],32'hFFFFFFFF);
                end
                begin
                   // Loop for BIST TimeOut
                   repeat (200000) @(posedge clock);
                		// $display("+1000 cycles");
                   test_fail = 1;
                end
                join_any
                disable fork; //disable pending fork activity
          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-7: BIST Test with Functional access test Passed");
	        end else begin
	    	    $display("Monitor: Step-7: BIST Test with Functional access test failed");
		 end

	    	$display("###################################################");
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


//-------------------------------------
// Insert user defined number of fault 
// -----------------------------------

task insert_fault;
input [3:0]  num0_fault;
input [3:0]  num1_fault;
input [3:0]  num2_fault;
input [3:0]  num3_fault;
input        fault_type; // 0 -> struck at 0 and 1 -> struck at 1
input [31:0]  mbist_signature;
reg [31:0] datain;
reg [8:0]  fail_addr1;
reg [8:0]  fail_addr2;
reg [8:0]  fail_addr3;
reg [8:0]  fail_addr4;
reg [3:0]  num_fault[0:3];
integer j;
begin
   num_fault[0] = num0_fault;
   num_fault[1] = num1_fault;
   num_fault[2] = num2_fault;
   num_fault[3] = num3_fault;
   repeat (2) @(posedge clock);
   fork
   begin
       // Remove the Bist Enable and Bist Run
       wb_user_core_write(`GLBL_BIST_CTRL1,'h000);
       // Remove WB and BIST RESET
       wb_user_core_write(`WB_GLBL_CTRL,'h001);
       // Set the Bist Enable and Bist Run
       wb_user_core_write(`GLBL_BIST_CTRL1,'h00000003);
       // Remove WB and BIST RESET
       wb_user_core_write(`WB_GLBL_CTRL,'h081);
      // Check for MBIST Done
      read_data = 'h0;
      while (read_data[0] != 1'b1) begin
         wb_user_core_read(`GLBL_BIST_STAT1,read_data);
      end
      // wait for some time for all the BIST to complete
      repeat (1000) @(posedge clock);
      // Toggle the Bist Load for update the shift data
      wb_user_core_write(`GLBL_BIST_CTRL1,'h00000004);
      wb_user_core_write(`GLBL_BIST_CTRL1,'h00000000);
      // Check Is there is any BIST Error
      // [0]   - Bist Done      
      // [1]   - Bist Error     
      // [2]   - Bist Correct   
      // [3]   - Reserved
      // [7:4] - Bist Error Cnt 
      wb_user_core_read_check(`GLBL_BIST_STAT1,read_data,mbist_signature[31:0],32'hFFFFFFFF);
      //wb_user_core_read_check(`GLBL_BIST_STAT2,read_data,mbist_signature[63:32],32'hFFFFFFFF);
   end
   // Insert  Error Insertion
   begin
      while(1) begin
         repeat (1) @(posedge clock);
         #1;

         if(u_top.u_sram0_2kb.web0 == 1'b0 && 
	   ((num_fault[0] > 0 && u_top.u_sram0_2kb.addr0 == faultaddr[0]) ||
	    (num_fault[0] > 1 && u_top.u_sram0_2kb.addr0 == faultaddr[1]) ||
	    (num_fault[0] > 2 && u_top.u_sram0_2kb.addr0 == faultaddr[2]) ||
	    (num_fault[0] > 3 && u_top.u_sram0_2kb.addr0 == faultaddr[3]) ||
	    (num_fault[0] > 4 && u_top.u_sram0_2kb.addr0 == faultaddr[4]) ||
	    (num_fault[0] > 5 && u_top.u_sram0_2kb.addr0 == faultaddr[5]) ||
	    (num_fault[0] > 6 && u_top.u_sram0_2kb.addr0 == faultaddr[6]) ||
	    (num_fault[0] > 7 && u_top.u_sram0_2kb.addr0 == faultaddr[7])))
             begin
	   if(fault_type == 0) // Struck at 0
	      force u_top.u_sram0_2kb.din0 = u_top.mem0_din_a  & 32'hFFFF_FFFE;
	   else
	      force u_top.u_sram0_2kb.din0 = u_top.mem0_din_a | 32'h1;
   	   -> error_insert;
         end else begin
            release u_top.u_sram0_2kb.din0;
         end

         if(u_top.u_sram1_2kb.web0 == 1'b0 && 
	   ((num_fault[1] > 0 && u_top.u_sram1_2kb.addr0 == faultaddr[0]+1) ||
	    (num_fault[1] > 1 && u_top.u_sram1_2kb.addr0 == faultaddr[1]+1) ||
	    (num_fault[1] > 2 && u_top.u_sram1_2kb.addr0 == faultaddr[2]+1) ||
	    (num_fault[1] > 3 && u_top.u_sram1_2kb.addr0 == faultaddr[3]+1) ||
	    (num_fault[1] > 4 && u_top.u_sram1_2kb.addr0 == faultaddr[4]+1) ||
	    (num_fault[1] > 5 && u_top.u_sram1_2kb.addr0 == faultaddr[5]+1) ||
	    (num_fault[1] > 6 && u_top.u_sram1_2kb.addr0 == faultaddr[6]+1) ||
	    (num_fault[1] > 7 && u_top.u_sram1_2kb.addr0 == faultaddr[7]+1)))
             begin
	   if(fault_type == 0) // Struck at 0
	      force u_top.u_sram1_2kb.din0 = u_top.mem1_din_a  & 32'hFFFF_FFFE;
	   else
	      force u_top.u_sram1_2kb.din0 = u_top.mem1_din_a | 32'h1;
   	   -> error_insert;
         end else begin
            release u_top.u_sram1_2kb.din0;
         end

         if(u_top.u_sram2_2kb.web0 == 1'b0 && 
	   ((num_fault[2] > 0 && u_top.u_sram2_2kb.addr0 == faultaddr[0]+2) ||
	    (num_fault[2] > 1 && u_top.u_sram2_2kb.addr0 == faultaddr[1]+2) ||
	    (num_fault[2] > 2 && u_top.u_sram2_2kb.addr0 == faultaddr[2]+2) ||
	    (num_fault[2] > 3 && u_top.u_sram2_2kb.addr0 == faultaddr[3]+2) ||
	    (num_fault[2] > 4 && u_top.u_sram2_2kb.addr0 == faultaddr[4]+2) ||
	    (num_fault[2] > 5 && u_top.u_sram2_2kb.addr0 == faultaddr[5]+2) ||
	    (num_fault[2] > 6 && u_top.u_sram2_2kb.addr0 == faultaddr[6]+2) ||
	    (num_fault[2] > 7 && u_top.u_sram2_2kb.addr0 == faultaddr[7]+2)))
             begin
	   if(fault_type == 0) // Struck at 0
	      force u_top.u_sram2_2kb.din0 = u_top.mem2_din_a  & 32'hFFFF_FFFE;
	   else
	      force u_top.u_sram2_2kb.din0 = u_top.mem2_din_a | 32'h1;
   	   -> error_insert;
         end else begin
            release u_top.u_sram2_2kb.din0;
         end

         if(u_top.u_sram3_2kb.web0 == 1'b0 && 
	   ((num_fault[3] > 0 && u_top.u_sram3_2kb.addr0 == faultaddr[0]+3) ||
	    (num_fault[3] > 1 && u_top.u_sram3_2kb.addr0 == faultaddr[1]+3) ||
	    (num_fault[3] > 2 && u_top.u_sram3_2kb.addr0 == faultaddr[2]+3) ||
	    (num_fault[3] > 3 && u_top.u_sram3_2kb.addr0 == faultaddr[3]+3) ||
	    (num_fault[3] > 4 && u_top.u_sram3_2kb.addr0 == faultaddr[4]+3) ||
	    (num_fault[3] > 5 && u_top.u_sram3_2kb.addr0 == faultaddr[5]+3) ||
	    (num_fault[3] > 6 && u_top.u_sram3_2kb.addr0 == faultaddr[6]+3) ||
	    (num_fault[3] > 7 && u_top.u_sram3_2kb.addr0 == faultaddr[7]+3)))
             begin
	   if(fault_type == 0) // Struck at 0
	      force u_top.u_sram3_2kb.din0 = u_top.mem3_din_a  & 32'hFFFF_FFFE;
	   else
	      force u_top.u_sram3_2kb.din0 = u_top.mem3_din_a | 32'h1;
   	   -> error_insert;
         end else begin
            release u_top.u_sram3_2kb.din0;
         end

         //if(u_top.u_sram5_1kb.web0 == 1'b0 && 
	 //  ((num_fault > 0 && u_top.u_sram5_1kb.addr0 == faultaddr[0]+4) ||
	 //   (num_fault > 1 && u_top.u_sram5_1kb.addr0 == faultaddr[1]+4) ||
	 //   (num_fault > 2 && u_top.u_sram5_1kb.addr0 == faultaddr[2]+4) ||
	 //   (num_fault > 3 && u_top.u_sram5_1kb.addr0 == faultaddr[3]+4) ||
	 //   (num_fault > 4 && u_top.u_sram5_1kb.addr0 == faultaddr[4]+4) ||
	 //   (num_fault > 5 && u_top.u_sram5_1kb.addr0 == faultaddr[5]+4) ||
	 //   (num_fault > 6 && u_top.u_sram5_1kb.addr0 == faultaddr[6]+4) ||
	 //   (num_fault > 7 && u_top.u_sram5_1kb.addr0 == faultaddr[7]+4)))
         //    begin
	 //  if(fault_type == 0) // Struck at 0
	 //     force u_top.u_sram5_1kb.din0 = u_top.mem5_din_b  & 32'hFFFF_FFFE;
	 //  else
	 //     force u_top.u_sram5_1kb.din0 = u_top.mem5_din_b | 32'h1;
   	 //  -> error_insert;
         //end else begin
         //   release u_top.u_sram5_1kb.din0;
         //end

         //if(u_top.u_sram6_1kb.web0 == 1'b0 && 
	 //  ((num_fault > 0 && u_top.u_sram6_1kb.addr0 == faultaddr[0]+5) ||
	 //   (num_fault > 1 && u_top.u_sram6_1kb.addr0 == faultaddr[1]+5) ||
	 //   (num_fault > 2 && u_top.u_sram6_1kb.addr0 == faultaddr[2]+5) ||
	 //   (num_fault > 3 && u_top.u_sram6_1kb.addr0 == faultaddr[3]+5) ||
	 //   (num_fault > 4 && u_top.u_sram6_1kb.addr0 == faultaddr[4]+5) ||
	 //   (num_fault > 5 && u_top.u_sram6_1kb.addr0 == faultaddr[5]+5) ||
	 //   (num_fault > 6 && u_top.u_sram6_1kb.addr0 == faultaddr[6]+5) ||
	 //   (num_fault > 7 && u_top.u_sram6_1kb.addr0 == faultaddr[7]+5)))
         //    begin
	 //  if(fault_type == 0) // Struck at 0
	 //     force u_top.u_sram6_1kb.din0 = u_top.mem6_din_b  & 32'hFFFF_FFFE;
	 //  else
	 //     force u_top.u_sram6_1kb.din0 = u_top.mem6_din_b | 32'h1;
   	 //  -> error_insert;
         //end else begin
         //   release u_top.u_sram6_1kb.din0;
         //end

         //if(u_top.u_sram7_1kb.web0 == 1'b0 && 
	 //  ((num_fault > 0 && u_top.u_sram7_1kb.addr0 == faultaddr[0]+6) ||
	 //   (num_fault > 1 && u_top.u_sram7_1kb.addr0 == faultaddr[1]+6) ||
	 //   (num_fault > 2 && u_top.u_sram7_1kb.addr0 == faultaddr[2]+6) ||
	 //   (num_fault > 3 && u_top.u_sram7_1kb.addr0 == faultaddr[3]+6) ||
	 //   (num_fault > 4 && u_top.u_sram7_1kb.addr0 == faultaddr[4]+6) ||
	 //   (num_fault > 5 && u_top.u_sram7_1kb.addr0 == faultaddr[5]+6) ||
	 //   (num_fault > 6 && u_top.u_sram7_1kb.addr0 == faultaddr[6]+6) ||
	 //   (num_fault > 7 && u_top.u_sram7_1kb.addr0 == faultaddr[7]+6)))
         //    begin
	 //  if(fault_type == 0) // Struck at 0
	 //     force u_top.u_sram7_1kb.din0 = u_top.mem7_din_b  & 32'hFFFF_FFFE;
	 //  else
	 //     force u_top.u_sram7_1kb.din0 = u_top.mem7_din_b | 32'h1;
   	 //  -> error_insert;
         //end else begin
         //   release u_top.u_sram7_1kb.din0;
         //end

         //if(u_top.u_sram8_1kb.web0 == 1'b0 && 
	 //  ((num_fault > 0 && u_top.u_sram8_1kb.addr0 == faultaddr[0]+7) ||
	 //   (num_fault > 1 && u_top.u_sram8_1kb.addr0 == faultaddr[1]+7) ||
	 //   (num_fault > 2 && u_top.u_sram8_1kb.addr0 == faultaddr[2]+7) ||
	 //   (num_fault > 3 && u_top.u_sram8_1kb.addr0 == faultaddr[3]+7) ||
	 //   (num_fault > 4 && u_top.u_sram8_1kb.addr0 == faultaddr[4]+7) ||
	 //   (num_fault > 5 && u_top.u_sram8_1kb.addr0 == faultaddr[5]+7) ||
	 //   (num_fault > 6 && u_top.u_sram8_1kb.addr0 == faultaddr[6]+7) ||
	 //   (num_fault > 7 && u_top.u_sram8_1kb.addr0 == faultaddr[7]+7)))
         //    begin
	 //  if(fault_type == 0) // Struck at 0
	 //     force u_top.u_sram8_1kb.din0 = u_top.mem8_din_b  & 32'hFFFF_FFFE;
	 //  else
	 //     force u_top.u_sram8_1kb.din0 = u_top.mem8_din_b | 32'h1;
   	 //  -> error_insert;
         //end else begin
         //   release u_top.u_sram8_1kb.din0;
         //end

      end
   end
   begin
      // Loop for BIST TimeOut
      repeat (200000) @(posedge clock);
   		// $display("+1000 cycles");
      test_fail = 1;
   end
   join_any
   disable fork; //disable pending fork activity

   // Read Back the Failure Address and cross-check all the 8 MBIST
   // Read Signature is comming is reverse order, MBIST4 => MBIST3 => MBIST2
   for(j=`NO_SRAM; j > 0; j=j-1) begin
      fail_addr1 = faultaddr[0]+j-1;
      fail_addr2 = faultaddr[1]+j-1;
      fail_addr3 = faultaddr[2]+j-1;
      fail_addr4 = faultaddr[3]+j-1;

      if(num_fault[j-1] == 1) begin
          wb_user_core_read_check(`GLBL_BIST_SRDATA,read_data,{32'h0},32'hFFFF_FFFF);
          wb_user_core_read_check(`GLBL_BIST_SRDATA,read_data,{7'h0,fail_addr1,16'h0},32'hFFFF_FFFF);
      end else if(num_fault[j-1] == 2) begin
          wb_user_core_read_check(`GLBL_BIST_SRDATA,read_data,{32'h0},32'hFFFF_FFFF);
          wb_user_core_read_check(`GLBL_BIST_SRDATA,read_data,{7'h0,fail_addr1,7'h0,fail_addr2},32'hFFFF_FFFF);
     end else if(num_fault[j-1] == 3) begin
          wb_user_core_read_check(`GLBL_BIST_SRDATA,read_data,{7'h0,fail_addr3,16'h0},32'hFFFF_FFFF);
          wb_user_core_read_check(`GLBL_BIST_SRDATA,read_data,{7'h0,fail_addr1,7'h0,fail_addr2},32'hFFFF_FFFF);
      end else if(num_fault[j-1] >= 4) begin
          wb_user_core_read_check(`GLBL_BIST_SRDATA,read_data,{7'h0,fail_addr3,7'h0,fail_addr4},32'hFFFF_FFFF);
          wb_user_core_read_check(`GLBL_BIST_SRDATA,read_data,{7'h0,fail_addr1,7'h0,fail_addr2},32'hFFFF_FFFF);
      end else begin
          wb_user_core_read_check(`GLBL_BIST_SRDATA,read_data,32'h0,32'hFFFF_FFFF);
          wb_user_core_read_check(`GLBL_BIST_SRDATA,read_data,32'h0,32'hFFFF_FFFF);
      end
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
  $display("STATUS: WB USER ACCESS WRITE Address : 0x%x, Data : 0x%x",address,data);
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
  #1;
  data  = wbd_ext_dat_o;  
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_cyc_i ='h0;  // strobe/request
  wbd_ext_stb_i ='h0;  // strobe/request
  wbd_ext_adr_i ='h0;  // address
  wbd_ext_we_i  ='h0;  // write
  wbd_ext_dat_i ='h0;  // data output
  wbd_ext_sel_i ='h0;  // byte enable
  //$display("STATUS: WB USER ACCESS READ  Address : 0x%x, Data : 0x%x",address,data);
  repeat (2) @(posedge clock);
end
endtask

task  wb_user_core_read_check;
input [31:0] address;
output [31:0] data;
input [31:0] cmp_data;
input [31:0] cmp_mask;
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
  #1;
  data  = wbd_ext_dat_o;  
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_cyc_i ='h0;  // strobe/request
  wbd_ext_stb_i ='h0;  // strobe/request
  wbd_ext_adr_i ='h0;  // address
  wbd_ext_we_i  ='h0;  // write
  wbd_ext_dat_i ='h0;  // data output
  wbd_ext_sel_i ='h0;  // byte enable
  if((data & cmp_mask) !== (cmp_data & cmp_mask) ) begin
     $display("ERROR : WB USER ACCESS READ  Address : 0x%x, Exd: 0x%x Rxd: 0x%x ",address,(cmp_data & cmp_mask),(data & cmp_mask));
     test_fail = 1;
  end else begin
     $display("STATUS: WB USER ACCESS READ  Address : 0x%x, Data : 0x%x",address,(data & cmp_mask));
  end
  repeat (2) @(posedge clock);
end
endtask


endmodule
`default_nettype wire
