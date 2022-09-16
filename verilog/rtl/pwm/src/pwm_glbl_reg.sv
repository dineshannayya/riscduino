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
// SPDX-FileContributor: Created by Dinesh Annayya <dinesh.annayya@gmail.com>
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
////    0.2 - 13th Sept 2022, Dinesh A                            ////
////          Change Register to PWM Based                        ////
//////////////////////////////////////////////////////////////////////
//
module pwm_glbl_reg  (
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

                       output logic [5:0]    cfg_pwm_enb        , // PWM operation enable
                       output logic [5:0]    cfg_pwm_run        , // PWM operation Run
                       output logic [5:0]    cfg_pwm_dupdate    , // Disable Config update

                       input logic [5:0]     pwm_os_done        , // Indicate oneshot sequence over
                       input logic [5:0]     pwm_ovflow         , // pwm sequence cross over
                       input logic [5:0]     gpio_tgr           , // Enable PWM based on trigger

                       output logic          pwm_intr 
                       

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
logic [31:0]   reg_0           ; // CONFIG - Unused
logic [31:0]   reg_1           ; // PWM-REG-0
logic [31:0]   reg_2           ; // PWM-REG-1
logic [31:0]   reg_3           ; // PWM-REG-2

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


//-----------------------------------------
// PWM Enable Generation
//----------------------------------------

assign cfg_pwm_enb      = {3'b0,reg_0[2:0]};
assign cfg_pwm_run      = {3'b0,reg_0[10:8]};
assign cfg_pwm_dupdate  = {3'b0,reg_0[18:16]};

//------------------------------------------------------------------------
// Design wise has avoided the pwm_os_done & gpio_tgr occur at same cycle
//------------------------------------------------------------------------
logic [2:0] reg_0_0;
always @ (posedge mclk or negedge h_reset_n)
begin 
   if (h_reset_n == 1'b0) begin
      reg_0_0[2:0]  <= 'h0;
   end else if (reg_cs && sw_wr_en_0 && sw_be[0] && reg_ack) begin
      reg_0_0[2:0]  <= sw_reg_wdata[2:0] ;
   end
end
assign reg_0[2:0] = reg_0_0; // Modified due to iverilog issue
assign reg_0[7:3] = 'h0;

logic [2:0] reg_0_1;
always @ (posedge mclk or negedge h_reset_n)
begin 
   if (h_reset_n == 1'b0) begin
      reg_0_1[2:0]  <= 'h0;
   end else if (reg_cs && sw_wr_en_0 && sw_be[1] && reg_ack) begin
      reg_0_1[2:0]  <= sw_reg_wdata[10:8] | gpio_tgr;
   end else begin
      reg_0_1[2:0]  <= (reg_0_1[2:0] | gpio_tgr) ^ pwm_os_done;
   end
end
assign reg_0[10:8] = reg_0_1; // Modified due to iverilog issue
assign reg_0[15:11] = 'h0;

logic [2:0] reg_0_2;
always @ (posedge mclk or negedge h_reset_n)
begin 
   if (h_reset_n == 1'b0) begin
      reg_0_2[2:0]  <= 'h0;
   end else if (reg_cs && sw_wr_en_0 && sw_be[2] && reg_ack) begin
      reg_0_2[2:0]  <= sw_reg_wdata[18:16] ;
   end
end
assign reg_0[18:16] = reg_0_2; // Modified due to iverilog issue
assign reg_0[31:19] = 'h0;

//-----------------------------------------------------------------------
// Logic for PWM-1 Config - Reserved
//-----------------------------------------------------------------------
assign  reg_1 = 'h0;


//-----------------------------------------------------------------------
// Reg-2: Interrupt Mask
//-----------------------------------------------------------------------

generic_register #(6,6'h0  ) u_reg_2 (
	      .we            ({6{sw_wr_en_2 & 
                             reg_ack    & 
                             sw_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[5:0] ),
	      .reset_n       (h_reset_n         ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_2[5:0]        )
          );

assign reg_2[31:6] = 'h0;
//-----------------------------------------------------------------------
// Reg-3: Interrupt Status
//-----------------------------------------------------------------------

assign  pwm_intr     = |(reg_2[5:0] & reg_3[5:0]); 

generic_intr_stat_reg #(.WD(6),
	                .RESET_DEFAULT(0)) u_reg4 (
		 //inputs
		 .clk         (mclk               ),
		 .reset_n     (h_reset_n          ),
         .reg_we      ({6{sw_wr_en_3 & 
                          reg_ack    & 
                          sw_be[0]}}),	      
		 .reg_din     ( sw_reg_wdata[5:0]  ),
		 .hware_req   ( pwm_ovflow         ), 
		 
		 //outputs
		 .data_out    ( reg_3[5:0]         )
	      );

assign reg_3[31:6] = 'h0;

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
