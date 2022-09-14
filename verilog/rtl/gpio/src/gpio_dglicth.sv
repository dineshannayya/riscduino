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
////  GPIO De-Glitch                                              ////
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
////      - Dinesh Annayya, dinesh.annayya@gmail.com              ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 13th Sept 2022, Dinesh A                            ////
////          initial version                                     ////
//////////////////////////////////////////////////////////////////////
//


module gpio_dglitch (
                  input logic    reset_n,
                  input logic    mclk,
                  input logic    pulse_1us,
                  input logic    cfg_mode, // 0 - 1 us, 1 - every system clock
                  input logic    gpio_in,
                  output logic   gpio_out
                     );

logic [3:0] gpio_ss;
logic       gpio_reg;

// Pass the input data , if there is no transition, else send old data
assign gpio_out = ((gpio_ss[3] == gpio_ss[2]) && (gpio_ss[2] == gpio_ss[1])) ? gpio_ss[3] : gpio_reg;


always@(negedge reset_n or posedge mclk)
begin
   if(reset_n == 1'b0) begin
      gpio_ss  <= 'h0;
      gpio_reg <= 'h0;
   end else begin
       gpio_reg <= gpio_out;
       if(cfg_mode == 1'b0) begin // De-glitch sampling at 1us pulse
           if(pulse_1us)  gpio_ss <= {gpio_ss[2:0],gpio_in};
       end else begin // De-glitch on on every system clock
           gpio_ss <= {gpio_ss[2:0],gpio_in};
       end
   end
end


endmodule
