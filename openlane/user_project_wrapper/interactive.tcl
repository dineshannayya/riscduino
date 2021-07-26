#!/usr/bin/tclsh
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


package require openlane;

proc run_floorplan_yifive {args} {
		puts_info "Running Floorplanning for yifive..."
		# |----------------------------------------------------|
		# |----------------   2. FLOORPLAN   ------------------|
		# |----------------------------------------------------|
		#
                set script_dir [file dirname [file normalize [info script]]]
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
		puts_info "Running pdn_gen for yifive..."
		# power grid generation
		#run_power_grid_generation
		set ::env(SAVE_DEF) [index_file $::env(pdn_tmp_file_tag).def]
		try_catch openroad -exit $script_dir/gen_pdn.tcl \
           	|& tee $::env(TERMINAL_OUTPUT) [index_file $::env(pdn_log_file_tag).log 0]

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

	# generate multiple power grids per pair of (VDD,GND)
	# offseted by WIDTH + SPACING
	foreach vdd $::env(VDD_NETS) gnd $::env(GND_NETS) {
		set ::env(VDD_NET) $vdd
		set ::env(GND_NET) $gnd

		gen_pdn

		set ::env(FP_PDN_ENABLE_RAILS) 0

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
	}
	set ::env(FP_PDN_ENABLE_RAILS) 1
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

	run_synthesis
	run_floorplan_yifive
	run_placement
	run_cts
	run_routing

	if { ($::env(DIODE_INSERTION_STRATEGY) == 2) || ($::env(DIODE_INSERTION_STRATEGY) == 5) } {
		run_antenna_check
		heal_antenna_violators; # modifies the routed DEF
	}

    if { $::env(LVS_INSERT_POWER_PINS) } {
		write_powered_verilog
		set_netlist $::env(lvs_result_file_tag).powered.v
    }

	run_magic

	run_klayout

	run_klayout_gds_xor

	if { ! [info exists flags_map(-no_lvs)] } {
		run_magic_spice_export
	}

	if {  [info exists flags_map(-save) ] } {
		if { ! [info exists arg_values(-save_path)] } {
			set arg_values(-save_path) ""
		}
		save_views 	-lef_path $::env(magic_result_file_tag).lef \
			-def_path $::env(tritonRoute_result_file_tag).def \
			-gds_path $::env(magic_result_file_tag).gds \
			-mag_path $::env(magic_result_file_tag).mag \
			-maglef_path $::env(magic_result_file_tag).lef.mag \
			-spice_path $::env(magic_result_file_tag).spice \
			-spef_path $::env(tritonRoute_result_file_tag).spef \
			-verilog_path $::env(CURRENT_NETLIST) \
			-save_path $arg_values(-save_path) \
			-tag $::env(RUN_TAG)
	}

	# Physical verification
	if { ! [info exists flags_map(-no_lvs)] } {
		run_lvs; # requires run_magic_spice_export
	}

	if { ! [info exists flags_map(-no_drc)] } {
		run_magic_drc
		run_klayout_drc
	}

	if {  ! [info exists flags_map(-no_antennacheck) ] } {
		run_antenna_check
	}

	run_lef_cvc

	calc_total_runtime
	generate_final_summary_report

	puts_success "Flow Completed Without Fatal Errors."

}

run_flow {*}$argv
