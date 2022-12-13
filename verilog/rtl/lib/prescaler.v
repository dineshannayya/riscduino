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

module prescaler #(
  parameter BITS = 32
)(
  input  wire            rst_n      , // Asynchronous reset (active low)
  input  wire            clk        , // Clock (rising edge)
  input  wire            clear_n    , // Synchronous reset (active low)

  input  wire [BITS-1:0] multiplier , // frequency multiplier
  input  wire [BITS-1:0] divider    , // frequency divider

  output reg             tick         // output clock [Ftick=Fclk*(multiplier/divider)] with multiplier <= divider

);

  reg [BITS-1:0] div;
  reg [BITS-1:0] mul;
  reg [BITS-1:0] div_m_mul;
  reg [BITS-1:0] mul_m_div;
  reg [BITS-1:0] counter;

  always @(negedge rst_n or posedge clk) begin
    if (rst_n == 1'b0) begin
	  mul       <= {(BITS){1'b0}};
      div       <= {(BITS){1'b0}};
	  div_m_mul <= {(BITS){1'b0}};
      mul_m_div <= {(BITS){1'b0}};
      counter   <= {(BITS){1'b0}};
      tick      <= 1'b0;
    end else begin
      if (clear_n == 1'b0) begin
        counter   <= {(BITS){1'b0}};
        tick      <= 1'b0;
      end else begin
        if (counter > div_m_mul) begin
          counter <= counter + mul_m_div;
          tick    <= 1'b1;
        end else begin
          counter <= counter + mul;
          tick    <= 1'b0;
        end
      end
	  mul       <= multiplier;
      div       <= divider   ;
	  div_m_mul <= div - mul ;
      mul_m_div <= mul - div ;
    end
  end

endmodule
