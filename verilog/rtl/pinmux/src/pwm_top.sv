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
//////////////////////////////////////////////////////////////////////

module pwm_top  (
                       // System Signals
                       // Inputs
		               input logic           mclk,
                       input logic           h_reset_n,

		               // Reg Bus Interface Signal
                       input logic           reg_cs,
                       input logic           reg_wr,
                       input logic [2:0]     reg_addr,
                       input logic [31:0]    reg_wdata,
                       input logic [3:0]     reg_be,

                       // Outputs
                       output logic [31:0]   reg_rdata,
                       output logic          reg_ack,

                   
                       input  logic          pulse_1ms, 
                       input  logic [5:0]    cfg_pwm_enb,
                       output logic [5:0]    pwm_wfm 

                ); 

//---------------------------------------------------
// 6 PWM variabled
//---------------------------------------------------

logic [15:0]    cfg_pwm0_high           ;
logic [15:0]    cfg_pwm0_low            ;
logic [15:0]    cfg_pwm1_high           ;
logic [15:0]    cfg_pwm1_low            ;
logic [15:0]    cfg_pwm2_high           ;
logic [15:0]    cfg_pwm2_low            ;
logic [15:0]    cfg_pwm3_high           ;
logic [15:0]    cfg_pwm3_low            ;
logic [15:0]    cfg_pwm4_high           ;
logic [15:0]    cfg_pwm4_low            ;
logic [15:0]    cfg_pwm5_high           ;
logic [15:0]    cfg_pwm5_low            ;



pwm_reg  u_reg (
		       .mclk             (mclk                ),
               .h_reset_n        (h_reset_n           ),

		       // Reg Bus Interface Signal
               .reg_cs           (reg_cs              ),
               .reg_wr           (reg_wr              ),
               .reg_addr         (reg_addr            ),
               .reg_wdata        (reg_wdata           ),
               .reg_be           (reg_be              ),

               // Outputs
               .reg_rdata        (reg_rdata           ),
               .reg_ack          (reg_ack             ),

               .cfg_pwm0_high    (cfg_pwm0_high       ),
               .cfg_pwm0_low     (cfg_pwm0_low        ),
               .cfg_pwm1_high    (cfg_pwm1_high       ),
               .cfg_pwm1_low     (cfg_pwm1_low        ),
               .cfg_pwm2_high    (cfg_pwm2_high       ),
               .cfg_pwm2_low     (cfg_pwm2_low        ),
               .cfg_pwm3_high    (cfg_pwm3_high       ),
               .cfg_pwm3_low     (cfg_pwm3_low        ),
               .cfg_pwm4_high    (cfg_pwm4_high       ),
               .cfg_pwm4_low     (cfg_pwm4_low        ),
               .cfg_pwm5_high    (cfg_pwm5_high       ),
               .cfg_pwm5_low     (cfg_pwm5_low        )

                ); 


// 6 PWM Waveform Generator
pwm  u_pwm_0 (
	  .waveform                    (pwm_wfm[0]         ), 
	  .h_reset_n                   (h_reset_n          ),
	  .mclk                        (mclk               ),
	  .pulse1m_mclk                (pulse_1ms          ),
	  .cfg_pwm_enb                 (cfg_pwm_enb[0]     ),
	  .cfg_pwm_high                (cfg_pwm0_high      ),
	  .cfg_pwm_low                 (cfg_pwm0_low       )
     );

pwm  u_pwm_1 (
	  .waveform                    (pwm_wfm[1]         ), 
	  .h_reset_n                   (h_reset_n          ),
	  .mclk                        (mclk               ),
	  .pulse1m_mclk                (pulse_1ms          ),
	  .cfg_pwm_enb                 (cfg_pwm_enb[1]     ),
	  .cfg_pwm_high                (cfg_pwm1_high      ),
	  .cfg_pwm_low                 (cfg_pwm1_low       )
     );
   
pwm  u_pwm_2 (
	  .waveform                    (pwm_wfm[2]         ), 
	  .h_reset_n                   (h_reset_n          ),
	  .mclk                        (mclk               ),
	  .pulse1m_mclk                (pulse_1ms          ),
	  .cfg_pwm_enb                 (cfg_pwm_enb[2]     ),
	  .cfg_pwm_high                (cfg_pwm2_high      ),
	  .cfg_pwm_low                 (cfg_pwm2_low       )
     );

pwm  u_pwm_3 (
	  .waveform                    (pwm_wfm[3]         ), 
	  .h_reset_n                   (h_reset_n          ),
	  .mclk                        (mclk               ),
	  .pulse1m_mclk                (pulse_1ms          ),
	  .cfg_pwm_enb                 (cfg_pwm_enb[3]     ),
	  .cfg_pwm_high                (cfg_pwm3_high      ),
	  .cfg_pwm_low                 (cfg_pwm3_low       )
     );
pwm  u_pwm_4 (
	  .waveform                    (pwm_wfm[4]         ), 
	  .h_reset_n                   (h_reset_n          ),
	  .mclk                        (mclk               ),
	  .pulse1m_mclk                (pulse_1ms          ),
	  .cfg_pwm_enb                 (cfg_pwm_enb[4]     ),
	  .cfg_pwm_high                (cfg_pwm4_high      ),
	  .cfg_pwm_low                 (cfg_pwm4_low       )
     );
pwm  u_pwm_5 (
	  .waveform                    (pwm_wfm[5]         ), 
	  .h_reset_n                   (h_reset_n          ),
	  .mclk                        (mclk               ),
	  .pulse1m_mclk                (pulse_1ms          ),
	  .cfg_pwm_enb                 (cfg_pwm_enb[5]     ),
	  .cfg_pwm_high                (cfg_pwm5_high      ),
	  .cfg_pwm_low                 (cfg_pwm5_low       )
     );

endmodule
