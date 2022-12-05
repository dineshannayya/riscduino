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
////  Wishbone Arbitor                                            ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  https://github.com/dineshannayya/yifive_r0.git              ////
////  http://www.opencores.org/cores/yifive/                      ////
////                                                              ////
////  Description                                                 ////
////      This block implement simple round robine request        ////
//        arbitor for wishbone interface.                         ////
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


module wb_arb(clk, rstn, req, gnt);

input		clk;
input		rstn;
input	[3:0]	req;	// Req input
output	[1:0]	gnt; 	// Grant output

///////////////////////////////////////////////////////////////////////
//
// Parameters
//


parameter	[1:0]
                grant0 = 2'h0,
                grant1 = 2'h1,
                grant2 = 2'h2,
                grant3 = 2'h3;

///////////////////////////////////////////////////////////////////////
// Local Registers and Wires
//////////////////////////////////////////////////////////////////////

reg [1:0]	state, next_state;

///////////////////////////////////////////////////////////////////////
//  Misc Logic 
//////////////////////////////////////////////////////////////////////

assign	gnt = state;

always@(posedge clk or negedge rstn)
	if(!rstn)       state <= grant0;
	else		state <= next_state;

///////////////////////////////////////////////////////////////////////
//
// Next State Logic 
//   - implements round robin arbitration algorithm
//   - switches grant if current req is dropped or next is asserted
//   - parks at last grant
//////////////////////////////////////////////////////////////////////

always@(state or req )
   begin
      next_state = state;	// Default Keep State
      case(state)		
         grant0:
      	// if this req is dropped or next is asserted, check for other req's
      	if(!req[0] ) begin
      		if(req[1])	    next_state = grant1;
      		else if(req[2])	next_state = grant2;
      		else if(req[3])	next_state = grant3;
      	end
         grant1:
      	// if this req is dropped or next is asserted, check for other req's
      	if(!req[1] ) begin
      		if(req[2])	    next_state = grant2;
      		if(req[3])	    next_state = grant3;
      		else if(req[0])	next_state = grant0;
      	end
         grant2:
      	// if this req is dropped or next is asserted, check for other req's
      	if(!req[2] ) begin
      	   if(req[0])	        next_state = grant0;
      	   else if(req[1])	next_state = grant1;
      	   else if(req[3])	next_state = grant3;
      	end
         grant3:
      	// if this req is dropped or next is asserted, check for other req's
      	if(!req[3] ) begin
      	   if(req[0])	        next_state = grant0;
      	   else if(req[1])	next_state = grant1;
      	   else if(req[2])	next_state = grant2;
      	end
      endcase
   end

endmodule 

