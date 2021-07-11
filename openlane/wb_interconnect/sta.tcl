# SPDX-FileCopyrightText:  2021 , Dinesh Annayya
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
# SPDX-FileContributor: Modified by Dinesh Annayya <dinesha@opencores.org>


set ::env(LIB_FASTEST) "$::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ff_n40C_1v95.lib"
set ::env(LIB_SLOWEST) "$::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ss_100C_1v60.lib"
set ::env(CURRENT_NETLIST) runs/wb_interconnect/results/synthesis/wb_interconnect.synthesis_preroute.v
set ::env(DESIGN_NAME) "wb_interconnect"
set ::env(CURRENT_SPEF) ../../spef/wb_interconnect.spef
set ::env(BASE_SDC_FILE) "base.sdc"
set ::env(SYNTH_DRIVING_CELL) "sky130_fd_sc_hd__inv_8"
set ::env(SYNTH_DRIVING_CELL_PIN) "Y"
set ::env(SYNTH_CAP_LOAD) "17.65"
set ::env(WIRE_RC_LAYER) "met1"


set_cmd_units -time ns -capacitance pF -current mA -voltage V -resistance kOhm -distance um
read_liberty -min $::env(LIB_FASTEST)
read_liberty -max $::env(LIB_SLOWEST)
read_verilog $::env(CURRENT_NETLIST)
link_design  $::env(DESIGN_NAME)

read_spef  $::env(CURRENT_SPEF)

read_sdc -echo $::env(BASE_SDC_FILE)

# check for missing constraints
check_setup  -verbose > unconstraints.rpt

set_operating_conditions -analysis_type single
# Propgate the clock
set_propagated_clock [all_clocks]

report_tns
report_wns
report_power 
report_checks -unique -slack_max -0.0 -group_count 100 
report_checks -unique -slack_min -0.0 -group_count 100 
report_checks -path_delay min_max 
report_checks -group_count 100  -slack_max -0.01  > timing.rpt

report_checks -group_count 100  -slack_min -0.01 >> timing.rpt


