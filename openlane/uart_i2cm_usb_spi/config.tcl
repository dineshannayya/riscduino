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
set ::env(DESIGN_NAME) uart_i2c_usb_spi_top


set ::env(DESIGN_IS_CORE) "0"
set ::env(FP_PDN_CORE_RING) "0"

# Timing configuration
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "app_clk usb_clk u_uart_core.u_lineclk_buf.u_mux/X"

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
    $script_dir/../../verilog/rtl/uart/src/uart_core.sv  \
    $script_dir/../../verilog/rtl/uart/src/uart_cfg.sv   \
    $script_dir/../../verilog/rtl/uart/src/uart_rxfsm.sv \
    $script_dir/../../verilog/rtl/uart/src/uart_txfsm.sv \
    $script_dir/../../verilog/rtl/lib/async_wb.sv   \
    $script_dir/../../verilog/rtl/lib/async_fifo.sv      \
    $script_dir/../../verilog/rtl/lib/async_fifo_th.sv   \
    $script_dir/../../verilog/rtl/lib/reset_sync.sv      \
    $script_dir/../../verilog/rtl/lib/double_sync_low.v  \
    $script_dir/../../verilog/rtl/lib/clk_ctl.v          \
    $script_dir/../../verilog/rtl/lib/registers.v        \
    $script_dir/../../verilog/rtl/i2cm/src/core/i2cm_bit_ctrl.v      \
    $script_dir/../../verilog/rtl/i2cm/src/core/i2cm_byte_ctrl.v     \
    $script_dir/../../verilog/rtl/i2cm/src/core/i2cm_top.v           \
    $script_dir/../../verilog/rtl/usb1_host/src/core/usbh_core.sv    \
    $script_dir/../../verilog/rtl/usb1_host/src/core/usbh_crc16.sv   \
    $script_dir/../../verilog/rtl/usb1_host/src/core/usbh_crc5.sv    \
    $script_dir/../../verilog/rtl/usb1_host/src/core/usbh_fifo.sv    \  
    $script_dir/../../verilog/rtl/usb1_host/src/core/usbh_sie.sv     \
    $script_dir/../../verilog/rtl/usb1_host/src/phy/usb_fs_phy.v     \
    $script_dir/../../verilog/rtl/usb1_host/src/phy/usb_transceiver.v\
    $script_dir/../../verilog/rtl/usb1_host/src/top/usb1_host.sv     \
    $script_dir/../../verilog/rtl/sspim/src/sspim_top.sv             \
    $script_dir/../../verilog/rtl/sspim/src/sspim_ctl.sv             \
    $script_dir/../../verilog/rtl/sspim/src/sspim_if.sv              \
    $script_dir/../../verilog/rtl/sspim/src/sspim_cfg.sv             \
    $script_dir/../../verilog/rtl/uart_i2c_usb_spi/src/uart_i2c_usb_spi.sv\
    $script_dir/../../verilog/rtl/lib/ctech_cells.sv     \
    "

set ::env(SYNTH_READ_BLACKBOX_LIB) 1
set ::env(VERILOG_INCLUDE_DIRS) [glob $script_dir/../../verilog/rtl/i2cm/src/includes $script_dir/../../verilog/rtl/usb1_host/src/includes ]
set ::env(SYNTH_DEFINES) [list SYNTHESIS ]

set ::env(SDC_FILE) "$script_dir/base.sdc"
set ::env(BASE_SDC_FILE) "$script_dir/base.sdc"

set ::env(LEC_ENABLE) 0

set ::env(VDD_PIN) [list {vccd1}]
set ::env(GND_PIN) [list {vssd1}]


# Floorplanning
# -------------

set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg
set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) [list 0.0 0.0 500.0 700.0]



# If you're going to use multiple power domains, then keep this disabled.
set ::env(RUN_CVC) 0

#set ::env(PDN_CFG) $script_dir/pdn.tcl


set ::env(PL_TIME_DRIVEN) 1
set ::env(PL_TARGET_DENSITY) "0.45"

# helps in anteena fix
set ::env(USE_ARC_ANTENNA_CHECK) "0"

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
