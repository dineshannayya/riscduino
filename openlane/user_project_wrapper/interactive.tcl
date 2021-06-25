package require openlane
set script_dir [file dirname [file normalize [info script]]]

prep -design $script_dir -tag 24June2021 -overwrite
set save_path $script_dir/../..	

run_synthesis
run_floorplan
run_placement
run_cts
run_routing

write_powered_verilog
set_netlist $::env(lvs_result_file_tag).powered.v
run_magic
run_magic_drc
puts $::env(CURRENT_NETLIST)
run_magic_spice_export

save_views 	-lef_path $::env(magic_result_file_tag).lef \
		-def_path $::env(tritonRoute_result_file_tag).def \
		-gds_path $::env(magic_result_file_tag).gds \
		-mag_path $::env(magic_result_file_tag).mag \
		-maglef_path $::env(magic_result_file_tag).lef.mag \
		-spice_path $::env(magic_result_file_tag).spice \
		-verilog_path $::env(CURRENT_NETLIST)\
	        -save_path $save_path \
                -tag $::env(RUN_TAG)	
	
run_lvs
run_antenna_check
calc_total_runtime
generate_final_summary_report
puts_success "Flow Completed Without Fatal Errors."
