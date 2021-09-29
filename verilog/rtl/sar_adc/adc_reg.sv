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
////  ADC register                                                ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
////      This block generate all the ADC config and status       ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 26 Sept 2021  Dinesh A                              ////
////          Initial version                                     ////
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

module adc_reg (

        input logic             mclk,
        input logic             reset_n,

        // Reg Bus Interface Signal
        input logic             reg_cs,
        input logic             reg_wr,
        input logic [7:0]       reg_addr,
        input logic [31:0]      reg_wdata,
        input logic [3:0]       reg_be,

       // Outputs
        output logic [31:0]     reg_rdata,
        output logic            reg_ack,

	input  logic            pulse1m_mclk,
       // ADC I/F
       output logic            start_conv,
       output logic [2:0]      adc_ch_no,           
       input  logic            conv_done,
       input  logic [7:0]      adc_result


        );



//-----------------------------------------------------------------------
// Internal Wire Declarations
//-----------------------------------------------------------------------

logic           sw_rd_en;
logic           sw_wr_en;
logic  [3:0]    sw_addr ; // addressing 16 registers
logic  [3:0]    wr_be   ;
logic  [31:0]   sw_reg_wdata;

logic           reg_cs_l    ;
logic           reg_cs_2l    ;


logic [31:0]    reg_0;  // ADC Config
logic [31:0]    reg_1;  // ADC Ch-1 Result
logic [31:0]    reg_2;  // ADC Ch-2 Result 
logic [31:0]    reg_3;  // ADC Ch-3 Result
logic [31:0]    reg_4;  // ADC Ch-4 Result
logic [31:0]    reg_5;  // ADC Ch-5 Result
logic [31:0]    reg_6;  // ADC Ch-6 Result
logic [31:0]    reg_7;  // Software-Reg_7
logic [31:0]    reg_out;

//-----------------------------------------------------------------------
// Main code starts here
//-----------------------------------------------------------------------

//-----------------------------------------------------------------------
// To avoid interface timing, all the content are registered
//-----------------------------------------------------------------------
always @ (posedge mclk or negedge reset_n)
begin 
   if (reset_n == 1'b0)
   begin
    sw_addr       <= '0;
    sw_rd_en      <= '0;
    sw_wr_en      <= '0;
    sw_reg_wdata  <= '0;
    wr_be         <= '0;
    reg_cs_l      <= '0;
    reg_cs_2l     <= '0;
  end else begin
    sw_addr       <= reg_addr [5:2];
    sw_rd_en      <= reg_cs & !reg_wr;
    sw_wr_en      <= reg_cs & reg_wr;
    sw_reg_wdata  <= reg_wdata;
    wr_be         <= reg_be;
    reg_cs_l      <= reg_cs;
    reg_cs_2l     <= reg_cs_l;
  end
end


//-----------------------------------------------------------------------
// Read path mux
//-----------------------------------------------------------------------

always @ (posedge mclk or negedge reset_n)
begin : preg_out_Seq
   if (reset_n == 1'b0) begin
      reg_rdata [31:0]  <= 32'h0000_0000;
      reg_ack           <= 1'b0;
   end else if (sw_rd_en && !reg_ack && !reg_cs_2l) begin
      reg_rdata [31:0]  <= reg_out [31:0];
      reg_ack           <= 1'b1;
   end else if (sw_wr_en && !reg_ack && !reg_cs_2l) begin 
      reg_ack           <= 1'b1;
   end else begin
      reg_ack        <= 1'b0;
   end
end


//-----------------------------------------------------------------------
// register read enable and write enable decoding logic
//-----------------------------------------------------------------------
wire   sw_wr_en_0 = sw_wr_en & (sw_addr == 4'h0);
wire   sw_rd_en_0 = sw_rd_en & (sw_addr == 4'h0);
wire   sw_wr_en_1 = sw_wr_en & (sw_addr == 4'h1);
wire   sw_rd_en_1 = sw_rd_en & (sw_addr == 4'h1);
wire   sw_wr_en_2 = sw_wr_en & (sw_addr == 4'h2);
wire   sw_rd_en_2 = sw_rd_en & (sw_addr == 4'h2);
wire   sw_wr_en_3 = sw_wr_en & (sw_addr == 4'h3);
wire   sw_rd_en_3 = sw_rd_en & (sw_addr == 4'h3);
wire   sw_wr_en_4 = sw_wr_en & (sw_addr == 4'h4);
wire   sw_rd_en_4 = sw_rd_en & (sw_addr == 4'h4);
wire   sw_wr_en_5 = sw_wr_en & (sw_addr == 4'h5);
wire   sw_rd_en_5 = sw_rd_en & (sw_addr == 4'h5);
wire   sw_wr_en_6 = sw_wr_en & (sw_addr == 4'h6);
wire   sw_rd_en_6 = sw_rd_en & (sw_addr == 4'h6);
wire   sw_wr_en_7 = sw_wr_en & (sw_addr == 4'h7);
wire   sw_rd_en_7 = sw_rd_en & (sw_addr == 4'h7);

always @( *)
begin : preg_sel_Com

  reg_out [31:0] = 32'd0;

  case (sw_addr [3:0])
    4'b0000 : reg_out [31:0] = reg_0 [31:0];     
    4'b0001 : reg_out [31:0] = {24'h0,reg_1 [7:0]};    
    4'b0010 : reg_out [31:0] = {24'h0,reg_2 [7:0]};     
    4'b0011 : reg_out [31:0] = {24'h0,reg_3 [7:0]};    
    4'b0100 : reg_out [31:0] = {24'h0,reg_4 [7:0]};    
    4'b0101 : reg_out [31:0] = {24'h0,reg_5 [7:0]};    
    4'b0110 : reg_out [31:0] = {24'h0,reg_6 [7:0]};    
    default : reg_out [31:0] = 'h0;
  endcase
end



//-----------------------------------------------------------------------
// Individual register assignments
//-----------------------------------------------------------------------
logic [5:0] cfg_adc_enb = reg_0[5:0];

gen_32b_reg  #(32'h0) u_reg_0	(
	      //List of Inputs
	      .reset_n    (reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_0    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_0        )
	      );


always @(posedge mclk or negedge reset_n)
begin
   if(~reset_n) begin
      reg_1[7:0]   <= 8'h0;
      reg_2[7:0]   <= 8'h0;
      reg_3[7:0]   <= 8'h0;
      reg_4[7:0]   <= 8'h0;
      reg_5[7:0]   <= 8'h0;
      reg_6[7:0]   <= 8'h0;
      start_conv   <= '0;
      adc_ch_no    <= '0;
   end else begin
      if(cfg_adc_enb[0] && pulse1m_mclk) begin
	 if(start_conv && conv_done) begin
            start_conv <= 0;
	    case(adc_ch_no)
	    3'b000: reg_1[7:0] <= adc_result;
	    3'b001: reg_2[7:0] <= adc_result;
	    3'b010: reg_3[7:0] <= adc_result;
	    3'b011: reg_4[7:0] <= adc_result;
	    3'b100: reg_5[7:0] <= adc_result;
	    3'b101: reg_6[7:0] <= adc_result;
	    endcase
         end
      end else begin
	 start_conv <= 1;
	 if(adc_ch_no == 5) begin
	    adc_ch_no <= 0;
         end else begin
	    adc_ch_no    <= adc_ch_no+1;
	 end
      end
   end
end




endmodule
