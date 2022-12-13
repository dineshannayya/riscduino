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
// Frame decoder
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module nec_ir_frame_decoder #(
  parameter DBITS = 32 // Number of bits of delay counter
)(
  input  wire  rst_n                    , // Asynchronous reset (active low)
  input  wire  clk                      , // Clock (rising edge)

  input  wire             receiver_en   , // Receiver enable
  input  wire             repeat_en     , // Repeat enable
  input  wire [DBITS-1:0] delay_mask    , // Mask delay

  // Input event interface
  input  wire             event_new     , // New event strobe
  input  wire             event_type    , // Type of event (0:rising, 1:falling)
  input  wire [DBITS-1:0] event_delay   , // Delay from last event
  input  wire             event_timeout , // Timeout flag

  // Output frame interface
  output reg  [7:0]       frame_addr    , // Frame address
  output reg  [7:0]       frame_data    , // Frame data
  output reg              frame_repeat  , // Frame repeat flag
  output reg              frame_write     // Frame write strobe
);

  localparam
    idle_state        = 3'b000,
    start_state       = 3'b001,
    data_prefix_state = 3'b010,
    data_latch_state  = 3'b011,
    stop_state        = 3'b100,
    idle_a_state      = 3'b101,
    idle_b_state      = 3'b110,
    idle_c_state      = 3'b111;

  reg [2:0] frame_state_reg ;
  wire is_valid_start_a     ;
  wire is_valid_start_b     ;
  wire is_valid_repeat      ;
  wire is_valid_bit_prefix  ;
  wire is_valid_bit_zero    ;
  wire is_valid_bit_one     ;
  wire is_valid_bit         ;
  wire is_valid_stop        ;
  wire is_valid_addr        ;
  wire is_valid_data        ;

  reg [31:0] frame_shift    ;
  reg        initial_timeout;

  assign is_valid_start_a    = ((event_timeout == 1'b0) && (event_type == 1'b0) && ((event_delay & delay_mask) == 128)); // 9.00ms pulse to 1'b1
  assign is_valid_start_b    = ((event_timeout == 1'b0) && (event_type == 1'b1) && ((event_delay & delay_mask) ==  64)); // 4.50ms pulse to 1'b0
  assign is_valid_repeat     = ((event_timeout == 1'b0) && (event_type == 1'b1) && ((event_delay & delay_mask) ==  32) && (initial_timeout == 0)); // 2.25ms pulse to 1'b0
  assign is_valid_bit_prefix = ((event_timeout == 1'b0) && (event_type == 1'b0) && ((event_delay & delay_mask) ==   8));
  assign is_valid_bit_zero   = ((event_timeout == 1'b0) && (event_type == 1'b1) && ((event_delay & delay_mask) ==   8));
  assign is_valid_bit_one    = ((event_timeout == 1'b0) && (event_type == 1'b1) && ((event_delay & delay_mask) ==  24));
  assign is_valid_bit        = (is_valid_bit_zero || is_valid_bit_one);
  assign is_valid_stop       = ((event_timeout == 1'b0) && (event_type == 1'b0) && ((event_delay & delay_mask) ==   8));
  assign is_valid_addr       = ((frame_shift[7:0] == ~frame_shift[15:8]));
  assign is_valid_data       = ((frame_shift[23:16] == ~frame_shift[31:24]));

  // Frame decoder
  always @(negedge rst_n or posedge clk) begin
    if (rst_n == 1'b0) begin
      frame_state_reg  <= idle_state;
      frame_shift      <= 32'h80000000;
      frame_repeat     <= 1'b0;
      frame_write      <= 1'b0;
      frame_addr       <= 8'h00;
      frame_data       <= 8'h00;
    end else begin

      if (receiver_en == 1'b0) begin
        frame_state_reg <= idle_state;
        initial_timeout <= 1'b1;
        frame_shift     <= 32'h80000000;
        frame_repeat    <= 1'b0;
      end else begin
        if (event_new == 1'b1) begin
          case(frame_state_reg)
            idle_state,
            idle_a_state,
            idle_b_state,
            idle_c_state:
              if(is_valid_start_a) begin
                frame_state_reg <= start_state;
              end
            start_state:
              if (is_valid_start_b) begin
                frame_state_reg <= data_prefix_state;
              end else if (repeat_en && is_valid_repeat) begin
                frame_state_reg <= stop_state;
              end else begin
                frame_state_reg <= idle_state;
              end
            data_prefix_state:
              if (is_valid_bit_prefix) begin
                frame_state_reg <= data_latch_state;
              end else begin
                frame_state_reg <= idle_state;
              end
            data_latch_state:
              if (is_valid_bit) begin
                if (frame_shift[0] == 1'b1) begin
                  frame_state_reg <= stop_state;
                end else begin
                  frame_state_reg <= data_prefix_state;
                end
              end else begin
                frame_state_reg <= idle_state;
              end
            stop_state:
              frame_state_reg <= idle_state;
            default:
              frame_state_reg <= idle_state;
            endcase

          if ((frame_state_reg == idle_state) && (event_timeout == 1'b1)) begin
            initial_timeout <= 1'b1;
          end else if ((frame_state_reg == stop_state) && is_valid_stop && is_valid_addr && is_valid_data && (frame_repeat == 0)) begin
            initial_timeout <= 1'b0;
          end

          if ((frame_state_reg == start_state) && is_valid_start_b) begin
            frame_shift <= 32'h80000000;
          end else if (frame_state_reg == data_latch_state) begin
            if (is_valid_bit_zero) begin
              frame_shift <= {1'b0, frame_shift[31:1]};
            end else begin
              frame_shift <= {1'b1, frame_shift[31:1]};
            end
          end

          if (frame_state_reg == start_state) begin
            if (repeat_en && is_valid_repeat) begin
              frame_repeat <= 1'b1;
            end else begin
              frame_repeat <= 1'b0;
            end
          end

        end

        if ((receiver_en == 1'b1) && (event_new == 1'b1) && (frame_state_reg == stop_state) && is_valid_stop && is_valid_addr && is_valid_data) begin
          frame_write <= 1'b1;
          frame_addr  <= frame_shift[7:0];
          frame_data  <= frame_shift[23:16];
        end else begin
          frame_write <= 1'b0;
        end
      end
    end
  end

endmodule
