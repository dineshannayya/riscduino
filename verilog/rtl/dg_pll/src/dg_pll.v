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


/*****************************************************************
Formula clock period: 1.168 + (bcount * 0.012)

Example for bcount: 10
        clock period = 1.168 + (10 *0.012) = 1.288

Offset	bcount	clock period	 4xclock period (ns)	clock (Mhz)
1.168	0	    1.168	            4.672	        214.041095890411
1.168	1	    1.18	            4.72	        211.864406779661
1.168	2	    1.192	            4.768	        209.731543624161
1.168	3	    1.204	            4.816	        207.641196013289
1.168	4	    1.216	            4.864	        205.592105263158
1.168	5	    1.228	            4.912	        203.583061889251
1.168	6	    1.24	            4.96	        201.612903225806
1.168	7	    1.252	            5.008	        199.680511182109
1.168	8	    1.264	            5.056	        197.784810126582
1.168	9	    1.276	            5.104	        195.924764890282
1.168	10	    1.288	            5.152	        194.099378881988
1.168	11	    1.3	                5.2	            192.307692307692
1.168	12	    1.312	            5.248	        190.548780487805
1.168	13	    1.324	            5.296	        188.821752265861
1.168	14	    1.336	            5.344	        187.125748502994
1.168	15	    1.348	            5.392	        185.459940652819
1.168	16	    1.36	            5.44	        183.823529411765
1.168	17	    1.372	            5.488	        182.215743440233
1.168	18	    1.384	            5.536	        180.635838150289
1.168	19	    1.396	            5.584	        179.083094555874
1.168	20	    1.408	            5.632	        177.556818181818
1.168	21	    1.42	            5.68	        176.056338028169
1.168	22	    1.432	            5.728	        174.581005586592
1.168	23	    1.444	            5.776	        173.130193905817
1.168	24	    1.456	            5.824	        171.703296703297
1.168	25	    1.468	            5.872	        170.299727520436
1.168	26	    1.48	            5.92	        168.918918918919

**************************************************/
`default_nettype none
// Digital PLL (ring oscillator + controller)
// Technically this is a frequency locked loop, not a phase locked loop.

module dg_pll(
`ifdef USE_POWER_PINS
    VPWR,
    VGND,
`endif
    resetb, enable, osc, clockp, div, dco, ext_trim);

`ifdef USE_POWER_PINS
    input VPWR;
    input VGND;
`endif

    input	 resetb;	// Sense negative reset
    input	 enable;	// Enable PLL
    input	 osc;		// Input oscillator to match
    input [4:0]	 div;		// PLL feedback division ratio
    input 	 dco;		// Run in DCO mode
    input [25:0] ext_trim;	// External trim for DCO mode

    output [1:0] clockp;	// Two 90 degree clock phases

    wire [25:0]  itrim;		// Internally generated trim bits
    wire [25:0]  otrim;		// Trim bits applied to the ring oscillator
    wire	 creset;	// Controller reset
    wire	 ireset;	// Internal reset (external reset OR disable)

    assign ireset = ~resetb | ~enable;

    // In DCO mode: Hold controller in reset and apply external trim value

    assign itrim = (dco == 1'b0) ? otrim : ext_trim;
    assign creset = (dco == 1'b0) ? ireset : 1'b1;

    ring_osc2x13 ringosc (
        .reset(ireset),
        .trim(itrim),
        .clockp(clockp)
    );

    digital_pll_controller pll_control (
        .reset(creset),
        .clock(clockp[0]),
        .osc(osc),
        .div(div),
        .trim(otrim)
    );

endmodule
`default_nettype wire
