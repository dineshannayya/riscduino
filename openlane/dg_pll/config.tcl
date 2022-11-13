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

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) dg_pll
set ::env(DESIGN_IS_CORE) 0

set ::env(VERILOG_FILES) "$::env(DESIGN_DIR)/../../verilog/rtl/dg_pll/src/dg_pll.v \
                          $::env(DESIGN_DIR)/../../verilog/rtl/dg_pll/src/digital_pll_controller.v \
                          $::env(DESIGN_DIR)/../../verilog/rtl/dg_pll/src/ring_osc2x13.v"

set ::env(CLOCK_PORT) ""
set ::env(CLOCK_TREE_SYNTH) 0

# Synthesis
set ::env(SYNTH_READ_BLACKBOX_LIB) 1
set ::env(SYNTH_MAX_FANOUT) 6
set ::env(SYNTH_BUFFERING) 0
set ::env(SYNTH_SIZING) 0

# Timing configuration
set ::env(BASE_SDC_FILE) $::env(DESIGN_DIR)/base.sdc 

## Floorplan
set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg

set ::env(MACRO_PLACEMENT_CFG) $::env(DESIGN_DIR)/macro.cfg

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 90 100"
set ::env(GRT_OBS)  "met4 0 0 90 100"


#set ::env(TOP_MARGIN_MULT) 2
#set ::env(BOTTOM_MARGIN_MULT) 2

#LVS Issue - DEF Base looks to having issue
set ::env(MAGIC_EXT_USE_GDS) {1}


set ::env(CELL_PAD)  0

## PDN 
set ::env(FP_PDN_VPITCH) 40
set ::env(FP_PDN_HPITCH) 40
set ::env(FP_PDN_VWIDTH) 6.2
set ::env(FP_PDN_HWIDTH) 6.2
set ::env(FP_PDN_VOFFSET) "5"
set ::env(FP_PDN_HOFFSET) "5"
set ::env(FP_PDN_HSPACING) {13.8}
set ::env(FP_PDN_VSPACING) {13.8}
set ::env(FP_PDN_HORIZONTAL_HALO) "10"
set ::env(FP_PDN_VERTICAL_HALO) "10"

## Placement
set ::env(PL_TARGET_DENSITY) 0.82


## Routing 

#set ::env(GLB_RT_MAXLAYER) 5
set ::env(RT_MAX_LAYER) {met4}

#Lef 
set ::env(MAGIC_GENERATE_LEF) {1}
set ::env(MAGIC_WRITE_FULL_LEF) {0}


set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 1
set ::env(PL_RESIZER_BUFFER_INPUT_PORTS) 0
set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) 0
set ::env(DIODE_INSERTION_STRATEGY) 0
#set ::env(FILL_INSERTION) 0
#set ::env(TAP_DECAP_INSERTION) 0
set ::env(CLOCK_TREE_SYNTH) 0

## Diode Insertion
#set ::env(DIODE_INSERTION_STRATEGY) "4"


