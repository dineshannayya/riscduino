#!/usr/bin/env tclsh
# Copyright 2020-2022 Efabless Corporation
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
package require openlane; # provides the utils as well
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
    if { $::env(RSZ_USE_OLD_REMOVER) == 1} {
        remove_buffers_from_nets
    }
}

proc run_routing_step {args} {
    if { ! [ info exists ::env(ROUTING_CURRENT_DEF) ] } {
        set ::env(ROUTING_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(ROUTING_CURRENT_DEF)
    }
    if { $::env(ECO_ENABLE) == 0 } {
        run_routing
    }
}

proc run_parasitics_sta_step {args} {
    if { ! [ info exists ::env(PARSITICS_CURRENT_DEF) ] } {
        set ::env(PARSITICS_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(PARSITICS_CURRENT_DEF)
    }

    if { $::env(RUN_SPEF_EXTRACTION) && ($::env(ECO_ENABLE) == 0)} {
        run_parasitics_sta
    }
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

proc run_irdrop_report_step {args} {
    if { $::env(RUN_IRDROP_REPORT) } {
        run_irdrop_report
    }
}

proc run_lvs_step {{ lvs_enabled 1 }} {
    if { ! [ info exists ::env(LVS_CURRENT_DEF) ] } {
        set ::env(LVS_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(LVS_CURRENT_DEF)
    }

    if { $lvs_enabled && $::env(RUN_LVS) } {
        run_magic_spice_export;
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
        if { $::env(RUN_MAGIC_DRC) } {
            run_magic_drc
        }
        if {$::env(RUN_KLAYOUT_DRC)} {
            run_klayout_drc
        }
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

proc run_erc_step {args} {
    if { $::env(RUN_CVC) } {
        run_erc
    }
}

proc run_eco_step {args} {
    if { $::env(ECO_ENABLE) == 1 } {
        run_eco_flow
    }
}

proc run_magic_step {args} {
    if {$::env(RUN_MAGIC)} {
        run_magic
    }
}

proc run_klayout_step {args} {
    if {$::env(RUN_KLAYOUT)} {
        run_klayout
    }
    if {$::env(RUN_KLAYOUT_XOR)} {
        run_klayout_gds_xor
    }
}

proc run_post_run_hooks {} {
    if { [file exists $::env(DESIGN_DIR)/hooks/post_run.py]} {
        puts_info "Running post run hook"
        set result [exec $::env(OPENROAD_BIN) -exit -no_init -python $::env(DESIGN_DIR)/hooks/post_run.py]
        puts_info "$result"
    } else {
        puts_info "hooks/post_run.py not found, skipping"
    }
}

proc run_floorplan {args} {
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

    #if { [info exist ::env(EXTRA_LEFS)] } {
        if { [info exist ::env(MACRO_PLACEMENT_CFG)] } {
            file copy -force $::env(MACRO_PLACEMENT_CFG) $::env(placement_tmpfiles)/macro_placement.cfg
            manual_macro_placement -f
        } else {
        #    global_placement_or
        #    basic_macro_placement
        }
    #}

    if { $::env(RUN_TAP_DECAP_INSERTION) } {
        tap_decap_or
    }

    scrot_klayout -layout $::env(CURRENT_DEF) -log $::env(floorplan_logs)/screenshot.log

    run_power_grid_generation
}



proc run_flow {args} {
    set options {
        {-design optional}
        {-from optional}
        {-to optional}
        {-save_path optional}
        {-override_env optional}
    }
    set flags {-save -run_hooks -no_lvs -no_drc -no_antennacheck -gui}
    parse_key_args "run_non_interactive_mode" args arg_values $options flags_map $flags -no_consume

    prep {*}$args
    # signal trap SIGINT save_state;

    if { [info exists flags_map(-gui)] } {
        or_gui
        return
    }
    if { [info exists arg_values(-override_env)] } {
        load_overrides $arg_values(-override_env)
    }

    set LVS_ENABLED 1
    set DRC_ENABLED 1

    set ANTENNACHECK_ENABLED [expr ![info exists flags_map(-no_antennacheck)] ]

    set steps [dict create \
        "synthesis" "run_synthesis" \
        "floorplan" "run_floorplan" \
        "placement" "run_placement_step" \
        "cts" "run_cts_step" \
        "routing" "run_routing_step" \
        "parasitics_sta" "run_parasitics_sta_step" \
        "eco" "run_eco_step" \
        "diode_insertion" "run_diode_insertion_2_5_step" \
        "irdrop" "run_irdrop_report_step" \
        "gds_magic" "run_magic_step" \
        "gds_klayout" "run_klayout_step" \
        "lvs" "run_lvs_step $LVS_ENABLED " \
        "drc" "run_drc_step $DRC_ENABLED " \
        "antenna_check" "run_antenna_check_step $ANTENNACHECK_ENABLED " \
        "cvc" "run_lef_cvc"
    ]

    if { [info exists arg_values(-from) ]} {
        puts_info "Starting flow at $arg_values(-from)..."
        set ::env(CURRENT_STEP) $arg_values(-from)
    } elseif {  [info exists ::env(CURRENT_STEP) ] } {
        puts_info "Resuming flow from $::env(CURRENT_STEP)..."
    } else {
        set ::env(CURRENT_STEP) "synthesis"
    }

    set_if_unset arg_values(-from) $::env(CURRENT_STEP)
    set_if_unset arg_values(-to) "cvc"

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
    save_final_views

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
