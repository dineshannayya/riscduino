
    set ::env(USER_ROOT)    ".."
    set ::env(PDK_ROOT)     "/opt/pdk_mpw7/sky130B"
    define_corners ss tt ff

    read_liberty -corner tt $::env(PDK_ROOT)/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib	

	# User project netlist
    read_verilog $::env(USER_ROOT)/verilog/gl/pinmux_top.v  


	link_design pinmux_top


	## User Project Spef
    read_spef  -corner tt $::env(USER_ROOT)/spef/pinmux_top.spef


	read_sdc -echo ./sdc/pinmux.sdc	
	set_propagated_clock [all_clocks]

	check_setup  -verbose >  unconstraints.rpt
	report_checks -path_delay min -fields {slew cap input nets fanout} -format full_clock_expanded -group_count 50	
	report_checks -path_delay max -fields {slew cap input nets fanout} -format full_clock_expanded -group_count 50	
	report_worst_slack -max 	
	report_worst_slack -min 	
	report_checks -path_delay min -fields {slew cap input nets fanout} -format full_clock_expanded -slack_max 0.18 -group_count 10	
	report_check_types -max_slew -max_capacitance -max_fanout -violators  > slew.cap.fanout.vio.rpt

