# //////////////////////////////////////////////////////////////////////////////
# // SPDX-FileCopyrightText: 2021, Dinesh Annayya
# // 
# // Licensed under the Apache License, Version 2.0 (the "License");
# // you may not use this file except in compliance with the License.
# // You may obtain a copy of the License at
# //
# //      http://www.apache.org/licenses/LICENSE-2.0
# //
# // Unless required by applicable law or agreed to in writing, software
# // distributed under the License is distributed on an "AS IS" BASIS,
# // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# // See the License for the specific language governing permissions and
# // limitations under the License.
# // SPDX-License-Identifier: Apache-2.0
# // SPDX-FileContributor: Dinesh Annayya <dinesha@opencores.org>
# // //////////////////////////////////////////////////////////////////////////
#------------------------------------------------------------------------------
# Makefile for Synthesis
#------------------------------------------------------------------------------

# Paths
export ROOT_DIR := $(shell pwd)
export REPORT_DIR  := $(ROOT_DIR)/reports
export NETLIST_DIR  := $(ROOT_DIR)/netlist
export TMP_DIR  := $(ROOT_DIR)/tmp


# Targets
.PHONY: clean create synth

default: clean create synth

synth: clean create 
	yosys -g -c synth.tcl -l synth.log

create:
	mkdir -p ./tmp/synthesis; 
	mkdir -p ./reports; 
	mkdir -p ./netlist;
	$(OPENLANE_ROOT)/scripts/libtrim.pl $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib $(PDK_ROOT)/sky130A/libs.tech/openlane/sky130_fd_sc_hd/no_synth.cells > ./tmp/trimmed.lib
	#create No PG Pin library for hand instantiated cells
	sed '/pg_pin.*/a \         direction : "inout";'  $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib  > ./tmp/sky130_fd_sc_hd__tt_025C_1v80.no_pg.lib
	sed -i 's/pg_pin/pin/' ./tmp/sky130_fd_sc_hd__tt_025C_1v80.no_pg.lib



clean:
	$(RM) -R synth.log
	$(RM) -R $(REPORT_DIR)
	$(RM) -R $(NETLIST_DIR)
	$(RM) -R $(TMP_DIR)
