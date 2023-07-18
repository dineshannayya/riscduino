###############################################################################
# Created by write_sdc
# Sat Mar 11 15:47:07 2023
###############################################################################
current_design wb_host
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name wbm_clk_i -period 10.0000 [get_ports {wbm_clk_i}]
set_clock_transition 0.1500 [get_clocks {wbm_clk_i}]
set_clock_uncertainty -setup 0.5000 wbm_clk_i
set_clock_uncertainty -hold 0.2500 wbm_clk_i
set_propagated_clock [get_clocks {wbm_clk_i}]
create_clock -name wbs_clk_i -period 10.0000 [get_ports {wbs_clk_i}]
set_clock_transition 0.1500 [get_clocks {wbs_clk_i}]
set_clock_uncertainty -setup 0.5000 wbs_clk_i
set_clock_uncertainty -hold 0.2500 wbs_clk_i
set_propagated_clock [get_clocks {wbs_clk_i}]
create_clock -name uart_clk -period 100.0000 [get_pins {u_uart2wb.u_core.u_uart_clk.genblk1.u_mux/X}]
set_clock_transition 0.1500 [get_clocks {uart_clk}]
set_clock_uncertainty -setup 0.5000 uart_clk
set_clock_uncertainty -hold 0.2500 uart_clk
set_propagated_clock [get_clocks {uart_clk}]
create_clock -name int_pll_clock -period 10.0000 
set_clock_uncertainty -setup 0.5000 int_pll_clock
set_clock_uncertainty -hold 0.2500 int_pll_clock
create_clock -name wbs_ref_clk -period 10.0000 
set_clock_uncertainty -setup 0.5000 wbs_ref_clk
set_clock_uncertainty -hold 0.2500 wbs_ref_clk
create_clock -name cpu_ref_clk -period 10.0000 
set_clock_uncertainty -setup 0.5000 cpu_ref_clk
set_clock_uncertainty -hold 0.2500 cpu_ref_clk
create_clock -name usb_ref_clk -period 10.0000 
set_clock_uncertainty -setup 0.5000 usb_ref_clk
set_clock_uncertainty -hold 0.2500 usb_ref_clk
set_clock_groups -name async_clock -asynchronous \
 -group [get_clocks {cpu_ref_clk}]\
 -group [get_clocks {int_pll_clock}]\
 -group [get_clocks {uart_clk}]\
 -group [get_clocks {usb_ref_clk}]\
 -group [get_clocks {wbm_clk_i}]\
 -group [get_clocks {wbs_clk_i}]\
 -group [get_clocks {wbs_ref_clk}] -comment {Async Clock group}
set_input_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_rst_i}]
set_input_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_rst_i}]
set_input_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_stb_i}]
set_input_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_stb_i}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_ack_i}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_ack_i}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[0]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[0]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[10]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[10]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[11]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[11]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[12]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[12]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[13]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[13]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[14]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[14]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[15]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[15]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[16]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[16]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[17]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[17]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[18]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[18]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[19]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[19]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[1]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[1]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[20]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[20]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[21]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[21]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[22]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[22]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[23]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[23]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[24]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[24]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[25]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[25]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[26]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[26]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[27]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[27]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[28]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[28]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[29]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[29]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[2]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[2]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[30]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[30]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[31]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[31]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[3]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[3]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[4]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[4]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[5]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[5]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[6]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[6]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[7]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[7]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[8]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[8]}]
set_input_delay 2.0000 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_i[9]}]
set_input_delay 6.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_i[9]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_ack_o}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_ack_o}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[0]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[0]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[10]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[10]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[11]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[11]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[12]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[12]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[13]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[13]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[14]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[14]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[15]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[15]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[16]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[16]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[17]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[17]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[18]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[18]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[19]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[19]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[1]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[1]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[20]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[20]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[21]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[21]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[22]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[22]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[23]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[23]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[24]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[24]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[25]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[25]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[26]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[26]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[27]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[27]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[28]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[28]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[29]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[29]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[2]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[2]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[30]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[30]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[31]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[31]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[3]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[3]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[4]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[4]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[5]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[5]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[6]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[6]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[7]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[7]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[8]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[8]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_dat_o[9]}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_dat_o[9]}]
set_output_delay 1.0000 -clock [get_clocks {wbm_clk_i}] -min -add_delay [get_ports {wbm_err_o}]
set_output_delay 5.0000 -clock [get_clocks {wbm_clk_i}] -max -add_delay [get_ports {wbm_err_o}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[0]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[0]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[10]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[10]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[11]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[11]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[12]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[12]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[13]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[13]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[14]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[14]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[15]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[15]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[16]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[16]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[17]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[17]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[18]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[18]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[19]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[19]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[1]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[1]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[20]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[20]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[21]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[21]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[22]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[22]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[23]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[23]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[24]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[24]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[25]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[25]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[26]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[26]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[27]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[27]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[28]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[28]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[29]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[29]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[2]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[2]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[30]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[30]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[31]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[31]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[3]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[3]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[4]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[4]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[5]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[5]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[6]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[6]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[7]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[7]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[8]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[8]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_adr_o[9]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_adr_o[9]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_cyc_o}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_cyc_o}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[0]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[0]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[10]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[10]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[11]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[11]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[12]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[12]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[13]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[13]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[14]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[14]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[15]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[15]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[16]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[16]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[17]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[17]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[18]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[18]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[19]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[19]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[1]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[1]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[20]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[20]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[21]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[21]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[22]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[22]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[23]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[23]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[24]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[24]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[25]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[25]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[26]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[26]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[27]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[27]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[28]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[28]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[29]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[29]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[2]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[2]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[30]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[30]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[31]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[31]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[3]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[3]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[4]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[4]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[5]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[5]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[6]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[6]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[7]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[7]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[8]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[8]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_dat_o[9]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_dat_o[9]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_sel_o[0]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_sel_o[0]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_sel_o[1]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_sel_o[1]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_sel_o[2]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_sel_o[2]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_sel_o[3]}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_sel_o[3]}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_stb_o}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_stb_o}]
set_output_delay -1.7500 -clock [get_clocks {wbs_clk_i}] -min -add_delay [get_ports {wbs_we_o}]
set_output_delay 3.0000 -clock [get_clocks {wbs_clk_i}] -max -add_delay [get_ports {wbs_we_o}]
set_multicycle_path -hold\
    -from [list [get_ports {wbm_adr_i[0]}]\
           [get_ports {wbm_adr_i[10]}]\
           [get_ports {wbm_adr_i[11]}]\
           [get_ports {wbm_adr_i[12]}]\
           [get_ports {wbm_adr_i[13]}]\
           [get_ports {wbm_adr_i[14]}]\
           [get_ports {wbm_adr_i[15]}]\
           [get_ports {wbm_adr_i[16]}]\
           [get_ports {wbm_adr_i[17]}]\
           [get_ports {wbm_adr_i[18]}]\
           [get_ports {wbm_adr_i[19]}]\
           [get_ports {wbm_adr_i[1]}]\
           [get_ports {wbm_adr_i[20]}]\
           [get_ports {wbm_adr_i[21]}]\
           [get_ports {wbm_adr_i[22]}]\
           [get_ports {wbm_adr_i[23]}]\
           [get_ports {wbm_adr_i[24]}]\
           [get_ports {wbm_adr_i[25]}]\
           [get_ports {wbm_adr_i[26]}]\
           [get_ports {wbm_adr_i[27]}]\
           [get_ports {wbm_adr_i[28]}]\
           [get_ports {wbm_adr_i[29]}]\
           [get_ports {wbm_adr_i[2]}]\
           [get_ports {wbm_adr_i[30]}]\
           [get_ports {wbm_adr_i[31]}]\
           [get_ports {wbm_adr_i[3]}]\
           [get_ports {wbm_adr_i[4]}]\
           [get_ports {wbm_adr_i[5]}]\
           [get_ports {wbm_adr_i[6]}]\
           [get_ports {wbm_adr_i[7]}]\
           [get_ports {wbm_adr_i[8]}]\
           [get_ports {wbm_adr_i[9]}]\
           [get_ports {wbm_cyc_i}]\
           [get_ports {wbm_dat_i[0]}]\
           [get_ports {wbm_dat_i[10]}]\
           [get_ports {wbm_dat_i[11]}]\
           [get_ports {wbm_dat_i[12]}]\
           [get_ports {wbm_dat_i[13]}]\
           [get_ports {wbm_dat_i[14]}]\
           [get_ports {wbm_dat_i[15]}]\
           [get_ports {wbm_dat_i[16]}]\
           [get_ports {wbm_dat_i[17]}]\
           [get_ports {wbm_dat_i[18]}]\
           [get_ports {wbm_dat_i[19]}]\
           [get_ports {wbm_dat_i[1]}]\
           [get_ports {wbm_dat_i[20]}]\
           [get_ports {wbm_dat_i[21]}]\
           [get_ports {wbm_dat_i[22]}]\
           [get_ports {wbm_dat_i[23]}]\
           [get_ports {wbm_dat_i[24]}]\
           [get_ports {wbm_dat_i[25]}]\
           [get_ports {wbm_dat_i[26]}]\
           [get_ports {wbm_dat_i[27]}]\
           [get_ports {wbm_dat_i[28]}]\
           [get_ports {wbm_dat_i[29]}]\
           [get_ports {wbm_dat_i[2]}]\
           [get_ports {wbm_dat_i[30]}]\
           [get_ports {wbm_dat_i[31]}]\
           [get_ports {wbm_dat_i[3]}]\
           [get_ports {wbm_dat_i[4]}]\
           [get_ports {wbm_dat_i[5]}]\
           [get_ports {wbm_dat_i[6]}]\
           [get_ports {wbm_dat_i[7]}]\
           [get_ports {wbm_dat_i[8]}]\
           [get_ports {wbm_dat_i[9]}]\
           [get_ports {wbm_sel_i[0]}]\
           [get_ports {wbm_sel_i[1]}]\
           [get_ports {wbm_sel_i[2]}]\
           [get_ports {wbm_sel_i[3]}]\
           [get_ports {wbm_we_i}]] 2
set_multicycle_path -setup\
    -from [list [get_ports {wbm_adr_i[0]}]\
           [get_ports {wbm_adr_i[10]}]\
           [get_ports {wbm_adr_i[11]}]\
           [get_ports {wbm_adr_i[12]}]\
           [get_ports {wbm_adr_i[13]}]\
           [get_ports {wbm_adr_i[14]}]\
           [get_ports {wbm_adr_i[15]}]\
           [get_ports {wbm_adr_i[16]}]\
           [get_ports {wbm_adr_i[17]}]\
           [get_ports {wbm_adr_i[18]}]\
           [get_ports {wbm_adr_i[19]}]\
           [get_ports {wbm_adr_i[1]}]\
           [get_ports {wbm_adr_i[20]}]\
           [get_ports {wbm_adr_i[21]}]\
           [get_ports {wbm_adr_i[22]}]\
           [get_ports {wbm_adr_i[23]}]\
           [get_ports {wbm_adr_i[24]}]\
           [get_ports {wbm_adr_i[25]}]\
           [get_ports {wbm_adr_i[26]}]\
           [get_ports {wbm_adr_i[27]}]\
           [get_ports {wbm_adr_i[28]}]\
           [get_ports {wbm_adr_i[29]}]\
           [get_ports {wbm_adr_i[2]}]\
           [get_ports {wbm_adr_i[30]}]\
           [get_ports {wbm_adr_i[31]}]\
           [get_ports {wbm_adr_i[3]}]\
           [get_ports {wbm_adr_i[4]}]\
           [get_ports {wbm_adr_i[5]}]\
           [get_ports {wbm_adr_i[6]}]\
           [get_ports {wbm_adr_i[7]}]\
           [get_ports {wbm_adr_i[8]}]\
           [get_ports {wbm_adr_i[9]}]\
           [get_ports {wbm_cyc_i}]\
           [get_ports {wbm_dat_i[0]}]\
           [get_ports {wbm_dat_i[10]}]\
           [get_ports {wbm_dat_i[11]}]\
           [get_ports {wbm_dat_i[12]}]\
           [get_ports {wbm_dat_i[13]}]\
           [get_ports {wbm_dat_i[14]}]\
           [get_ports {wbm_dat_i[15]}]\
           [get_ports {wbm_dat_i[16]}]\
           [get_ports {wbm_dat_i[17]}]\
           [get_ports {wbm_dat_i[18]}]\
           [get_ports {wbm_dat_i[19]}]\
           [get_ports {wbm_dat_i[1]}]\
           [get_ports {wbm_dat_i[20]}]\
           [get_ports {wbm_dat_i[21]}]\
           [get_ports {wbm_dat_i[22]}]\
           [get_ports {wbm_dat_i[23]}]\
           [get_ports {wbm_dat_i[24]}]\
           [get_ports {wbm_dat_i[25]}]\
           [get_ports {wbm_dat_i[26]}]\
           [get_ports {wbm_dat_i[27]}]\
           [get_ports {wbm_dat_i[28]}]\
           [get_ports {wbm_dat_i[29]}]\
           [get_ports {wbm_dat_i[2]}]\
           [get_ports {wbm_dat_i[30]}]\
           [get_ports {wbm_dat_i[31]}]\
           [get_ports {wbm_dat_i[3]}]\
           [get_ports {wbm_dat_i[4]}]\
           [get_ports {wbm_dat_i[5]}]\
           [get_ports {wbm_dat_i[6]}]\
           [get_ports {wbm_dat_i[7]}]\
           [get_ports {wbm_dat_i[8]}]\
           [get_ports {wbm_dat_i[9]}]\
           [get_ports {wbm_sel_i[0]}]\
           [get_ports {wbm_sel_i[1]}]\
           [get_ports {wbm_sel_i[2]}]\
           [get_ports {wbm_sel_i[3]}]\
           [get_ports {wbm_we_i}]] 2
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0334 [get_ports {cfg_fast_sim}]
set_load -pin_load 0.0334 [get_ports {cfg_strap_pad_ctrl}]
set_load -pin_load 0.0334 [get_ports {cpu_clk}]
set_load -pin_load 0.0334 [get_ports {e_reset_n}]
set_load -pin_load 0.0334 [get_ports {p_reset_n}]
set_load -pin_load 0.0334 [get_ports {s_reset_n}]
set_load -pin_load 0.0334 [get_ports {sdout}]
set_load -pin_load 0.0334 [get_ports {sdout_oen}]
set_load -pin_load 0.0334 [get_ports {uartm_txd}]
set_load -pin_load 0.0334 [get_ports {wbd_clk_wh}]
set_load -pin_load 0.0334 [get_ports {wbd_int_rst_n}]
set_load -pin_load 0.0334 [get_ports {wbd_pll_rst_n}]
set_load -pin_load 0.0334 [get_ports {wbm_ack_o}]
set_load -pin_load 0.0334 [get_ports {wbm_err_o}]
set_load -pin_load 0.0334 [get_ports {wbs_clk_out}]
set_load -pin_load 0.0334 [get_ports {wbs_cyc_o}]
set_load -pin_load 0.0334 [get_ports {wbs_stb_o}]
set_load -pin_load 0.0334 [get_ports {wbs_we_o}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[31]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[30]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[29]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[28]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[27]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[26]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[25]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[24]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[23]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[22]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[21]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[20]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[19]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[18]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[17]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[16]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[15]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[14]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[13]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[12]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[11]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[10]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[9]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[8]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[7]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[6]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[5]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[4]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[3]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[2]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[1]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl1[0]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[31]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[30]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[29]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[28]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[27]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[26]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[25]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[24]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[23]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[22]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[21]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[20]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[19]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[18]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[17]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[16]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[15]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[14]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[13]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[12]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[11]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[10]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[9]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[8]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[7]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[6]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[5]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[4]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[3]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[2]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[1]}]
set_load -pin_load 0.0334 [get_ports {cfg_clk_skew_ctrl2[0]}]
set_load -pin_load 0.0334 [get_ports {system_strap[31]}]
set_load -pin_load 0.0334 [get_ports {system_strap[30]}]
set_load -pin_load 0.0334 [get_ports {system_strap[29]}]
set_load -pin_load 0.0334 [get_ports {system_strap[28]}]
set_load -pin_load 0.0334 [get_ports {system_strap[27]}]
set_load -pin_load 0.0334 [get_ports {system_strap[26]}]
set_load -pin_load 0.0334 [get_ports {system_strap[25]}]
set_load -pin_load 0.0334 [get_ports {system_strap[24]}]
set_load -pin_load 0.0334 [get_ports {system_strap[23]}]
set_load -pin_load 0.0334 [get_ports {system_strap[22]}]
set_load -pin_load 0.0334 [get_ports {system_strap[21]}]
set_load -pin_load 0.0334 [get_ports {system_strap[20]}]
set_load -pin_load 0.0334 [get_ports {system_strap[19]}]
set_load -pin_load 0.0334 [get_ports {system_strap[18]}]
set_load -pin_load 0.0334 [get_ports {system_strap[17]}]
set_load -pin_load 0.0334 [get_ports {system_strap[16]}]
set_load -pin_load 0.0334 [get_ports {system_strap[15]}]
set_load -pin_load 0.0334 [get_ports {system_strap[14]}]
set_load -pin_load 0.0334 [get_ports {system_strap[13]}]
set_load -pin_load 0.0334 [get_ports {system_strap[12]}]
set_load -pin_load 0.0334 [get_ports {system_strap[11]}]
set_load -pin_load 0.0334 [get_ports {system_strap[10]}]
set_load -pin_load 0.0334 [get_ports {system_strap[9]}]
set_load -pin_load 0.0334 [get_ports {system_strap[8]}]
set_load -pin_load 0.0334 [get_ports {system_strap[7]}]
set_load -pin_load 0.0334 [get_ports {system_strap[6]}]
set_load -pin_load 0.0334 [get_ports {system_strap[5]}]
set_load -pin_load 0.0334 [get_ports {system_strap[4]}]
set_load -pin_load 0.0334 [get_ports {system_strap[3]}]
set_load -pin_load 0.0334 [get_ports {system_strap[2]}]
set_load -pin_load 0.0334 [get_ports {system_strap[1]}]
set_load -pin_load 0.0334 [get_ports {system_strap[0]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[31]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[30]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[29]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[28]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[27]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[26]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[25]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[24]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[23]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[22]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[21]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[20]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[19]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[18]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[17]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[16]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[15]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[14]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[13]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[12]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[11]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[10]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[9]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[8]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[7]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[6]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[5]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[4]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[3]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[2]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[1]}]
set_load -pin_load 0.0334 [get_ports {wbm_dat_o[0]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[31]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[30]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[29]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[28]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[27]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[26]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[25]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[24]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[23]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[22]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[21]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[20]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[19]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[18]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[17]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[16]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[15]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[14]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[13]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[12]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[11]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[10]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[9]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[8]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[7]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[6]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[5]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[4]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[3]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[2]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[1]}]
set_load -pin_load 0.0334 [get_ports {wbs_adr_o[0]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[31]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[30]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[29]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[28]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[27]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[26]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[25]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[24]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[23]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[22]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[21]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[20]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[19]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[18]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[17]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[16]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[15]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[14]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[13]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[12]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[11]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[10]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[9]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[8]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[7]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[6]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[5]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[4]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[3]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[2]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[1]}]
set_load -pin_load 0.0334 [get_ports {wbs_dat_o[0]}]
set_load -pin_load 0.0334 [get_ports {wbs_sel_o[3]}]
set_load -pin_load 0.0334 [get_ports {wbs_sel_o[2]}]
set_load -pin_load 0.0334 [get_ports {wbs_sel_o[1]}]
set_load -pin_load 0.0334 [get_ports {wbs_sel_o[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {int_pll_clock}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {sclk}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {sdin}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {ssn}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {uartm_rxd}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {user_clock1}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {user_clock2}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbd_clk_int}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_clk_i}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_cyc_i}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_rst_i}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_stb_i}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_we_i}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_ack_i}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_clk_i}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_err_i}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {xtal_clk}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {cfg_cska_wh[3]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {cfg_cska_wh[2]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {cfg_cska_wh[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {cfg_cska_wh[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {la_data_in[17]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {la_data_in[16]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {la_data_in[15]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {la_data_in[14]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {la_data_in[13]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {la_data_in[12]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {la_data_in[11]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {la_data_in[10]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {la_data_in[9]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {la_data_in[8]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {la_data_in[7]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {la_data_in[6]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {la_data_in[5]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {la_data_in[4]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {la_data_in[3]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {la_data_in[2]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {la_data_in[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {la_data_in[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[31]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[30]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[29]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[28]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[27]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[26]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[25]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[24]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[23]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[22]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[21]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[20]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[19]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[18]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[17]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[16]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[15]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[14]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[13]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[12]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[11]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[10]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[9]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[8]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[7]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[6]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[5]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[4]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[3]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[2]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_sticky[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_uartm[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {strap_uartm[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[31]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[30]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[29]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[28]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[27]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[26]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[25]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[24]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[23]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[22]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[21]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[20]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[19]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[18]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[17]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[16]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[15]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[14]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[13]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[12]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[11]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[10]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[9]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[8]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[7]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[6]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[5]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[4]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[3]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[2]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_adr_i[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[31]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[30]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[29]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[28]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[27]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[26]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[25]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[24]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[23]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[22]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[21]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[20]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[19]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[18]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[17]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[16]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[15]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[14]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[13]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[12]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[11]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[10]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[9]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[8]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[7]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[6]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[5]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[4]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[3]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[2]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_dat_i[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_sel_i[3]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_sel_i[2]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_sel_i[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbm_sel_i[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[31]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[30]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[29]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[28]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[27]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[26]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[25]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[24]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[23]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[22]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[21]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[20]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[19]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[18]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[17]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[16]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[15]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[14]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[13]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[12]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[11]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[10]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[9]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[8]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[7]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[6]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[5]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[4]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[3]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[2]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbs_dat_i[0]}]
set_case_analysis 0 [get_ports {cfg_cska_wh[0]}]
set_case_analysis 0 [get_ports {cfg_cska_wh[1]}]
set_case_analysis 0 [get_ports {cfg_cska_wh[2]}]
set_case_analysis 0 [get_ports {cfg_cska_wh[3]}]
set_timing_derate -early 0.9500
set_timing_derate -late 1.0500
###############################################################################
# Design Rules
###############################################################################
set_max_transition 1.0000 [current_design]
set_max_capacitance 0.2000 [current_design]
set_max_fanout 10.0000 [current_design]
