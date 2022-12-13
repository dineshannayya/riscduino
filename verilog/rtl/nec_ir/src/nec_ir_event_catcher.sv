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
// Event catcher
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module nec_ir_event_catcher #(
  parameter DBITS = 32 // Number of bits of delay counter
)(
  input  wire             rst_n         , // Asynchronous reset (active low)
  input  wire             clk           , // Clock (rising edge)
  input  wire             clear_n       , // Synchronous reset (active low)
  input  wire [DBITS-1:0] reload_offset , // Delay counter reload offset

  input  wire             i_value       , // Input value
  input  wire             i_valid       , // Input valid strobe

  output reg              event_new     ,
  output reg              event_type    ,
  output reg  [DBITS-1:0] event_delay   ,
  output reg              event_timeout
);

  wire detect_event;
  wire [DBITS-1:0] next_cnt;
  wire full_cnt;

  reg last_value;
  reg [DBITS-1:0] cnt;

  assign detect_event = (i_value != last_value);
  assign next_cnt     = cnt + 1'b1;
  assign full_cnt     = (cnt == {DBITS{1'b1}});

  // Event catcher
  always @(negedge rst_n or posedge clk) begin
    if (rst_n == 1'b0) begin
      last_value    <= 1'b0;
      cnt           <= {DBITS{1'b1}};
      event_new     <= 1'b0;
      event_type    <= 1'b0;
      event_delay   <= {DBITS{1'b0}};
      event_timeout <= 1'b0;
    end else begin

    if (clear_n == 1'b0) begin
        last_value    <= 1'b0;
        cnt           <= {DBITS{1'b1}};
        event_new     <= 1'b0;
        event_type    <= 1'b0;
        event_delay   <= {DBITS{1'b0}};
        event_timeout <= 1'b0;
    end else begin

        if (i_valid == 1'b1) begin

          //event detect
          last_value <= i_value;

          //counter update
          if (detect_event == 1'b1) begin
            cnt <= reload_offset;
          end else if (!full_cnt) begin
            cnt <= next_cnt;
          end
        end

        //report event
        if ((i_valid == 1'b1) && (detect_event == 1'b1)) begin
          event_new     <= 1'b1;
          event_type    <= i_value; // 1: rising_edge, 0: falling_edge
          event_delay   <= next_cnt;
          event_timeout <= full_cnt;
        end else begin
          event_new     <= 1'b0;
        end

    end

    end
  end

endmodule
