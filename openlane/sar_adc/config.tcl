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

# section begin
set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) sar_adc
#section end
set ::env(RUN_KLAYOUT) 0
set ::env(DESIGN_IS_CORE) 0
set ::env(FP_PDN_CORE_RING) 0 

# User Configurations
set ::env(SYNTH_READ_BLACKBOX_LIB) 1

## Source Verilog Files
set ::env(VERILOG_FILES) "\
	$script_dir/../../caravel/verilog/rtl/defines.v \
	$script_dir/../../verilog/rtl/sar_adc/SAR.sv \
	$script_dir/../../verilog/rtl/sar_adc/ACMP.sv \
	$script_dir/../../verilog/rtl/sar_adc/sar_adc.sv \
	$script_dir/../../verilog/rtl/sar_adc/adc_reg.sv \
        $script_dir/../../verilog/rtl/lib/registers.v"

## Clock configurations
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_NET)  "clk"

set ::env(CLOCK_PERIOD) "100"

set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg
set ::env(PDN_CFG) $script_dir/pdn.tcl

set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) "0 0 500 300"

#set ::env(FP_HORIZONTAL_HALO) 15
#set ::env(FP_VERTICAL_HALO)   15

#set ::env(GLB_RT_OBS) "met2 109.85000 19.89500 171.54500 69.22000"
set ::env(CLOCK_TREE_SYNTH) 0

set ::env(PL_TARGET_DENSITY) "0.01"
set ::env(GLB_RT_MAXLAYER) 5
set ::env(GLB_RT_ADJUSTMENT) 0.15

set ::env(FP_PDN_CHECK_NODES) 0
set ::env(FP_PDN_VPITCH) "45"
set ::env(FP_PDN_VWIDTH) "3.5"
#
set ::env(FP_PDN_HPITCH) "40"
set ::env(FP_PDN_HWIDTH) "6.5"

set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) 1
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 1

set ::env(DIODE_INSERTION_STRATEGY) 4

#set ::env(FP_VERTICAL_HALO) "35"
#set ::env(FP_HERTICAL_HALO) "35"


## Internal Macros
### Macro Placement
#set ::env(MACRO_PLACEMENT_CFG) $script_dir/macro.cfg

### Black-box verilog and views

set ::env(VDD_NETS) [list {vccd1} {vccd2}]
set ::env(GND_NETS) [list {vssd1} {vssd2}]
set ::env(SYNTH_USE_PG_PINS_DEFINES) "USE_POWER_PINS"

## LVS mismatch is to be solved manually by shorting VDD and VSS pins to the core ring 
set ::env(QUIT_ON_LVS_ERROR) "1"
