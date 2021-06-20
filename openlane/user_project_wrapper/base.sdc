set_units -time ns
set ::env(WB_CLOCK_PERIOD) "10"
set ::env(WB_CLOCK_PORT)   "wb_clk_i"

set ::env(SDRAM_CLOCK_PERIOD) "20"
set ::env(SDRAM_CLOCK_PORT)   "digital_core.u_glbl_cfg.sdram_clk"

set ::env(PAD_SDRAM_CLOCK_PERIOD) "20"
set ::env(PAD_SDRAM_CLOCK_PORT)   "digital_core.u_sdram_ctrl.sdram_pad_clk"

set ::env(CPU_CLOCK_PERIOD) "50"
set ::env(CPU_CLOCK_PORT)   "digital_core.u_glbl_cfg.cpu_clk"

set ::env(RTC_CLOCK_PERIOD) "50"
set ::env(RTC_CLOCK_PORT)   "digital_core.u_glbl_cfg.rtc_clk"
######################################
# WB Clock domain input output
######################################
create_clock [get_ports $::env(WB_CLOCK_PORT)]  -name $::env(WB_CLOCK_PORT)  -period $::env(WB_CLOCK_PERIOD)
set wb_input_delay_value [expr $::env(WB_CLOCK_PERIOD) * 0.6]
set wb_output_delay_value [expr $::env(WB_CLOCK_PERIOD) * 0.6]
puts "\[INFO\]: Setting wb output delay to:$wb_output_delay_value"
puts "\[INFO\]: Setting wb input delay to: $wb_input_delay_value"


set_input_delay 2.0 -clock [get_clocks $::env(WB_CLOCK_PORT)] {wb_rst_i}

set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wbs_stb_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wbs_cyc_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wbs_we_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wbs_sel_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wbs_dat_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wbs_adr_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wb_cti_i*]

set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wbs_dat_o*]
set_output_delay 3.0                     -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wbs_ack_o*]

######################################
# SDRAM Clock domain input output
######################################
create_clock [get_pins (SDRAM_CLOCK_PORT)]  -name $::env(SDRAM_CLOCK_PORT)  -period $::env(SDRAM_CLOCK_PERIOD)
create_clock [get_pins (PAD_SDRAM_CLOCK_PORT)]  -name $::env(PAD_SDRAM_CLOCK_PORT)  -period $::env(PAD_SDRAM_CLOCK_PERIOD)
create_clock [get_pins (CPU_CLOCK_PORT)] -name $::env(CPU_CLOCK_PORT)  -period $::env(CPU_CLOCK_PERIOD)
create_clock [get_pins (RTC_CLOCK_PORT)] -name $::env(RTC_CLOCK_PORT)  -period $::env(RTC_CLOCK_PERIOD)

set_clock_groups -name async_clock -asynchronous -comment "Async Clock group" -group [get_clocks $::env(WB_CLOCK_PORT)] -group [get_clocks $::env(SDRAM_CLOCK_PORT)] -group [get_clocks $::env(CPU_CLOCK_PORT)] -group [get_clocks $::env(RTC_CLOCK_PORT)]



# TODO set this as parameter
set_driving_cell -lib_cell $::env(SYNTH_DRIVING_CELL) -pin $::env(SYNTH_DRIVING_CELL_PIN) [all_inputs]
set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]

