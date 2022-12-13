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
// tick div8 block
//////////////////////////////////////////////////////////////////////

module nec_div8 (
       input  logic   rst_n        , // Asynchronous reset (active low)
       input  logic   clk          , // Clock (rising edge)
       input  logic   tick         ,
       output logic   tick_div8     

    );


  logic [2:0] cnt;
  always @(negedge rst_n or posedge clk) begin
    if (rst_n == 1'b0) begin
      cnt       <= '0;
      tick_div8 <= 'b0;
    end else begin
       if(tick) cnt <= cnt + 1;
       if(cnt == 7 && tick) tick_div8 <= 1'b1;
       else tick_div8 <= 1'b0;

    end
  end
    


endmodule   
