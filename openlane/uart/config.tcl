# Global
# ------

set script_dir [file dirname [file normalize [info script]]]
# Name
set ::env(DESIGN_NAME) uart_core



# Timing configuration
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "app_clk"


# Sources
# -------

# Local sources + no2usb sources
set ::env(VERILOG_FILES) "\
    $script_dir/../../verilog/rtl/uart/src/uart_core.sv  \
    $script_dir/../../verilog/rtl/uart/src/uart_cfg.sv   \
    $script_dir/../../verilog/rtl/uart/src/uart_rxfsm.sv \
    $script_dir/../../verilog/rtl/uart/src/uart_txfsm.sv \
    $script_dir/../../verilog/rtl/lib/async_fifo_th.sv   \
    $script_dir/../../verilog/rtl/lib/reset_sync.sv      \
    "

#set ::env(VERILOG_INCLUDE_DIRS) [glob $script_dir/../../verilog/rtl/sdram_ctrl/src/defs ]

set ::env(SDC_FILE) "$script_dir/base.sdc"
set ::env(BASE_SDC_FILE) "$script_dir/base.sdc"


# Floorplanning
# -------------

set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg
set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) [list 0.0 0.0 100.0 100.0]




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


