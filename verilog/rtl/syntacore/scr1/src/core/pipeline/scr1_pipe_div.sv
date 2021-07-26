/////////////////////////////////////////////////////////////////////////////
//// SPDX-FileCopyrightText: 2021, Dinesh Annayya
//// 
//// Licensed under the Apache License, Version 2.0 (the "License");
//// you may not use this file except in compliance with the License.
//// You may obtain a copy of the License at
////
////      http://www.apache.org/licenses/LICENSE-2.0
////
//// Unless required by applicable law or agreed to in writing, software
//// distributed under the License is distributed on an "AS IS" BASIS,
//// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//// See the License for the specific language governing permissions and
//// limitations under the License.
//// SPDX-License-Identifier: Apache-2.0
//// SPDX-FileContributor: Dinesh Annayya <dinesha@opencores.org>          
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
////                                                                     ////
////  32 / 32 Divider with 16 stage pipe line , Support Signed Division  ////
////                                                                     ////
////  This file is part of the yifive cores project                      ////
////  https://github.com/dineshannayya/yifive_r0.git                     ////
////  http://www.opencores.org/cores/yifive/                             ////
////                                                                     ////
////  Description:                                                       ////
////    32 Div By 32 with 16 stage pipe line for timing reason           ////
////    Note: 2 Bit are computed at a time                               ////
////          bit[32] =1 indicate negative number                        ////
////                                                                     ////
////  Example: 4'b1011 Div 4'b0011                                       ////
////                                                                     ////
////                                                                     ////
////       """"""""|                                                     ////
////          1011 |  <- qr reg                                          ////
////      -0011000 |  <- Shuft Divider by 3                              ////
////       """"""""|  <-  0011000 > 1011 , ignore sub, Quo: 0            ////
////          1011 |                                                     ////
////       -001100 |  <- Shift Divider by 2                              ////
////       """"""""|  <-  001100 > 1011 , ignore sub, Quo:00             ////
////          1011 |                                                     ////
////        -00110 |  <- Shift Divider by 1                              ////
////       """"""""|  <- 00110 < 1011, Rem: 0101 and Quo:001             ////
////          0101 |                                                     ////
////         -0011 |  <- Shift Divider by 0                              ////
////       """"""""|  <- 0011 < 0101 , Rem: 10 and Quo: 0011             ////
////            10 |                                                     ////
////                                                                     ////
////   Quotient, 3 (0011); remainder 2 (10).                             ////
////                                                                     ////
////  To Do:                                                             ////
////    nothing                                                          ////
////                                                                     ////
////  Author(s):                                                         ////
////      - Dinesh Annayya, dinesha@opencores.org                        ////
////                                                                     ////
////  Revision :                                                         ////
////                                                                     ////
/////////////////////////////////////////////////////////////////////////////
////                                                                     ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                        ////
////                                                                     ////
//// This source file may be used and distributed without                ////
//// restriction provided that this copyright statement is not           ////
//// removed from the file and that any derivative work contains         ////
//// the original copyright notice and the associated disclaimer.        ////
////                                                                     ////
//// This source file is free software; you can redistribute it          ////
//// and/or modify it under the terms of the GNU Lesser General          ////
//// Public License as published by the Free Software Foundation;        ////
//// either version 2.1 of the License, or (at your option) any          ////
//// later version.                                                      ////
////                                                                     ////
//// This source is distributed in the hope that it will be              ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied          ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR             ////
//// PURPOSE.  See the GNU Lesser General Public License for more        ////
//// details.                                                            ////
////                                                                     ////
//// You should have received a copy of the GNU Lesser General           ////
//// Public License along with this source; if not, download it          ////
//// from http://www.opencores.org/lgpl.shtml                            ////
////                                                                     ////
/////////////////////////////////////////////////////////////////////////////

module scr1_pipe_div(
	input   logic        clk, 
	input   logic        rstn, 
	input   logic        data_valid,   // input valid
	input   logic [32:0] Din1,         // dividend
	input   logic [32:0] Din2,         // divider
	output  logic [31:0] quotient,     // quotient
	output  logic [31:0] remainder,    // remainder
	output  logic        div_rdy_o,    // Div result ready
	input   logic        data_done     // Result processing complete indication
     );

parameter WAIT_CMD      = 2'b00; // Accept command and Do Signed to unsigned
parameter WAIT_COMP     = 2'b01; // Wait for COMPUTATION
parameter WAIT_DONE     = 2'b10; // Do Signed to Unsigned conversion 
parameter WAIT_EXIT     = 2'b11; // Wait for Data Completion

logic [31:0] src1, src2;

// wires
logic div0, div1;
logic [31:0] rem0, rem1, rem2;
logic [32:0] sub0, sub1;
logic [63:0] cmp0, cmp1;
logic [31:0] div_out, rem_out;
logic [1:0]  state, next_state;
logic        div_rdy_i;
logic [31:0] quotient_next;     // quotient
logic [31:0] remainder_next;    // remainder

// real registers
logic [3:0]  cycle,next_cycle;

// The main logic
assign cmp1 = src2 << ({4'b1111 - cycle, 1'b0} + 'h1);
assign cmp0 = src2 << ({4'b1111 - cycle, 1'b0} + 'h0);

assign rem2 = cycle != 0 ? remainder : src1;

assign sub1 = {1'b0, rem2} - {1'b0, cmp1[31:0]};
assign div1 = |cmp1[63:32] ? 1'b0 : !sub1[32];
assign rem1 = div1 ? sub1[31:0] : rem2[31:0];

assign sub0 = {1'b0, rem1} - {1'b0, cmp0[31:0]};
assign div0 = |cmp0[63:32] ? 1'b0 : !sub0[32];
assign rem0 = div0 ? sub0[31:0] : rem1[31:0];

//
// in clock cycle 0 we first calculate two MSB bits, ...
// till finally in clock cycle 3 we calculate two LSB bits
assign div_out = {quotient[29:0], div1, div0};
assign rem_out = rem0;

//
// divider works in four clock cycles -- 0, 1, 2 and 3
always_ff @(posedge clk or negedge rstn)
begin
  if (!rstn) begin
    state        <= WAIT_CMD;
    cycle        <= 4'b0;
    div_rdy_o    <= 1'b0;
    quotient     <= 32'h0;
    remainder    <= 32'h0;
    src1         <= 32'h0;
    src2         <= 32'h0;
  end else begin
     cycle        <= next_cycle;
     state        <= next_state;
     div_rdy_o    <= div_rdy_i;
     if(data_valid && state== WAIT_CMD ) begin
        src1   <= (Din1[32] == 1'b1) ? (32'hFFFF_FFFF ^ Din1[31:0])+1 : Din1[31:0];
        src2   <= (Din2[32] == 1'b1) ? (32'hFFFF_FFFF ^ Din2[31:0])+1 : Din2[31:0];
     end
     quotient    <= quotient_next;
     remainder   <= remainder_next;
  end
end


always_comb
begin
     div_rdy_i        = 0;
     next_cycle       = cycle;
     next_state       = state;
     quotient_next    = quotient;
     remainder_next   = remainder;
     case(state)
     WAIT_CMD: if(data_valid)  begin 
	     next_cycle = 0;
	     if(Din2[31:0] == 0) begin // Div by 0 case
	        next_state = WAIT_DONE;
	     end else begin
	        next_state = WAIT_COMP;
             end
	 end
     // WAIT for Computation
     WAIT_COMP:  
	begin
           quotient_next    = div_out;
           remainder_next   = rem_out;
	   next_cycle = cycle +1;
	   if(cycle == 15) begin
	      next_state  = WAIT_DONE;
           end else begin
	      next_cycle = cycle +1;
	   end
	end
     WAIT_DONE:  
	begin
	   if(Din2[31:0] == 0) begin // Handling div by 0 case
	       quotient_next = 32'hFFFF_FFFF;
               remainder_next = Din1[31:0];
           end else begin
	      if(Din1[32] ^ Din2[32])  begin
                 quotient_next = (32'hFFFF_FFFF ^ quotient[31:0]) + 1;
              end
              if(Din1[32])  begin
                 remainder_next = (32'hFFFF_FFFF ^ remainder[31:0]) + 1;
	      end
	   end
           div_rdy_i = 1'b1;
	   next_state  = WAIT_EXIT;
	end
	WAIT_EXIT: begin
	    if(data_done) // Wait for data completion command
	        next_state  = WAIT_CMD;
	end	
    endcase
end
endmodule
