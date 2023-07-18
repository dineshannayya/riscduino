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

set ::env(ROUTING_CORES) "6"

set ::env(DESIGN_NAME) ycr_intf
set ::env(DESIGN_IS_CORE) "0"
set ::env(FP_PDN_CORE_RING) "0"

# Timing configuration
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "wb_clk core_clk"

set ::env(SYNTH_MAX_FANOUT) 4
set ::env(SYNTH_BUFFERING) {0}

## CTS BUFFER
set ::env(CTS_CLK_MAX_WIRE_LENGTH) {250}
set ::env(CTS_CLK_BUFFER_LIST) "sky130_fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_8"
set ::env(CTS_SINK_CLUSTERING_SIZE) "16"
set ::env(CLOCK_BUFFER_FANOUT) "8"
set ::env(LEC_ENABLE) 0

set ::env(VERILOG_FILES) "\
        $::env(DESIGN_DIR)/../../verilog/rtl/lib/clk_skew_adjust.gv                  \
        $::env(DESIGN_DIR)/../../verilog/rtl/lib/ctech_cells.sv                      \
        $::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/cache/src/core/dcache_top.sv            \
        $::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/cache/src/core/dcache_tag_fifo.sv       \
        $::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/cache/src/core/icache_tag_fifo.sv       \
        $::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/cache/src/core/icache_top.sv            \
        $::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/cache/src/core/icache_app_fsm.sv        \
        $::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/lib/ycr_async_wbb.sv                    \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/top/ycr_dmem_wb.sv                      \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/top/ycr_intf.sv                        \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/top/ycr_sram_mux.sv                   \
        $::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/lib/async_fifo.sv                       \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/core/primitives/ycr_reset_cells.sv     \
	"
set ::env(VERILOG_INCLUDE_DIRS) [glob $::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/includes ]
set ::env(SYNTH_READ_BLACKBOX_LIB) 1
set ::env(SYNTH_DEFINES) [list SYNTHESIS ]


set ::env(SDC_FILE) $::env(DESIGN_DIR)/base.sdc
set ::env(BASE_SDC_FILE) $::env(DESIGN_DIR)/base.sdc

set ::env(SYNTH_ENB_CG) 1
set ::env(LEC_ENABLE) 0

set ::env(VDD_PIN) [list {vccd1}]
set ::env(GND_PIN) [list {vssd1}]

## Floorplan
set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg
set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 650 625 "
#set ::env(CELL_PAD) "8"
set ::env(GRT_ADJUSTMENT) {0.2}

set ::env(PL_TARGET_DENSITY) 0.45

#set ::env(FP_IO_VEXTEND) {6}
#set ::env(FP_IO_HEXTEND) {6}

set ::env(RT_MAX_LAYER) {met4}
#set ::env(GLB_RT_MAXLAYER) "5"
#set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 10
set ::env(DIODE_INSERTION_STRATEGY) 3

#LVS Issue - DEF Base looks to having issue
set ::env(MAGIC_EXT_USE_GDS) {1}

set ::env(GLB_RESIZER_MAX_SLEW_MARGIN) {1.5}
set ::env(PL_RESIZER_MAX_SLEW_MARGIN) {1.5}

set ::env(GLB_RESIZER_MAX_CAP_MARGIN) {0.25}
set ::env(PL_RESIZER_MAX_CAP_MARGIN) {0.25}

set ::env(GLB_RESIZER_MAX_WIRE_LENGTH) {500}
set ::env(PL_RESIZER_MAX_WIRE_LENGTH) {500}

set ::env(QUIT_ON_TIMING_VIOLATIONS) "0"
set ::env(QUIT_ON_MAGIC_DRC) "1"
set ::env(QUIT_ON_LVS_ERROR) "1"
set ::env(QUIT_ON_SLEW_VIOLATIONS) "0"

#Need to cross-check why global timing opimization creating setup vio with hugh hold fix
set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) "0"

#PDN
set ::env(FP_PDN_VPITCH) 100
set ::env(FP_PDN_HPITCH) 100
set ::env(FP_PDN_VWIDTH) 6.2
set ::env(FP_PDN_HWIDTH) 6.2
