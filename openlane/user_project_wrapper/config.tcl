# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0

# Base Configurations. Don't Touch
# section begin
set script_dir [file dirname [file normalize [info script]]]

source $script_dir/../../caravel/openlane/user_project_wrapper_empty/fixed_wrapper_cfgs.tcl

set ::env(DESIGN_NAME) user_project_wrapper
set verilog_root $script_dir/../../verilog/
set lef_root $script_dir/../../lef/
set gds_root $script_dir/../../gds/
#section end

# User Configurations

## Source Verilog Files
set ::env(VERILOG_FILES) "\
	$script_dir/../../caravel/verilog/rtl/defines.v \
	$script_dir/../../verilog/rtl/digital_core/src/digital_core.sv \
	$script_dir/../../verilog/rtl/user_project_wrapper.v"

## Clock configurations
set ::env(CLOCK_PORT) "user_clock2 wb_clk_i"
#set ::env(CLOCK_NET) "mprj.clk"

set ::env(CLOCK_PERIOD) "10"

## Internal Macros
### Macro Placement
set ::env(FP_SIZING) "absolute"
set ::env(MACRO_PLACEMENT_CFG) $script_dir/macro.cfg

set ::env(SDC_FILE) "$script_dir/base.sdc"
set ::env(BASE_SDC_FILE) "$script_dir/base.sdc"


### Black-box verilog and views
set ::env(VERILOG_FILES_BLACKBOX) "\
        $script_dir/../../verilog/gl/spi_master.v \
        $script_dir/../../verilog/gl/wb_interconnect.v \
        $script_dir/../../verilog/gl/glbl_cfg.v     \
        $script_dir/../../verilog/gl/uart.v     \
	$script_dir/../../verilog/gl/sdram.v \
	$script_dir/../../verilog/gl/syntacore.v \
	"

set ::env(EXTRA_LEFS) "\
	$lef_root/spi_master.lef \
	$lef_root/glbl_cfg.lef \
	$lef_root/wb_interconnect.lef \
	$lef_root/sdram.lef \
	$lef_root/uart.lef \
	$lef_root/syntacore.lef \
	"

set ::env(EXTRA_GDS_FILES) "\
	$gds_root/spi_master.gds \
	$gds_root/glbl_cfg.gds \
	$gds_root/wb_interconnect.gds \
	$gds_root/uart.gds \
	$gds_root/sdram.gds \
	$gds_root/syntacore.gds \
	"

set ::env(SYNTH_DEFINES) [list SYNTHESIS ]

set ::env(VERILOG_INCLUDE_DIRS) [glob $script_dir/../../verilog/rtl/syntacore/scr1/src/includes $script_dir/../../verilog/rtl/sdram_ctrl/src/defs ]



# The following is because there are no std cells in the example wrapper project.
#set ::env(SYNTH_TOP_LEVEL) 1
set ::env(PL_BASIC_PLACEMENT) 1

# Important for large macro placement
set ::env(PL_DIAMOND_SEARCH_HEIGHT) "400"
set ::env(ROUTING_OPT_ITERS) "20"

set ::env(GLB_RT_ALLOW_CONGESTION) 1
set ::env(GLB_RT_MAXLAYER) 5
set ::env(GLB_RT_MINLAYER) 2
set ::env(GLB_RT_ADJUSTMENT) 0.45
set ::env(GENERATE_FINAL_SUMMARY_REPORT) 1
set ::env(SYNTH_READ_BLACKBOX_LIB) 1
set ::env(FP_PDN_CHECK_NODES) 0
# This makes sure that the core rings are outside the boundaries
# of your block.
set ::env(MAGIC_ZEROIZE_ORIGIN) 0

# Area Configurations. DON'T TOUCH.
set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 2920 3520"

set ::env(RUN_CVC) 0

# Pin Configurations. DON'T TOUCH
set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

set ::unit 2.4
set ::env(FP_IO_VEXTEND) [expr 2*$::unit]
set ::env(FP_IO_HEXTEND) [expr 2*$::unit]
set ::env(FP_IO_VLENGTH) $::unit
set ::env(FP_IO_HLENGTH) $::unit

set ::env(FP_IO_VTHICKNESS_MULT) 4
set ::env(FP_IO_HTHICKNESS_MULT) 4

# Power & Pin Configurations. DON'T TOUCH.
set ::env(FP_PDN_CORE_RING) 1
set ::env(FP_PDN_CORE_RING_VWIDTH) 3
set ::env(FP_PDN_CORE_RING_HWIDTH) $::env(FP_PDN_CORE_RING_VWIDTH)
set ::env(FP_PDN_CORE_RING_VOFFSET) 14
set ::env(FP_PDN_CORE_RING_HOFFSET) $::env(FP_PDN_CORE_RING_VOFFSET)
set ::env(FP_PDN_CORE_RING_VSPACING) 1.7
set ::env(FP_PDN_CORE_RING_HSPACING) $::env(FP_PDN_CORE_RING_VSPACING)

set ::env(FP_PDN_VWIDTH) 3
set ::env(FP_PDN_HWIDTH) 3
set ::env(FP_PDN_VOFFSET) 5
set ::env(FP_PDN_HOFFSET) $::env(FP_PDN_VOFFSET)
set ::env(FP_PDN_VPITCH) 180
set ::env(FP_PDN_HPITCH) $::env(FP_PDN_VPITCH)
set ::env(FP_PDN_VSPACING) [expr 5*$::env(FP_PDN_CORE_RING_VWIDTH)]
set ::env(FP_PDN_HSPACING) [expr 5*$::env(FP_PDN_CORE_RING_HWIDTH)]
set ::env(VDD_NETS) [list {vccd1} {vccd2} {vdda1} {vdda2}]
set ::env(GND_NETS) [list {vssd1} {vssd2} {vssa1} {vssa2}]
set ::env(SYNTH_USE_PG_PINS_DEFINES) "USE_POWER_PINS"

set ::env(DIODE_INSERTION_STRATEGY) 0
set ::env(FILL_INSERTION) 0
set ::env(TAP_DECAP_INSERTION) 0
set ::env(CLOCK_TREE_SYNTH) 0
