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
////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Metastability filter
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module metastability_filter #(
  parameter NB_STAGES = 3
)(
  input  wire  rst_n      , // Asynchronous reset (active low)
  input  wire  clk        , // Clock (rising edge)

  input  wire  i_raw      , // Raw input
  output wire  o_filtered   // Filtered output
);

  reg [NB_STAGES-1:0]  meta_i;

  always @(negedge rst_n or posedge clk) begin
    if (rst_n == 1'b0) begin
      meta_i <= 'b0;
    end else begin
      meta_i <= {meta_i[NB_STAGES-2: 0],i_raw};
    end
  end
  assign o_filtered = meta_i[NB_STAGES-1];

endmodule
