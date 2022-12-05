//////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2021 , Dinesh Annayya                          
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
// SPDX-FileContributor: Created by Dinesh Annayya <dinesha@opencores.org>
//
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OMS8051 I2C Master Core Module                              ////
////  WISHBONE revB.2 compliant I2C Master controller Top-level   ////
////                                                              ////
////  This file is part of the OMS 8051 cores project             ////
////  http://www.opencores.org/cores/oms8051mini/                 ////
////                                                              ////
////  Description                                                 ////
////  OMS 8051 definitions.                                       ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      -Richard Herveille ,  richard@asics.ws, www.asics.ws    ////
////      -Dinesh Annayya, dinesha@opencores.org                  ////
////                                                              ////
////  Revision : Jan 6, 2017                                      //// 
////                                                              ////
//////////////////////////////////////////////////////////////////////
//     v0.0 - Dinesh A, 6th Jan 2017
//          1. Initail version picked from
//              http://www.opencores.org/projects/i2c/
//          2. renaming of reset signal to aresetn and sresetn
//     v0.1 - Dinesh A, 28th Aug 2022
//          Generated i2c_fsm_busy to identify fsm busy state 
//
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

`include "i2cm_defines.v"

module i2cm_top(
	// wishbone signals
	input        wb_clk_i,     // master clock input
	input        sresetn,      // synchronous reset
	input        aresetn,      // asynchronous reset
	input  [2:0] wb_adr_i,     // lower address bits
	input  [7:0] wb_dat_i,     // databus input
	output reg [7:0] wb_dat_o,     // databus output
	input        wb_we_i,      // write enable input
	input        wb_stb_i,     // stobe/core select signal
	input        wb_cyc_i,     // valid bus cycle input
	output reg   wb_ack_o,     // bus cycle acknowledge output
	output reg  wb_inta_o,    // interrupt request signal output

	// I2C signals
	// i2c clock line
	input        scl_pad_i,    // SCL-line input
	output       scl_pad_o,    // SCL-line output (always 1'b0)
	output       scl_padoen_o, // SCL-line output enable (active low)

	// i2c data line
	input        sda_pad_i,    // SDA-line input
	output       sda_pad_o,    // SDA-line output (always 1'b0)
	output       sda_padoen_o  // SDA-line output enable (active low)

         );


	//
	// variable declarations
	//

	// registers
	reg  [15:0] prer; // clock prescale register
	reg  [ 7:0] ctr;  // control register
	reg  [ 7:0] txr;  // transmit register
	wire [ 7:0] rxr;  // receive register
	reg  [ 7:0] cr;   // command register
	wire [ 7:0] sr;   // status register

	// done signal: command completed, clear command register
	wire done;

	// core enable signal
	wire core_en;
	wire ien;

	// status register signals
	wire irxack;
	reg  rxack;       // received aknowledge from slave
	reg  tip;         // transfer in progress
	reg  irq_flag;    // interrupt pending flag
	wire i2c_busy;    // bus busy (start signal detected)
	wire i2c_fsm_busy;// i2C FSM Busy
	wire i2c_al;      // i2c bus arbitration lost
	reg  al;          // status register arbitration lost bit

//###################################
// Application Reset Synchronization
//###################################
wire aresetn_ss;
reset_sync  u_app_rst (
	      .scan_mode  (1'b0           ),
          .dclk       (wb_clk_i       ), // Destination clock domain
	      .arst_n     (aresetn        ), // active low async reset
          .srst_n     (aresetn_ss     )
          );

	//
	// module body
	//


	// generate wishbone signals
	wire wb_wacc = wb_we_i & wb_ack_o;

	// generate acknowledge output signal
	always @(posedge wb_clk_i)
	  wb_ack_o <= #1 wb_cyc_i & wb_stb_i & ~wb_ack_o; // because timing is always honored

	// assign DAT_O
	always @(posedge wb_clk_i)
	begin
	  case (wb_adr_i) // synopsys parallel_case
	    3'b000: wb_dat_o <= #1 prer[ 7:0];
	    3'b001: wb_dat_o <= #1 prer[15:8];
	    3'b010: wb_dat_o <= #1 ctr;
	    3'b011: wb_dat_o <= #1 rxr; // write is transmit register (txr)
	    3'b100: wb_dat_o <= #1 sr;  // write is command register (cr)
	    3'b101: wb_dat_o <= #1 txr;
	    3'b110: wb_dat_o <= #1 cr;
	    3'b111: wb_dat_o <= #1 0;   // reserved
	  endcase
	end

	// generate registers
	always @(posedge wb_clk_i or negedge aresetn_ss)
	  if (!aresetn_ss)
	    begin
	        prer <= #1 16'hffff;
	        ctr  <= #1  8'h0;
	        txr  <= #1  8'h0;
	    end
	  else if (!sresetn)
	    begin
	        prer <= #1 16'hffff;
	        ctr  <= #1  8'h0;
	        txr  <= #1  8'h0;
	    end
	  else
	    if (wb_wacc)
	      case (wb_adr_i) // synopsys parallel_case
	         3'b000 : prer [ 7:0] <= #1 wb_dat_i;
	         3'b001 : prer [15:8] <= #1 wb_dat_i;
	         3'b010 : ctr         <= #1 wb_dat_i;
	         3'b011 : txr         <= #1 wb_dat_i;
	         default: ;
	      endcase

	// generate command register (special case)
	always @(posedge wb_clk_i or negedge aresetn_ss)
	  if (!aresetn_ss)
	    cr <= #1 8'h0;
	  else if (!sresetn)
	    cr <= #1 8'h0;
	  else if (wb_wacc)
	    begin
	        if (core_en & (wb_adr_i == 3'b100) )
	          cr <= #1 wb_dat_i;
	    end
	  else
	    begin
	        if (done | i2c_al)
	          cr[7:4] <= #1 4'h0;           // clear command bits when done
	                                        // or when aribitration lost
	        cr[2:1] <= #1 2'b0;             // reserved bits
	        cr[0]   <= #1 1'b0;             // clear IRQ_ACK bit
	    end


	// decode command register
	wire sta  = cr[7];
	wire sto  = cr[6];
	wire rd   = cr[5];
	wire wr   = cr[4];
	wire ack  = cr[3];
	wire iack = cr[0];

	// decode control register
	assign core_en = ctr[7];
	assign ien = ctr[6];

	// hookup byte controller block
	i2cm_byte_ctrl u_byte_ctrl (
		.clk          ( wb_clk_i     ),
		.sresetn      ( sresetn      ),
		.aresetn      ( aresetn_ss   ),
		.ena          ( core_en      ),
		.clk_cnt      ( prer         ),
		.start        ( sta          ),
		.stop         ( sto          ),
		.read         ( rd           ),
		.write        ( wr           ),
		.ack_in       ( ack          ),
		.din          ( txr          ),
		.cmd_ack      ( done         ),
		.ack_out      ( irxack       ),
		.dout         ( rxr          ),
		.i2c_busy     ( i2c_busy     ),
		.i2c_fsm_busy ( i2c_fsm_busy ),
		.i2c_al       ( i2c_al       ),
		.scl_i        ( scl_pad_i    ),
		.scl_o        ( scl_pad_o    ),
		.scl_oen      ( scl_padoen_o ),
		.sda_i        ( sda_pad_i    ),
		.sda_o        ( sda_pad_o    ),
		.sda_oen      ( sda_padoen_o )
	);

	// status register block + interrupt request signal
	always @(posedge wb_clk_i or negedge aresetn_ss)
	  if (!aresetn_ss)
	    begin
	        al       <= #1 1'b0;
	        rxack    <= #1 1'b0;
	        tip      <= #1 1'b0;
	        irq_flag <= #1 1'b0;
	    end
	  else if (!sresetn)
	    begin
	        al       <= #1 1'b0;
	        rxack    <= #1 1'b0;
	        tip      <= #1 1'b0;
	        irq_flag <= #1 1'b0;
	    end
	  else
	    begin
	        al       <= #1 i2c_al | (al & ~sta);
	        rxack    <= #1 irxack;
	        tip      <= #1 (rd | wr);
	        irq_flag <= #1 (done | i2c_al | irq_flag) & ~iack; // interrupt request flag is always generated
	    end

	// generate interrupt request signals
	always @(posedge wb_clk_i or negedge aresetn_ss)
	  if (!aresetn_ss)
	    wb_inta_o <= #1 1'b0;
	  else if (!sresetn)
	    wb_inta_o <= #1 1'b0;
	  else
	    wb_inta_o <= #1 irq_flag && ien; // interrupt signal is only generated when IEN (interrupt enable bit is set)

	// assign status register bits
	assign sr[7]   = rxack;
	assign sr[6]   = i2c_busy;
	assign sr[5]   = al;
	assign sr[4]   = i2c_fsm_busy; // I2C FSM Busy
	assign sr[3:2] = 2'h0; // reserved
	assign sr[1]   = tip;
	assign sr[0]   = irq_flag;

endmodule
