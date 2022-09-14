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
////  PWM Register                                                ////
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
module pwm_reg  (
                       // System Signals
                       // Inputs
		               input logic           mclk               ,
                       input logic           h_reset_n          ,

		               // Reg Bus Interface Signal
                       input logic           reg_cs             ,
                       input logic           reg_wr             ,
                       input logic [2:0]     reg_addr           ,
                       input logic [31:0]    reg_wdata          ,
                       input logic [3:0]     reg_be             ,

                       // Outputs
                       output logic [31:0]   reg_rdata          ,
                       output logic          reg_ack            ,

                       output logic [15:0]    cfg_pwm0_high     ,
                       output logic [15:0]    cfg_pwm0_low      ,
                       output logic [15:0]    cfg_pwm1_high     ,
                       output logic [15:0]    cfg_pwm1_low      ,
                       output logic [15:0]    cfg_pwm2_high     ,
                       output logic [15:0]    cfg_pwm2_low      ,
                       output logic [15:0]    cfg_pwm3_high     ,
                       output logic [15:0]    cfg_pwm3_low      ,
                       output logic [15:0]    cfg_pwm4_high     ,
                       output logic [15:0]    cfg_pwm4_low      ,
                       output logic [15:0]    cfg_pwm5_high     ,
                       output logic [15:0]    cfg_pwm5_low      

                ); 

//-----------------------------------------------------------------------
// Internal Wire Declarations
//-----------------------------------------------------------------------

logic          sw_rd_en        ;
logic          sw_wr_en        ;
logic [2:0]    sw_addr         ; // addressing 16 registers
logic [31:0]   sw_reg_wdata    ;
logic [3:0]    sw_be           ;

logic [31:0]   reg_out         ;
logic [31:0]   reg_0           ; // CONFIG - Unused
logic [31:0]   reg_1           ; // PWM-REG-0
logic [31:0]   reg_2           ; // PWM-REG-1
logic [31:0]   reg_3           ; // PWM-REG-2
logic [31:0]   reg_4           ; // PWM-REG-3
logic [31:0]   reg_5           ; // PWM-REG-4
logic [31:0]   reg_6           ; // PWM-REG-5

assign       sw_addr       = reg_addr;
assign       sw_rd_en      = reg_cs & !reg_wr;
assign       sw_wr_en      = reg_cs & reg_wr;
assign       sw_be         = reg_be;
assign       sw_reg_wdata  = reg_wdata;

//-----------------------------------------------------------------------
// register read enable and write enable decoding logic
//-----------------------------------------------------------------------
wire   sw_wr_en_0 = sw_wr_en  & (sw_addr == 3'h0);
wire   sw_wr_en_1 = sw_wr_en  & (sw_addr == 3'h1);
wire   sw_wr_en_2 = sw_wr_en  & (sw_addr == 3'h2);
wire   sw_wr_en_3 = sw_wr_en  & (sw_addr == 3'h3);
wire   sw_wr_en_4 = sw_wr_en  & (sw_addr == 3'h4);
wire   sw_wr_en_5 = sw_wr_en  & (sw_addr == 3'h5);
wire   sw_wr_en_6 = sw_wr_en  & (sw_addr == 3'h6);

wire   sw_rd_en_0 = sw_rd_en  & (sw_addr == 3'h0);
wire   sw_rd_en_1 = sw_rd_en  & (sw_addr == 3'h1);
wire   sw_rd_en_2 = sw_rd_en  & (sw_addr == 3'h2);
wire   sw_rd_en_3 = sw_rd_en  & (sw_addr == 3'h3);
wire   sw_rd_en_4 = sw_rd_en  & (sw_addr == 3'h4);
wire   sw_rd_en_5 = sw_rd_en  & (sw_addr == 3'h5);
wire   sw_rd_en_6 = sw_rd_en  & (sw_addr == 3'h6);


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

//--------------------------------------------
// reg-0: Reserve for pwm global config
//---------------------------------------------
assign reg_0 = 'h0;
//-----------------------------------------------------------------------
// Logic for PWM-0 Config
//-----------------------------------------------------------------------
assign  cfg_pwm0_low  = reg_1[15:0];  // low period of w/f 
assign  cfg_pwm0_high = reg_1[31:16]; // high period of w/f 

gen_32b_reg  #(32'h0) u_reg_1	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_1    ),
	      .we         (sw_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_1         )
	      );


//-----------------------------------------------------------------------
// Logic for PWM-1 Config
//-----------------------------------------------------------------------
assign  cfg_pwm1_low  = reg_2[15:0];  // low period of w/f 
assign  cfg_pwm1_high = reg_2[31:16]; // high period of w/f 
gen_32b_reg  #(32'h0) u_reg_2	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_2    ),
	      .we         (sw_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_2         )
	      );

//-----------------------------------------------------------------------
// Logic for PWM-2 Config
//-----------------------------------------------------------------------
assign  cfg_pwm2_low  = reg_3[15:0];  // low period of w/f 
assign  cfg_pwm2_high = reg_3[31:16]; // high period of w/f 
gen_32b_reg  #(32'h0) u_reg_3	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_3   ),
	      .we         (sw_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_3        )
	      );

//-----------------------------------------------------------------------
// Logic for PWM-3 Config
//-----------------------------------------------------------------------
assign  cfg_pwm3_low  = reg_4[15:0];  // low period of w/f 
assign  cfg_pwm3_high = reg_4[31:16]; // high period of w/f 
gen_32b_reg  #(32'h0) u_reg_4	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_4   ),
	      .we         (sw_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_4        )
	      );

//-----------------------------------------------------------------------
// Logic for PWM-4 Config
//-----------------------------------------------------------------------
assign  cfg_pwm4_low  = reg_5[15:0];  // low period of w/f 
assign  cfg_pwm4_high = reg_5[31:16]; // high period of w/f 

gen_32b_reg  #(32'h0) u_reg_5	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_5   ),
	      .we         (sw_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_5        )
	      );

//-----------------------------------------------------------------------
// Logic for PWM-5 Config
//-----------------------------------------------------------------------
assign  cfg_pwm5_low  = reg_6[15:0];  // low period of w/f 
assign  cfg_pwm5_high = reg_6[31:16]; // high period of w/f 

gen_32b_reg  #(32'h0) u_reg_6	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_6    ),
	      .we         (sw_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_6        )
	      );


always_comb
begin 
  reg_out [31:0] = 32'h0;

  case (sw_addr [2:0])
    3'b000    : reg_out [31:0] = reg_0 [31:0];     
    3'b001    : reg_out [31:0] = reg_1 [31:0];    
    3'b010    : reg_out [31:0] = reg_2 [31:0];     
    3'b011    : reg_out [31:0] = reg_3 [31:0];    
    3'b100    : reg_out [31:0] = reg_4 [31:0];    
    3'b101    : reg_out [31:0] = reg_5 [31:0];    
    3'b110    : reg_out [31:0] = reg_6 [31:0];    
    default   : reg_out [31:0] = 32'h0;
  endcase
end

endmodule
