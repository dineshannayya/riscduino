//////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: Syntacore LLC © 2016-2021
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
// SPDX-FileContributor: Syntacore LLC
// //////////////////////////////////////////////////////////////////////////
/// @file       <scr1_cg.sv>
/// @brief      SCR1 clock gate primitive
///

`include "scr1_arch_description.svh"

`ifdef SCR1_CLKCTRL_EN
module scr1_cg (
    input   logic   clk,
    input   logic   clk_en,
    input   logic   test_mode,
    output  logic   clk_out
);

// The code below is a clock gate model for simulation.
// For synthesis, it should be replaced by implementation-specific
// clock gate code.

logic latch_en;

always_latch begin
    if (~clk) begin
        latch_en <= test_mode | clk_en;
    end
end

assign clk_out  = latch_en & clk;

endmodule : scr1_cg

`endif // SCR1_CLKCTRL_EN
