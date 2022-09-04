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
////////////////////////////////////////////////////////////////////////

// #################################################################
// Module: clock div by 2,4,8 supported
//
//
//  
// #################################################################


module clk_div8 (
   // Outputs
       output logic clk_div_8,
       output logic clk_div_4,
       output logic clk_div_2,
   // Inputs
       input logic  mclk,
       input logic  reset_n 
   );


               

//------------------------------------
// Clock Divide func is done here
//------------------------------------
reg  [2:0]      clk_cnt       ; // high level counter


assign clk_div_2  = clk_cnt[0];
assign clk_div_4  = clk_cnt[1];
assign clk_div_8  = clk_cnt[2];

always @ (posedge mclk or negedge reset_n)
begin // {
   if(reset_n == 1'b0) 
   begin 
      clk_cnt  <= 'h0;
   end   else begin 
      clk_cnt  <= clk_cnt + 1;
   end   // }
end   // }


endmodule 

