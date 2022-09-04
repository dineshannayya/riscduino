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
////  Tubo 8051 cores common library Module                       ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
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
////  Revision : Mar 2, 2011                                      //// 
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

/*********************************************************************
** module: bit register

** description: infers a register, make it modular
 ***********************************************************************/
module bit_register (
		 //inputs
		 we,		 
		 clk,
		 reset_n,
		 data_in,
		 
		 //outputs
		 data_out
		 );

//---------------------------------
// Reset Default value
//---------------------------------
parameter  RESET_DEFAULT = 1'h0;

  input	 we;
  input	 clk;
  input	 reset_n;
  input	 data_in;
  output data_out;
  
  reg	 data_out;
  
  //infer the register
  always @(posedge clk or negedge reset_n)
    begin
      if (!reset_n)
	data_out <= RESET_DEFAULT;
      else if (we)
	data_out <= data_in;
    end // always @ (posedge clk or negedge reset_n)
endmodule // register


/*********************************************************************
** module: req register.

** description: This register is set by cpu writting 1 and reset by
                harward req = 1

 Note: When there is a clash between cpu and hardware, cpu is given higher
       priority

 ***********************************************************************/
module req_register (
		 //inputs
		 clk,
		 reset_n,
		 cpu_we,		 
		 cpu_req,
		 hware_ack,
		 
		 //outputs
		 data_out
		 );

//---------------------------------
// Reset Default value
//---------------------------------
parameter  RESET_DEFAULT = 1'h0;

  input	 clk      ;
  input	 reset_n  ;
  input	 cpu_we   ; // cpu write enable
  input	 cpu_req  ; // CPU Request
  input	 hware_ack; // Hardware Ack
  output data_out ;
  
  reg	 data_out;
  
  //infer the register
  always @(posedge clk or negedge reset_n)
    begin
      if (!reset_n)
	data_out <= RESET_DEFAULT;
      else if (cpu_we & cpu_req) // Set on CPU Request
	 data_out <= 1'b1;
      else if (hware_ack)  // Reset the flag on Hardware ack
	 data_out <= 1'b0;
    end // always @ (posedge clk or negedge reset_n)
endmodule // register


/*********************************************************************
** module: req register.

** description: This register is cleared by cpu writting 1 and set by
                harward req = 1

 Note: When there is a clash between cpu and hardware, 
       hardware is given higher priority

 ***********************************************************************/
module stat_register (
		 //inputs
		 clk,
		 reset_n,
		 cpu_we,		 
		 cpu_ack,
		 hware_req,
		 
		 //outputs
		 data_out
		 );

//---------------------------------
// Reset Default value
//---------------------------------
parameter  RESET_DEFAULT = 1'h0;

  input	 clk      ;
  input	 reset_n  ;
  input	 cpu_we   ; // cpu write enable
  input	 cpu_ack  ; // CPU Ack
  input	 hware_req; // Hardware Req
  output data_out ;
  
  reg	 data_out;
  
  //infer the register
  always @(posedge clk or negedge reset_n)
    begin
      if (!reset_n)
	data_out <= RESET_DEFAULT;
      else if (hware_req)  // Set the flag on Hardware Req
	 data_out <= 1'b1;
      else if (cpu_we & cpu_ack) // Clear on CPU Ack
	 data_out <= 1'b0;
    end // always @ (posedge clk or negedge reset_n)
endmodule // register





/*********************************************************************
 module: generic register
***********************************************************************/
module  generic_register	(
	      //List of Inputs
	      we,		 
	      data_in,
	      reset_n,
	      clk,
	      
	      //List of Outs
	      data_out
	      );

  parameter   WD               = 1;  
  parameter   RESET_DEFAULT    = 0;  
  input [WD-1:0]     we;	
  input [WD-1:0]     data_in;	
  input              reset_n;
  input		     clk;
  output [WD-1:0]    data_out;


generate
  genvar i;
  for (i = 0; i < WD; i = i + 1) begin : gen_bit_reg
    bit_register #(RESET_DEFAULT[i]) u_bit_reg (   
                .we         (we[i]),
                .clk        (clk),
                .reset_n    (reset_n),
                .data_in    (data_in[i]),
                .data_out   (data_out[i])
            );
  end
endgenerate


endmodule


/*********************************************************************
 module: generic interrupt status
***********************************************************************/
module  generic_intr_stat_reg	(
		 //inputs
		 clk,
		 reset_n,
		 reg_we,		 
		 reg_din,
		 hware_req,
		 
		 //outputs
		 data_out
	      );

  parameter   WD               = 1;  
  parameter   RESET_DEFAULT    = 0;  
  input [WD-1:0]     reg_we;	
  input [WD-1:0]     reg_din;	
  input [WD-1:0]     hware_req;	
  input              reset_n;
  input		     clk;
  output [WD-1:0]    data_out;


generate
  genvar i;
  for (i = 0; i < WD; i = i + 1) begin : gen_bit_reg
    stat_register #(RESET_DEFAULT[i]) u_bit_reg (
		 //inputs
		 . clk        (clk           ),
		 . reset_n    (reset_n       ),
		 . cpu_we     (reg_we[i]     ),		 
		 . cpu_ack    (reg_din[i]    ),
		 . hware_req  (hware_req[i]  ),
		 
		 //outputs
		 . data_out  (data_out[i]    )
		 );

  end
endgenerate


endmodule

/*********************************************************************
 module: generic 16b register
***********************************************************************/
module  gen_16b_reg	(
	      //List of Inputs
	      cs,
	      we,		 
	      data_in,
	      reset_n,
	      clk,
	      
	      //List of Outs
	      data_out
	      );

  parameter   RESET_DEFAULT    = 16'h0;  
  input [1:0]      we;	
  input            cs;
  input [15:0]     data_in;	
  input            reset_n;
  input		       clk;
  output [15:0]    data_out;


  reg [15:0]    data_out;

always @ (posedge clk or negedge reset_n) begin 
  if (reset_n == 1'b0) begin
    data_out  <= RESET_DEFAULT ;
  end
  else begin
    if(cs && we[0]) data_out[7:0]   <= data_in[7:0];
    if(cs && we[1]) data_out[15:8]  <= data_in[15:8];
  end
end


endmodule

/*********************************************************************
 module: generic 32b register
***********************************************************************/
module  gen_32b_reg	(
	      //List of Inputs
	      cs,
	      we,		 
	      data_in,
	      reset_n,
	      clk,
	      
	      //List of Outs
	      data_out
	      );

  parameter   RESET_DEFAULT    = 32'h0;  
  input [3:0]      we;	
  input            cs;
  input [31:0]     data_in;	
  input            reset_n;
  input		   clk;
  output [31:0]    data_out;


  reg [31:0]    data_out;

always @ (posedge clk or negedge reset_n) begin 
  if (reset_n == 1'b0) begin
    data_out  <= RESET_DEFAULT ;
  end
  else begin
    if(cs && we[0]) data_out[7:0]   <= data_in[7:0];
    if(cs && we[1]) data_out[15:8]  <= data_in[15:8];
    if(cs && we[2]) data_out[23:16] <= data_in[23:16];
    if(cs && we[3]) data_out[31:24] <= data_in[31:24];
  end
end


endmodule

/*********************************************************************
 module: generic 32b register
***********************************************************************/
module  gen_32b_reg2	(
	      //List of Inputs
          rst_in,
	      cs,
	      we,		 
	      data_in,
	      reset_n,
	      clk,
	      
	      //List of Outs
	      data_out
	      );

  input [31:0]     rst_in;
  input [3:0]      we;	
  input            cs;
  input [31:0]     data_in;	
  input            reset_n;
  input		       clk;
  output [31:0]    data_out;


  reg [31:0]    data_out;

always @ (posedge clk) begin 
  if (reset_n == 1'b0) begin
    data_out  <= rst_in ;
  end
  else begin
    if(cs && we[0]) data_out[7:0]   <= data_in[7:0];
    if(cs && we[1]) data_out[15:8]  <= data_in[15:8];
    if(cs && we[2]) data_out[23:16] <= data_in[23:16];
    if(cs && we[3]) data_out[31:24] <= data_in[31:24];
  end
end


endmodule
