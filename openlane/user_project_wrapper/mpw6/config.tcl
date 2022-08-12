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

set ::env(PDK) "sky130A"
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"

# YOU ARE NOT ALLOWED TO CHANGE ANY VARIABLES DEFINED IN THE FIXED WRAPPER CFGS 
source $::env(CARAVEL_ROOT)/openlane/user_project_wrapper/fixed_wrapper_cfgs.tcl


# YOU CAN CHANGE ANY VARIABLES DEFINED IN THE DEFAULT WRAPPER CFGS BY OVERRIDING THEM IN THIS CONFIG.TCL
source $::env(CARAVEL_ROOT)/openlane/user_project_wrapper/default_wrapper_cfgs.tcl


set script_dir [file dirname [file normalize [info script]]]
set proj_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) user_project_wrapper
set verilog_root $::env(DESIGN_DIR)/../../verilog/
set lef_root $::env(DESIGN_DIR)/../../lef/
set gds_root $::env(DESIGN_DIR)/../../gds/
#section end

# User Configurations
#
set ::env(DESIGN_IS_CORE) 1
set ::env(FP_PDN_CORE_RING) 1


## Source Verilog Files
set ::env(VERILOG_FILES) "\
	$::env(DESIGN_DIR)/../../verilog/rtl//yifive/ycr1c/src/top/ycr_top_wb.sv \
	$::env(DESIGN_DIR)/../../verilog/rtl/user_project_wrapper.v"


## Clock configurations
set ::env(CLOCK_PORT) "user_clock2 wb_clk_i"
#set ::env(CLOCK_NET) "mprj.clk"

set ::env(CLOCK_PERIOD) "10"

## Internal Macros
### Macro Placement
set ::env(FP_SIZING) "absolute"
set ::env(MACRO_PLACEMENT_CFG) $::env(DESIGN_DIR)/macro.cfg

set ::env(PDN_CFG) $proj_dir/pdn_cfg.tcl

set ::env(SDC_FILE) $::env(DESIGN_DIR)/base.sdc
set ::env(BASE_SDC_FILE) $::env(DESIGN_DIR)/base.sdc

set ::env(SYNTH_READ_BLACKBOX_LIB) 1

### Black-box verilog and views
set ::env(VERILOG_FILES_BLACKBOX) "\
        $::env(DESIGN_DIR)/../../verilog/gl/qspim_top.v \
        $::env(DESIGN_DIR)/../../verilog/gl/wb_interconnect.v \
        $::env(DESIGN_DIR)/../../verilog/gl/pinmux.v     \
        $::env(DESIGN_DIR)/../../verilog/gl/uart_i2c_usb_spi_top.v     \
	$::env(DESIGN_DIR)/../../verilog/gl/wb_host.v \
	$::env(DESIGN_DIR)/../../verilog/gl/ycr_intf.v \
	$::env(DESIGN_DIR)/../../verilog/gl/ycr_core_top.v \
	$::env(DESIGN_DIR)/../../verilog/gl/ycr_iconnect.v \
	$::env(DESIGN_DIR)/../../verilog/gl/digital_pll.v \
	$::env(DESIGN_DIR)/../../verilog/rtl/sar_adc_10b/sar_adc_10b.v \
	$::env(PDK_ROOT)/sky130A/libs.ref/sky130_sram_macros/verilog/sky130_sram_2kbyte_1rw1r_32x512_8.v \
	"

set ::env(EXTRA_LEFS) "\
	$lef_root/qspim_top.lef \
	$lef_root/pinmux.lef \
	$lef_root/wb_interconnect.lef \
	$lef_root/uart_i2c_usb_spi_top.lef \
	$lef_root/wb_host.lef \
	$lef_root/ycr_intf.lef \
	$lef_root/ycr_core_top.lef \
	$lef_root/ycr_iconnect.lef \
	$lef_root/digital_pll.lef \
	$lef_root/sar_adc_10b.lef \
	$::env(PDK_ROOT)/sky130A/libs.ref/sky130_sram_macros/lef/sky130_sram_2kbyte_1rw1r_32x512_8.lef \
	"

set ::env(EXTRA_GDS_FILES) "\
	$gds_root/qspim_top.gds \
	$gds_root/pinmux.gds \
	$gds_root/wb_interconnect.gds \
	$gds_root/uart_i2c_usb_spi_top.gds \
	$gds_root/wb_host.gds \
	$gds_root/ycr_intf.gds \
	$gds_root/ycr_core_top.gds \
	$gds_root/ycr_iconnect.gds \
	$gds_root/digital_pll.gds \
	$gds_root/sar_adc_10b.gds \
	$::env(PDK_ROOT)/sky130A/libs.ref/sky130_sram_macros/gds/sky130_sram_2kbyte_1rw1r_32x512_8.gds \
	"

set ::env(SYNTH_DEFINES) [list SYNTHESIS ]

set ::env(VERILOG_INCLUDE_DIRS) [glob $::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/includes ]

#set ::env(GLB_RT_MAXLAYER) 6
set ::env(RT_MAX_LAYER) {met5}

set ::env(FP_PDN_CHECK_NODES) 0


## Internal Macros
### Macro PDN Connections
set ::env(FP_PDN_ENABLE_MACROS_GRID) "1"
set ::env(FP_PDN_ENABLE_GLOBAL_CONNECTIONS) "1"

set ::env(VDD_NETS) {vccd1 vccd2 vdda1 vdda2}
set ::env(GND_NETS) {vssd1 vssd2 vssa1 vssa2}
#
set ::env(VDD_PIN) {vccd1 vccd2 vdda1 vdda2}
set ::env(GND_PIN) {vssd1 vssd2 vssa1 vssa2}

set ::env(GLB_RT_OBS) "                              \
	                li1   150 130  833.1  546.54,\
	                met1  150 130  833.1  546.54,\
	                met2  150 130  833.1  546.54,\
                        met3  150 130  833.1  546.54,\
	                li1   950 130  1633.1 546.54,\
	                met1  950 130  1633.1 546.54,\
	                met2  950 130  1633.1 546.54,\
                        met3  950 130  1633.1 546.54,\
                        li1   150  750 833.1  1166.54,\
                        met1  150  750 833.1  1166.54,\
                        met2  150  750 833.1  1166.54,\
                        met3  150  750 833.1  1166.54,\
                        met1  2250 2150 2800  2600,\
                        met2  2250 2150 2800  2600,\
                        met3  2250 2150 2800  2600,\
			met1  950  650  1760  1290,\
			met2  950  650  1760  1290,\
			met3  950  650  1760  1290,\

	                met5  0 0 2920 3520"


set ::env(FP_PDN_MACRO_HOOKS) " \
	u_intercon vccd1 vssd1,\
	u_pinmux vccd1 vssd1,\
	u_qspi_master vccd1 vssd1,\
	u_riscv_top vccd1 vssd1,\
	u_tsram0_2kb vccd1 vssd1,\
	u_icache_2kb vccd1 vssd1,\
	u_dcache_2kb vccd1 vssd1,\
	u_sram0_2kb vccd1 vssd1,\
	u_sram1_2kb vccd1 vssd1,\
	u_sram2_2kb vccd1 vssd1,\
	u_sram3_2kb vccd1 vssd1,\
	u_uart_i2c_usb_spi vccd1 vssd1,\
	u_wb_host vccd1 vssd1,\
	u_riscv_top.i_core_top_0 vccd1 vssd1, \
	u_riscv_top.u_intf vccd1 vssd1 \
       	"


# The following is because there are no std cells in the example wrapper project.
set ::env(CELL_PAD) "4"
set ::env(SYNTH_TOP_LEVEL) 0
set ::env(PL_RANDOM_GLB_PLACEMENT) 1
set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_BUFFER_INPUT_PORTS) 0
set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) 0
set ::env(FP_PDN_ENABLE_RAILS) 0
set ::env(DIODE_INSERTION_STRATEGY) 0
set ::env(FILL_INSERTION) 0
set ::env(TAP_DECAP_INSERTION) 0
set ::env(CLOCK_TREE_SYNTH) 0
set ::env(QUIT_ON_LVS_ERROR) "1"
set ::env(QUIT_ON_MAGIC_DRC) "0"
set ::env(QUIT_ON_NEGATIVE_WNS) "0"
set ::env(QUIT_ON_SLEW_VIOLATIONS) "0"
set ::env(QUIT_ON_TIMING_VIOLATIONS) "0"
set ::env(FP_PDN_IRDROP) "0"
set ::env(FP_PDN_HORIZONTAL_HALO) "10"
set ::env(FP_PDN_VERTICAL_HALO) "10"
set ::env(FP_PDN_VOFFSET) "5"
set ::env(FP_PDN_VPITCH) "80"
set ::env(FP_PDN_VSPACING) "15.5"
set ::env(FP_PDN_VWIDTH) "3.1"
set ::env(FP_PDN_HOFFSET) "10"
set ::env(FP_PDN_HPITCH) "90"
set ::env(FP_PDN_HSPACING) "10"
set ::env(FP_PDN_HWIDTH) "3.1"
