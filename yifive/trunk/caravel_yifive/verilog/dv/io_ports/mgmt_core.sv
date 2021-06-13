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
module mgmt_core (
`ifdef USE_POWER_PINS
	inout VPWR,	   
	inout VGND,
`endif
	// GPIO (dedicated pad)
	output gpio_out_pad,		// Connect to out on gpio pad
	input  gpio_in_pad,		// Connect to in on gpio pad
	output gpio_mode0_pad,		// Connect to dm[0] on gpio pad
	output gpio_mode1_pad,		// Connect to dm[2] on gpio pad
	output gpio_outenb_pad,		// Connect to oe_n on gpio pad
	output gpio_inenb_pad,		// Connect to inp_dis on gpio pad
	// Flash memory control (SPI master)
	output flash_csb,
	output flash_clk,
	output flash_csb_oeb,
	output flash_clk_oeb,
	output flash_io0_oeb,
	output flash_io1_oeb,
	output flash_io2_oeb,	// through GPIO 36
	output flash_io3_oeb,	// through GPIO 37
	output flash_csb_ieb,
	output flash_clk_ieb,
	output flash_io0_ieb,
	output flash_io1_ieb,
	output flash_io0_do,
	output flash_io1_do,
	output flash_io2_do,	// through GPIO 36
	output flash_io3_do,	// through GPIO 37
	input flash_io0_di,
	input flash_io1_di,
	// Master reset
	input resetb,
	input porb,
	// Clocking
	input clock,
	// LA signals
    	input  [127:0] la_input,           	// From User Project to cpu
    	output [127:0] la_output,          	// From CPU to User Project
    	output [127:0] la_oenb,                 // LA output enable  
    	output [127:0] la_iena,                 // LA input enable  
	// Housekeeping SPI
	output sdo_out,
	output sdo_outenb,
	// JTAG
	output jtag_out,
	output jtag_outenb,
	// User Project Control Signals
	input [`MPRJ_IO_PADS-1:0] mgmt_in_data,
	output [`MPRJ_IO_PADS-1:0] mgmt_out_data,
	output [`MPRJ_PWR_PADS-1:0] pwr_ctrl_out,
	input mprj_vcc_pwrgood,
	input mprj2_vcc_pwrgood,
	input mprj_vdd_pwrgood,
	input mprj2_vdd_pwrgood,
	output mprj_io_loader_resetn,
	output mprj_io_loader_clock,
	output mprj_io_loader_data_1,
	output mprj_io_loader_data_2,
	// WB MI A (User project)
    	input mprj_ack_i,
	input [31:0] mprj_dat_i,
    	output mprj_cyc_o,
	output mprj_stb_o,
	output mprj_we_o,
	output [3:0] mprj_sel_o,
	output [31:0] mprj_adr_o,
	output [31:0] mprj_dat_o,
	
    	output core_clk,
    	output user_clk,
    	output core_rstn,
	input [2:0] user_irq,
	output [2:0] user_irq_ena,

	// Metal programmed user ID / mask revision vector
	input [31:0] mask_rev,
	
    // MGMT area R/W interface for mgmt RAM
    output [`RAM_BLOCKS-1:0] mgmt_ena, 
    output [(`RAM_BLOCKS*4)-1:0] mgmt_wen_mask,
    output [`RAM_BLOCKS-1:0] mgmt_wen,
    output [7:0] mgmt_addr,
    output [31:0] mgmt_wdata,
    input  [(`RAM_BLOCKS*32)-1:0] mgmt_rdata,

    // MGMT area RO interface for user RAM 
    output mgmt_ena_ro,
    output [7:0] mgmt_addr_ro,
    input  [31:0] mgmt_rdata_ro
);
    	wire ext_clk_sel;
    	wire pll_clk, pll_clk90;
    	wire ext_reset;
	wire hk_connect;
	wire trap;
	wire irq_spi;

	// JTAG (to be implemented)
	wire jtag_out;
	wire jtag_out_pre = 1'b0;
	wire jtag_outenb = 1'b1;
	wire jtag_oenb_state;

	// SDO
	wire sdo_out;
	wire sdo_out_pre;
	wire sdo_oenb_state;

	// Housekeeping SPI vectors
	wire [4:0]  spi_pll_div;
	wire [2:0]  spi_pll_sel;
	wire [2:0]  spi_pll90_sel;
	wire [25:0] spi_pll_trim;

	// Override default function for SDO and JTAG outputs if purposely
	// set for override by the management SoC.
	assign sdo_out = (sdo_oenb_state == 1'b0) ? mgmt_out_data[1] : sdo_out_pre;
	assign jtag_out = (jtag_oenb_state == 1'b0) ? mgmt_out_data[0] : jtag_out_pre;

	caravel_clocking clocking1(
		.ext_clk_sel(ext_clk_sel),
		.ext_clk(clock),
		.pll_clk(pll_clk),
		.pll_clk90(pll_clk90),
		.resetb(resetb), 
		.sel(spi_pll_sel),
		.sel2(spi_pll90_sel),
		.ext_reset(ext_reset),	// From housekeeping SPI
		.core_clk(core_clk),
		.user_clk(user_clk),
		.resetb_sync(core_rstn)
	);


endmodule
`default_nettype wire
