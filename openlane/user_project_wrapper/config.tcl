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
set ::env(MACRO_PLACEMENT_CFG) $script_dir/macro_placement.cfg

### Black-box verilog and views
set ::env(VERILOG_FILES_BLACKBOX) "\
        $script_dir/../../verilog/rtl/spi_master/src/spim_top.sv \
        $script_dir/../../verilog/rtl/wb_interconnect/src/wb_interconnect.sv  \
        $script_dir/../../verilog/rtl/digital_core/src/glbl_cfg.sv     \
	$script_dir/macro/bb/sdram.v \
	$script_dir/macro/bb/syntacore.v \
	"

set ::env(EXTRA_LEFS) "\
	$lef_root/spi_master.lef \
	$lef_root/glbl_cfg.lef \
	$lef_root/wb_interconnect.lef \
	$lef_root/sdram.lef \
	$lef_root/syntacore.lef \
	"

set ::env(EXTRA_GDS_FILES) "\
	$gds_root/spi_master.gds \
	$gds_root/glbl_cfg.gds \
	$gds_root/wb_interconnect.gds \
	$gds_root/sdram.gds \
	$gds_root/syntacore.gds \
	"

set ::env(SYNTH_DEFINES) [list SYNTHESIS ]

set ::env(VERILOG_INCLUDE_DIRS) [glob $script_dir/../../verilog/rtl/syntacore/scr1/src/includes $script_dir/../../verilog/rtl/sdram_ctrl/src/defs ]

set ::env(GLB_RT_MAXLAYER) 5

set ::env(FP_PDN_CHECK_NODES) 0

# The following is because there are no std cells in the example wrapper project.
#set ::env(SYNTH_TOP_LEVEL) 1
#set ::env(PL_RANDOM_GLB_PLACEMENT) 1

set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_BUFFER_INPUT_PORTS) 0
set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) 0

set ::env(DIODE_INSERTION_STRATEGY) 0
set ::env(FILL_INSERTION) 0
set ::env(TAP_DECAP_INSERTION) 0
set ::env(CLOCK_TREE_SYNTH) 0

# Important for large macro placement
set ::env(PL_DIAMOND_SEARCH_HEIGHT) "400"
set ::env(ROUTING_OPT_ITERS) "20"

