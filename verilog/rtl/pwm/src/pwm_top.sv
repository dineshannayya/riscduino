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
////  PWM Top                                                     ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
///     Includes 6 PWM                                            ////
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
////    0.2 - 14th Sept 2022, Dinesh A                            ////
////          Improved PWM logic                                  ////
//////////////////////////////////////////////////////////////////////

module pwm_top  (
                       // System Signals
                       // Inputs
		               input logic           mclk,
                       input logic           h_reset_n,

		               // Reg Bus Interface Signal
                       input logic           reg_cs,
                       input logic           reg_wr,
                       input logic [4:0]     reg_addr,
                       input logic [31:0]    reg_wdata,
                       input logic [3:0]     reg_be,

                       // Outputs
                       output logic [31:0]   reg_rdata,
                       output logic          reg_ack,

                       input  logic [7:0]    pad_gpio,
                       output logic [5:0]    pwm_wfm ,
                       output logic          pwm_intr 

                ); 

//---------------------------------------------------
// 3 PWM variabled
//---------------------------------------------------

logic [5:0]    cfg_pwm_enb      ;
logic [5:0]    cfg_pwm_run      ;
logic [5:0]    cfg_pwm_dupdate  ;
logic [5:0]    pwm_os_done      ;
logic [5:0]    pwm_ovflow       ;
logic [5:0]    gpio_tgr         ;
logic          reg_cs_glbl      ;
logic [5:0]    reg_cs_pwm       ;
logic          reg_ack_glbl     ;
logic [31:0]   reg_rdata_glbl   ;
logic          reg_ack_pwm0     ;
logic [31:0]   reg_rdata_pwm0   ;
logic          reg_ack_pwm1     ;
logic [31:0]   reg_rdata_pwm1   ;
logic          reg_ack_pwm2     ;
logic [31:0]   reg_rdata_pwm2   ;
logic          reg_ack_pwm3     ;
logic [31:0]   reg_rdata_pwm3   ;
logic          reg_ack_pwm4     ;
logic [31:0]   reg_rdata_pwm4   ;
logic          reg_ack_pwm5     ;
logic [31:0]   reg_rdata_pwm5   ;

//------------------------------------------------------
// Register Map Decoding

`define SEL_GLBL    3'b000   // GLOBAL REGISTER
`define SEL_PWM0    3'b001   // PWM-0
`define SEL_PWM1    3'b010   // PWM-1
`define SEL_PWM2    3'b011   // PWM-2
`define SEL_PWM3    3'b100   // PWM-3
`define SEL_PWM4    3'b101   // PWM-4
`define SEL_PWM5    3'b110   // PWM-5


pwm_glbl_reg  u_glbl_reg (
		       .mclk             (mclk                ),
               .h_reset_n        (h_reset_n           ),

		       // Reg Bus Interface Signal
               .reg_cs           (reg_cs_glbl         ),
               .reg_wr           (reg_wr              ),
               .reg_addr         (reg_addr[1:0]       ),
               .reg_wdata        (reg_wdata           ),
               .reg_be           (reg_be              ),

               // Outputs
               .reg_rdata        (reg_rdata_glbl      ),
               .reg_ack          (reg_ack_glbl        ),

               .cfg_pwm_enb      (cfg_pwm_enb         ),
               .cfg_pwm_run      (cfg_pwm_run         ),
               .cfg_pwm_dupdate  (cfg_pwm_dupdate     ),

               .pwm_os_done      (pwm_os_done         ),
               .pwm_ovflow       (pwm_ovflow          ),
               .gpio_tgr         (gpio_tgr            ),

                .pwm_intr        (pwm_intr            )


                ); 


// 6 PWM Waveform Generator

pwm_core u_pwm_0(

	.h_reset_n         (h_reset_n          ),
	.mclk              (mclk               ),

    .reg_cs            (reg_cs_pwm[0]      ),
    .reg_wr            (reg_wr             ),
    .reg_addr          (reg_addr[1:0]      ),
    .reg_wdata         (reg_wdata          ),
    .reg_be            (reg_be             ),
                                         
    .reg_rdata         (reg_rdata_pwm0     ),
    .reg_ack           (reg_ack_pwm0       ),
                                         
    .cfg_pwm_enb       (cfg_pwm_enb[0]     ), // pwm operation enable
    .cfg_pwm_run       (cfg_pwm_run[0]     ), // pwm operation enable
    .cfg_pwm_dupdate   (cfg_pwm_dupdate[0] ), // Disable Config update
    .pad_gpio          (pad_gpio           ),
	.pwm_os_done       (pwm_os_done[0]     ),
	.pwm_ovflow        (pwm_ovflow[0]      ),
    .gpio_tgr          (gpio_tgr[0]        ),
	.pwm_wfm_o         (pwm_wfm[0]       )

);

pwm_core u_pwm_1(

	.h_reset_n         (h_reset_n          ),
	.mclk              (mclk               ),

    .reg_cs            (reg_cs_pwm[1]      ),
    .reg_wr            (reg_wr             ),
    .reg_addr          (reg_addr[1:0]      ),
    .reg_wdata         (reg_wdata          ),
    .reg_be            (reg_be             ),
                                         
    .reg_rdata         (reg_rdata_pwm1     ),
    .reg_ack           (reg_ack_pwm1       ),
                                         
    .cfg_pwm_enb       (cfg_pwm_enb[1]     ), // pwm operation enable
    .cfg_pwm_run       (cfg_pwm_run[1]     ), // pwm operation enable
    .cfg_pwm_dupdate   (cfg_pwm_dupdate[1] ), // Disable Config update
    .pad_gpio          (pad_gpio           ),
	.pwm_os_done       (pwm_os_done[1]     ),
	.pwm_ovflow        (pwm_ovflow[1]      ),
    .gpio_tgr          (gpio_tgr[1]        ),
	.pwm_wfm_o         (pwm_wfm[1]       )

);
pwm_core u_pwm_2(

	.h_reset_n         (h_reset_n          ),
	.mclk              (mclk               ),

    .reg_cs            (reg_cs_pwm[2]      ),
    .reg_wr            (reg_wr             ),
    .reg_addr          (reg_addr[1:0]      ),
    .reg_wdata         (reg_wdata          ),
    .reg_be            (reg_be             ),
                                         
    .reg_rdata         (reg_rdata_pwm2     ),
    .reg_ack           (reg_ack_pwm2       ),
                                         
    .cfg_pwm_enb       (cfg_pwm_enb[2]     ), // pwm operation enable
    .cfg_pwm_run       (cfg_pwm_run[2]     ), // pwm operation enable
    .cfg_pwm_dupdate   (cfg_pwm_dupdate[2] ), // Disable Config update
    .pad_gpio          (pad_gpio           ),
	.pwm_os_done       (pwm_os_done[2]     ),
	.pwm_ovflow        (pwm_ovflow[2]      ),
    .gpio_tgr          (gpio_tgr[2]        ),
	.pwm_wfm_o         (pwm_wfm[2]       )

);


/***
pwm_core u_pwm_3(

	.h_reset_n         (h_reset_n          ),
	.mclk              (mclk               ),

    .reg_cs            (reg_cs_pwm[3]      ),
    .reg_wr            (reg_wr             ),
    .reg_addr          (reg_addr[1:0]      ),
    .reg_wdata         (reg_wdata          ),
    .reg_be            (reg_be             ),
                                         
    .reg_rdata         (reg_rdata_pwm3     ),
    .reg_ack           (reg_ack_pwm3       ),
                                         
    .cfg_pwm_enb       (cfg_pwm_enb[3]     ), // pwm operation enable
    .cfg_pwm_run       (cfg_pwm_run[3]     ), // pwm operation enable
    .cfg_pwm_dupdate   (cfg_pwm_dupdate[3] ), // Disable Config update
    .pad_gpio          (pad_gpio           ),
	.pwm_os_done       (pwm_os_done[3]     ),
	.pwm_ovflow        (pwm_ovflow[3]      ),
    .gpio_tgr          (gpio_tgr[3]        ),
	.pwm_wfm_o         (pwm_wfm[3]       )

);
***/
assign pwm_wfm[3]     = pwm_wfm[0];
assign pwm_os_done[3] = 1'b0;
assign pwm_ovflow[3]  = 1'b0;
assign gpio_tgr[3]    = 1'b0;

/****
pwm_core u_pwm_4(

	.h_reset_n         (h_reset_n          ),
	.mclk              (mclk               ),

    .reg_cs            (reg_cs_pwm[4]      ),
    .reg_wr            (reg_wr             ),
    .reg_addr          (reg_addr[1:0]      ),
    .reg_wdata         (reg_wdata          ),
    .reg_be            (reg_be             ),
                                         
    .reg_rdata         (reg_rdata_pwm4     ),
    .reg_ack           (reg_ack_pwm4       ),
                                         
    .cfg_pwm_enb       (cfg_pwm_enb[4]     ), // pwm operation enable
    .cfg_pwm_run       (cfg_pwm_run[4]     ), // pwm operation enable
    .cfg_pwm_dupdate   (cfg_pwm_dupdate[4] ), // Disable Config update
    .pad_gpio          (pad_gpio           ),
	.pwm_os_done       (pwm_os_done[4]     ),
	.pwm_ovflow        (pwm_ovflow[4]      ),
    .gpio_tgr          (gpio_tgr[4]        ),
	.pwm_wfm_o         (pwm_wfm[4]       )

);
***/
assign pwm_wfm[4] = pwm_wfm[1];
assign pwm_os_done[4] = 1'b0;
assign pwm_ovflow[4]  = 1'b0;
assign gpio_tgr[4]    = 1'b0;

/***
pwm_core u_pwm_5(

	.h_reset_n         (h_reset_n          ),
	.mclk              (mclk               ),

    .reg_cs            (reg_cs_pwm[5]      ),
    .reg_wr            (reg_wr             ),
    .reg_addr          (reg_addr[1:0]      ),
    .reg_wdata         (reg_wdata          ),
    .reg_be            (reg_be             ),
                                         
    .reg_rdata         (reg_rdata_pwm5     ),
    .reg_ack           (reg_ack_pwm5       ),
                                         
    .cfg_pwm_enb       (cfg_pwm_enb[5]     ), // pwm operation enable
    .cfg_pwm_run       (cfg_pwm_run[5]     ), // pwm operation enable
    .cfg_pwm_dupdate   (cfg_pwm_dupdate[5] ), // Disable Config update
    .pad_gpio          (pad_gpio           ),
	.pwm_os_done       (pwm_os_done[5]     ),
	.pwm_ovflow        (pwm_ovflow[5]      ),
    .gpio_tgr          (gpio_tgr[5]        ),
	.pwm_wfm_o         (pwm_wfm[5]       )

);

**/
assign pwm_wfm[5] = pwm_wfm[2];
assign pwm_os_done[5] = 1'b0;
assign pwm_ovflow[5]  = 1'b0;
assign gpio_tgr[5]    = 1'b0;


//-----------------------------------
// Register Select
//------------------------------------
logic [2:0] blk_sel;

always @(posedge mclk or negedge h_reset_n)
begin
   if(h_reset_n == 1'b0) begin
      blk_sel <= 3'b0;
   end else begin
      blk_sel <= reg_addr[4:2];
   end
end

assign reg_rdata = (blk_sel == `SEL_GLBL)  ? {reg_rdata_glbl} : 
	               (blk_sel == `SEL_PWM0)  ? {reg_rdata_pwm0} :
	               (blk_sel == `SEL_PWM1)  ? {reg_rdata_pwm1} :
	               (blk_sel == `SEL_PWM2)  ? {reg_rdata_pwm2} :'h0;

assign reg_ack   = (blk_sel == `SEL_GLBL)  ? reg_ack_glbl   : 
	               (blk_sel == `SEL_PWM0)  ? reg_ack_pwm0   : 
	               (blk_sel == `SEL_PWM1)  ? reg_ack_pwm1   : 
	               (blk_sel == `SEL_PWM2)  ? reg_ack_pwm2   : 'h0;

assign reg_cs_glbl    = (reg_addr[4:2] == `SEL_GLBL) ? reg_cs : 1'b0;
assign reg_cs_pwm[0]  = (reg_addr[4:2] == `SEL_PWM0) ? reg_cs : 1'b0;
assign reg_cs_pwm[1]  = (reg_addr[4:2] == `SEL_PWM1) ? reg_cs : 1'b0;
assign reg_cs_pwm[2]  = (reg_addr[4:2] == `SEL_PWM2) ? reg_cs : 1'b0;
assign reg_cs_pwm[3]  = (reg_addr[4:2] == `SEL_PWM3) ? reg_cs : 1'b0;
assign reg_cs_pwm[4]  = (reg_addr[4:2] == `SEL_PWM4) ? reg_cs : 1'b0;
assign reg_cs_pwm[5]  = (reg_addr[4:2] == `SEL_PWM5) ? reg_cs : 1'b0;
endmodule
