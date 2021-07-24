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
set ::env(DESIGN_NAME) scr1_top_wb

set ::env(DESIGN_IS_CORE) "0"
set ::env(FP_PDN_CORE_RING) "0"

# Timing configuration
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "wb_clk core_clk"

set ::env(SYNTH_MAX_FANOUT) 4

# Sources
# -------

# Local sources + no2usb sources
set ::env(VERILOG_FILES) "\
	$script_dir/../../verilog/rtl/syntacore/scr1/src/core/pipeline/scr1_pipe_top.sv  \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/core/scr1_core_top.sv  \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/core/scr1_dm.sv  \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/core/scr1_tapc_synchronizer.sv  \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/core/scr1_clk_ctrl.sv  \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/core/scr1_scu.sv  \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/core/scr1_tapc.sv  \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/core/scr1_tapc_shift_reg.sv  \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/core/scr1_dmi.sv  \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/core/primitives/scr1_reset_cells.sv  \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/core/pipeline/scr1_pipe_ifu.sv  \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/core/pipeline/scr1_pipe_idu.sv  \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/core/pipeline/scr1_pipe_exu.sv  \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/core/pipeline/scr1_pipe_mprf.sv  \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/core/pipeline/scr1_pipe_csr.sv  \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/core/pipeline/scr1_pipe_ialu.sv  \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/core/pipeline/scr1_pipe_mul.sv  \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/core/pipeline/scr1_pipe_div.sv  \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/core/pipeline/scr1_pipe_lsu.sv  \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/core/pipeline/scr1_pipe_hdu.sv  \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/core/pipeline/scr1_pipe_tdu.sv  \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/core/pipeline/scr1_ipic.sv   \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/top/scr1_dmem_router.sv   \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/top/scr1_imem_router.sv   \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/top/scr1_tcm.sv   \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/top/scr1_timer.sv   \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/top/scr1_top_wb.sv   \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/top/scr1_dmem_wb.sv   \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/top/scr1_imem_wb.sv   \
	$script_dir/../../verilog/rtl/syntacore/scr1/src/top/scr1_intf.sv   \
	$script_dir/../../verilog/rtl/lib/async_fifo.sv "

set ::env(VERILOG_INCLUDE_DIRS) [glob $script_dir/../../verilog/rtl/syntacore/scr1/src/includes ]

set ::env(SDC_FILE) "$script_dir/base.sdc"
set ::env(BASE_SDC_FILE) "$script_dir/base.sdc"
#set ::env(SYNTH_DEFINES) [list SCR1_DBG_EN ]

set ::env(LEC_ENABLE) 0

set ::env(VDD_PIN) [list {vccd1}]
set ::env(GND_PIN) [list {vssd1}]


# --------
# Floorplanning
# -------------

set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) [list 0.0 0.0 1600.0 1200.0]


# If you're going to use multiple power domains, then keep this disabled.
set ::env(RUN_CVC) 0

#set ::env(PDN_CFG) $script_dir/pdn.tcl


set ::env(PL_TIME_DRIVEN) 1
set ::env(PL_TARGET_DENSITY) "0.45"
set ::env(GLOBAL_ROUTER) "fastroute"
set ::env(DETAILED_ROUTER) "tritonroute"
set ::env(CELL_PAD) "4"

set ::env(FP_IO_VEXTEND) 4
set ::env(FP_IO_HEXTEND) 4


set ::env(GLB_RT_MAXLAYER) 5
set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 10
set ::env(DIODE_INSERTION_STRATEGY) 4


#set ::env(LVS_CONNECT_BY_LABEL) 1

set ::env(FP_PDN_VPITCH) 100
set ::env(FP_PDN_HPITCH) 100
set ::env(FP_PDN_VWIDTH) 3
set ::env(FP_PDN_HWIDTH) 3
