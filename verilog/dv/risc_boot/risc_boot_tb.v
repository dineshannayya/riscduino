//////////////////////////////////////////////////////////////////////
////                                                              ////
////  User Risc Core Boot Validation                              ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
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

`include "uprj_netlists.v"
`include "caravel_netlists.v"
`include "spiflash.v"
`include "mt48lc8m8a2.v"

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
           //$dumpvars(2,risc_boot_tb.uut);
           $dumpvars(4,risc_boot_tb.uut.mprj.u_core);
           //$dumpvars(0,risc_boot_tb.u_user_spiflash);
	   $display("Waveform Dump started");
        end
        `endif

	initial begin

		// Repeat cycles of 1000 clock edges as needed to complete testbench
		repeat (200) begin
			repeat (1000) @(posedge clock);
			// $display("+1000 cycles");
		end
		$display("%c[1;31m",27);
		`ifdef GL
			$display ("Monitor: Timeout, Test user Risc Boot (GL) Failed");
		`else
			$display ("Monitor: Timeout, Test user Risc Boot (RTL) Failed");
		`endif
		$display("%c[0m",27);
		$finish;
	end

	initial begin
	   wait(checkbits == 16'h AB60);
		$display("Monitor: Test User Risc Boot Started");
		wait(checkbits == 16'h AB61);
	    	$display("#############################################");
		`ifdef GL
	    	$display("Monitor: Test User Risc Boot (GL) Passed");
		`else
		    $display("Monitor: Test User Risc Boot (RTL) Passed");
		`endif
	    	$display("#############################################");
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

   wire user_flash_clk = mprj_io[30];
   wire user_flash_csb = mprj_io[31];
   //tri  user_flash_io0 = mprj_io[33];
   //tri  user_flash_io1 = mprj_io[34];
   //tri  user_flash_io2 = mprj_io[35];
   //tri  user_flash_io3 = mprj_io[36];

   // Quard flash
	spiflash #(
		.FILENAME("user_risc_boot.hex")
	) u_user_spiflash (
		.csb(user_flash_csb),
		.clk(user_flash_clk),
		.io0(mprj_io[32]),
		.io1(mprj_io[33]),
		.io2(mprj_io[34]),
		.io3(mprj_io[35])	
	);


//------------------------------------------------
// Integrate the SDRAM 8 BIT Memory
// -----------------------------------------------

tri [7:0]    Dq                  ; // SDRAM Read/Write Data Bus
wire [0:0]    sdr_dqm            ; // SDRAM DATA Mask
wire [1:0]    sdr_ba             ; // SDRAM Bank Select
wire [12:0]   sdr_addr           ; // SDRAM ADRESS
wire          sdr_cs_n           ; // chip select
wire          sdr_cke            ; // clock gate
wire          sdr_ras_n          ; // ras
wire          sdr_cas_n          ; // cas
wire          sdr_we_n           ; // write enable        
wire          sdram_clk         ;      

//assign  Dq[7:0]           =    mprj_io [7:0];
assign  sdr_addr[12:0]    =    mprj_io [20:8]     ;
assign  sdr_ba[1:0]       =    mprj_io [22:21]    ;
assign  sdr_dqm[0]        =    mprj_io [23]       ;
assign  sdr_we_n          =    mprj_io [24]       ;
assign  sdr_cas_n         =    mprj_io [25]       ;
assign  sdr_ras_n         =    mprj_io [26]       ;
assign  sdr_cs_n          =    mprj_io [27]       ;
assign  sdr_cke           =    mprj_io [28]       ;
assign  sdram_clk         =    mprj_io [29]       ;

// to fix the sdram interface timing issue
wire #(2.0) sdram_clk_d   = sdram_clk;

	// SDRAM 8bit
mt48lc8m8a2 #(.data_bits(8)) u_sdram8 (
          .Dq                 (mprj_io [7:0]      ) , 
          .Addr               (sdr_addr[11:0]     ), 
          .Ba                 (sdr_ba             ), 
          .Clk                (sdram_clk_d        ), 
          .Cke                (sdr_cke            ), 
          .Cs_n               (sdr_cs_n           ), 
          .Ras_n              (sdr_ras_n          ), 
          .Cas_n              (sdr_cas_n          ), 
          .We_n               (sdr_we_n           ), 
          .Dqm                (sdr_dqm            )
     );



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
