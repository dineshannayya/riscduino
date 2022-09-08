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

/********************************************************************************
  To handle reset removal on power up new logic is created,
  One power up data_out will be reset value and one cycle later it will latch the rst_in.

This will handle case when one of the bit of rst_n high, Still reset will be asserted in dataout 
and one cycle latter it will get updated
**********************************************************************************/

module  glbl_rst_reg	(
	      input logic        s_reset_n,
	      //List of Inputs
          input logic [31:0] rst_in,
	      input logic        cs,
	      input logic [3:0]  we,		 
	      input logic [31:0] data_in,
	      input logic        clk,
	      
	      //List of Outs
	      output logic [31:0]data_out
	      );

  parameter   RESET_DEFAULT    = 32'h0;  


logic flag;
always @ (posedge clk or negedge s_reset_n) begin 
  if (s_reset_n == 1'b0) begin
    data_out       <= RESET_DEFAULT ;
    flag           <= 1'b1;
  end else begin
      flag         <= 1'b0;
      if (flag == 1'b1) begin
        data_out    <= rst_in ;
      end else begin
        if(cs && we[0]) data_out[7:0]   <= data_in[7:0];
        if(cs && we[1]) data_out[15:8]  <= data_in[15:8];
        if(cs && we[2]) data_out[23:16] <= data_in[23:16];
        if(cs && we[3]) data_out[31:24] <= data_in[31:24];
      end
   end
end


endmodule
