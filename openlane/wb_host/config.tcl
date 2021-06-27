# Global
# ------

set script_dir [file dirname [file normalize [info script]]]
# Name

set ::env(DESIGN_NAME) wb_host

# Timing configuration
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "wbm_clk_i wbs_clk_i"

set ::env(SYNTH_MAX_FANOUT) 4

# Sources
# -------

# Local sources + no2usb sources
set ::env(VERILOG_FILES) "\
     $script_dir/../../verilog/rtl/wb_host/src/wb_host.sv \
     $script_dir/../../verilog/rtl/lib/async_fifo.sv \
     $script_dir/../../verilog/rtl/lib/async_wb.sv \
     $script_dir/../../verilog/rtl/lib/registers.v"

#set ::env(SDC_FILE) "$script_dir/base.sdc"
#set ::env(BASE_SDC_FILE) "$script_dir/base.sdc"

set ::env(LEC_ENABLE) 0

set ::env(VDD_PIN) [list {vccd1}]
set ::env(GND_PIN) [list {vssd1}]


# Floorplanning
# -------------

set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 1000 200"



set ::env(FP_PDN_VPITCH) 50
#set ::env(PDN_CFG) $script_dir/pdn.tcl

#set ::env(FP_VERTICAL_HALO) 6
set ::env(PL_TARGET_DENSITY) 0.62
set ::env(PL_TARGET_DENSITY_CELLS) 0.5
set ::env(PL_OPENPHYSYN_OPTIMIZATIONS) 1
#set ::env(CELL_PAD) 4

set ::env(GLB_RT_TILES) 14
set ::env(GLB_RT_MAXLAYER) 5

set ::env(DIODE_INSERTION_STRATEGY) 4


