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

## Caravel Pointers
CARAVEL_ROOT ?= ../../../caravel
CARAVEL_PATH ?= $(CARAVEL_ROOT)
CARAVEL_FIRMWARE_PATH = $(CARAVEL_PATH)/verilog/dv/caravel
CARAVEL_VERILOG_PATH  = $(CARAVEL_PATH)/verilog
CARAVEL_RTL_PATH = $(CARAVEL_VERILOG_PATH)/rtl
CARAVEL_BEHAVIOURAL_MODELS = $(CARAVEL_VERILOG_PATH)/dv/caravel


## User Project Pointers
UPRJ_VERILOG_PATH ?= ../../../verilog
UPRJ_RTL_PATH = $(UPRJ_VERILOG_PATH)/rtl
UPRJ_GL_PATH = $(UPRJ_VERILOG_PATH)/gl
UPRJ_BEHAVIOURAL_MODELS = ../model
UPRJ_BEHAVIOURAL_AGENTS = ../agents
UPRJ_INCLUDE_PATH1 = $(UPRJ_RTL_PATH)/yifive/ycr1c/src/includes
UPRJ_INCLUDE_PATH2 = $(UPRJ_RTL_PATH)/sdram_ctrl/src/defs
UPRJ_INCLUDE_PATH3 = $(UPRJ_RTL_PATH)/i2cm/src/includes
UPRJ_INCLUDE_PATH4 = $(UPRJ_RTL_PATH)/usb1_host/src/includes
UPRJ_INCLUDE_PATH5 = $(UPRJ_RTL_PATH)/mbist/include

## YIFIVE FIRMWARE
YIFIVE_FIRMWARE_PATH = $(UPRJ_VERILOG_PATH)/dv/firmware
GCC64_PREFIX?=riscv64-unknown-elf

## RISCV GCC 
GCC_PATH?=/ef/apps/bin
GCC_PREFIX?=riscv32-unknown-elf
PDK_PATH?=/ef/tech/SW/sky130A

## Simulation mode: RTL/GL
SIM?=RTL
DUMP?=OFF

.SUFFIXES:

PATTERN = user_spi

all:  ${PATTERN:=.vcd}


vvp:  ${PATTERN:=.vvp}

%.vvp: %_tb.v
ifeq ($(SIM),RTL)
   ifeq ($(DUMP),OFF)
	iverilog -g2005-sv -DFUNCTIONAL -DSIM -I $(PDK_PATH) \
	-I $(CARAVEL_BEHAVIOURAL_MODELS) -I $(CARAVEL_RTL_PATH) \
	-I $(UPRJ_BEHAVIOURAL_MODELS)    -I $(UPRJ_RTL_PATH) -I $(UPRJ_VERILOG_PATH) \
	-I $(UPRJ_BEHAVIOURAL_AGENTS)    \
	-I $(UPRJ_INCLUDE_PATH1)    -I $(UPRJ_INCLUDE_PATH2) -I $(UPRJ_INCLUDE_PATH3) \
	-I $(UPRJ_INCLUDE_PATH4) -I $(UPRJ_INCLUDE_PATH5) \
	$< -o $@ 
    else  
	iverilog -g2005-sv -DWFDUMP -DFUNCTIONAL -DSIM -I $(PDK_PATH) \
	-I $(CARAVEL_BEHAVIOURAL_MODELS) -I $(CARAVEL_RTL_PATH) \
	-I $(UPRJ_BEHAVIOURAL_MODELS)    -I $(UPRJ_RTL_PATH) -I $(UPRJ_VERILOG_PATH) \
	-I $(UPRJ_BEHAVIOURAL_AGENTS)    \
	-I $(UPRJ_INCLUDE_PATH1)    -I $(UPRJ_INCLUDE_PATH2) -I $(UPRJ_INCLUDE_PATH3) \
	-I $(UPRJ_INCLUDE_PATH4) -I $(UPRJ_INCLUDE_PATH5) \
	$< -o $@ 
   endif
else  
	iverilog -g2005-sv -DFUNCTIONAL -DSIM -DGL -I $(PDK_PATH) \
	-I $(CARAVEL_BEHAVIOURAL_MODELS) -I $(CARAVEL_RTL_PATH) -I $(CARAVEL_VERILOG_PATH) \
	-I $(UPRJ_BEHAVIOURAL_MODELS) -I $(UPRJ_GL_PATH) \
	-I $(UPRJ_BEHAVIOURAL_AGENTS)    \
	$< -o $@ 
endif

%.vcd: %.vvp
	vvp $<

%.hex: 
	echo @"This is user boot test, noting to compile the mangment core code"


# ---- Clean ----

clean:
	rm -f *.vvp *.vcd *.log *.fst

.PHONY: clean hex all
