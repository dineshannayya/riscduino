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
module simple_fifo #(
  parameter ASIZE =  5 , // FIFO size (FIFO_size=(2**ASIZE)-1)
  parameter DSIZE = 32   // Number of bits of data
)(
  input  wire             rst_n   , // Asynchronous reset (active low)
  input  wire             clk     , // Clock (rising edge)
  input  wire             clear_n , // Synchronous clear (active low)

  // Write port
  input  wire [DSIZE-1:0] wr_data ,
  input  wire             wr_valid,
  output wire             wr_ready, // Ready flag (0: FIFO full, 1: FIFO not full)

  // Read port
  output wire [DSIZE-1:0] rd_data ,
  output wire             rd_valid,
  input  wire             rd_ready  // Ready flag (0: FIFO empty, 1: FIFO not empty)
);

  wire [ASIZE-1:0]    rd_ptr_next         ;
  wire [ASIZE-1:0]    wr_ptr_next         ;
  reg  [ASIZE-1:0]    rd_ptr              ;
  reg  [ASIZE-1:0]    wr_ptr              ;
  reg  [DSIZE-1:0]    memory[2**ASIZE-1:0];

  assign wr_ptr_next = wr_ptr + 1'b1;
  assign rd_ptr_next = rd_ptr + 1'b1;

  assign wr_ready = (wr_ptr_next != rd_ptr);
  assign rd_valid = (rd_ptr != wr_ptr);

  // Write pointer update
  always @(negedge rst_n or posedge clk) begin
    if (rst_n == 1'b0) begin
      wr_ptr <= 'b0;
    end else begin
      if (clear_n == 1'b0) begin
        wr_ptr <= 'b0;
      end else if (wr_valid && wr_ready) begin
        wr_ptr <= wr_ptr_next;
      end
    end
  end

  // Write operation
  always @(posedge clk) begin
    if (wr_valid && wr_ready) begin
      memory[wr_ptr] <= wr_data;
    end
  end

  // Read pointer update
  always @(negedge rst_n or posedge clk) begin
    if (rst_n == 1'b0) begin
      rd_ptr <= 'b0;
    end else begin
      if (clear_n == 1'b0) begin
        rd_ptr <= 'b0;
      end else if (rd_valid && rd_ready) begin
        rd_ptr <= rd_ptr_next;
      end
    end
  end

  // Read operation
  assign rd_data = memory[rd_ptr];

endmodule
