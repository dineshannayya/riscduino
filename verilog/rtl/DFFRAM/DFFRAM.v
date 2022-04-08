// SPDX-FileCopyrightText: 2020 Efabless Corporation
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

`default_nettype none




module DFFRAM (
`ifdef USE_POWER_PINS
    input VPWR,
    input VGND,
`endif
    input CLK,
    input [3:0] WE,
    input EN,
    input [31:0] Di,
    output reg [31:0] Do,
    input [7:0] A
);
  
parameter MEM_WORDS= 256;

reg [31:0] mem [0:MEM_WORDS-1];

always @(posedge CLK) begin
    if (EN == 1'b1) begin
        Do <= mem[A];
        if (WE[0]) mem[A][ 7: 0] <= Di[ 7: 0];
        if (WE[1]) mem[A][15: 8] <= Di[15: 8];
        if (WE[2]) mem[A][23:16] <= Di[23:16];
        if (WE[3]) mem[A][31:24] <= Di[31:24];
    end
end
endmodule

