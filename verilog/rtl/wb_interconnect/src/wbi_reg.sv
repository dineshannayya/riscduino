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
////  Wishbone Inter-connect Register                             ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
////      Hold all the Register                                   ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 9th Feb 2023, Dinesh A                              ////
////          initial version                                     ////
//////////////////////////////////////////////////////////////////////
//

module wbi_reg (
                       // System Signals
                       // Inputs
		               input logic             mclk                   ,
	                   input logic             reset_n                ,  // external reset


		       // Reg Bus Interface Signal
                       input logic             reg_cs                 ,
                       input logic             reg_wr                 ,
                       input logic [4:0]       reg_addr               ,
                       input logic [31:0]      reg_wdata              ,
                       input logic [3:0]       reg_be                 ,

                       // Outputs
                       output logic [31:0]     reg_rdata              ,
                       output logic            reg_ack                ,

                       // Dynamic Clock gate config
                       output logic [31:0]      cfg_dcg_ctrl          ,

                       // clock gate indication
                       input  logic [7:0]      stat_reg_req           , // Register Request
                       input  logic [7:0]      stat_clk_gate            // Clock Gate Status

   ); 


                       
//-----------------------------------------------------------------------
// Internal Wire Declarations
//-----------------------------------------------------------------------

logic          sw_rd_en               ;
logic          sw_wr_en;
logic [2:0]    sw_addr; // addressing 16 registers
logic [31:0]   sw_reg_wdata;
logic [3:0]    wr_be  ;

logic [31:0]   reg_out;
logic [31:0]   reg_0;  
logic [31:0]   reg_1;  
logic [31:0]   reg_2;  
logic [31:0]   reg_3;  
logic [31:0]   reg_4;  
logic [31:0]   reg_5;  
logic [31:0]   reg_6;  
logic [31:0]   reg_7;  

assign       sw_addr       = reg_addr [4:2] ;
assign       sw_rd_en      = reg_cs & !reg_wr;
assign       sw_wr_en      = reg_cs & reg_wr;
assign       wr_be         = reg_be;
assign       sw_reg_wdata  = reg_wdata;


always @ (posedge mclk or negedge reset_n)
begin : preg_out_Seq
   if (reset_n == 1'b0) begin
      reg_rdata  <= 'h0;
      reg_ack    <= 1'b0;
   end else if (reg_cs && !reg_ack) begin
      reg_rdata <= reg_out ;
      reg_ack   <= 1'b1;
   end else begin
      reg_ack        <= 1'b0;
   end
end



//-----------------------------------------------------------------------
// register read enable and write enable decoding logic
//-----------------------------------------------------------------------
wire   sw_wr_en_0  = sw_wr_en  & (sw_addr == 3'h0);
wire   sw_wr_en_1  = sw_wr_en  & (sw_addr == 3'h1);
wire   sw_wr_en_2  = sw_wr_en  & (sw_addr == 3'h2);
wire   sw_wr_en_3  = sw_wr_en  & (sw_addr == 3'h3);
wire   sw_wr_en_4  = sw_wr_en  & (sw_addr == 3'h4);
wire   sw_wr_en_5  = sw_wr_en  & (sw_addr == 3'h5);
wire   sw_wr_en_6  = sw_wr_en  & (sw_addr == 3'h6);
wire   sw_wr_en_7  = sw_wr_en  & (sw_addr == 3'h7);

wire   sw_rd_en_0  = sw_rd_en  & (sw_addr == 3'h0);
wire   sw_rd_en_1  = sw_rd_en  & (sw_addr == 3'h1);
wire   sw_rd_en_2  = sw_rd_en  & (sw_addr == 3'h2);
wire   sw_rd_en_3  = sw_rd_en  & (sw_addr == 3'h3);
wire   sw_rd_en_4  = sw_rd_en  & (sw_addr == 3'h4);
wire   sw_rd_en_5  = sw_rd_en  & (sw_addr == 3'h5);
wire   sw_rd_en_6  = sw_rd_en  & (sw_addr == 3'h6);
wire   sw_rd_en_7  = sw_rd_en  & (sw_addr == 3'h7);

//-----------------------------------------------------------------------
// Individual register assignments
//-----------------------------------------------------------------------
//------------------------------------------
// reg-0: GLBL_STATUS_0
//------------------------------------------

assign reg_0 = {16'h0,stat_clk_gate,stat_reg_req};


//------------------------------------------
// reg-1: GLBL_CFG_0
//------------------------------------------
assign cfg_dcg_ctrl = reg_1;


gen_32b_reg  #(32'h0) u_reg_1	(
	      //List of Inputs
	      .reset_n    (reset_n       ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_1    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_1         )
	      );

//----------------------------------------------
// reg-2: GLBL_CFG_1
//------------------------------------------


gen_32b_reg  u_reg_2	(
	      //List of Inputs
	      .reset_n    (reset_n       ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_2    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_2         )
	      );

//-----------------------------------------------------------------------
// reg-3 : GLBL_CFG_2
//-----------------------------------------------------------------------

gen_32b_reg  #(32'h0) u_reg_3	(
	      //List of Inputs
	      .reset_n    (reset_n       ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_3    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_3         )
	      );

//-----------------------------------------------------------------------
// reg-4 : GLBL_CFG_3
//-----------------------------------------------------------------------

gen_32b_reg  #(32'h0) u_reg_4	(
	      //List of Inputs
	      .reset_n    (reset_n       ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_4    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_4         )
	      );

//-----------------------------------------------------------------------
// reg-5 : GLBL_CFG_4
//-----------------------------------------------------------------------

gen_32b_reg  #(32'h0) u_reg_5	(
	      //List of Inputs
	      .reset_n    (reset_n       ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_5    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_5         )
	      );


//-----------------------------------------------------------------------
// reg-6 : GLBL_CFG_5
//-----------------------------------------------------------------------

gen_32b_reg  #(32'h0) u_reg_6	(
	      //List of Inputs
	      .reset_n    (reset_n       ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_6    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_6         )
	      );

//-----------------------------------------------------------------------
// reg-7 : GLBL_CFG_6
//-----------------------------------------------------------------------

gen_32b_reg  #(32'h0) u_reg_7	(
	      //List of Inputs
	      .reset_n    (reset_n       ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_7    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_7         )
	      );

//-----------------------------------------------------------------------
// Register Read Path Multiplexer instantiation
//-----------------------------------------------------------------------

always_comb
begin 
  reg_out [31:0] = 32'h0;

  case (sw_addr [2:0])
    3'b000   : reg_out [31:0] = reg_0  ;     
    3'b001   : reg_out [31:0] = reg_1  ;    
    3'b010   : reg_out [31:0] = reg_2  ;     
    3'b011   : reg_out [31:0] = reg_3  ;    
    3'b100   : reg_out [31:0] = reg_4  ;    
    3'b101   : reg_out [31:0] = reg_5  ;    
    3'b110   : reg_out [31:0] = reg_6  ;    
    3'b111   : reg_out [31:0] = reg_7  ;    
    default  : reg_out [31:0] = 32'h0;
  endcase
end



endmodule                       
