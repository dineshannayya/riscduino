# Global
# ------

set script_dir [file dirname [file normalize [info script]]]
# Name
set ::env(DESIGN_NAME) sdrc_top



# Timing configuration
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "wb_clk_i sdram_clk"


# Sources
# -------

# Local sources + no2usb sources
set ::env(VERILOG_FILES) "\
         $script_dir/../../verilog/rtl/sdram_ctrl/src/top/sdrc_top.v \
         $script_dir/../../verilog/rtl/sdram_ctrl/src/wb2sdrc/wb2sdrc.v \
         $script_dir/../../verilog/rtl/lib/async_fifo.sv  \
         $script_dir/../../verilog/rtl/sdram_ctrl/src/core/sdrc_core.v \
         $script_dir/../../verilog/rtl/sdram_ctrl/src/core/sdrc_bank_ctl.v \
         $script_dir/../../verilog/rtl/sdram_ctrl/src/core/sdrc_bank_fsm.v \
         $script_dir/../../verilog/rtl/sdram_ctrl/src/core/sdrc_bs_convert.v\ 
         $script_dir/../../verilog/rtl/sdram_ctrl/src/core/sdrc_req_gen.v \
         $script_dir/../../verilog/rtl/sdram_ctrl/src/core/sdrc_xfr_ctl.v "

set ::env(VERILOG_INCLUDE_DIRS) [glob $script_dir/../../verilog/rtl/sdram_ctrl/src/defs ]

set ::env(SDC_FILE) "$script_dir/base.sdc"
set ::env(BASE_SDC_FILE) "$script_dir/base.sdc"

set ::env(LEC_ENABLE) 0

set ::env(VDD_PIN) [list {vccd1}]
set ::env(GND_PIN) [list {vssd1}]


# Floorplanning
# -------------

set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg
set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) [list 0.0 0.0 700.0 500.0]




set ::env(FP_PDN_VPITCH) 50
#set ::env(PDN_CFG) $script_dir/pdn.tcl

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


