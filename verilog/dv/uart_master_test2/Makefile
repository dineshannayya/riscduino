# SPDX-FileCopyrightText: 2020 Efabless Corporation
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
#
# SPDX-License-Identifier: Apache-2.0


 
PWDD := $(shell pwd)
BLOCKS := $(shell basename $(PWDD))

# ---- Include Partitioned Makefiles ----

DESIGNS?=../../..
CONFIG = caravel_user_project
TOOLS?=/opt/riscv32i/

########################################################
#include $(MCW_ROOT)/verilog/dv/make/env.makefile
########################################################
#######################################################################
## Global Environment Variables for local repo  
#######################################################################

export PDK_PATH =      $(PDK_ROOT)/sky130A
export VIP_PATH =      $(CORE_VERILOG_PATH)/dv/vip
export FIRMWARE_PATH = $(CORE_VERILOG_PATH)/dv/firmware

#######################################################################
## Caravel Verilog for Integration Tests
#######################################################################

export CARAVEL_VERILOG_PATH ?=  $(CARAVEL_ROOT)/verilog
export CORE_VERILOG_PATH    ?=  $(CARAVEL_ROOT)/mgmt_core_wrapper/verilog
export USER_PROJECT_VERILOG ?=  $(DESIGNS)/verilog

export CARAVEL_PATH = $(CARAVEL_VERILOG_PATH)
export VERILOG_PATH = $(CORE_VERILOG_PATH)

#######################################################################
## Compiler Information 
#######################################################################

export TOOLS     ?=  /opt/riscv32i 
export GCC_PATH  ?=  $(TOOLS)/bin
GCC_PREFIX?=riscv32-unknown-elf








########################################################
#include $(MCW_ROOT)/verilog/dv/make/var.makefile
########################################################

CPU=vexriscv
CPUFAMILY=riscv
CPUFLAGS=-march=rv32i      -mabi=ilp32 -D__vexriscv__
CPUENDIANNESS=little
CLANG=0


######################################################
# include $(MCW_ROOT)/verilog/dv/make/cpu.makefile
######################################################

ifeq ($(CPU),picorv32)
	LINKER_SCRIPT=$(FIRMWARE_PATH)/sections.lds
	SOURCE_FILES=$(FIRMWARE_PATH)/start.s 
	VERILOG_FILES=
endif

ifeq ($(CPU),ibex)
	LINKER_SCRIPT=$(FIRMWARE_PATH)/link_ibex.ld
	SOURCE_FILES=$(FIRMWARE_PATH)/crt0_ibex.S $(FIRMWARE_PATH)/simple_system_common.c
# 	VERILOG_FILES=../ibex/*
	VERILOG_FILES=
endif

ifeq ($(CPU),vexriscv)
# 	LINKER_SCRIPT=$(FIRMWARE_PATH)/sections_vexriscv.lds
# 	SOURCE_FILES=$(FIRMWARE_PATH)/start_caravel_vexriscv.s
	LINKER_SCRIPT=$(FIRMWARE_PATH)/sections.lds
	SOURCE_FILES=$(FIRMWARE_PATH)/crt0_vex.S $(FIRMWARE_PATH)/isr.c
	VERILOG_FILES=
endif



#####################################################
#include $(MCW_ROOT)/verilog/dv/make/sim.makefile
######################################################

export IVERILOG_DUMPER = fst

# RTL/GL/GL_SDF
SIM?=RTL
DUMP?=OFF


.SUFFIXES:


all:  ${BLOCKS:=.vcd} ${BLOCKS:=.vvp}


#.SUFFIXES:

	
##############################################################################
# Runing the simulations
##############################################################################

%.vvp: %_tb.v 

## RTL
ifeq ($(SIM),RTL)
   ifeq ($(DUMP),OFF)
	iverilog -g2005-sv -Ttyp -DFUNCTIONAL -DSIM -DUSE_POWER_PINS -DUNIT_DELAY=#0.1 \
        -f$(USER_PROJECT_VERILOG)/includes/includes.rtl.$(CONFIG) \
        -f$(VERILOG_PATH)/includes/includes.rtl.caravel \
        -o $@ $<
    else  
	iverilog -g2005-sv -DWFDUMP -Ttyp -DFUNCTIONAL -DSIM -DUSE_POWER_PINS -DUNIT_DELAY=#0.1 \
        -f$(USER_PROJECT_VERILOG)/includes/includes.rtl.$(CONFIG) \
        -f$(VERILOG_PATH)/includes/includes.rtl.caravel \
        -o $@ $<
   endif
endif

##GL
ifeq ($(SIM),GL)
   ifeq ($(DUMP),OFF)
	iverilog -Ttyp -DFUNCTIONAL -DGL -DUSE_POWER_PINS -DUNIT_DELAY=#0.1 \
        -f$(VERILOG_PATH)/includes/includes.gl.caravel \
        -f$(USER_PROJECT_VERILOG)/includes/includes.gl.$(CONFIG) -o $@ $<
    else
	iverilog -Ttyp -DWFDUMP -DFUNCTIONAL -DGL -DUSE_POWER_PINS -DUNIT_DELAY=#0.1 \
        -f$(VERILOG_PATH)/includes/includes.gl.caravel \
        -f$(USER_PROJECT_VERILOG)/includes/includes.gl.$(CONFIG) -o $@ $<
    endif
endif 

## GL+SDF
ifeq ($(SIM),GL_SDF)
    ifeq ($(CONFIG),caravel_user_project)
		cvc64  +interp \
		+define+SIM +define+FUNCTIONAL +define+GL +define+USE_POWER_PINS +define+UNIT_DELAY +define+ENABLE_SDF \
		+change_port_type +dump2fst +fst+parallel2=on   +nointeractive +notimingchecks +mipdopt \
		-f $(VERILOG_PATH)/includes/includes.gl+sdf.caravel \
		-f $(USER_PROJECT_VERILOG)/includes/includes.gl+sdf.$(CONFIG) $<
	else
		cvc64  +interp \
		+define+SIM +define+FUNCTIONAL +define+GL +define+USE_POWER_PINS +define+UNIT_DELAY +define+ENABLE_SDF \
		+change_port_type +dump2fst +fst+parallel2=on   +nointeractive +notimingchecks +mipdopt \
		-f $(VERILOG_PATH)/includes/includes.gl+sdf.$(CONFIG) \
		-f $CARAVEL_PATH/gl/__user_project_wrapper.v $<
    endif
endif

%.vcd: %.vvp
	vvp  $<

# twinwave: RTL-%.vcd GL-%.vcd
#     twinwave RTL-$@ * + GL-$@ *

check-env:
ifndef PDK_ROOT
	$(error PDK_ROOT is undefined, please export it before running make)
endif
ifeq (,$(wildcard $(PDK_ROOT)/sky130A))
	$(error $(PDK_ROOT)/sky130A not found, please install pdk before running make)
endif
ifeq (,$(wildcard $(GCC_PREFIX)-gcc ))
	$(error $(GCC_PREFIX)-gcc is not found, please export GCC_PATH and GCC_PREFIX before running make)
endif
# check for efabless style installation
ifeq (,$(wildcard $(PDK_ROOT)/sky130A/libs.ref/*/verilog))
SIM_DEFINES := ${SIM_DEFINES} -DEF_STYLE
endif


# ---- Clean ----

clean:
	\rm  -f *.elf *.hex *.bin *.vvp *.log *.vcd *.lst *.hexe

.PHONY: clean hex all






