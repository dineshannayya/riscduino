////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2022 , Julien OURY                       
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
// SPDX-FileContributor: Created by Julien OURY <julien.oury@outlook.fr>
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Orginal Reference: https://github.com/JulienOury/ChristmasTreeController.git
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Xoroshiro64++
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module pseudorandom (
  input  wire        rst_n     , // Asynchronous reset (active low)
  input  wire        clk       , // Clock (rising edge)
  input  wire        next      , // Request next value
  output wire [31:0] random      // Random value
);
  reg  [31:0] s0;
  reg  [31:0] s1;
  reg  [31:0] n0;
  reg  [31:0] n1;
  reg  [31:0] n1_plus_n0;
  wire [31:0] s1_xor_s0;

  assign s1_xor_s0 = (s1 ^ s0);

  assign random = ({n1_plus_n0[14:0],n1_plus_n0[31 : 15]} + n0);
  
  always @(negedge rst_n or posedge clk) begin
    if (rst_n == 1'b0) begin
      s0         <= (32'h00000001);
      s1         <= (32'h00000000);
      n0         <= (32'h00000000);
      n1         <= (32'h00000000);
	  n1_plus_n0 <= (32'h00000000);
    end else begin
	
	  // stage 1
      if (next == 1'b1) begin
        s0 <= n0;
        s1 <= n1;
      end

	  // stage 2
      n0 <= (({s0[5:0],s0[31:6]} ^ s1_xor_s0) ^ (s1_xor_s0 <<< 9));
      n1 <= {s1_xor_s0[18:0],s1_xor_s0[31:19]};
	  
	  // stage 3
	  n1_plus_n0 <= (n0 + n1);
	  
    end
  end

endmodule
