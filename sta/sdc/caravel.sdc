set ::env(IO_PCT) "0.2"
set ::env(SYNTH_MAX_FANOUT) "5"
set ::env(SYNTH_CAP_LOAD) "1"
set ::env(SYNTH_TIMING_DERATE) 0.01
set ::env(SYNTH_CLOCK_SETUP_UNCERTAINITY) 0.25
set ::env(SYNTH_CLOCK_HOLD_UNCERTAINITY) 0.25
set ::env(SYNTH_CLOCK_TRANSITION) 0.15

## MASTER CLOCKS
create_clock [get_ports {"clock"} ] -name "clock"  -period 25
create_clock [get_pins clocking/user_clk ] -name "user_clk2"  -period 25
#create_clock [get_pins  housekeeping/_8847_/X ] -name "csclk"  -period 25
#create_clock [get_pins  clocking/pll_clk ] -name "pll_clk"  -period 25
#create_clock [get_pins  clocking/pll_clk90 ] -name "pll_clk90"  -period 25

create_generated_clock -name wb_clk -add -source [get_ports {clock}] -master_clock [get_clocks clock] -divide_by 1 -comment {Wishbone User Clock} [get_pins mprj/wb_clk_i]
create_clock -name int_pll_clock -period 5.0000  [get_pins {mprj/u_wb_host/u_clkbuf_pll.u_buf/X}]

create_clock -name wbs_ref_clk -period 5.0000   [get_pins {mprj/u_wb_host/u_wbs_ref_clkbuf.u_buf/X}]
create_clock -name wbs_clk_i   -period 10.0000  [get_pins {mprj/u_wb_host/wbs_clk_out}]

create_clock -name cpu_ref_clk -period 5.0000   [get_pins {mprj/u_wb_host/u_cpu_ref_clkbuf.u_buf/X}]
create_clock -name cpu_clk     -period 10.0000  [get_pins {mprj/u_wb_host/cpu_clk}]

create_clock -name rtc_clk     -period 50.0000  [get_pins {mprj/u_wb_host/rtc_clk}]

create_clock -name pll_ref_clk -period 20.0000  [get_pins {mprj/u_wb_host/pll_ref_clk}]
create_clock -name pll_clk_0   -period 5.0000   [get_pins {mprj/u_pll/ringosc.ibufp01/Y}]

create_clock -name usb_ref_clk -period 5.0000   [get_pins {mprj/u_wb_host/u_usb_ref_clkbuf.u_buf/X}]
create_clock -name usb_clk     -period 20.0000  [get_pins {mprj/u_wb_host/usb_clk}]
create_clock -name uarts0_clk  -period 100.0000 [get_pins {mprj/u_uart_i2c_usb_spi/u_uart0_core.u_lineclk_buf.genblk1.u_mux/X}]
create_clock -name uarts1_clk  -period 100.0000 [get_pins {mprj/u_uart_i2c_usb_spi/u_uart1_core.u_lineclk_buf.genblk1.u_mux/X}]
create_clock -name uartm_clk   -period 100.0000 [get_pins {mprj/u_wb_host/u_uart2wb.u_core.u_uart_clk.genblk1.u_mux/X}]


## Case analysis

set_case_analysis 0 [get_pins {mprj/u_intercon/cfg_cska_wi[0]}]
set_case_analysis 0 [get_pins {mprj/u_intercon/cfg_cska_wi[1]}]
set_case_analysis 0 [get_pins {mprj/u_intercon/cfg_cska_wi[2]}]
set_case_analysis 1 [get_pins {mprj/u_intercon/cfg_cska_wi[3]}]

set_case_analysis 0 [get_pins {mprj/u_pinmux/cfg_cska_pinmux[0]}]
set_case_analysis 0 [get_pins {mprj/u_pinmux/cfg_cska_pinmux[1]}]
set_case_analysis 0 [get_pins {mprj/u_pinmux/cfg_cska_pinmux[2]}]
set_case_analysis 1 [get_pins {mprj/u_pinmux/cfg_cska_pinmux[3]}]

set_case_analysis 0 [get_pins {mprj/u_qspi_master/cfg_cska_sp_co[0]}]
set_case_analysis 0 [get_pins {mprj/u_qspi_master/cfg_cska_sp_co[1]}]
set_case_analysis 0 [get_pins {mprj/u_qspi_master/cfg_cska_sp_co[2]}]
set_case_analysis 0 [get_pins {mprj/u_qspi_master/cfg_cska_sp_co[3]}]

set_case_analysis 1 [get_pins {mprj/u_qspi_master/cfg_cska_spi[0]}]
set_case_analysis 0 [get_pins {mprj/u_qspi_master/cfg_cska_spi[1]}]
set_case_analysis 0 [get_pins {mprj/u_qspi_master/cfg_cska_spi[2]}]
set_case_analysis 1 [get_pins {mprj/u_qspi_master/cfg_cska_spi[3]}]

set_case_analysis 0 [get_pins {mprj/u_riscv_top.u_intf/cfg_cska_riscv[0]}]
set_case_analysis 0 [get_pins {mprj/u_riscv_top.u_intf/cfg_cska_riscv[1]}]
set_case_analysis 0 [get_pins {mprj/u_riscv_top.u_intf/cfg_cska_riscv[2]}]
set_case_analysis 1 [get_pins {mprj/u_riscv_top.u_intf/cfg_cska_riscv[3]}]

set_case_analysis 1 [get_pins {mprj/u_wb_host/cfg_cska_wh[0]}]
set_case_analysis 0 [get_pins {mprj/u_wb_host/cfg_cska_wh[1]}]
set_case_analysis 0 [get_pins {mprj/u_wb_host/cfg_cska_wh[2]}]
set_case_analysis 1 [get_pins {mprj/u_wb_host/cfg_cska_wh[3]}]

set_case_analysis 1 [get_pins {mprj/u_uart_i2c_usb_spi/cfg_cska_uart[0]}]
set_case_analysis 1 [get_pins {mprj/u_uart_i2c_usb_spi/cfg_cska_uart[1]}]
set_case_analysis 1 [get_pins {mprj/u_uart_i2c_usb_spi/cfg_cska_uart[2]}]
set_case_analysis 0 [get_pins {mprj/u_uart_i2c_usb_spi/cfg_cska_uart[3]}]


#Keept the SRAM clock driving edge at pos edge
set_case_analysis 0 [get_pins {mprj/u_riscv_top.u_intf/cfg_sram_lphase[0]}]
set_case_analysis 0 [get_pins {mprj/u_riscv_top.u_intf/cfg_sram_lphase[1]}]

set_case_analysis 0 [get_pins {mprj/u_riscv_top.u_connect/cfg_sram_lphase[0]}]
set_case_analysis 0 [get_pins {mprj/u_riscv_top.u_connect/cfg_sram_lphase[1]}]

#disable clock gating check at static clock select pins
set_false_path -through [get_pins mprj/u_wb_host/u_wbs_clk_sel.genblk1.u_mux/S]

set_propagated_clock [all_clocks]

set_clock_groups -name async_clock -asynchronous \
 -group [get_clocks {clock wb_clk }]\
 -group [get_clocks {user_clk2}]\
 -group [get_clocks {int_pll_clock}]\
 -group [get_clocks {wbs_clk_i}]\
 -group [get_clocks {wbs_ref_clk}]\
 -group [get_clocks {cpu_clk}]\
 -group [get_clocks {cpu_ref_clk}]\
 -group [get_clocks {rtc_clk}]\
 -group [get_clocks {usb_ref_clk}]\
 -group [get_clocks {pll_ref_clk}]\
 -group [get_clocks {pll_clk_0}]\
 -group [get_clocks {usb_clk}]\
 -group [get_clocks {uarts0_clk}]\
 -group [get_clocks {uarts1_clk}]\
 -group [get_clocks {uartm_clk}]\
 -comment {Async Clock group}

## INPUT/OUTPUT DELAYS
set input_delay_value 1
set output_delay_value [expr 25 * $::env(IO_PCT)]
puts "\[INFO\]: Setting output delay to: $output_delay_value"
puts "\[INFO\]: Setting input delay to: $input_delay_value"

set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {gpio}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[0]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[1]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[2]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[3]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[4]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[5]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[6]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[7]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[8]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[9]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[10]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[11]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[12]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[13]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[14]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[15]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[16]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[17]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[18]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[19]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[20]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[21]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[22]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[23]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[24]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[25]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[26]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[27]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[28]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[29]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[30]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[31]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[32]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[33]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[34]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[35]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[36]}]
set_input_delay $input_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {mprj_io[37]}]

set_output_delay $output_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {flash_csb}]
set_output_delay $output_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {flash_clk}]
set_output_delay $output_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {flash_io0}]
set_output_delay $output_delay_value  -clock [get_clocks {clock}] -add_delay [get_ports {flash_io1}]

set_max_fanout $::env(SYNTH_MAX_FANOUT) [current_design]

## Set system monitoring mux select to zero so that the clock/user_clk monitoring is disabled 
set_case_analysis 0 [get_pins housekeeping/_4449_/S]
set_case_analysis 0 [get_pins housekeeping/_4450_/S]

## FALSE PATHS (ASYNCHRONOUS INPUTS)
set_false_path -from [get_ports {resetb}]
set_false_path -from [get_ports mprj_io[*]]
set_false_path -from [get_ports gpio]


# TODO set this as parameter
set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]

puts "\[INFO\]: Setting timing derate to: [expr {$::env(SYNTH_TIMING_DERATE) * 10}] %"
set_timing_derate -early [expr {1-$::env(SYNTH_TIMING_DERATE)}]
set_timing_derate -late [expr {1+$::env(SYNTH_TIMING_DERATE)}]

puts "\[INFO\]: Setting clock setup uncertainity to: $::env(SYNTH_CLOCK_SETUP_UNCERTAINITY)"
puts "\[INFO\]: Setting clock hold uncertainity to: $::env(SYNTH_CLOCK_HOLD_UNCERTAINITY)"
set_clock_uncertainty -setup $::env(SYNTH_CLOCK_SETUP_UNCERTAINITY) [all_clocks]
set_clock_uncertainty -hold $::env(SYNTH_CLOCK_HOLD_UNCERTAINITY) [all_clocks]


#set_output_delay -max 5.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_adr_i[*]}]
#set_output_delay -max 5.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_cyc_i}]
#set_output_delay -max 5.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_i[*]}]
#set_output_delay -max 5.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_sel_i[*]}]
#set_output_delay -max 5.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_stb_i}]
#set_output_delay -max 5.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_we_i}]
#
#set_output_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_adr_i[*]}]
#set_output_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_cyc_i}]
#set_output_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_i[*]}]
#set_output_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_sel_i[*]}]
#set_output_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_stb_i}]
#set_output_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_we_i}]
#
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_ack_o}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[0]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[10]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[11]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[12]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[13]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[14]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[15]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[16]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[17]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[18]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[19]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[1]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[20]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[21]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[22]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[23]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[24]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[25]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[26]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[27]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[28]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[29]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[2]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[30]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[31]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[3]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[4]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[5]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[6]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[7]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[8]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[9]}]
#
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_ack_o}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[0]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[10]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[11]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[12]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[13]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[14]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[15]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[16]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[17]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[18]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[19]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[1]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[20]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[21]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[22]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[23]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[24]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[25]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[26]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[27]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[28]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[29]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[2]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[30]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[31]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[3]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[4]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[5]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[6]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[7]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[8]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[9]}]



puts "\[INFO\]: Setting clock transition to: $::env(SYNTH_CLOCK_TRANSITION)"
set_clock_transition $::env(SYNTH_CLOCK_TRANSITION) [get_clocks {clock}]
