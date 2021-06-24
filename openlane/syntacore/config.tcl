# Global
# ------

set script_dir [file dirname [file normalize [info script]]]
# Name
set ::env(DESIGN_NAME) scr1_top_wb

set ::env(SYNTH_READ_BLACKBOX_LIB) 1

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
	$script_dir/../../verilog/rtl/lib/async_fifo.sv "

set ::env(VERILOG_INCLUDE_DIRS) [glob $script_dir/../../verilog/rtl/syntacore/scr1/src/includes ]

set ::env(SDC_FILE) "$script_dir/base.sdc"
set ::env(BASE_SDC_FILE) "$script_dir/base.sdc"
#set ::env(SYNTH_DEFINES) [list SCR1_DBG_EN ]

set ::env(LEC_ENABLE) 0

# --------
# Floorplanning
# -------------

#set ::env(FP_DEF_TEMPLATE) $script_dir/floorplan.def
set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) [list 0.0 0.0 1500.0 1200.0]



set ::env(FP_PDN_VPITCH) 50
set ::env(PDN_CFG) $script_dir/pdn.tcl

set ::env(FP_VERTICAL_HALO) 6
set ::env(PL_TARGET_DENSITY) 0.52
set ::env(PL_TARGET_DENSITY_CELLS) 0.38
set ::env(PL_OPENPHYSYN_OPTIMIZATIONS) 1
set ::env(CELL_PAD) 4

set ::env(GLB_RT_ADJUSTMENT) 0
set ::env(GLB_RT_L2_ADJUSTMENT) 0.2
set ::env(GLB_RT_L3_ADJUSTMENT) 0.25
set ::env(GLB_RT_L4_ADJUSTMENT) 0.2
set ::env(GLB_RT_L5_ADJUSTMENT) 0.1
set ::env(GLB_RT_L6_ADJUSTMENT) 0.1
set ::env(GLB_RT_TILES) 14
set ::env(GLB_RT_MAXLAYER) 5

set ::env(DIODE_INSERTION_STRATEGY) 4


