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
////////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores common library Module                       ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  https://github.com/dineshannayya/yifive_r0.git              ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////      1.0    Mar 2, 2011,Dinesh.A                             ////
////              Initial Version                                 ////
////      1.1   Nov 15,2021,Dinesh A                              //// 
////            Bug fix in High and Low count width               ////
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

// #################################################################
// Module: clk_ctl
//
// Description:  Generic clock control logic , clk-out = mclk/(2+clk_div_ratio)
//
//  
// #################################################################


module clk_ctl (
   // Outputs
       clk_o,
   // Inputs
       mclk,
       reset_n, 
       clk_div_ratio 
   );

//---------------------------------
// CLOCK Default Divider value.
// This value will be change from outside
//---------------------------------
parameter  WD = 'h1;

//---------------------------------------------
// All the input to this block are declared here
// --------------------------------------------
   input        mclk          ;// 
   input        reset_n       ;// primary reset signal
   input [WD:0] clk_div_ratio ;// primary clock divide ratio
                               // output clock = selected clock / (div_ratio+1)
   
//---------------------------------------------
// All the output to this block are declared here
// --------------------------------------------
   output       clk_o             ; // clock out

               

//------------------------------------
// Clock Divide func is done here
//------------------------------------
reg  [WD:0]      high_count       ; // high level counter
reg  [WD:0]      low_count        ; // low level counter
reg              mclk_div         ; // divided clock


assign clk_o  = mclk_div;

always @ (posedge mclk or negedge reset_n)
begin // {
   if(reset_n == 1'b0) 
   begin 
      high_count  <= 'h0;
      low_count   <= 'h0;
      mclk_div    <= 'b0;
   end   
   else 
   begin 
      if(high_count != 0)
      begin // {
         high_count    <= high_count - 1;
         mclk_div      <= 1'b1;
      end   // }
      else if(low_count != 0)
      begin // {
         low_count     <= low_count - 1;
         mclk_div      <= 1'b0;
      end   // }
      else
      begin // {
         high_count    <= clk_div_ratio[WD:1] + {{WD-1{1'b0}},clk_div_ratio[0]};
         low_count     <= clk_div_ratio[WD:1] + 1;
         mclk_div      <= ~mclk_div;
      end   // }
   end   // }
end   // }


endmodule 

