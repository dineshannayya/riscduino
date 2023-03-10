###############################################################################
# Created by write_sdc
# Fri Mar  3 03:30:45 2023
###############################################################################
current_design uart_i2c_usb_spi_top
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name app_clk -period 10.0000 [get_ports {app_clk}]
set_clock_transition 0.1500 [get_clocks {app_clk}]
set_clock_uncertainty -setup 0.5000 app_clk
set_clock_uncertainty -hold 0.2500 app_clk
set_propagated_clock [get_clocks {app_clk}]
create_clock -name uart0_baud_clk -period 100.0000 [get_pins {u_uart0_core.u_lineclk_buf.genblk1.u_mux/X}]
set_clock_transition 0.1500 [get_clocks {uart0_baud_clk}]
set_clock_uncertainty -setup 0.5000 uart0_baud_clk
set_clock_uncertainty -hold 0.2500 uart0_baud_clk
set_propagated_clock [get_clocks {uart0_baud_clk}]
create_clock -name uart1_baud_clk -period 100.0000 [get_pins {u_uart1_core.u_lineclk_buf.genblk1.u_mux/X}]
set_clock_transition 0.1500 [get_clocks {uart1_baud_clk}]
set_clock_uncertainty -setup 0.5000 uart1_baud_clk
set_clock_uncertainty -hold 0.2500 uart1_baud_clk
set_propagated_clock [get_clocks {uart1_baud_clk}]
create_clock -name usb_clk -period 100.0000 [get_ports {usb_clk}]
set_clock_transition 0.1500 [get_clocks {usb_clk}]
set_clock_uncertainty -setup 0.5000 usb_clk
set_clock_uncertainty -hold 0.2500 usb_clk
set_propagated_clock [get_clocks {usb_clk}]
set_clock_groups -name async_clock -asynchronous \
 -group [get_clocks {app_clk}]\
 -group [get_clocks {uart0_baud_clk}]\
 -group [get_clocks {uart1_baud_clk}]\
 -group [get_clocks {usb_clk}] -comment {Async Clock group}
set_input_delay 1.5000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {i2c_rstn}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {i2c_rstn}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_addr[0]}]
set_input_delay 5.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_addr[0]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_addr[1]}]
set_input_delay 5.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_addr[1]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_addr[2]}]
set_input_delay 5.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_addr[2]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_addr[3]}]
set_input_delay 5.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_addr[3]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_addr[4]}]
set_input_delay 5.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_addr[4]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_addr[5]}]
set_input_delay 5.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_addr[5]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_addr[6]}]
set_input_delay 5.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_addr[6]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_addr[7]}]
set_input_delay 5.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_addr[7]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_addr[8]}]
set_input_delay 5.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_addr[8]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_be[0]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_be[0]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_be[1]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_be[1]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_be[2]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_be[2]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_be[3]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_be[3]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_cs}]
set_input_delay 5.7500 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_cs}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[0]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[0]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[10]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[10]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[11]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[11]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[12]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[12]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[13]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[13]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[14]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[14]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[15]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[15]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[16]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[16]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[17]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[17]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[18]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[18]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[19]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[19]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[1]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[1]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[20]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[20]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[21]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[21]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[22]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[22]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[23]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[23]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[24]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[24]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[25]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[25]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[26]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[26]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[27]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[27]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[28]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[28]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[29]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[29]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[2]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[2]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[30]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[30]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[31]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[31]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[3]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[3]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[4]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[4]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[5]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[5]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[6]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[6]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[7]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[7]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[8]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[8]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wdata[9]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wdata[9]}]
set_input_delay 2.0000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_wr}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_wr}]
set_input_delay 1.5000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {uart_rstn[0]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {uart_rstn[0]}]
set_input_delay 1.5000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {uart_rstn[1]}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {uart_rstn[1]}]
set_input_delay 1.5000 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {usb_rstn}]
set_input_delay 6.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {usb_rstn}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_ack}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[0]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[0]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[10]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[10]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[11]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[11]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[12]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[12]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[13]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[13]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[14]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[14]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[15]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[15]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[16]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[16]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[17]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[17]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[18]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[18]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[19]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[19]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[1]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[1]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[20]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[20]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[21]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[21]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[22]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[22]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[23]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[23]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[24]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[24]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[25]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[25]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[26]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[26]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[27]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[27]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[28]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[28]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[29]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[29]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[2]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[2]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[30]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[30]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[31]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[31]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[3]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[3]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[4]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[4]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[5]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[5]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[6]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[6]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[7]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[7]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[8]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[8]}]
set_output_delay -2.7500 -clock [get_clocks {app_clk}] -min -add_delay [get_ports {reg_rdata[9]}]
set_output_delay 1.0000 -clock [get_clocks {app_clk}] -max -add_delay [get_ports {reg_rdata[9]}]
set_multicycle_path -hold\
    -from [list [get_ports {reg_addr[0]}]\
           [get_ports {reg_addr[1]}]\
           [get_ports {reg_addr[2]}]\
           [get_ports {reg_addr[3]}]\
           [get_ports {reg_addr[4]}]\
           [get_ports {reg_addr[5]}]\
           [get_ports {reg_addr[6]}]\
           [get_ports {reg_addr[7]}]\
           [get_ports {reg_addr[8]}]]\
    -to [list [get_ports {reg_ack}]\
           [get_ports {reg_rdata[0]}]\
           [get_ports {reg_rdata[10]}]\
           [get_ports {reg_rdata[11]}]\
           [get_ports {reg_rdata[12]}]\
           [get_ports {reg_rdata[13]}]\
           [get_ports {reg_rdata[14]}]\
           [get_ports {reg_rdata[15]}]\
           [get_ports {reg_rdata[16]}]\
           [get_ports {reg_rdata[17]}]\
           [get_ports {reg_rdata[18]}]\
           [get_ports {reg_rdata[19]}]\
           [get_ports {reg_rdata[1]}]\
           [get_ports {reg_rdata[20]}]\
           [get_ports {reg_rdata[21]}]\
           [get_ports {reg_rdata[22]}]\
           [get_ports {reg_rdata[23]}]\
           [get_ports {reg_rdata[24]}]\
           [get_ports {reg_rdata[25]}]\
           [get_ports {reg_rdata[26]}]\
           [get_ports {reg_rdata[27]}]\
           [get_ports {reg_rdata[28]}]\
           [get_ports {reg_rdata[29]}]\
           [get_ports {reg_rdata[2]}]\
           [get_ports {reg_rdata[30]}]\
           [get_ports {reg_rdata[31]}]\
           [get_ports {reg_rdata[3]}]\
           [get_ports {reg_rdata[4]}]\
           [get_ports {reg_rdata[5]}]\
           [get_ports {reg_rdata[6]}]\
           [get_ports {reg_rdata[7]}]\
           [get_ports {reg_rdata[8]}]\
           [get_ports {reg_rdata[9]}]] 1
set_multicycle_path -setup\
    -from [list [get_ports {reg_addr[0]}]\
           [get_ports {reg_addr[1]}]\
           [get_ports {reg_addr[2]}]\
           [get_ports {reg_addr[3]}]\
           [get_ports {reg_addr[4]}]\
           [get_ports {reg_addr[5]}]\
           [get_ports {reg_addr[6]}]\
           [get_ports {reg_addr[7]}]\
           [get_ports {reg_addr[8]}]]\
    -to [list [get_ports {reg_ack}]\
           [get_ports {reg_rdata[0]}]\
           [get_ports {reg_rdata[10]}]\
           [get_ports {reg_rdata[11]}]\
           [get_ports {reg_rdata[12]}]\
           [get_ports {reg_rdata[13]}]\
           [get_ports {reg_rdata[14]}]\
           [get_ports {reg_rdata[15]}]\
           [get_ports {reg_rdata[16]}]\
           [get_ports {reg_rdata[17]}]\
           [get_ports {reg_rdata[18]}]\
           [get_ports {reg_rdata[19]}]\
           [get_ports {reg_rdata[1]}]\
           [get_ports {reg_rdata[20]}]\
           [get_ports {reg_rdata[21]}]\
           [get_ports {reg_rdata[22]}]\
           [get_ports {reg_rdata[23]}]\
           [get_ports {reg_rdata[24]}]\
           [get_ports {reg_rdata[25]}]\
           [get_ports {reg_rdata[26]}]\
           [get_ports {reg_rdata[27]}]\
           [get_ports {reg_rdata[28]}]\
           [get_ports {reg_rdata[29]}]\
           [get_ports {reg_rdata[2]}]\
           [get_ports {reg_rdata[30]}]\
           [get_ports {reg_rdata[31]}]\
           [get_ports {reg_rdata[3]}]\
           [get_ports {reg_rdata[4]}]\
           [get_ports {reg_rdata[5]}]\
           [get_ports {reg_rdata[6]}]\
           [get_ports {reg_rdata[7]}]\
           [get_ports {reg_rdata[8]}]\
           [get_ports {reg_rdata[9]}]] 2
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0334 [get_ports {i2cm_intr_o}]
set_load -pin_load 0.0334 [get_ports {reg_ack}]
set_load -pin_load 0.0334 [get_ports {scl_pad_o}]
set_load -pin_load 0.0334 [get_ports {scl_pad_oen_o}]
set_load -pin_load 0.0334 [get_ports {sda_pad_o}]
set_load -pin_load 0.0334 [get_ports {sda_padoen_o}]
set_load -pin_load 0.0334 [get_ports {sspim_sck}]
set_load -pin_load 0.0334 [get_ports {sspim_so}]
set_load -pin_load 0.0334 [get_ports {usb_intr_o}]
set_load -pin_load 0.0334 [get_ports {usb_out_dn}]
set_load -pin_load 0.0334 [get_ports {usb_out_dp}]
set_load -pin_load 0.0334 [get_ports {usb_out_tx_oen}]
set_load -pin_load 0.0334 [get_ports {wbd_clk_uart}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[31]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[30]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[29]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[28]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[27]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[26]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[25]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[24]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[23]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[22]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[21]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[20]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[19]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[18]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[17]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[16]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[15]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[14]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[13]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[12]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[11]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[10]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[9]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[8]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[7]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[6]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[5]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[4]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[3]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[2]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[1]}]
set_load -pin_load 0.0334 [get_ports {reg_rdata[0]}]
set_load -pin_load 0.0334 [get_ports {sspim_ssn[3]}]
set_load -pin_load 0.0334 [get_ports {sspim_ssn[2]}]
set_load -pin_load 0.0334 [get_ports {sspim_ssn[1]}]
set_load -pin_load 0.0334 [get_ports {sspim_ssn[0]}]
set_load -pin_load 0.0334 [get_ports {uart_txd[1]}]
set_load -pin_load 0.0334 [get_ports {uart_txd[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {app_clk}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {i2c_rstn}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_cs}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wr}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {scl_pad_i}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {sda_pad_i}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {spi_rstn}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {sspim_si}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {usb_clk}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {usb_in_dn}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {usb_in_dp}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {usb_rstn}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wbd_clk_int}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {cfg_cska_uart[3]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {cfg_cska_uart[2]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {cfg_cska_uart[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {cfg_cska_uart[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_addr[8]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_addr[7]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_addr[6]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_addr[5]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_addr[4]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_addr[3]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_addr[2]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_addr[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_addr[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_be[3]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_be[2]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_be[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_be[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[31]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[30]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[29]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[28]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[27]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[26]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[25]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[24]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[23]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[22]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[21]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[20]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[19]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[18]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[17]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[16]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[15]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[14]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[13]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[12]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[11]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[10]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[9]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[8]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[7]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[6]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[5]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[4]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[3]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[2]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reg_wdata[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {uart_rstn[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {uart_rstn[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {uart_rxd[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {uart_rxd[0]}]
set_case_analysis 0 [get_ports {cfg_cska_uart[0]}]
set_case_analysis 0 [get_ports {cfg_cska_uart[1]}]
set_case_analysis 0 [get_ports {cfg_cska_uart[2]}]
set_case_analysis 0 [get_ports {cfg_cska_uart[3]}]
set_timing_derate -early 0.9500
set_timing_derate -late 1.0500
###############################################################################
# Design Rules
###############################################################################
set_max_transition 1.0000 [current_design]
set_max_capacitance 0.2000 [current_design]
set_max_fanout 10.0000 [current_design]
