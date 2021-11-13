# SPDX-FileCopyrightText:  2021 , Dinesh Annayya
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
# Name

set ::env(DESIGN_NAME) wb_host

set ::env(DESIGN_IS_CORE) "0"

# Timing configuration
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "wbm_clk_i wbs_clk_i"

set ::env(SYNTH_MAX_FANOUT) 4

# Sources
# -------

# Local sources + no2usb sources
set ::env(VERILOG_FILES) "\
     $script_dir/../../verilog/rtl/clk_skew_adjust/src/clk_skew_adjust.gv \
     $script_dir/../../verilog/rtl/wb_host/src/wb_host.sv \
     $script_dir/../../verilog/rtl/lib/async_fifo.sv      \
     $script_dir/../../verilog/rtl/lib/async_wb.sv        \
     $script_dir/../../verilog/rtl/lib/clk_ctl.v          \
     $script_dir/../../verilog/rtl/lib/ctech_cells.sv     \
     $script_dir/../../verilog/rtl/lib/registers.v"

set ::env(SYNTH_READ_BLACKBOX_LIB) 1
set ::env(SDC_FILE) "$script_dir/base.sdc"
set ::env(BASE_SDC_FILE) "$script_dir/base.sdc"

set ::env(LEC_ENABLE) 0

set ::env(VDD_PIN) [list {vccd1}]
set ::env(GND_PIN) [list {vssd1}]


# Floorplanning
# -------------

set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 500 300"

# If you're going to use multiple power domains, then keep this disabled.
set ::env(RUN_CVC) 1

#set ::env(PDN_CFG) $script_dir/pdn.tcl


set ::env(PL_TIME_DRIVEN) 1
set ::env(PL_TARGET_DENSITY) "0.30"



set ::env(FP_IO_VEXTEND) 4
set ::env(FP_IO_HEXTEND) 4

set ::env(FP_PDN_VPITCH) 100
set ::env(FP_PDN_HPITCH) 100
set ::env(FP_PDN_VWIDTH) 5
set ::env(FP_PDN_HWIDTH) 5

set ::env(GLB_RT_MAXLAYER) 5
set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 10
set ::env(DIODE_INSERTION_STRATEGY) 4

#To fix the metal density issue in tapeout check -recommded by jeffdi 
#set ::env(DECAP_CELL) "sky130_ef_sc_hd__decap_12 sky130_fd_sc_hd__decap_3 sky130_fd_sc_hd__decap_4 sky130_fd_sc_hd__decap_6 sky130_fd_sc_hd__decap_8"

set ::env(QUIT_ON_TIMING_VIOLATIONS) "0"
set ::env(QUIT_ON_MAGIC_DRC) "1"
set ::env(QUIT_ON_LVS_ERROR) "0"
set ::env(QUIT_ON_SLEW_VIOLATIONS) "0"
