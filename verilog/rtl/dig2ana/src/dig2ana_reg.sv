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
////  Digital To Analog Register                                  ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
////     Manages all the analog related config                    ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 29rd Sept 2022, Dinesh A                            ////
////          initial version                                     ////
//////////////////////////////////////////////////////////////////////


module dig2ana_reg #(   
                        parameter DW = 32,    // DATA WIDTH
                        parameter AW = 4,     // ADDRESS WIDTH
                        parameter BW = 4      // BYTE WIDTH
                    ) (
                       // System Signals
                       // Inputs
		               input logic           mclk                 ,
                       input logic           h_reset_n            ,

		               // Reg Bus Interface Signal
                       input logic           reg_cs               ,
                       input logic           reg_wr               ,
                       input logic [AW-1:0]  reg_addr             ,
                       input logic [DW-1:0]  reg_wdata            ,
                       input logic [BW-1:0]  reg_be               ,

                       // Outputs
                       output logic [DW-1:0] reg_rdata            ,
                       output logic          reg_ack              ,

                       output logic [7:0]    cfg_dac0_mux_sel     ,
                       output logic [7:0]    cfg_dac1_mux_sel     ,
                       output logic [7:0]    cfg_dac2_mux_sel     ,
                       output logic [7:0]    cfg_dac3_mux_sel     



                ); 

//-----------------------------------------------------------------------
// Internal Wire Declarations
//-----------------------------------------------------------------------

logic          sw_rd_en              ;
logic          sw_wr_en              ;
logic [AW-1:0] sw_addr               ; 
logic [DW-1:0] sw_reg_wdata          ;
logic [BW-1:0] sw_be                 ;

logic [DW-1:0] reg_out               ;
logic [DW-1:0] reg_0                 ; 
logic [DW-1:0] reg_1                 ; 
logic [DW-1:0] reg_2                 ; 
logic [DW-1:0] reg_3                 ; 


assign       sw_addr       = reg_addr;
assign       sw_be         = reg_be;
assign       sw_rd_en      = reg_cs & !reg_wr;
assign       sw_wr_en      = reg_cs & reg_wr;
assign       sw_reg_wdata  = reg_wdata;

//-----------------------------------------------------------------------
// register read enable and write enable decoding logic
//-----------------------------------------------------------------------
wire   sw_wr_en_0  = sw_wr_en  & (sw_addr == 4'h0);
wire   sw_wr_en_1  = sw_wr_en  & (sw_addr == 4'h1);
wire   sw_wr_en_2  = sw_wr_en  & (sw_addr == 4'h2);
wire   sw_wr_en_3  = sw_wr_en  & (sw_addr == 4'h3);



always @ (posedge mclk or negedge h_reset_n)
begin : preg_out_Seq
   if (h_reset_n == 1'b0) begin
      reg_rdata  <= 'h0;
      reg_ack    <= 1'b0;
   end else if (reg_cs && !reg_ack) begin
      reg_rdata  <= reg_out[DW-1:0] ;
      reg_ack    <= 1'b1;
   end else begin
      reg_ack    <= 1'b0;
   end
end

//-----------------------------------------------------------------------
//   reg-0
//-----------------------------------------------------------------

assign cfg_dac0_mux_sel = reg_0[7:0];
generic_register #(8,8'h0  ) u_reg0_be0 (
	      .we            ({8{sw_wr_en_0 & 
                             sw_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[7:0]    ),
	      .reset_n       (h_reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_0[7:0]        )
          );

assign reg_0[31:8] = 'h0;

//-----------------------------------------------------------------------
//   reg-1
//-----------------------------------------------------------------

assign cfg_dac1_mux_sel = reg_1[7:0];
generic_register #(8,8'h0  ) u_reg1_be0 (
	      .we            ({8{sw_wr_en_1 & 
                             sw_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[7:0]    ),
	      .reset_n       (h_reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_1[7:0]        )
          );

assign reg_1[31:8] = 'h0;

//-----------------------------------------------------------------------
//   reg-2
//-----------------------------------------------------------------

assign cfg_dac2_mux_sel = reg_2[7:0];
generic_register #(8,8'h0  ) u_reg2_be0 (
	      .we            ({8{sw_wr_en_2 & 
                             sw_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[7:0]    ),
	      .reset_n       (h_reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_2[7:0]        )
          );

assign reg_2[31:8] = 'h0;

//-----------------------------------------------------------------------
//   reg-3
//-----------------------------------------------------------------

assign cfg_dac3_mux_sel = reg_3[7:0];
generic_register #(8,8'h0  ) u_reg3_be0 (
	      .we            ({8{sw_wr_en_3 & 
                             sw_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[7:0]    ),
	      .reset_n       (h_reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_3[7:0]        )
          );

assign reg_3[31:8] = 'h0;

//-----------------------------------------------------------------------
// Register Read Path Multiplexer instantiation
//-----------------------------------------------------------------------

always_comb
begin 
  reg_out [31:0] = 32'h0;

  case (sw_addr [3:0])
    4'b0000 : reg_out [31:0] = reg_0  ;     
    4'b0001 : reg_out [31:0] = reg_1  ;    
    4'b0010 : reg_out [31:0] = reg_2  ;     
    4'b0011 : reg_out [31:0] = reg_3  ;    
    default  : reg_out [31:0] = 32'h0;
  endcase
end


endmodule
