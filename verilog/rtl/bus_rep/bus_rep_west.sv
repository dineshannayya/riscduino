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
//               Bus Repater                                        //
//////////////////////////////////////////////////////////////////////
module bus_rep_west #(
	parameter BUS_REP_WD = 7
        ) (
`ifdef USE_POWER_PINS
         input logic            vccd1,    // User area 1 1.8V supply
         input logic            vssd1,    // User area 1 digital ground
`endif
	 // Bus repeaters
	 input  [BUS_REP_WD-1:0]  ch_in,
	 output [BUS_REP_WD-1:0] ch_out
      );

// channel repeater

`ifndef SYNTHESIS

assign ch_out = ch_in;

`else

 genvar i;
 generate
	for (i = 0; i < BUS_REP_WD; i = i + 1) begin : u_rp
       sky130_fd_sc_hd__clkbuf_4 u_buf ( .A(ch_in[i]), .X(ch_out[i]));
    end
 endgenerate

`endif


endmodule

