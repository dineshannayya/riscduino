# Global
# ------

set script_dir [file dirname [file normalize [info script]]]
# Name

set ::env(DESIGN_NAME) wb_host

set ::env(DESIGN_IS_CORE) "0"
set ::env(FP_PDN_CORE_RING) "0"

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


# If you're going to use multiple power domains, then keep this disabled.
set ::env(RUN_CVC) 0

#set ::env(PDN_CFG) $script_dir/pdn.tcl


set ::env(PL_ROUTABILITY_DRIVEN) 1

set ::env(FP_IO_VEXTEND) 4
set ::env(FP_IO_HEXTEND) 4


set ::env(GLB_RT_MAXLAYER) 4
set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 10

set ::env(DIODE_INSERTION_STRATEGY) 5

