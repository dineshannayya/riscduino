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
////  Timer Register                                              ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 15th Aug 2022, Dinesh A                             ////
////          initial version                                     ////
//////////////////////////////////////////////////////////////////////
//
module timer_reg  (
                       // System Signals
                       // Inputs
		               input logic           mclk               ,
                       input logic           h_reset_n          ,

		               // Reg Bus Interface Signal
                       input logic           reg_cs             ,
                       input logic           reg_wr             ,
                       input logic [1:0]     reg_addr           ,
                       input logic [31:0]    reg_wdata          ,
                       input logic [3:0]     reg_be             ,

                       // Outputs
                       output logic [31:0]   reg_rdata          ,
                       output logic          reg_ack            ,

                       output logic [9:0]    cfg_pulse_1us      ,
                       output logic [2:0]    cfg_timer_update   , // CPU write to timer register
                       output logic [18:0]   cfg_timer0         , // Timer-0 register
                       output logic [18:0]   cfg_timer1         , // Timer-1 register
                       output logic [18:0]   cfg_timer2           // Timer-2 register

                ); 

//-----------------------------------------------------------------------
// Internal Wire Declarations
//-----------------------------------------------------------------------

logic          sw_rd_en        ;
logic          sw_wr_en        ;
logic [1:0]    sw_addr         ; // addressing 16 registers
logic [31:0]   sw_reg_wdata    ;
logic [3:0]    sw_be           ;

logic [31:0]   reg_out         ;
logic [31:0]   reg_0           ;  // TIMER GLOBAL CONFIG
logic [31:0]   reg_1           ;  // TIMER-0
logic [31:0]   reg_2           ;  // TIMER-1
logic [31:0]   reg_3           ;  // TIMER-2

assign       sw_addr       = reg_addr;
assign       sw_rd_en      = reg_cs & !reg_wr;
assign       sw_wr_en      = reg_cs & reg_wr;
assign       sw_be         = reg_be;
assign       sw_reg_wdata  = reg_wdata;

//-----------------------------------------------------------------------
// register read enable and write enable decoding logic
//-----------------------------------------------------------------------
wire   sw_wr_en_0 = sw_wr_en  & (sw_addr == 2'h0);
wire   sw_wr_en_1 = sw_wr_en  & (sw_addr == 2'h1);
wire   sw_wr_en_2 = sw_wr_en  & (sw_addr == 2'h2);
wire   sw_wr_en_3 = sw_wr_en  & (sw_addr == 2'h3);

wire   sw_rd_en_0 = sw_rd_en  & (sw_addr == 2'h0);
wire   sw_rd_en_1 = sw_rd_en  & (sw_addr == 2'h1);
wire   sw_rd_en_2 = sw_rd_en  & (sw_addr == 2'h2);
wire   sw_rd_en_3 = sw_rd_en  & (sw_addr == 2'h3);


always @ (posedge mclk or negedge h_reset_n)
begin : preg_out_Seq
   if (h_reset_n == 1'b0) begin
      reg_rdata  <= 'h0;
      reg_ack    <= 1'b0;
   end else if (reg_cs && !reg_ack) begin
      reg_rdata  <= reg_out;
      reg_ack    <= 1'b1;
   end else begin
      reg_ack    <= 1'b0;
   end
end


//----------------------------------------------
// reg-0: GLBL_CFG
//------------------------------------------

gen_32b_reg  #('h0) u_reg_0	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_0    ),
	      .we         (sw_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_0         )
	      );

assign cfg_pulse_1us       = reg_0[9:0];

//-----------------------------------------------------------------------
//   reg-1
// Assumption: wr_en is two cycle and reg_ack is asserted in second cycle
//     In first cycle, local register will be updated
//     In second cycle, update indication sent to timer block
//   -----------------------------------------------------------------
assign cfg_timer0          = reg_1[18:0];
assign cfg_timer_update[0] = sw_wr_en_1 & reg_ack; 

gen_32b_reg  #(32'h0) u_reg_1	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_1    ),
	      .we         (sw_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_1[31:0]  )
	      );

//-----------------------------------------------------------------------
//   reg-2
// Assumption: wr_en is two cycle and reg_ack is asserted in second cycle
//     In first cycle, local register will be updated
//     In second cycle, update indication sent to timer block
//   -----------------------------------------------------------------
assign cfg_timer1          = reg_2[18:0];
assign cfg_timer_update[1] = sw_wr_en_2 & reg_ack;

gen_32b_reg  #(32'h0) u_reg_2	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_2    ),
	      .we         (sw_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_2[31:0]   )
	      );


//-----------------------------------------------------------------------
//   reg-3
// Assumption: wr_en is two cycle and reg_ack is asserted in second cycle
//     In first cycle, local register will be updated
//     In second cycle, update indication sent to timer block
//   -----------------------------------------------------------------
assign cfg_timer2          = reg_3[18:0];
assign cfg_timer_update[2] = sw_wr_en_3 & reg_ack;

gen_32b_reg  #(32'h0) u_reg_3	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_3    ),
	      .we         (sw_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_3[31:0]   )
	      );

//-----------------------------------------------------------------------
// Register Read Path Multiplexer instantiation
//-----------------------------------------------------------------------

always_comb
begin 
  reg_out [31:0] = 32'h0;

  case (sw_addr [1:0])
    2'b00    : reg_out [31:0] = reg_0 [31:0];     
    2'b01    : reg_out [31:0] = reg_1 [31:0];    
    2'b10    : reg_out [31:0] = reg_2 [31:0];     
    2'b11    : reg_out [31:0] = reg_3 [31:0];    
    default  : reg_out [31:0] = 32'h0;
  endcase
end

endmodule
