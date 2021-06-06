#------------------------------------------------------------------------------
# Makefile for Synthesis
#------------------------------------------------------------------------------

# Paths
export ROOT_DIR := $(shell pwd)
export DESIGN_FILE  := $(ROOT_DIR)/pyfive.sv
export SYNTH_LOG    := $(ROOT_DIR)/synth.log
export REPORT_DIR  := $(ROOT_DIR)/reports
export NETLIST_DIR  := $(ROOT_DIR)/netlist
export TMP_DIR  := $(ROOT_DIR)/tmp


# Targets
.PHONY: clean create merge synth

default: clean create merge synth

synth: clean create merge 
	yosys -g -c synth.tcl -l synth.log

create:
	mkdir -p ./tmp/synthesis; 
	mkdir -p ./reports; 
	mkdir -p ./netlist;
	$(OPENLANE_ROOT)/scripts/libtrim.pl $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib $(PDK_ROOT)/sky130A/libs.tech/openlane/sky130_fd_sc_hd/no_synth.cells > ./tmp/trimmed.lib

merge: 
	################################################ 
	# yosys has issue in propgating the golbal parameter from one file to other file 
	# to fix this issue, we have concatinated all the rtl file into single file before starting synthesis 
	# only memory are exclded from this list 
	# ################################################
	cat ../src/core/pipeline/scr1_pipe_top.sv > pyfive.sv; 
	cat ../src/core/scr1_core_top.sv >> pyfive.sv; 
	cat ../src/core/scr1_dm.sv >> pyfive.sv; 
	cat ../src/core/scr1_tapc_synchronizer.sv >> pyfive.sv; 
	cat ../src/core/scr1_clk_ctrl.sv >> pyfive.sv; 
	cat ../src/core/scr1_scu.sv >> pyfive.sv; 
	cat ../src/core/scr1_tapc.sv >> pyfive.sv; 
	cat ../src/core/scr1_tapc_shift_reg.sv >> pyfive.sv; 
	cat ../src/core/scr1_dmi.sv >> pyfive.sv; 
	cat ../src/core/primitives/scr1_reset_cells.sv >> pyfive.sv; 
	cat ../src/core/pipeline/scr1_pipe_ifu.sv >> pyfive.sv; 
	cat ../src/core/pipeline/scr1_pipe_idu.sv >> pyfive.sv; 
	cat ../src/core/pipeline/scr1_pipe_exu.sv >> pyfive.sv; 
	cat ../src/core/pipeline/scr1_pipe_mprf.sv >> pyfive.sv; 
	cat ../src/core/pipeline/scr1_pipe_csr.sv >> pyfive.sv; 
	cat ../src/core/pipeline/scr1_pipe_ialu.sv >> pyfive.sv; 
	cat ../src/core/pipeline/scr1_pipe_lsu.sv >> pyfive.sv; 
	cat ../src/core/pipeline/scr1_pipe_hdu.sv >> pyfive.sv; 
	cat ../src/core/pipeline/scr1_pipe_tdu.sv >> pyfive.sv; 
	cat ../src/core/pipeline/scr1_ipic.sv >> pyfive.sv; 
	cat ../src/top/scr1_dmem_router.sv >> pyfive.sv; 
	cat ../src/top/scr1_imem_router.sv >> pyfive.sv; 
	#cat ../src/top/scr1_dp_memory.sv >> pyfive.sv; 
	cat ../src/top/scr1_tcm.sv >> pyfive.sv; 
	cat ../src/top/scr1_timer.sv >> pyfive.sv; 
	#cat ../src/top/scr1_dmem_ahb.sv >> pyfive.sv; 
	#cat ../src/top/scr1_imem_ahb.sv >> pyfive.sv; 
	cat ../src/top/scr1_top_axi.sv >> pyfive.sv; 
	cat ../src/top/scr1_mem_axi.sv>> pyfive.sv;



clean:
	$(RM) $(DESIGN_FILE)
	$(RM) $(SYNTH_LOG)
	$(RM) -R $(REPORT_DIR)
	$(RM) -R $(NETLIST_DIR)
	$(RM) -R $(TMP_DIR)
