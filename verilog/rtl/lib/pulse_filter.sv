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
// Pulse filter
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module pulse_filter (
  input  wire  rst_n      , // Asynchronous reset (active low)
  input  wire  clk        , // Clock (rising edge)
  input  wire  clear_n  , // Synchronous reset (active low)

  input  wire  i_value    , // Input value
  input  wire  i_valid    , // Input valid strobe

  output wire  o_value    , // Output value
  output reg   o_valid      // Output valid strobe
);

  reg [2:0]  filter_reg;

  always @(negedge rst_n or posedge clk) begin
    if (rst_n == 1'b0) begin
      filter_reg <= 'b0;
      o_valid    <= 1'b0;
    end else begin
      if (clear_n == 1'b0) begin
          filter_reg <= 'b0;
          o_valid    <= 1'b0;
      end else begin
        if (i_valid == 1'b1) begin
          filter_reg[2] <= i_value;
          filter_reg[1] <= filter_reg[2];
          filter_reg[0] <= filter_reg[1];
          o_valid       <= 1'b1;
        end else begin
          o_valid       <= 1'b0;
        end
      end
    end
  end

  assign o_value = (filter_reg[0] & filter_reg[1]) |
                   (filter_reg[1] & filter_reg[2]) |
                   (filter_reg[2] & filter_reg[0]) ;
endmodule
