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
set ::env(DESIGN_NAME) ycr1_top_wb

set ::env(DESIGN_IS_CORE) "0"
set ::env(FP_PDN_CORE_RING) "0"

# Timing configuration
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "wb_clk core_clk"

set ::env(SYNTH_MAX_FANOUT) 4

## CTS BUFFER
set ::env(CTS_CLK_BUFFER_LIST) "sky130_fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_8"
set ::env(CTS_SINK_CLUSTERING_SIZE) "16"
set ::env(CLOCK_BUFFER_FANOUT) "8"

# Sources
# -------

# Local sources + no2usb sources
set ::env(VERILOG_FILES) "\
        $script_dir/../../verilog/rtl/clk_skew_adjust/src/clk_skew_adjust.gv \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr1_pipe_top.sv  \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/core/ycr1_core_top.sv  \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/core/ycr1_dm.sv  \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/core/ycr1_tapc_synchronizer.sv  \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/core/ycr1_clk_ctrl.sv  \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/core/ycr1_scu.sv  \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/core/ycr1_tapc.sv  \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/core/ycr1_tapc_shift_reg.sv  \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/core/ycr1_dmi.sv  \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/core/primitives/ycr1_reset_cells.sv  \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr1_pipe_ifu.sv  \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr1_pipe_idu.sv  \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr1_pipe_exu.sv  \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr1_pipe_mprf.sv  \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr1_pipe_csr.sv  \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr1_pipe_ialu.sv  \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr1_pipe_mul.sv  \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr1_pipe_div.sv  \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr1_pipe_lsu.sv  \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr1_pipe_hdu.sv  \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr1_pipe_tdu.sv  \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr1_ipic.sv   \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/top/ycr1_dmem_router.sv   \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/top/ycr1_imem_router.sv   \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/top/ycr1_icache_router.sv \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/top/ycr1_dcache_router.sv \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/top/ycr1_tcm.sv   \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/top/ycr1_timer.sv   \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/top/ycr1_top_wb.sv   \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/top/ycr1_dmem_wb.sv   \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/top/ycr1_imem_wb.sv   \
	$script_dir/../../verilog/rtl/yifive/ycr1c/src/top/ycr1_intf.sv   \
        $script_dir/../../verilog/rtl/yifive/ycr1c/src/cache/src/core/icache_top.sv             \
        $script_dir/../../verilog/rtl/yifive/ycr1c/src/cache/src/core/icache_app_fsm.sv         \
        $script_dir/../../verilog/rtl/yifive/ycr1c/src/cache/src/core/icache_tag_fifo.sv        \
        $script_dir/../../verilog/rtl/yifive/ycr1c/src/cache/src/core/dcache_tag_fifo.sv        \
        $script_dir/../../verilog/rtl/yifive/ycr1c/src/cache/src/core/dcache_top.sv             \
        $script_dir/../../verilog/rtl/yifive/ycr1c/src/lib/ycr1_async_wbb.sv                    \
        $script_dir/../../verilog/rtl/yifive/ycr1c/src/lib/ycr1_arb.sv                          \
        $script_dir/../../verilog/rtl/yifive/ycr1c/src/lib/sync_fifo.sv                         \
        $script_dir/../../verilog/rtl/yifive/ycr1c/src/lib/async_fifo.sv                        \
        $script_dir/../../verilog/rtl/yifive/ycr1c/src/lib/ctech_cells.sv                       \
	"

set ::env(VERILOG_INCLUDE_DIRS) [glob $script_dir/../../verilog/rtl/yifive/ycr1c/src/includes ]
set ::env(SYNTH_READ_BLACKBOX_LIB) 1
set ::env(SYNTH_DEFINES) [list SYNTHESIS ]

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
set ::env(DIE_AREA) [list 0.0 0.0 725.0 1550.0]


# If you're going to use multiple power domains, then keep this disabled.
set ::env(RUN_CVC) 0

#set ::env(PDN_CFG) $script_dir/pdn.tcl


set ::env(PL_TIME_DRIVEN) 1
set ::env(PL_TARGET_DENSITY) "0.35"
set ::env(FP_CORE_UTIL) "50"

# helps in anteena fix
set ::env(USE_ARC_ANTENNA_CHECK) "0"

set ::env(FP_IO_VEXTEND) 4
set ::env(FP_IO_HEXTEND) 4

set ::env(FP_PDN_VPITCH) 100
set ::env(FP_PDN_HPITCH) 100
set ::env(FP_PDN_VWIDTH) 3
set ::env(FP_PDN_HWIDTH) 3

set ::env(GLB_RT_MAXLAYER) 6
set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 10
set ::env(DIODE_INSERTION_STRATEGY) 4


set ::env(QUIT_ON_TIMING_VIOLATIONS) "0"
set ::env(QUIT_ON_MAGIC_DRC) "1"
set ::env(QUIT_ON_LVS_ERROR) "0"
set ::env(QUIT_ON_SLEW_VIOLATIONS) "0"

#Need to cross-check why global timing opimization creating setup vio with hugh hold fix
set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) "0"

