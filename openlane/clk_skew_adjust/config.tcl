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
# SPDX-FileContributor: Modified by Dinesh Annayya <dinesha@opencores.org>

# Global
# ------

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


## Source Verilog Files
set ::env(VERILOG_FILES) "\
	$::env(DESIGN_DIR)/../../verilog/rtl/lib/ctech_cells.sv \
	$::env(DESIGN_DIR)/../../verilog/rtl/lib/clk_skew_adjust.gv"

## Clock configurations
#set ::env(CLOCK_PORT) "clk_in"

#set ::env(CLOCK_PERIOD) "10"

## Internal Macros
### Macro Placement
set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 100 100"




set ::env(VDD_PIN) [list {vccd1}]
set ::env(GND_PIN) [list {vssd1}]

set ::env(SYNTH_READ_BLACKBOX_LIB) 1

# Fill this
set ::env(CLOCK_TREE_SYNTH) 0

set ::env(CELL_PAD) 4

set ::env(FP_CORE_UTIL) 40
set ::env(PL_RANDOM_GLB_PLACEMENT) 1

set ::env(BOTTOM_MARGIN_MULT) 2
set ::env(TOP_MARGIN_MULT) 2
set ::env(GLB_RT_MAXLAYER) 4

# helps in anteena fix
set ::env(USE_ARC_ANTENNA_CHECK) "0"

set ::env(FP_PDN_VPITCH) 20
set ::env(FP_PDN_HPITCH) 20
set ::env(FP_PDN_VWIDTH) 3
set ::env(FP_PDN_HWIDTH) 3
