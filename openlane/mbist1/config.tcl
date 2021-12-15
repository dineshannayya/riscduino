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

set ::env(DESIGN_NAME) mbist_top1

set ::env(DESIGN_IS_CORE) "0"

# Timing configuration
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "u_cts_wb_clk_b1.u_buf/X  u_cts_wb_clk_b2.u_buf/X u_mem_sel.u_cts_mem_clk_a.u_buf/X u_mem_sel.u_cts_mem_clk_b.u_buf/X"

set ::env(SYNTH_MAX_FANOUT) 4

# Sources
# -------

# Local sources + no2usb sources
set ::env(VERILOG_FILES) "\
     $script_dir/../../verilog/rtl/clk_skew_adjust/src/clk_skew_adjust.gv \
     $script_dir/../../verilog/rtl/mbist/src/core/mbist_addr_gen.sv \
     $script_dir/../../verilog/rtl/mbist/src/core/mbist_fsm.sv     \
     $script_dir/../../verilog/rtl/mbist/src/core/mbist_op_sel.sv  \
     $script_dir/../../verilog/rtl/mbist/src/core/mbist_repair_addr.sv \
     $script_dir/../../verilog/rtl/mbist/src/core/mbist_sti_sel.sv \
     $script_dir/../../verilog/rtl/mbist/src/core/mbist_pat_sel.sv \
     $script_dir/../../verilog/rtl/mbist/src/core/mbist_mux.sv \
     $script_dir/../../verilog/rtl/mbist/src/core/mbist_data_cmp.sv \
     $script_dir/../../verilog/rtl/mbist/src/core/mbist_mem_wrapper.sv \
     $script_dir/../../verilog/rtl/mbist/src/top/mbist_top1.sv  \
     $script_dir/../../verilog/rtl/lib/ctech_cells.sv     \
     $script_dir/../../verilog/rtl/lib/reset_sync.sv \
	     "

set ::env(VERILOG_INCLUDE_DIRS) [glob $script_dir/../../verilog/rtl/mbist/include ]
set ::env(SYNTH_DEFINES) [list SYNTHESIS ]


set ::env(SYNTH_PARAMS) "BIST_ADDR_WD 9,\
	                 BIST_DATA_WD 32,\
		         BIST_ADDR_START 9'h000,\
			 BIST_ADDR_END 9'h1FB,\
			 BIST_REPAIR_ADDR_START 9'h1FC,\
			 BIST_RAD_WD_I 9,\
			 BIST_RAD_WD_O 9\
			 "

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
set ::env(DIE_AREA) "0 0 200 275"


# If you're going to use multiple power domains, then keep this disabled.
set ::env(RUN_CVC) 1

#set ::env(PDN_CFG) $script_dir/pdn.tcl


set ::env(PL_TIME_DRIVEN) 1
set ::env(PL_TARGET_DENSITY) "0.35"



set ::env(FP_IO_VEXTEND) 4
set ::env(FP_IO_HEXTEND) 4

set ::env(FP_PDN_VPITCH) 100
set ::env(FP_PDN_HPITCH) 100
set ::env(FP_PDN_VWIDTH) 5
set ::env(FP_PDN_HWIDTH) 5

set ::env(GLB_RT_MAXLAYER) 5
set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 10

set ::env(DIODE_INSERTION_STRATEGY) 4


set ::env(QUIT_ON_TIMING_VIOLATIONS) "0"
set ::env(QUIT_ON_MAGIC_DRC) "1"
set ::env(QUIT_ON_LVS_ERROR) "0"
set ::env(QUIT_ON_SLEW_VIOLATIONS) "0"
