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

set ::env(DESIGN_NAME) clk_skew_adjust
set verilog_root $script_dir/../../verilog/
set lef_root $script_dir/../../lef/
set gds_root $script_dir/../../gds/
#section end

# User Configurations
#
set ::env(DESIGN_IS_CORE) 0
set ::env(FP_PDN_CORE_RING) "0"
set ::env(SYNTH_READ_BLACKBOX_LIB) "1"


## Source Verilog Files
set ::env(VERILOG_FILES) "\
	$script_dir/../../verilog/rtl/clk_skew_adjust/src/clk_skew_adjust.gv"

## Clock configurations
set ::env(CLOCK_PORT) "clk_in"

set ::env(CLOCK_PERIOD) "10"

## Internal Macros
### Macro Placement
set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg
set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 50 50"
set ::env(PL_TARGET_DENSITY) 0.85
set ::env(FP_CORE_UTIL) "60"



set ::env(FP_PDN_CHECK_NODES) 0

set ::env(RUN_KLAYOUT_DRC) 0

set ::env(VDD_PIN) [list {vccd1}]
set ::env(GND_PIN) [list {vssd1}]

# If you're going to use multiple power domains, then keep this disabled.
set ::env(RUN_CVC) 0

# The following is because there are no std cells in the example wrapper project.
set ::env(SYNTH_TOP_LEVEL) 1

set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_BUFFER_INPUT_PORTS) 0
set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) 0

# No Synthesis and CTS
set ::env(RUN_SIMPLE_CTS) 0
set ::env(SYNTH_BUFFERING) 0
set ::env(SYNTH_SIZING) 0
set ::env(CLOCK_TREE_SYNTH) 0
set ::env(PL_OPENPHYSYN_OPTIMIZATIONS) 0
set ::env(FILL_INSERTION) 1
set ::env(RUN_SIMPLE_CTS) 0
set ::env(LVS_CONNECT_BY_LABEL) 1
set ::env(CELL_PAD) 0




set ::env(PL_ROUTABILITY_DRIVEN) 1
set ::env(FP_IO_VEXTEND) 4
set ::env(FP_IO_HEXTEND) 4
set ::env(GLB_RT_MAXLAYER) 4
set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 10
set ::env(DIODE_INSERTION_STRATEGY) 4
