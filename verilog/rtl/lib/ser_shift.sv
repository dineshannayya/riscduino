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
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  ser_shift                                                   ////
////                                                              ////
////  This file is part of the mbist_ctrl cores project           ////
////  https://github.com/dineshannayya/riscdunio.git              ////
////                                                              ////
////  Description                                                 ////
////   This block manages the parallel to serial conversion       ////
////   This block usefull for Bist SDI/SDO access                 ////
////         asserts Reg Ack                                      ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.0 - 16th Dec 2021, Dinesh A                             ////
////          Initial integration                                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

module ser_shift
     #(parameter WD = 32)
       (

    // Master Port
       input   logic               rst_n       ,  // Regular Reset signal
       input   logic               clk         ,  // System clock
       input   logic               load        ,  // load request
       input   logic               shift       ,  // shift
       input   logic [WD-1:0]      load_data   ,  // load data
       input   logic               sdi         ,  // sdi
       output  logic               sdo            // sdo


    );

logic [WD-1:0] shift_reg;

always@(negedge rst_n or posedge clk)
begin
   if(rst_n == 0) begin
      shift_reg   <= 'h0;
   end else if(load) begin
      shift_reg   <= load_data;
   end else if(shift) begin
      shift_reg   <= {sdi,shift_reg[WD-1:1]};
   end
end

assign sdo = shift_reg[0];



endmodule
