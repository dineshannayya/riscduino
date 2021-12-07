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
    # set pdndef_dirname [file dirname $::env(pdn_tmp_file_tag).def]
    # set pdndef [lindex [glob $pdndef_dirname/*pdn*] 0]
    # set_def $pdndef
    if { ! [ info exists ::env(PLACEMENT_CURRENT_DEF) ] } {
        set ::env(PLACEMENT_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(PLACEMENT_CURRENT_DEF)
    }

    run_placement
}

proc run_cts_step {args} {
    # set_def $::env(opendp_result_file_tag).def
    if { ! [ info exists ::env(CTS_CURRENT_DEF) ] } {
        set ::env(CTS_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(CTS_CURRENT_DEF)
    }

    run_cts
    run_resizer_timing
}

proc run_routing_step {args} {
    # set resizerdef_dirname [file dirname $::env(resizer_tmp_file_tag)_timing.def]
    # set resizerdef [lindex [glob $resizerdef_dirname/*resizer*] 0]
    # set_def $resizerdef
    if { ! [ info exists ::env(ROUTING_CURRENT_DEF) ] } {
        set ::env(ROUTING_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(ROUTING_CURRENT_DEF)
    }
    run_routing
}

proc run_diode_insertion_2_5_step {args} {
    # set_def $::env(tritonRoute_result_file_tag).def
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

proc run_power_pins_insertion_step {args} {
    # set_def $::env(tritonRoute_result_file_tag).def
    if { ! [ info exists ::env(POWER_PINS_INSERTION_CURRENT_DEF) ] } {
        set ::env(POWER_PINS_INSERTION_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(POWER_PINS_INSERTION_CURRENT_DEF)
    }
    if { $::env(LVS_INSERT_POWER_PINS) } {
		write_powered_verilog
		set_netlist $::env(lvs_result_file_tag).powered.v
    }

}

proc run_lvs_step {{ lvs_enabled 1 }} {
    # set_def $::env(tritonRoute_result_file_tag).def
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

proc gen_pdn {args} {
    puts_info "Generating PDN..."
    TIMER::timer_start
	
    set ::env(SAVE_DEF) [index_file $::env(pdn_tmp_file_tag).def]
    set ::env(PGA_RPT_FILE) [index_file $::env(pdn_report_file_tag).pga.rpt]

    try_catch $::env(OPENROAD_BIN) -exit $::env(SCRIPTS_DIR)/openroad/pdn.tcl \
	|& tee $::env(TERMINAL_OUTPUT) [index_file $::env(pdn_log_file_tag).log 0]


    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> [index_file $::env(pdn_log_file_tag)_runtime.txt 0]

	quit_on_unconnected_pdn_nodes

    set_def $::env(SAVE_DEF)
}

proc run_power_grid_generation {args} {
	if { [info exists ::env(VDD_NETS)] || [info exists ::env(GND_NETS)] } {
		# they both must exist and be equal in length
		# current assumption: they cannot have a common ground
		if { ! [info exists ::env(VDD_NETS)] || ! [info exists ::env(GND_NETS)] } {
			puts_err "VDD_NETS and GND_NETS must *both* either be defined or undefined"
			return -code error
		}
		# standard cell power and ground nets are assumed to be the first net 
		set ::env(VDD_PIN) [lindex $::env(VDD_NETS) 0]
		set ::env(GND_PIN) [lindex $::env(GND_NETS) 0]
	} elseif { [info exists ::env(SYNTH_USE_PG_PINS_DEFINES)] } {
		set ::env(VDD_NETS) [list]
		set ::env(GND_NETS) [list]
		# get the pins that are in $yosys_tmp_file_tag.pg_define.v
		# that are not in $yosys_result_file_tag.v
		#
		set full_pins {*}[extract_pins_from_yosys_netlist $::env(yosys_tmp_file_tag).pg_define.v]
		puts_info $full_pins

		set non_pg_pins {*}[extract_pins_from_yosys_netlist $::env(yosys_result_file_tag).v]
		puts_info $non_pg_pins

		# assumes the pins are ordered correctly (e.g., vdd1, vss1, vcc1, vss1, ...)
		foreach {vdd gnd} $full_pins {
			if { $vdd ne "" && $vdd ni $non_pg_pins } {
				lappend ::env(VDD_NETS) $vdd
			}
			if { $gnd ne "" && $gnd ni $non_pg_pins } {
				lappend ::env(GND_NETS) $gnd
			}
		}
	} else {
		set ::env(VDD_NETS) $::env(VDD_PIN)
		set ::env(GND_NETS) $::env(GND_PIN)
	}

	puts_info "Power planning the following nets"
	puts_info "Power: $::env(VDD_NETS)"
	puts_info "Ground: $::env(GND_NETS)"

	if { [llength $::env(VDD_NETS)] != [llength $::env(GND_NETS)] } {
		puts_err "VDD_NETS and GND_NETS must be of equal lengths"
		return -code error
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
		        set power_net_indx [lsearch $::env(VDD_NETS) $power_net]
		        set ground_net_indx [lsearch $::env(GND_NETS) $ground_net]

		        # make sure that the specified power domains exist.
		        if { $power_net_indx == -1  || $ground_net_indx == -1 || $power_net_indx != $ground_net_indx } {
		        	puts_err "Can't find $power_net and $ground_net domain. \
		        	Make sure that both exist in $::env(VDD_NETS) and $::env(GND_NETS)." 
		        } 
		}
		
	}
	
	# generate multiple power grids per pair of (VDD,GND)
	# offseted by WIDTH + SPACING
	foreach vdd $::env(VDD_NETS) gnd $::env(GND_NETS) {
		set ::env(VDD_NET) $vdd
		set ::env(GND_NET) $gnd
	        puts_info "Connecting Power: $vdd & gnd to All internal macros."

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
						puts_info "Connecting $instance_name to $power and $ground nets."
						lappend ::env(FP_PDN_MACROS) $instance_name
					}
				}
			} 
		} else {
			puts_warn "All internal macros will not be connected to power $vdd & $gnd."
		}
		
		gen_pdn

		set ::env(FP_PDN_ENABLE_RAILS) 0
		set ::env(FP_PDN_ENABLE_MACROS_GRID) 0

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
		puts "FP_PDN_HOFFSET: $::env(FP_PDN_VOFFSET)"
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
				file copy -force $::env(MACRO_PLACEMENT_CFG) $::env(TMP_DIR)/macro_placement.cfg
				manual_macro_placement f
			} else {
				global_placement_or
				basic_macro_placement
			}
		}

		# tapcell
		tap_decap_or
		scrot_klayout -layout $::env(CURRENT_DEF)
		# power grid generation
		run_power_grid_generation
}


proc run_flow {args} {
       set script_dir [file dirname [file normalize [info script]]]

		set options {
		{-design required}
		{-save_path optional}
		{-no_lvs optional}
	    {-no_drc optional}
	    {-no_antennacheck optional}
	}
	set flags {-save}
	parse_key_args "run_flow" args arg_values $options flags_map $flags -no_consume

	prep {*}$args

        set LVS_ENABLED 1
        set DRC_ENABLED 0
        set ANTENNACHECK_ENABLED 1

        set steps [dict create "synthesis" {run_synthesis "" } \
                "floorplan" {run_floorplan ""} \
                "placement" {run_placement_step ""} \
                "cts" {run_cts_step ""} \
                "routing" {run_routing_step ""}\
                "diode_insertion" {run_diode_insertion_2_5_step ""} \
                "power_pins_insertion" {run_power_pins_insertion_step ""} \
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

	if {  [info exists flags_map(-save) ] } {
		if { ! [info exists arg_values(-save_path)] } {
			set arg_values(-save_path) ""
		}
		save_views 	-lef_path $::env(magic_result_file_tag).lef \
			-def_path $::env(CURRENT_DEF) \
			-gds_path $::env(magic_result_file_tag).gds \
			-mag_path $::env(magic_result_file_tag).mag \
			-maglef_path $::env(magic_result_file_tag).lef.mag \
			-spice_path $::env(magic_result_file_tag).spice \
			-spef_path $::env(CURRENT_SPEF) \
			-verilog_path $::env(CURRENT_NETLIST) \
			-save_path $arg_values(-save_path) \
			-tag $::env(RUN_TAG)
	}


	calc_total_runtime
	save_state
	generate_final_summary_report
	
	check_timing_violations

	puts_success "Flow Completed Without Fatal Errors."

}

run_flow {*}$argv
