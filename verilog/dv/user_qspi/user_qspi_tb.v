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
////   Digital core flash access through External WB i/F.         ////
////   1.  Check SPI Read Identification                          ////
////   2.  Check the Direct Memory Read (Qual/Single/Quad)        ////        
////   3.  Direct SPI Memory Prefetch - 3DW                       ////
////   4.  Direct SPI Memory Prefetch - 2DW                       ////
////   5.  Direct SPI Memory Prefetch - 1DW                       ////
////   6.  Direct SPI Memory Prefetch - 7DW                       ////
////   7.  1DW  Indirect Read                                     ////
////   8.  2DW  Indirect Read                                     ////
////   9.  3DW  Indirect Read                                     ////
////   10. 4DW  Indirect Read                                     ////
////   11. 5DW  Indirect Read                                     ////
////   12. 8DW  Indirect Read                                     ////
////   13. Sector Erase command + Page Write & Read Back          ////
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

`timescale 1 ns/1 ps

`include "sram_macros/sky130_sram_2kbyte_1rw1r_32x512_8.v"
`include "is62wvs1288.v"

module user_qspi_tb;
parameter real CLK1_PERIOD  = 20; // 50Mhz
parameter real CLK2_PERIOD = 2.5;
parameter real IPLL_PERIOD = 5.008;
parameter real XTAL_PERIOD = 6;

`include "user_tasks.sv"

/*************************************************************
*  SPI FSM State Control
*
*   OPERATION   COMMAND                   SEQUENCE 
*
*    ERASE       P4E(0x20)           ->  COMMAND + ADDRESS
*    ERASE       P8E(0x40)           ->  COMMAND + ADDRESS
*    ERASE       SE(0xD8)            ->  COMMAND + ADDRESS
*    ERASE       BE(0x60)            ->  COMMAND + ADDRESS
*    ERASE       BE(0xC7)            ->  COMMAND 
*    PROGRAM     PP(0x02)            ->  COMMAND + ADDRESS + Write DATA
*    PROGRAM     QPP(0x32)           ->  COMMAND + ADDRESS + Write DATA
*    READ        READ(0x3)           ->  COMMAND + ADDRESS + READ DATA
*    READ        FAST_READ(0xB)      ->  COMMAND + ADDRESS + DUMMY + READ DATA
*    READ        DOR (0x3B)          ->  COMMAND + ADDRESS + DUMMY + READ DATA
*    READ        QOR (0x6B)          ->  COMMAND + ADDRESS + DUMMY + READ DATA
*    READ        DIOR (0xBB)         ->  COMMAND + ADDRESS + MODE  + READ DATA
*    READ        QIOR (0xEB)         ->  COMMAND + ADDRESS + MODE  + DUMMY + READ DATA
*    READ        RDID (0x9F)         ->  COMMAND + READ DATA
*    READ        READ_ID (0x90)      ->  COMMAND + ADDRESS + READ DATA
*    WRITE       WREN(0x6)           ->  COMMAND
*    WRITE       WRDI                ->  COMMAND
*    STATUS      RDSR(0x05)          ->  COMMAND + READ DATA
*    STATUS      RCR(0x35)           ->  COMMAND + READ DATA
*    CONFIG      WRR(0x01)           ->  COMMAND + WRITE DATA
*    CONFIG      CLSR(0x30)          ->  COMMAND
*    Power Saving DP(0xB9)           ->  COMMAND
*    Power Saving RES(0xAB)          ->  COMMAND + READ DATA
*    OTP          OTPP(0x42)         ->  COMMAND + ADDR+ WRITE DATA
*    OTP          OTPR(0x4B)         ->  COMMAND + ADDR + DUMMY + READ DATA
*    ********************************************************************/
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


	`ifdef WFDUMP
	   initial begin
	   	$dumpfile("simx.vcd");
	   	$dumpvars(5, user_qspi_tb);
	   end
       `endif

	initial begin
		$dumpon;
        init();

		#200; // Wait for reset removal
	    repeat (10) @(posedge clock);
		$display("Monitor: Standalone User Risc Boot Test Started");

		// Remove Wb Reset
		wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,'h1);

        // Enable QSPI DCG
		wb_user_core_write(`ADDR_SPACE_WBI+`WBI_CFG_DCG,'h01);

	        repeat (2) @(posedge clock);
		#1;
		// Enable SPI Reset
        wb_user_core_read(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG0,read_data);
        read_data = read_data | 8'h02;
        wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG0,read_data);

        wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h0000); // Change the Bank Sel 0000


		test_fail = 0;
	    repeat (200) @(posedge clock);
        wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 1000

        if(u_top.u_qspi_master.strap_sram) begin // if the SRAM STRAP in QUAD Mode, then send reset command to switch to SINGLE PHASE
		   wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0000,P_MODE_SWITCH_IDLE,P_QUAD,P_QUAD,4'b0100});
		   wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'h0,2'b00,2'b00,P_FSM_C,8'h00,8'hFF});
		   wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h0);
        end
		// CS#2 SSPI Indirect RAM READ ACCESS-
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0000,P_MODE_SWITCH_IDLE,P_SINGLE,P_SINGLE,4'b0100});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'h4,2'b00,2'b10,P_FSM_CADR,8'h00,8'h03});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000000);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h03020100);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000004);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h07060504);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000008);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h0b0a0908);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h0000000C);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h0f0e0d0c);

		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000200);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h11111111);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000204);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h22222222);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000208);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h33333333);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h0000020C);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h44444444);

		// CS#2 SSPI Indiect Write DATA
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0000,P_MODE_SWITCH_IDLE,P_SINGLE,P_SINGLE,4'b0100});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'h10,2'b00,2'b10,P_FSM_CAW,8'h00,8'h02});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000000);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00112233);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h44556677);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h8899AABB);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'hCCDDEEFF);
		
		// CS#2 SSPI Indirect READ DATA
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0000,P_MODE_SWITCH_IDLE,P_SINGLE,P_SINGLE,4'b0100});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'h10,2'b00,2'b10,P_FSM_CADR,8'h00,8'h03});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000000);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00112233);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h44556677);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h8899AABB);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'hCCDDEEFF);


		// CS#2 Switch to QSPI Mode
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0000,P_MODE_SWITCH_IDLE,P_SINGLE,P_SINGLE,4'b0100});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'h0,2'b00,2'b00,P_FSM_C,8'h00,8'h38});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h0);


		// CS#2 QUAD Indirect Write DATA
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0000,P_MODE_SWITCH_IDLE,P_QUAD,P_QUAD,4'b0100});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'h10,2'b00,2'b10,P_FSM_CAW,8'h00,8'h02});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000000);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h01234557);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h89ABCDEF);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h12345678);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h9ABCDEF0);


		// CS#2 QUAD Indirect READ DATA
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0000,P_MODE_SWITCH_IDLE,P_QUAD,P_QUAD,4'b0100});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'h10,2'b00,2'b10,P_FSM_CADR,8'h00,8'h03});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000000);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h01234557);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h89ABCDEF);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h12345678);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h9ABCDEF0);

		// CS#2 Switch From QSPI to SSPI Mode
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0000,P_MODE_SWITCH_IDLE,P_QUAD,P_QUAD,4'b0100});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'h0,2'b00,2'b00,P_FSM_C,8'h00,8'hFF});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h0);
		///////////////////// End of CS#1 Indirect Memory Access Testing ///////////////////////////////////

		$display("#############################################");
		$display("  Read Identification (RDID:0x9F)            ");
		$display("#############################################");
                wb_user_core_write(`ADDR_SPACE_QSPI+`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 1000
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0000,2'b00,P_SINGLE,P_SINGLE,4'b0001});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'h4,2'b00,2'b00,P_FSM_CR,8'h00,8'h9F});
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00190201);
		$display("#############################################");
		$display("Testing Direct SPI Memory Read              ");
		$display(" SPI Mode: QDDR (Dual 4 bit)                ");
		$display("Prefetch : 1DW, OPCODE:READ(0xED)           ");
		$display("SEQ: Command -> Address -> Read Data        ");
		$display("#############################################");
		// QDDR Config
                wb_user_core_write(`ADDR_SPACE_QSPI+`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 1000
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_DMEM_G0_RD_CTRL,{P_FSM_CAMDR,4'b0100,2'b10,P_MODE_SWITCH_AT_ADDR,P_QDDR,P_SINGLE,8'h00,8'hED});
                wb_user_core_write(`ADDR_SPACE_QSPI+`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h0000); // Change the Bank Sel 0000
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000200,read_data,32'h00000093);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000204,read_data,32'h00000113);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000208,read_data,32'h00000193);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000020C,read_data,32'h00000213);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000210,read_data,32'h00000293);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000214,read_data,32'h00000313);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000218,read_data,32'h00000393);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000021C,read_data,32'h00000413);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000300,read_data,32'h0005A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000304,read_data,32'h9DE30591);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000308,read_data,32'h02B7FEE5);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000030C,read_data,32'h43050049);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000310,read_data,32'h0062A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000314,read_data,32'h004902B7);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000318,read_data,32'h03130291);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000031C,read_data,32'ha0230630);
		$display("#############################################");
		$display("Testing Direct SPI Memory Read              ");
		$display(" SPI Mode: Normal/Single Bit                ");
		$display("Prefetch : 1DW, OPCODE:READ(0x3)            ");
		$display("SEQ: Command -> Address -> Read Data        ");
		$display("#############################################");
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 1000
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_DMEM_G0_RD_CTRL,{P_FSM_CAR,4'b0000,2'b10,P_MODE_SWITCH_IDLE,P_SINGLE,P_SINGLE,8'h00,8'h03});
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h0000); // Change the Bank Sel 0000
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000200,read_data,32'h00000093);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000204,read_data,32'h00000113);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000208,read_data,32'h00000193);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000020C,read_data,32'h00000213);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000210,read_data,32'h00000293);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000214,read_data,32'h00000313);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000218,read_data,32'h00000393);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000021C,read_data,32'h00000413);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000300,read_data,32'h0005A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000304,read_data,32'h9DE30591);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000308,read_data,32'h02B7FEE5);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000030C,read_data,32'h43050049);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000310,read_data,32'h0062A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000314,read_data,32'h004902B7);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000318,read_data,32'h03130291);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000031C,read_data,32'ha0230630);
		$display("#############################################");
		$display("Testing Direct SPI Memory Read              ");
		$display(" SPI Mode: Normal/Single Bit                ");
		$display("Prefetch : 1DW, OPCODE:FASTREAD(0xB)        ");
		$display("SEQ: Command -> Address -> Dummy -> Read Data");
		$display("#############################################");
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 1000
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_DMEM_G0_RD_CTRL,{P_FSM_CADR,4'b0000,2'b10,P_MODE_SWITCH_IDLE,P_SINGLE,P_SINGLE,8'h00,8'h0B});
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h0000); // Change the Bank Sel 0000
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000200,read_data,32'h00000093);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000204,read_data,32'h00000113);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000208,read_data,32'h00000193);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000020C,read_data,32'h00000213);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000210,read_data,32'h00000293);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000214,read_data,32'h00000313);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000218,read_data,32'h00000393);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000021C,read_data,32'h00000413);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000300,read_data,32'h0005A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000304,read_data,32'h9DE30591);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000308,read_data,32'h02B7FEE5);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000030C,read_data,32'h43050049);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000310,read_data,32'h0062A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000314,read_data,32'h004902B7);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000318,read_data,32'h03130291);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000031C,read_data,32'ha0230630);

		$display("#############################################");
		$display("Testing Direct SPI Memory Read              ");
		$display(" SPI Mode: Dual Mode                        ");
		$display("Prefetch : 1DW, OPCODE:DOR(0x3B)        ");
		$display("SEQ: Command -> Address -> Dummy -> Read Data");
		$display("#############################################");
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 1000
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_DMEM_G0_RD_CTRL,{P_FSM_CADR,4'b0000,2'b10,P_MODE_SWITCH_AT_DATA,P_DOUBLE,P_SINGLE,8'h00,8'h3B});
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h0000); // Change the Bank Sel 0000
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000200,read_data,32'h00000093);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000204,read_data,32'h00000113);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000208,read_data,32'h00000193);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000020C,read_data,32'h00000213);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000210,read_data,32'h00000293);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000214,read_data,32'h00000313);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000218,read_data,32'h00000393);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000021C,read_data,32'h00000413);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000300,read_data,32'h0005A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000304,read_data,32'h9DE30591);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000308,read_data,32'h02B7FEE5);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000030C,read_data,32'h43050049);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000310,read_data,32'h0062A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000314,read_data,32'h004902B7);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000318,read_data,32'h03130291);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000031C,read_data,32'ha0230630);

		$display("#############################################");
		$display("Testing Direct SPI Memory Read with Prefetch");
		$display(" SPI Mode: Quad                             ");
		$display("Prefetch : 8DW, OPCODE:URAD READ(0xEB)      ");
		$display("SEQ: Command -> Address -> Dummy -> Read Data");
		$display("#############################################");
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 1000
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_DMEM_G0_RD_CTRL,{P_FSM_CAMDR,4'b0001,2'b10,P_MODE_SWITCH_AT_ADDR,P_QUAD,P_SINGLE,8'h00,8'hEB});
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h0000); // Change the Bank Sel 0000
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000200,read_data,32'h00000093);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000204,read_data,32'h00000113);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000208,read_data,32'h00000193);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000020C,read_data,32'h00000213);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000210,read_data,32'h00000293);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000214,read_data,32'h00000313);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000218,read_data,32'h00000393);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000021C,read_data,32'h00000413);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000300,read_data,32'h0005A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000304,read_data,32'h9DE30591);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000308,read_data,32'h02B7FEE5);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000030C,read_data,32'h43050049);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000310,read_data,32'h0062A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000314,read_data,32'h004902B7);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000318,read_data,32'h03130291);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000031C,read_data,32'ha0230630);

		$display("#############################################");
		$display("Testing Direct SPI Memory Read with Prefetch:3DW");
		$display("#############################################");
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 1000
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_DMEM_G0_RD_CTRL,{P_FSM_CAMDR,4'b0001,2'b10,P_MODE_SWITCH_AT_ADDR,P_QUAD,P_SINGLE,8'h00,8'hEB});
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h0000); // Change the Bank Sel 0000
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000200,read_data,32'h00000093);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000204,read_data,32'h00000113);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000208,read_data,32'h00000193);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000020C,read_data,32'h00000213);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000210,read_data,32'h00000293);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000214,read_data,32'h00000313);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000218,read_data,32'h00000393);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000021C,read_data,32'h00000413);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000300,read_data,32'h0005A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000304,read_data,32'h9DE30591);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000308,read_data,32'h02B7FEE5);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000030C,read_data,32'h43050049);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000310,read_data,32'h0062A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000314,read_data,32'h004902B7);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000318,read_data,32'h03130291);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000031C,read_data,32'ha0230630);

		$display("#############################################");
		$display("Testing Direct SPI Memory Read with Prefetch:2DW");
		$display("#############################################");
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 1000
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_DMEM_G0_RD_CTRL,{P_FSM_CAMDR,4'b0001,2'b10,P_MODE_SWITCH_AT_ADDR,P_QUAD,P_SINGLE,8'h00,8'hEB});
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h0000); // Change the Bank Sel 0000
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000200,read_data,32'h00000093);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000204,read_data,32'h00000113);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000208,read_data,32'h00000193);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000020C,read_data,32'h00000213);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000210,read_data,32'h00000293);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000214,read_data,32'h00000313);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000218,read_data,32'h00000393);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000021C,read_data,32'h00000413);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000300,read_data,32'h0005A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000304,read_data,32'h9DE30591);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000308,read_data,32'h02B7FEE5);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000030C,read_data,32'h43050049);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000310,read_data,32'h0062A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000314,read_data,32'h004902B7);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000318,read_data,32'h03130291);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000031C,read_data,32'ha0230630);


		$display("#############################################");
		$display("Testing Direct SPI Memory Read with Prefetch:1DW");
		$display("#############################################");
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 1000
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_DMEM_G0_RD_CTRL,{P_FSM_CAMDR,4'b0001,2'b10,P_MODE_SWITCH_AT_ADDR,P_QUAD,P_SINGLE,8'h00,8'hEB});
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h0000); // Change the Bank Sel 0000
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000200,read_data,32'h00000093);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000204,read_data,32'h00000113);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000208,read_data,32'h00000193);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000020C,read_data,32'h00000213);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000210,read_data,32'h00000293);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000214,read_data,32'h00000313);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000218,read_data,32'h00000393);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000021C,read_data,32'h00000413);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000300,read_data,32'h0005A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000304,read_data,32'h9DE30591);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000308,read_data,32'h02B7FEE5);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000030C,read_data,32'h43050049);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000310,read_data,32'h0062A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000314,read_data,32'h004902B7);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000318,read_data,32'h03130291);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000031C,read_data,32'ha0230630);

		$display("#############################################");
		$display("Testing Direct SPI Memory Read with Prefetch:7DW");
		$display("#############################################");
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 1000
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_DMEM_G0_RD_CTRL,{P_FSM_CAMDR,4'b0001,2'b10,P_MODE_SWITCH_AT_ADDR,P_QUAD,P_SINGLE,8'h00,8'hEB});
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h0000); // Change the Bank Sel 0000
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000200,read_data,32'h00000093);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000204,read_data,32'h00000113);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000208,read_data,32'h00000193);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000020C,read_data,32'h00000213);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000210,read_data,32'h00000293);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000214,read_data,32'h00000313);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000218,read_data,32'h00000393);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000021C,read_data,32'h00000413);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000300,read_data,32'h0005A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000304,read_data,32'h9DE30591);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000308,read_data,32'h02B7FEE5);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000030C,read_data,32'h43050049);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000310,read_data,32'h0062A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000314,read_data,32'h004902B7);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000318,read_data,32'h03130291);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000031C,read_data,32'ha0230630);

		$display("#############################################");
		$display("  Testing Single Word Indirect SPI Memory Read");
		$display("#############################################");
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 1000
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0001,P_MODE_SWITCH_AT_ADDR,P_QUAD,P_SINGLE,4'b0001});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'h4,2'b00,2'b10,P_FSM_CAMDR,8'h00,8'hEB});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000200);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000093);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000204);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000113);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000208);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000193);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h0000020C);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000213);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000210);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000293);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000214);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000313);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000218);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000393);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h0000021C);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000413);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000300);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h0005A023);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000304);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h9DE30591);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000308);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h02B7FEE5);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h0000030C);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h43050049);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000310);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h0062A023);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000314);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h004902B7);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000318);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h03130291);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h0000031C);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'ha0230630);
		repeat (100) @(posedge clock);
		$display("#############################################");
		$display("  Testing Two Word Indirect SPI Memory Read");
		$display("#############################################");
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 1000
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0001,P_MODE_SWITCH_AT_ADDR,P_QUAD,P_SINGLE,4'b0001});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'h8,2'b00,2'b10,P_FSM_CAMDR,8'h00,8'hEB});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000200);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000093);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000113);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000208);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000193);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000213);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000210);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000293);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000313);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000218);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000393);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000413);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000300);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h0005A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h9DE30591);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000308);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h02B7FEE5);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h43050049);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000310);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h0062A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h004902B7);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000318);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h03130291);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'ha0230630);
		repeat (100) @(posedge clock);
		$display("#############################################");
		$display("  Testing Three Word Indirect SPI Memory Read");
		$display("#############################################");
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 1000
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0001,P_MODE_SWITCH_AT_ADDR,P_QUAD,P_SINGLE,4'b0001});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'hC,2'b00,2'b10,P_FSM_CAMDR,8'h00,8'hEB});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000200);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000093);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000113);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000193);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h0000020C);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000213);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000293);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000313);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000300);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h0005A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h9DE30591);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h02B7FEE5);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h0000030C);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h43050049);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h0062A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h004902B7);
		repeat (100) @(posedge clock);
		$display("#############################################");
		$display("  Testing Four Word Indirect SPI Memory Read");
		$display("#############################################");
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 1000
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0001,P_MODE_SWITCH_AT_ADDR,P_QUAD,P_SINGLE,4'b0001});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'h10,2'b00,2'b10,P_FSM_CAMDR,8'h00,8'hEB});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000200);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000093);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000113);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000193);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000213);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000210);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000293);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000313);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000393);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000413);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000300);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h0005A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h9DE30591);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h02B7FEE5);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h43050049);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000310);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h0062A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h004902B7);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h03130291);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'ha0230630);
		repeat (100) @(posedge clock);
		$display("#############################################");
		$display("  Testing Five Word Indirect SPI Memory Read");
		$display("#############################################");
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 1000
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0001,P_MODE_SWITCH_AT_ADDR,P_QUAD,P_SINGLE,4'b0001});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'h14,2'b00,2'b10,P_FSM_CAMDR,8'h00,8'hEB});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000200);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000093);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000113);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000193);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000213);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000293);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000300);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h0005A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h9DE30591);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h02B7FEE5);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h43050049);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h0062A023);
		$display("#############################################");
		$display("  Testing Eight Word Indirect SPI Memory Read");
		$display("#############################################");
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 1000
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0001,P_MODE_SWITCH_AT_ADDR,P_QUAD,P_SINGLE,4'b0001});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'h20,2'b00,2'b10,P_FSM_CAMDR,8'h00,8'hEB});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000200);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000093);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000113);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000193);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000213);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000293);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000313);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000393);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00000413);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000300);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h0005A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h9DE30591);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h02B7FEE5);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h43050049);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h0062A023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h004902B7);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h03130291);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'ha0230630);

		$display("#############################################");
		$display("  Sector Erase Command            ");
		$display("#############################################");
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 1000
		// WEN COMMAND
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0000,P_MODE_SWITCH_IDLE,P_SINGLE,P_SINGLE,4'b0001});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'h0,2'b00,2'b00,P_FSM_C,8'h00,8'h06});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h0);
                // Sector Erase
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0000,P_MODE_SWITCH_IDLE,P_SINGLE,P_SINGLE,4'b0001});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'h0,2'b00,2'b10,P_FSM_CA,8'h00,8'hD8});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000000);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h0);

		// RDSR
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0000,P_MODE_SWITCH_IDLE,P_SINGLE,P_SINGLE,4'b0001});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'h4,2'b00,2'b00,P_FSM_CR,8'h00,8'h05});
		read_data = 32'hFFFF_FFFF;
		while (read_data[1:0] == 2'b11) begin
		    wb_user_core_read(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data);
		    repeat (10) @(posedge clock);
		end

		$display("#############################################");
		$display("  Page Write Command Address: 0x00          ");
		$display("#############################################");
		// WEN COMMAND
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0000,P_MODE_SWITCH_IDLE,P_SINGLE,P_SINGLE,4'b0001});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'h0,2'b00,2'b00,P_FSM_C,8'h00,8'h06});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h0);
		 // Page Programing
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0000,P_MODE_SWITCH_IDLE,P_SINGLE,P_SINGLE,4'b0001});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'hF0,2'b00,2'b10,P_FSM_CAW,8'h00,8'h02});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000000);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010000);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010001);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010002);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010003);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010004);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010005);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010006);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010007);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010008);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010009);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010010);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010011);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010012);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010013);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010014);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010015);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010016);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010017);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010018);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010019);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010020);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010021);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010022);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010023);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010024);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010025);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010026);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010027);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010028);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010029);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010030);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010031);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010032);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010033);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010034);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010035);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010036);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010037);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010038);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010039);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010040);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010041);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010042);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010043);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010044);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010045);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010046);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010047);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010048);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010049);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010050);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010051);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010052);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010053);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010054);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010055);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010056);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010057);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010058);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00010059);

		// RDSR
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0000,P_MODE_SWITCH_IDLE,P_SINGLE,P_SINGLE,4'b0001});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'h4,2'b00,2'b00,P_FSM_CR,8'h00,8'h05});
		read_data = 32'hFFFF_FFFF;
		while (read_data[1:0] == 2'b11) begin
		    wb_user_core_read(`ADDR_SPACE_QSPI+`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data);
		    repeat (10) @(posedge clock);
		 end

		$display("#############################################");
		$display("  Page Read through Direct Access            ");
		$display("#############################################");
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h0000); // Change the Bank Sel 0000
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000000,read_data,32'h00010000);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000004,read_data,32'h00010001);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000008,read_data,32'h00010002);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000000C,read_data,32'h00010003);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000010,read_data,32'h00010004);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000014,read_data,32'h00010005);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000018,read_data,32'h00010006);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000001C,read_data,32'h00010007);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000020,read_data,32'h00010008);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000024,read_data,32'h00010009);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000028,read_data,32'h00010010);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000002C,read_data,32'h00010011);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000030,read_data,32'h00010012);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000034,read_data,32'h00010013);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000038,read_data,32'h00010014);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000003C,read_data,32'h00010015);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000040,read_data,32'h00010016);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000044,read_data,32'h00010017);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000048,read_data,32'h00010018);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000004C,read_data,32'h00010019);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000050,read_data,32'h00010020);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000054,read_data,32'h00010021);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000058,read_data,32'h00010022);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000005C,read_data,32'h00010023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000060,read_data,32'h00010024);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000064,read_data,32'h00010025);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000068,read_data,32'h00010026);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000006C,read_data,32'h00010027);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000070,read_data,32'h00010028);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000074,read_data,32'h00010029);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000078,read_data,32'h00010030);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000007C,read_data,32'h00010031);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000080,read_data,32'h00010032);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000084,read_data,32'h00010033);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000088,read_data,32'h00010034);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000008C,read_data,32'h00010035);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000090,read_data,32'h00010036);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000094,read_data,32'h00010037);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000098,read_data,32'h00010038);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000009C,read_data,32'h00010039);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000000A0,read_data,32'h00010040);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000000A4,read_data,32'h00010041);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000000A8,read_data,32'h00010042);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000000AC,read_data,32'h00010043);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000000B0,read_data,32'h00010044);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000000B4,read_data,32'h00010045);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000000B8,read_data,32'h00010046);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000000BC,read_data,32'h00010047);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000000C0,read_data,32'h00010048);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000000C4,read_data,32'h00010049);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000000C8,read_data,32'h00010050);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000000CC,read_data,32'h00010051);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000000D0,read_data,32'h00010052);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000000D4,read_data,32'h00010053);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000000D8,read_data,32'h00010054);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000000DC,read_data,32'h00010055);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000000E0,read_data,32'h00010056);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000000E4,read_data,32'h00010057);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000000E8,read_data,32'h00010058);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000000EC,read_data,32'h00010059);

		repeat (100) @(posedge clock);
		$display("#############################################");
		$display("  Page Read through Indirect Access           ");
		$display("#############################################");
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 1000
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0001,P_MODE_SWITCH_AT_ADDR,P_QUAD,P_SINGLE,4'b0001});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'hF0,2'b00,2'b10,P_FSM_CAMDR,8'h00,8'hEB});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000000);

		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010000);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010001);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010002);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010003);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010004);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010005);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010006);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010007);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010008);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010009);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010010);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010011);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010012);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010013);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010014);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010015);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010016);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010017);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010018);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010019);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010020);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010021);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010022);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010024);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010025);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010026);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010027);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010028);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010029);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010030);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010031);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010032);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010033);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010034);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010035);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010036);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010037);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010038);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010039);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010040);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010041);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010042);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010043);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010044);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010045);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010046);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010047);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010048);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010049);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010050);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010051);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010052);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010053);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010054);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010055);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010056);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010057);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010058);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00010059);

		repeat (100) @(posedge clock);
		$display("#############################################");
		$display("  Page Write Command Address: 0x200          ");
		$display("#############################################");
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 1000
		// WEN COMMAND
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0000,P_MODE_SWITCH_IDLE,P_SINGLE,P_SINGLE,4'b0001});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'h0,2'b00,2'b00,P_FSM_C,8'h00,8'h06});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h0);
		 // Page Programing
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0000,P_MODE_SWITCH_IDLE,P_SINGLE,P_SINGLE,4'b0001});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'hF0,2'b00,2'b10,P_FSM_CAW,8'h00,8'h02});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000200);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020000);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020001);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020002);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020003);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020004);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020005);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020006);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020007);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020008);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020009);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020010);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020011);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020012);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020013);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020014);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020015);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020016);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020017);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020018);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020019);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020020);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020021);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020022);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020023);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020024);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020025);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020026);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020027);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020028);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020029);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020030);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020031);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020032);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020033);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020034);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020035);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020036);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020037);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020038);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020039);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020040);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020041);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020042);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020043);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020044);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020045);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020046);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020047);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020048);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020049);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020050);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020051);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020052);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020053);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020054);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020055);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020056);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020057);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020058);
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_WDATA,32'h00020059);

		// RDSR
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0000,P_MODE_SWITCH_IDLE,P_SINGLE,P_SINGLE,4'b0001});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'h4,2'b00,2'b00,P_FSM_CR,8'h00,8'h05});
		read_data = 32'hFFFF_FFFF;
		while (read_data[1:0] == 2'b11) begin
		    wb_user_core_read(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data);
		    repeat (10) @(posedge clock);
		 end

		$display("#############################################");
		$display("  Page Read through Direct Access            ");
		$display("#############################################");
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h0000); // Change the Bank Sel 0000
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000200,read_data,32'h00020000);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000204,read_data,32'h00020001);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000208,read_data,32'h00020002);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000020C,read_data,32'h00020003);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000210,read_data,32'h00020004);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000214,read_data,32'h00020005);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000218,read_data,32'h00020006);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000021C,read_data,32'h00020007);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000220,read_data,32'h00020008);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000224,read_data,32'h00020009);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000228,read_data,32'h00020010);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000022C,read_data,32'h00020011);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000230,read_data,32'h00020012);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000234,read_data,32'h00020013);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000238,read_data,32'h00020014);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000023C,read_data,32'h00020015);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000240,read_data,32'h00020016);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000244,read_data,32'h00020017);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000248,read_data,32'h00020018);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000024C,read_data,32'h00020019);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000250,read_data,32'h00020020);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000254,read_data,32'h00020021);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000258,read_data,32'h00020022);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000025C,read_data,32'h00020023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000260,read_data,32'h00020024);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000264,read_data,32'h00020025);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000268,read_data,32'h00020026);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000026C,read_data,32'h00020027);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000270,read_data,32'h00020028);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000274,read_data,32'h00020029);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000278,read_data,32'h00020030);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000027C,read_data,32'h00020031);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000280,read_data,32'h00020032);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000284,read_data,32'h00020033);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000288,read_data,32'h00020034);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000028C,read_data,32'h00020035);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000290,read_data,32'h00020036);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000294,read_data,32'h00020037);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h00000298,read_data,32'h00020038);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h0000029C,read_data,32'h00020039);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000002A0,read_data,32'h00020040);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000002A4,read_data,32'h00020041);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000002A8,read_data,32'h00020042);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000002AC,read_data,32'h00020043);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000002B0,read_data,32'h00020044);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000002B4,read_data,32'h00020045);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000002B8,read_data,32'h00020046);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000002BC,read_data,32'h00020047);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000002C0,read_data,32'h00020048);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000002C4,read_data,32'h00020049);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000002C8,read_data,32'h00020050);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000002CC,read_data,32'h00020051);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000002D0,read_data,32'h00020052);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000002D4,read_data,32'h00020053);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000002D8,read_data,32'h00020054);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000002DC,read_data,32'h00020055);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000002E0,read_data,32'h00020056);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000002E4,read_data,32'h00020057);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000002E8,read_data,32'h00020058);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+32'h000002EC,read_data,32'h00020059);

		repeat (10) @(posedge clock);
		$display("#############################################");
		$display("  Page Read through Indirect Access           ");
		$display("#############################################");
                wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 1000
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL1,{16'h0,1'b0,1'b0,4'b0001,P_MODE_SWITCH_AT_ADDR,P_QUAD,P_SINGLE,4'b0001});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_CTRL2,{8'hF0,2'b00,2'b10,P_FSM_CAMDR,8'h00,8'hEB});
		wb_user_core_write(`ADDR_SPACE_QSPI+`QSPIM_IMEM_ADDR,32'h00000200);

		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020000);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020001);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020002);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020003);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020004);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020005);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020006);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020007);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020008);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020009);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020010);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020011);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020012);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020013);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020014);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020015);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020016);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020017);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020018);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020019);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020020);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020021);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020022);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020023);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020024);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020025);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020026);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020027);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020028);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020029);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020030);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020031);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020032);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020033);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020034);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020035);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020036);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020037);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020038);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020039);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020040);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020041);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020042);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020043);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020044);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020045);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020046);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020047);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020048);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020049);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020050);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020051);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020052);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020053);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020054);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020055);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020056);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020057);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020058);
		wb_user_core_read_check(`ADDR_SPACE_QSPI+`QSPIM_IMEM_RDATA,read_data,32'h00020059);

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

// SSPI Slave I/F
assign io_in[0]  = 1'b1; // RESET

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


   // Quad flash
     s25fl256s #(.mem_file_name("flash0.hex"),
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

   wire spiram_csb = (io_oeb[31]== 1'b0) ? io_out[31] : 1'b0;

   is62wvs1288 #(.mem_file_name("flash1.hex"))
	u_sfram (
         // Data Inputs/Outputs
           .io0     (flash_io0),
           .io1     (flash_io1),
           // Controls
           .clk    (flash_clk),
           .csb    (spiram_csb),
           .io2    (flash_io2),
           .io3    (flash_io3)
    );


endmodule
`include "s25fl256s.sv"
`default_nettype wire
