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
////  Timer Top                                                   ////
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

module timer_top  (
                       // System Signals
                       // Inputs
		               input logic           mclk,
                       input logic           h_reset_n,

		               // Reg Bus Interface Signal
                       input logic           reg_cs,
                       input logic           reg_wr,
                       input logic [1:0]     reg_addr,
                       input logic [31:0]    reg_wdata,
                       input logic [3:0]     reg_be,

                       // Outputs
                       output logic [31:0]   reg_rdata,
                       output logic          reg_ack,

                       output logic          pulse_1ms,
                       output logic          pulse_1us,
                       output logic [2:0]    timer_intr 

                ); 

//---------------------------------------------------------
// Timer Register                          
// -------------------------------------------------------
logic [2:0]    cfg_timer_update        ; // CPU write to timer register
logic [18:0]   cfg_timer0              ; // Timer-0 register
logic [18:0]   cfg_timer1              ; // Timer-1 register
logic [18:0]   cfg_timer2              ; // Timer-2 register

/* clock pulse */
//********************************************************
logic           pulse_1s                ; // 1Second Pulse for waveform Generator
logic [9:0]     cfg_pulse_1us           ; // 1us pulse generation config

timer_reg  u_reg (
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

               .cfg_pulse_1us    (cfg_pulse_1us       ),
               .cfg_timer_update (cfg_timer_update    ),
               .cfg_timer0       (cfg_timer0          ),
               .cfg_timer1       (cfg_timer1          ),
               .cfg_timer2       (cfg_timer2          )

                ); 

// 1us pulse
pulse_gen_type2  #(.WD(10)) u_pulse_1us (

	.clk_pulse_o               (pulse_1us        ),
	.clk                       (mclk             ),
    .reset_n                   (h_reset_n        ),
	.cfg_max_cnt               (cfg_pulse_1us    )

     );

// 1us/1000 to 1millisecond pulse
pulse_gen_type1 u_pulse_1ms (

	.clk_pulse_o               (pulse_1ms       ),
	.clk                       (mclk            ),
    .reset_n                   (h_reset_n       ),
	.trigger                   (pulse_1us       )

      );

// 1ms/1000 => 1 second pulse
pulse_gen_type1 u_pulse_1s (

	.clk_pulse_o               (pulse_1s    ),
	.clk                       (mclk        ),
    .reset_n                   (h_reset_n   ),
	.trigger                   (pulse_1ms   )

       );

// Timer

wire [1:0]  cfg_timer0_clksel = cfg_timer0[18:17];
wire        cfg_timer0_enb    = cfg_timer0[16];
wire [15:0] cfg_timer0_compare = cfg_timer0[15:0];

timer  u_timer_0
  (
     .reset_n                      (h_reset_n            ),// system syn reset
     .mclk                         (mclk                 ),// master clock
     .pulse_1us                    (pulse_1us            ),
     .pulse_1ms                    (pulse_1ms            ),
     .pulse_1s                     (pulse_1s             ),

     .cfg_timer_update             (cfg_timer_update[0]  ), 
     .cfg_timer_enb                (cfg_timer0_enb       ),     
     .cfg_timer_compare            (cfg_timer0_compare   ),
     .cfg_timer_clksel             (cfg_timer0_clksel    ),// to select the timer 1us/1ms reference clock

     .timer_intr                   (timer_intr[0]         )
   );

// Timer
wire [1:0] cfg_timer1_clksel   = cfg_timer1[18:17];
wire       cfg_timer1_enb      = cfg_timer1[16];
wire [15:0] cfg_timer1_compare = cfg_timer1[15:0];
timer  u_timer_1
  (
     .reset_n                      (h_reset_n            ),// system syn reset
     .mclk                         (mclk                 ),// master clock
     .pulse_1us                    (pulse_1us            ),
     .pulse_1ms                    (pulse_1ms            ),
     .pulse_1s                     (pulse_1s             ),

     .cfg_timer_update             (cfg_timer_update[1]  ), 
     .cfg_timer_enb                (cfg_timer1_enb       ),     
     .cfg_timer_compare            (cfg_timer1_compare   ),
     .cfg_timer_clksel             (cfg_timer1_clksel    ),// to select the timer 1us/1ms reference clock

     .timer_intr                   (timer_intr[1]         )
   );

// Timer
wire [1:0] cfg_timer2_clksel = cfg_timer2[18:17];
wire       cfg_timer2_enb    = cfg_timer2[16];
wire [15:0] cfg_timer2_compare = cfg_timer2[15:0];

timer  u_timer_2
  (
     .reset_n                      (h_reset_n            ),// system syn reset
     .mclk                         (mclk                 ),// master clock
     .pulse_1us                    (pulse_1us            ),
     .pulse_1ms                    (pulse_1ms            ),
     .pulse_1s                     (pulse_1s             ),

     .cfg_timer_update             (cfg_timer_update[2]  ), 
     .cfg_timer_enb                (cfg_timer2_enb       ),     
     .cfg_timer_compare            (cfg_timer2_compare   ),
     .cfg_timer_clksel             (cfg_timer2_clksel    ),// to select the timer 1us/1ms reference clock

     .timer_intr                   (timer_intr[2]        )
   );


endmodule
