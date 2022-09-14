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
////  GPIO Top                                                     ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
///                                                               ////
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

module gpio_top  (
                       // System Signals
                       // Inputs
		               input logic           mclk,
                       input logic           h_reset_n,
                       input logic           cfg_gpio_dgmode, // 0 - De-glitch sampling on 1us
                       input logic           pulse_1us,

		               // Reg Bus Interface Signal
                       input logic           reg_cs,
                       input logic           reg_wr,
                       input logic [3:0]     reg_addr,
                       input logic [31:0]    reg_wdata,
                       input logic [3:0]     reg_be,

                       // Outputs
                       output logic [31:0]   reg_rdata,
                       output logic          reg_ack,

                       output logic  [31:0]  cfg_gpio_out_type ,// GPIO Type, 1 - ws281x
                       output  logic [31:0]  cfg_gpio_dir_sel, 
                       input   logic [31:0]  pad_gpio_in,
                       output  logic [31:0]  pad_gpio_out,

                       output  logic [7:0]   pwm_gpio_in,

                       output  logic [31:0]  gpio_intr

                ); 


logic  [31:0]  gpio_prev_indata         ;// previously captured GPIO I/P pins data
logic  [31:0]  cfg_gpio_out_data        ;// GPIO statuc O/P data from config reg
logic  [31:0]  cfg_multi_func_sel       ;// GPIO Multi function type
logic  [31:0]  cfg_gpio_posedge_int_sel ;// select posedge interrupt
logic  [31:0]  cfg_gpio_negedge_int_sel ;// select negedge interrupt
logic  [31:00] cfg_gpio_data_in         ;
logic [31:0]   gpio_int_event           ;
logic [31:0]   gpio_dsync               ;


//------------------------------------------
// Assign GPIO PORT-C as PWM GPIO
//----------------------------------------

assign  pwm_gpio_in = gpio_dsync[23:16];

//--------------------------------------
// GPIO Ge-glitch logic
//--------------------------------------
genvar port;
generate
for (port = 0; $unsigned(port) < 32; port=port+1) begin : u_bit

gpio_dglitch u_dglitch(
                  .reset_n    (h_reset_n         ),
                  .mclk       (mclk              ),
                  .pulse_1us  (pulse_1us         ),
                  .cfg_mode   (cfg_gpio_dgmode   ), 
                  .gpio_in    (pad_gpio_in[port] ),
                  .gpio_out   (gpio_dsync[port])
                 );

end
endgenerate // dglitch




gpio_reg  u_reg (
		       .mclk                         (mclk                    ),
               .h_reset_n                    (h_reset_n               ),

		       // Reg Bus Interface Signal
               .reg_cs                       (reg_cs                  ),
               .reg_wr                       (reg_wr                  ),
               .reg_addr                     (reg_addr                ),
               .reg_wdata                    (reg_wdata               ),
               .reg_be                       (reg_be                  ),

               // Outputs
               .reg_rdata                    (reg_rdata               ),
               .reg_ack                      (reg_ack                 ),

            // GPIO input pins
               .gpio_in_data                 (gpio_dsync              ),
               .gpio_prev_indata             (gpio_prev_indata        ),
               .gpio_int_event               (gpio_int_event          ),

            // GPIO config pins
               .cfg_gpio_out_data            (cfg_gpio_out_data       ),
               .cfg_gpio_dir_sel             (cfg_gpio_dir_sel        ),
               .cfg_gpio_out_type            (cfg_gpio_out_type       ),
               .cfg_gpio_posedge_int_sel     (cfg_gpio_posedge_int_sel),
               .cfg_gpio_negedge_int_sel     (cfg_gpio_negedge_int_sel),
               .cfg_multi_func_sel           (cfg_multi_func_sel      ),
	           .cfg_gpio_data_in             (cfg_gpio_data_in        ),

               .gpio_intr                    (gpio_intr               )


                ); 


gpio_intr_gen u_gpio_intr (
   // System Signals
   // Inputs
          .mclk                    (mclk                    ),
          .h_reset_n               (h_reset_n                ),

   // GPIO cfg input pins
          .gpio_prev_indata        (gpio_prev_indata        ),
          .cfg_gpio_data_in        (cfg_gpio_data_in        ),
          .cfg_gpio_dir_sel        (cfg_gpio_dir_sel        ),
          .cfg_gpio_out_data       (cfg_gpio_out_data       ),
          .cfg_gpio_posedge_int_sel(cfg_gpio_posedge_int_sel),
          .cfg_gpio_negedge_int_sel(cfg_gpio_negedge_int_sel),


   // GPIO output pins
          .pad_gpio_out            (pad_gpio_out            ),
          .gpio_int_event          (gpio_int_event          )  
  );

endmodule
