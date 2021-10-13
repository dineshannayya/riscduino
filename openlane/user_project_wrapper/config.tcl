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

# YOU ARE NOT ALLOWED TO CHANGE ANY VARIABLES DEFINED IN THE FIXED WRAPPER CFGS 
source $::env(CARAVEL_ROOT)/openlane/user_project_wrapper_empty/fixed_wrapper_cfgs.tcl

# YOU CAN CHANGE ANY VARIABLES DEFINED IN THE DEFAULT WRAPPER CFGS BY OVERRIDING THEM IN THIS CONFIG.TCL
source $::env(CARAVEL_ROOT)/openlane/user_project_wrapper_empty/default_wrapper_cfgs.tcl

set script_dir [file dirname [file normalize [info script]]]
set proj_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) user_project_wrapper
set verilog_root $proj_dir/../../verilog/
set lef_root $proj_dir/../../lef/
set gds_root $proj_dir/../../gds/
#section end

# User Configurations
#
set ::env(DESIGN_IS_CORE) 1
set ::env(FP_PDN_CORE_RING) 1


## Source Verilog Files
set ::env(VERILOG_FILES) "\
	$proj_dir/../../caravel/verilog/rtl/defines.v \
	$proj_dir/../../verilog/rtl/user_project_wrapper.v"

## Clock configurations
set ::env(CLOCK_PORT) "user_clock2 wb_clk_i"
#set ::env(CLOCK_NET) "mprj.clk"

set ::env(CLOCK_PERIOD) "10"

## Internal Macros
### Macro Placement
set ::env(FP_SIZING) "absolute"
set ::env(MACRO_PLACEMENT_CFG) $proj_dir/macro.cfg

set ::env(PDN_CFG) $proj_dir/pdn.tcl

#set ::env(SDC_FILE) "$proj_dir/base.sdc"
#set ::env(BASE_SDC_FILE) "$proj_dir/base.sdc"

set ::env(SYNTH_READ_BLACKBOX_LIB) 1

### Black-box verilog and views
set ::env(VERILOG_FILES_BLACKBOX) "\
        $proj_dir/../../verilog/gl/qspim.v \
        $proj_dir/../../verilog/gl/wb_interconnect.v \
        $proj_dir/../../verilog/gl/pinmux.v     \
        $proj_dir/../../verilog/gl/sar_adc.v     \
        $proj_dir/../../verilog/gl/uart_i2cm_usb_spi.v     \
	$proj_dir/../../verilog/rtl/sar_adc/DAC_8BIT.v \
	$proj_dir/../../verilog/gl/wb_host.v \
	$proj_dir/../../verilog/gl/syntacore.v \
	$proj_dir/../../verilog/rtl/sram_macros/sky130_sram_2kbyte_1rw1r_32x512_8.v \
	"

set ::env(EXTRA_LEFS) "\
	$lef_root/qspim.lef \
	$lef_root/pinmux.lef \
	$lef_root/wb_interconnect.lef \
	$lef_root/uart_i2cm_usb_spi.lef \
	$lef_root/wb_host.lef \
	$lef_root/sar_adc.lef \
	$lef_root/DAC_8BIT.lef \
	$lef_root/syntacore.lef \
	$lef_root/sky130_sram_2kbyte_1rw1r_32x512_8.lef \
	"

set ::env(EXTRA_GDS_FILES) "\
	$gds_root/qspim.gds \
	$gds_root/pinmux.gds \
	$gds_root/wb_interconnect.gds \
	$gds_root/uart_i2cm_usb_spi.gds \
	$gds_root/wb_host.gds \
	$gds_root/sar_adc.gds \
	$gds_root/DAC_8BIT.gds \
	$gds_root/sky130_sram_2kbyte_1rw1r_32x512_8.gds \
	"

set ::env(SYNTH_DEFINES) [list SYNTHESIS ]

set ::env(VERILOG_INCLUDE_DIRS) [glob $proj_dir/../../verilog/rtl/syntacore/scr1/src/includes ]

set ::env(GLB_RT_MAXLAYER) 5

set ::env(FP_PDN_CHECK_NODES) 0

set ::env(RUN_KLAYOUT_DRC) 0

## Internal Macros
### Macro PDN Connections
set ::env(FP_PDN_ENABLE_MACROS_GRID) "0"
set ::env(FP_PDN_ENABLE_GLOBAL_CONNECTIONS) "1"

set ::env(VDD_NETS) "vccd1 vccd2 vdda1 vdda2"
set ::env(GND_NETS) "vssd1 vssd2 vssa1 vssa2"

set ::env(FP_PDN_ENABLE_RAILS) 0


# The following is because there are no std cells in the example wrapper project.
#set ::env(SYNTH_TOP_LEVEL) 1
#set ::env(PL_RANDOM_GLB_PLACEMENT) 1

set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_BUFFER_INPUT_PORTS) 0
set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) 0

set ::env(TAP_DECAP_INSERTION) "0"
set ::env(DIODE_INSERTION_STRATEGY) 0
set ::env(FILL_INSERTION) 0
set ::env(CLOCK_TREE_SYNTH) 0

#set ::env(MAGIC_EXT_USE_GDS) "1"
set ::env(QUIT_ON_LVS_ERROR) "1"

set ::env(PL_DIAMOND_SEARCH_HEIGHT) "250"


set ::env(FP_PDN_HOFFSET) "5"
set ::env(FP_PDN_HPITCH) "120"
set ::env(FP_PDN_HSPACING) "15"
set ::env(FP_PDN_HWIDTH) "3"
set ::env(FP_PDN_LOWER_LAYER) "met4"
set ::env(FP_PDN_RAILS_LAYER) "met1"
set ::env(FP_PDN_RAIL_OFFSET) "0"
set ::env(FP_PDN_RAIL_WIDTH) "0.48"
set ::env(FP_PDN_UPPER_LAYER) "met5"
set ::env(FP_PDN_VOFFSET) "5"
set ::env(FP_PDN_VPITCH) "120"
set ::env(FP_PDN_VSPACING) "15"
set ::env(FP_PDN_VWIDTH) "3"
