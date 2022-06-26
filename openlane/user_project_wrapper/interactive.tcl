#!/usr/bin/tclsh
# SPDX-FileCopyrightText: 2020 Efabless Corporation
# Copyright 2020 Efabless Corporation
# Copyright 2020 Sylvain Munaut
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0
package require openlane;
proc run_placement_step {args} {
    if { ! [ info exists ::env(PLACEMENT_CURRENT_DEF) ] } {
        set ::env(PLACEMENT_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(PLACEMENT_CURRENT_DEF)
    }
    run_placement
}
proc run_cts_step {args} {
    if { ! [ info exists ::env(CTS_CURRENT_DEF) ] } {
        set ::env(CTS_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(CTS_CURRENT_DEF)
    }
    run_cts
    run_resizer_timing
}
proc run_routing_step {args} {
    if { ! [ info exists ::env(ROUTING_CURRENT_DEF) ] } {
        set ::env(ROUTING_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(ROUTING_CURRENT_DEF)
    }
    run_routing
}
proc run_diode_insertion_2_5_step {args} {
    if { ! [ info exists ::env(DIODE_INSERTION_CURRENT_DEF) ] } {
        set ::env(DIODE_INSERTION_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(DIODE_INSERTION_CURRENT_DEF)
    }
	if { ($::env(DIODE_INSERTION_STRATEGY) == 2) || ($::env(DIODE_INSERTION_STRATEGY) == 5) } {
		run_antenna_check
		heal_antenna_violators; # modifies the routed DEF
	}
}
proc run_lvs_step {{ lvs_enabled 1 }} {
    if { ! [ info exists ::env(LVS_CURRENT_DEF) ] } {
        set ::env(LVS_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(LVS_CURRENT_DEF)
    }
	if { $lvs_enabled } {
		run_magic_spice_export
		run_lvs; # requires run_magic_spice_export
	}
}
proc run_drc_step {{ drc_enabled 1 }} {
    if { ! [ info exists ::env(DRC_CURRENT_DEF) ] } {
        set ::env(DRC_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(DRC_CURRENT_DEF)
    }
	if { $drc_enabled } {
		run_magic_drc
		run_klayout_drc
	}
}
proc run_antenna_check_step {{ antenna_check_enabled 1 }} {
    if { ! [ info exists ::env(ANTENNA_CHECK_CURRENT_DEF) ] } {
        set ::env(ANTENNA_CHECK_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(ANTENNA_CHECK_CURRENT_DEF)
    }
	if { $antenna_check_enabled } {
		run_antenna_check
	}
}
proc run_eco_step {args} {
	if {  $::env(ECO_ENABLE) == 1 } {
        run_eco
    }
}
proc save_final_views {args} {
	set options {
		{-save_path optional}
	}
	set flags {}
	parse_key_args "save_final_views" args arg_values $options flags_map $flags
	set arg_list [list]
	# If they don't exist, save_views will simply not copy them
	lappend arg_list -lef_path $::env(finishing_results)/$::env(DESIGN_NAME).lef
	lappend arg_list -gds_path $::env(finishing_results)/$::env(DESIGN_NAME).gds
	lappend arg_list -mag_path $::env(finishing_results)/$::env(DESIGN_NAME).mag
	lappend arg_list -maglef_path $::env(finishing_results)/$::env(DESIGN_NAME).lef.mag
	lappend arg_list -spice_path $::env(finishing_results)/$::env(DESIGN_NAME).spice
	
	# Guaranteed to have default values
	lappend arg_list -def_path $::env(CURRENT_DEF)
	lappend arg_list -verilog_path $::env(CURRENT_NETLIST)
	# Not guaranteed to have default values
	if { [info exists ::env(SPEF_TYPICAL)] } {
		lappend arg_list -spef_path $::env(SPEF_TYPICAL)
	}
	if { [info exists ::env(CURRENT_SDF)] } {
		lappend arg_list -sdf_path $::env(CURRENT_SDF)
	}
	if { [info exists ::env(CURRENT_SDC)] } {
		lappend arg_list -sdc_path $::env(CURRENT_SDC)
	}
	# Add the path if it exists...
	if { [info exists arg_values(-save_path) ] } {
		lappend arg_list -save_path $arg_values(-save_path)
	}
	# Aaand fire!
	save_views {*}$arg_list
}
proc run_post_run_hooks {} {
	if { [file exists $::env(DESIGN_DIR)/hooks/post_run.py]} {
		puts_info "Running post run hook"
		set result [exec $::env(OPENROAD_BIN) -python $::env(DESIGN_DIR)/hooks/post_run.py]
		puts_info "$result"
	} else {
		puts_info "hooks/post_run.py not found, skipping"
	}
}
proc gen_pdn {args} {
    puts_info "Generating PDN..."
    TIMER::timer_start
	
    set ::env(SAVE_DEF) [index_file $::env(floorplan_tmpfiles).def]
    set ::env(PGA_RPT_FILE) [index_file $::env(floorplan_tmpfiles).pga.rpt]
    run_openroad_script $::env(SCRIPTS_DIR)/openroad/pdn.tcl \
        |& -indexed_log [index_file $::env(floorplan_logs)/pdn.log]
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "pdn generation - openroad"
    quit_on_unconnected_pdn_nodes
    set_def $::env(SAVE_DEF)
}
proc run_power_grid_generation {args} {
	if {[info exists ::env(FP_PDN_POWER_STRAPS)]} {
	     set power_domains [split $::env(FP_PDN_POWER_STRAPS) ","]
	}
	# internal macros power connections 
	if {[info exists ::env(FP_PDN_MACRO_HOOKS)]} {
		set macro_hooks [dict create]
		set pdn_hooks [split $::env(FP_PDN_MACRO_HOOKS) ","]
		foreach pdn_hook $pdn_hooks {
			set instance_name [lindex $pdn_hook 0]
			set power_net [lindex $pdn_hook 1]
			set ground_net [lindex $pdn_hook 2]
			dict append macro_hooks $instance_name [subst {$power_net $ground_net}]
		}
		
		set power_net_indx [lsearch $::env(VDD_NETS) $power_net]
		set ground_net_indx [lsearch $::env(GND_NETS) $ground_net]
		# make sure that the specified power domains exist.
		if { $power_net_indx == -1  || $ground_net_indx == -1 || $power_net_indx != $ground_net_indx } {
			puts_err "Can't find $power_net and $ground_net domain. \
			Make sure that both exist in $::env(VDD_NETS) and $::env(GND_NETS)." 
		} 
	}
	
	# generate multiple power grids per pair of (VDD,GND)
	# offseted by WIDTH + SPACING
	foreach domain $power_domains {
		set ::env(VDD_NET)       [lindex $domain 0]
	        set ::env(GND_NET)       [lindex $domain 1]
	        set ::env(_WITH_STRAPS)  [lindex $domain 2]
	        puts_info "Connecting Power: $::env(VDD_NET) & $::env(GND_NET) to All internal macros."
		# internal macros power connections
		set ::env(FP_PDN_MACROS) ""
		if { $::env(FP_PDN_ENABLE_MACROS_GRID) == 1 } {
			# if macros connections to power are explicitly set
			# default behavoir macro pins will be connected to the first power domain
			if { [info exists ::env(FP_PDN_MACRO_HOOKS)] } {
				set ::env(FP_PDN_ENABLE_MACROS_GRID) 0
				foreach {instance_name hooks} $macro_hooks {
					set power [lindex $hooks 0]
					set ground [lindex $hooks 1]			 
					if { $power == $::env(VDD_NET) && $ground == $::env(GND_NET) } {
						set ::env(FP_PDN_ENABLE_MACROS_GRID) 1
                                                set ::env(FP_PDN_IRDROP) "0"
						puts_info "Connecting $instance_name to $power and $ground nets."
						lappend ::env(FP_PDN_MACROS) $instance_name
					}
				}
			} 
		} else {
			puts_warn "All internal macros will not be connected to power $::env(VDD_NET) & $::env(GND_NET)."
		}
		
		gen_pdn
		set ::env(FP_PDN_ENABLE_RAILS) 0
		set ::env(FP_PDN_ENABLE_MACROS_GRID) 0
                set ::env(FP_PDN_IRDROP) "0"
		# allow failure until open_pdks is up to date...
		catch {set ::env(FP_PDN_VOFFSET) [expr $::env(FP_PDN_VOFFSET)+$::env(FP_PDN_VWIDTH)+$::env(FP_PDN_VSPACING)]}
		catch {set ::env(FP_PDN_HOFFSET) [expr $::env(FP_PDN_HOFFSET)+$::env(FP_PDN_HWIDTH)+$::env(FP_PDN_HSPACING)]}
		catch {set ::env(FP_PDN_CORE_RING_VOFFSET) \
			[expr $::env(FP_PDN_CORE_RING_VOFFSET)\
			+2*($::env(FP_PDN_CORE_RING_VWIDTH)\
			+max($::env(FP_PDN_CORE_RING_VSPACING), $::env(FP_PDN_CORE_RING_HSPACING)))]}
		catch {set ::env(FP_PDN_CORE_RING_HOFFSET) [expr $::env(FP_PDN_CORE_RING_HOFFSET)\
			+2*($::env(FP_PDN_CORE_RING_HWIDTH)+\
			max($::env(FP_PDN_CORE_RING_VSPACING), $::env(FP_PDN_CORE_RING_HSPACING)))]}
		puts "FP_PDN_VOFFSET: $::env(FP_PDN_VOFFSET)"
		puts "FP_PDN_HOFFSET: $::env(FP_PDN_HOFFSET)"
		puts "FP_PDN_CORE_RING_VOFFSET: $::env(FP_PDN_CORE_RING_VOFFSET)"
		puts "FP_PDN_CORE_RING_HOFFSET: $::env(FP_PDN_CORE_RING_HOFFSET)"
	}
	set ::env(FP_PDN_ENABLE_RAILS) 1
}
proc run_floorplan {args} {
	puts_info "Running Floorplanning..."
	# |----------------------------------------------------|
	# |----------------   2. FLOORPLAN   ------------------|
	# |----------------------------------------------------|
	#
	# intial fp
	init_floorplan
	# check for deprecated io variables
	if { [info exists ::env(FP_IO_HMETAL)]} {
		set ::env(FP_IO_HLAYER) [lindex $::env(TECH_METAL_LAYERS) [expr {$::env(FP_IO_HMETAL) - 1}]]
		puts_warn "You're using FP_IO_HMETAL in your configuration, which is a deprecated variable that will be removed in the future."
		puts_warn "We recommend you update your configuration as follows:"
		puts_warn "\tset ::env(FP_IO_HLAYER) {$::env(FP_IO_HLAYER)}"
	}
	if { [info exists ::env(FP_IO_VMETAL)]} {
		set ::env(FP_IO_VLAYER) [lindex $::env(TECH_METAL_LAYERS) [expr {$::env(FP_IO_VMETAL) - 1}]]
		puts_warn "You're using FP_IO_VMETAL in your configuration, which is a deprecated variable that will be removed in the future."
		puts_warn "We recommend you update your configuration as follows:"
		puts_warn "\tset ::env(FP_IO_VLAYER) {$::env(FP_IO_VLAYER)}"
	}
	# place io
	if { [info exists ::env(FP_PIN_ORDER_CFG)] } {
		place_io_ol
	} else {
		if { [info exists ::env(FP_CONTEXT_DEF)] && [info exists ::env(FP_CONTEXT_LEF)] } {
			place_io
			global_placement_or
			place_contextualized_io \
				-lef $::env(FP_CONTEXT_LEF) \
				-def $::env(FP_CONTEXT_DEF)
		} else {
			place_io
		}
	}
	apply_def_template
	if { [info exist ::env(EXTRA_LEFS)] } {
		if { [info exist ::env(MACRO_PLACEMENT_CFG)] } {
			file copy -force $::env(MACRO_PLACEMENT_CFG) $::env(placement_tmpfiles)/macro_placement.cfg
			manual_macro_placement f
		} else {
			global_placement_or
			basic_macro_placement
		}
	}
	tap_decap_or
	scrot_klayout -layout $::env(CURRENT_DEF) $::env(floorplan_logs)/screenshot.log
	run_power_grid_generation
}
proc run_flow {args} {
	set options {
		{-design required}
		{-from optional}
		{-to optional}
		{-save_path optional}
		{-override_env optional}
	}
	set flags {-save -run_hooks -no_lvs -no_drc -no_antennacheck }
	parse_key_args "run_non_interactive_mode" args arg_values $options flags_map $flags -no_consume
	prep {*}$args
    # signal trap SIGINT save_state;
	if { [info exists arg_values(-override_env)] } {
		set env_overrides [split $arg_values(-override_env) ','] 
		foreach override $env_overrides {
			set kva [split $override '=']
			set key [lindex $kva 0]
			set value [lindex $kva 1]
			set ::env(${key}) $value
		}
	}
    set LVS_ENABLED 1
    set DRC_ENABLED 0
    set ANTENNACHECK_ENABLED 1
    set steps [dict create \
		"synthesis" {run_synthesis "" } \
		"floorplan" {run_floorplan ""} \
		"placement" {run_placement_step ""} \
		"cts" {run_cts_step ""} \
		"routing" {run_routing_step ""}\
                "eco" {run_eco_step ""} \
		"diode_insertion" {run_diode_insertion_2_5_step ""} \
		"gds_magic" {run_magic ""} \
		"gds_drc_klayout" {run_klayout ""} \
		"gds_xor_klayout" {run_klayout_gds_xor ""} \
		"lvs" "run_lvs_step $LVS_ENABLED" \
		"drc" "run_drc_step $DRC_ENABLED" \
		"antenna_check" "run_antenna_check_step $ANTENNACHECK_ENABLED" \
		"cvc" {run_lef_cvc}
    ]
    set_if_unset arg_values(-to) "cvc";
	if {  [info exists ::env(CURRENT_STEP) ] } {
        puts "\[INFO\]:Picking up where last execution left off"
        puts [format "\[INFO\]:Current stage is %s " $::env(CURRENT_STEP)]
    } else {
        set ::env(CURRENT_STEP) "synthesis";
    }
    set_if_unset arg_values(-from) $::env(CURRENT_STEP);
    set exe 0;
    dict for {step_name step_exe} $steps {
        if { [ string equal $arg_values(-from) $step_name ] } {
            set exe 1;
        }
        if { $exe } {
            # For when it fails
            set ::env(CURRENT_STEP) $step_name
            [lindex $step_exe 0] [lindex $step_exe 1] ;
        }
        if { [ string equal $arg_values(-to) $step_name ] } {
            set exe 0:
            break;
        }
    }
    # for when it resumes
    set steps_as_list [dict keys $steps]
    set next_idx [expr [lsearch $steps_as_list $::env(CURRENT_STEP)] + 1]
    set ::env(CURRENT_STEP) [lindex $steps_as_list $next_idx]
	# Saves to <RUN_DIR>/results/final
	if { $::env(SAVE_FINAL_VIEWS) == "1" } {
		save_final_views
	}
	# Saves to design directory or custom
	if {  [info exists flags_map(-save) ] } {
		if { ! [info exists arg_values(-save_path)] } {
			set arg_values(-save_path) $::env(DESIGN_DIR)
		}
		save_final_views\
			-save_path $arg_values(-save_path)\
			-tag $::env(RUN_TAG)
	}
	calc_total_runtime
	save_state
	generate_final_summary_report
	
	check_timing_violations
	
	if { [info exists arg_values(-save_path)]\
	    && $arg_values(-save_path) != "" } {
	    set ::env(HOOK_OUTPUT_PATH) "[file normalize $arg_values(-save_path)]"
	} else {
	    set ::env(HOOK_OUTPUT_PATH) $::env(RESULTS_DIR)/final
	}
	
	if {[info exists flags_map(-run_hooks)]} {
		run_post_run_hooks
	}
	
	puts_success "Flow complete."
	show_warnings "Note that the following warnings have been generated:"
}
run_flow {*}$argv
