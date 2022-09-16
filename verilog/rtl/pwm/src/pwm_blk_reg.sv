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
module pwm_blk_reg  (
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

                       input logic            cfg_pwm_enb       , // PWM operation enable
                       input logic            cfg_pwm_dupdate   , // Disable Config update
                       input logic            pwm_cfg_update    , // Update the pwm config on roll-over or completion
                       
                       output logic [3:0]     cfg_pwm_scale     , // clock scaling
                       output logic           cfg_pwm_oneshot   , // PWM OneShot mode
                       output logic           cfg_pwm_frun      , // PWM is free running
                       output logic           cfg_pwm_gpio_enb  , // PWM GPIO based trigger enable
                       output logic           cfg_pwm_gpio_edge , // PWM GPIO based trigger edge
                       output logic [2:0]     cfg_pwm_gpio_sel  , // GPIO Selection
                       output logic           cfg_pwm_hold      , // Hold data PWM data During PWM Disable
                       output logic           cfg_pwm_inv       , // invert output
                       output logic           cfg_pwm_zeropd    , // Reset on pmw_cnt match to period
                       output logic [1:0]     cfg_pwm_mode      , // PWM Pulse Generation mode
                       output logic           cfg_comp0_center  , // Compare cnt at comp0 center
                       output logic           cfg_comp1_center  , // Compare cnt at comp1 center
                       output logic           cfg_comp2_center  , // Compare cnt at comp2 center
                       output logic           cfg_comp3_center  , // Compare cnt at comp3 center
                       output logic [15:0]    cfg_pwm_period    , // PWM period
                       output logic [15:0]    cfg_pwm_comp0     , // compare0
                       output logic [15:0]    cfg_pwm_comp1     , // compare1
                       output logic [15:0]    cfg_pwm_comp2     , // compare2
                       output logic [15:0]    cfg_pwm_comp3       // compare3

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

//--------------------------------------------
// PWM-0 Config
//---------------------------------------------
logic [31:0] pwm_cfg0;

assign cfg_pwm_scale     = pwm_cfg0[3:0];
assign cfg_pwm_oneshot   = pwm_cfg0[4];
assign cfg_pwm_frun      = pwm_cfg0[5];
assign cfg_pwm_gpio_enb  = pwm_cfg0[6];
assign cfg_pwm_gpio_edge = pwm_cfg0[7]; // 1 -> negedge
assign cfg_pwm_gpio_sel  = pwm_cfg0[10:8];
assign cfg_pwm_hold      = pwm_cfg0[11];
assign cfg_pwm_mode      = pwm_cfg0[13:12];
assign cfg_pwm_inv       = pwm_cfg0[14];
assign cfg_pwm_zeropd    = pwm_cfg0[15]; // Reset on Matching Period
assign cfg_comp0_center  = pwm_cfg0[16];
assign cfg_comp1_center  = pwm_cfg0[17];
assign cfg_comp2_center  = pwm_cfg0[18];
assign cfg_comp3_center  = pwm_cfg0[19];

gen_32b_reg  #(32'h0) u_reg_0	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_0    ),
	      .we         (sw_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_0         )
	      );

pwm_cfg_dglitch u_dglitch_0 (
		  .mclk           (mclk               ),
          .h_reset_n      (h_reset_n          ),

          .enb            (cfg_pwm_enb        ), 
          .cfg_update     (pwm_cfg_update     ), 
          .cfg_dupdate    (cfg_pwm_dupdate    ), 
          .reg_in         (reg_0              ),
          .reg_out        (pwm_cfg0           )    


          );
//-----------------------------------------------------------------------
// Logic for PWM-1 Config
//-----------------------------------------------------------------------
logic [31:0] pwm_cfg1;
assign  cfg_pwm_period = pwm_cfg1[15:0];

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

pwm_cfg_dglitch u_dglitch_1 (
		  .mclk           (mclk               ),
          .h_reset_n      (h_reset_n          ),

          .enb            (cfg_pwm_enb        ), 
          .cfg_update     (pwm_cfg_update     ), 
          .cfg_dupdate    (cfg_pwm_dupdate    ), 
          .reg_in         (reg_1              ),
          .reg_out        (pwm_cfg1           )    


          );

//-----------------------------------------------------------------------
// Logic for PWM-2 Config
//-----------------------------------------------------------------------
logic [31:0] pwm_cfg2;
assign  cfg_pwm_comp0  = pwm_cfg2[15:0];  // Comparator-0
assign  cfg_pwm_comp1  = pwm_cfg2[31:16]; // Comparator-1
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

pwm_cfg_dglitch u_dglitch_2 (
		  .mclk           (mclk               ),
          .h_reset_n      (h_reset_n          ),

          .enb            (cfg_pwm_enb        ), 
          .cfg_update     (pwm_cfg_update     ), 
          .cfg_dupdate    (cfg_pwm_dupdate    ), 
          .reg_in         (reg_2              ),
          .reg_out        (pwm_cfg2           )    


          );
//-----------------------------------------------------------------------
// Logic for PWM-3 Config
//-----------------------------------------------------------------------
logic [31:0] pwm_cfg3;
assign  cfg_pwm_comp2  = reg_3[15:0];  // Comparator-2
assign  cfg_pwm_comp3  = reg_3[31:16]; // Comparator-3
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


pwm_cfg_dglitch u_dglitch_3 (
		  .mclk           (mclk               ),
          .h_reset_n      (h_reset_n          ),

          .enb            (cfg_pwm_enb        ), 
          .cfg_update     (pwm_cfg_update     ), 
          .cfg_dupdate    (cfg_pwm_dupdate    ), 
          .reg_in         (reg_3              ),
          .reg_out        (pwm_cfg3           )    


          );

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
