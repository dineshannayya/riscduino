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
MAKEFLAGS+=--warn-undefined-variables

export CARAVEL_ROOT?=$(PWD)/caravel
PRECHECK_ROOT?=${HOME}/mpw_precheck
export MCW_ROOT?=$(PWD)/mgmt_core_wrapper
SIM?=RTL
DUMP?=OFF
RISC_CORE ?=0

# Install lite version of caravel, (1): caravel-lite, (0): caravel
CARAVEL_LITE?=1

# PDK switch varient
export PDK?=sky130A
#export PDK?=gf180mcuC
export PDKPATH?=$(PDK_ROOT)/$(PDK)



ifeq ($(PDK),sky130A)
	SKYWATER_COMMIT=f70d8ca46961ff92719d8870a18a076370b85f6c
	export OPEN_PDKS_COMMIT?=0059588eebfc704681dc2368bd1d33d96281d10f
	export OPENLANE_TAG?=2022.10.20
	MPW_TAG ?= mpw-7g

ifeq ($(CARAVEL_LITE),1)
	CARAVEL_NAME := caravel-lite
	CARAVEL_REPO := https://github.com/efabless/caravel-lite
	CARAVEL_TAG := $(MPW_TAG)
else
	CARAVEL_NAME := caravel
	CARAVEL_REPO := https://github.com/efabless/caravel
	CARAVEL_TAG := $(MPW_TAG)
endif

endif

#RISCV COMPLIANCE test Environment
COREMARK_DIR   = verilog/dv/riscv_regress/dependencies/coremark
RISCV_COMP_DIR = verilog/dv/riscv_regress/dependencies/riscv-compliance
RISCV_TEST_DIR = verilog/dv/riscv_regress/dependencies/riscv-tests

COREMARK_REPO   =  https://github.com/eembc/coremark
RISCV_COMP_REPO =  https://github.com/riscv/riscv-compliance
RISCV_TEST_REPO =  https://github.com/riscv/riscv-tests

COREMARK_BRANCH   =  7f420b6bdbff436810ef75381059944e2b0d79e8
RISCV_COMP_BRANCH =  d51259b2a949be3af02e776c39e135402675ac9b
RISCV_TEST_BRANCH =  e30978a71921159aec38eeefd848fca4ed39a826

ifeq ($(PDK),sky130B)
	SKYWATER_COMMIT=f70d8ca46961ff92719d8870a18a076370b85f6c
	export OPEN_PDKS_COMMIT?=0059588eebfc704681dc2368bd1d33d96281d10f
	export OPENLANE_TAG?=2022.10.20
	MPW_TAG ?= mpw-7g

ifeq ($(CARAVEL_LITE),1)
	CARAVEL_NAME := caravel-lite
	CARAVEL_REPO := https://github.com/efabless/caravel-lite
	CARAVEL_TAG := $(MPW_TAG)
else
	CARAVEL_NAME := caravel
	CARAVEL_REPO := https://github.com/efabless/caravel
	CARAVEL_TAG := $(MPW_TAG)
endif

endif

ifeq ($(PDK),gf180mcuC)

	MPW_TAG ?= gfmpw-0a
	CARAVEL_NAME := caravel
	CARAVEL_REPO := https://github.com/efabless/caravel-gf180mcu
	CARAVEL_TAG := $(MPW_TAG)
	#OPENLANE_TAG=ddfeab57e3e8769ea3d40dda12be0460e09bb6d9
	export OPEN_PDKS_COMMIT?=0059588eebfc704681dc2368bd1d33d96281d10f
	export OPENLANE_TAG?=2022.11.17

endif

# Include Caravel Makefile Targets
.PHONY: % : check-caravel
%:
	export CARAVEL_ROOT=$(CARAVEL_ROOT) && $(MAKE) -f $(CARAVEL_ROOT)/Makefile $@

.PHONY: install
install:
	if [ -d "$(CARAVEL_ROOT)" ]; then\
		echo "Deleting exisiting $(CARAVEL_ROOT)" && \
		rm -rf $(CARAVEL_ROOT) && sleep 2;\
	fi
	echo "Installing $(CARAVEL_NAME).."
	git clone -b $(CARAVEL_TAG) $(CARAVEL_REPO) $(CARAVEL_ROOT) --depth=1

# Install DV setup
.PHONY: simenv
simenv:
	docker pull riscduino/dv_setup:latest

.PHONY: setup
setup: install check-env install_mcw openlane pdk-with-volare setup-timing-scripts

# Openlane
blocks=$(shell cd openlane && find * -maxdepth 0 -type d)
.PHONY: $(blocks)
$(blocks): % :
	$(MAKE) -C openlane $*


PATTERNS=$(shell cd verilog/dv && find * -maxdepth 0 -type d)
DV_PATTERNS = $(foreach dv, $(PATTERNS), verify-$(dv))
TARGET_PATH=$(shell pwd)
verify_command="cd ${TARGET_PATH}/verilog/dv/$* && export SIM=${SIM} DUMP=${DUMP} RISC_CORE=${RISC_CORE} && make"
$(DV_PATTERNS): verify-% : ./verilog/dv/%  check-coremark_repo check-riscv_comp_repo check-riscv_test_repo
	docker run -v ${TARGET_PATH}:${TARGET_PATH} \
		-e TARGET_PATH=${TARGET_PATH} \
		-e TOOLS=/opt/riscv32i \
		-e DESIGNS=$(TARGET_PATH) \
		-e GCC_PREFIX=riscv32-unknown-elf \
		-u $$(id -u $$USER):$$(id -g $$USER) riscduino/dv_setup:latest \
		sh -c $(verify_command)


.PHONY: verify
verify: 
	cd ./verilog/dv/ && \
	export SIM=${SIM} DUMP=${DUMP} && \
		$(MAKE) -j$(THREADS)


# Install Openlane
.PHONY: openlane
openlane:
	@if [ "$$(realpath $${OPENLANE_ROOT})" = "$$(realpath $$(pwd)/openlane)" ]; then\
		echo "OPENLANE_ROOT is set to '$$(pwd)/openlane' which contains openlane config files"; \
		echo "Please set it to a different directory"; \
		exit 1; \
	fi
	cd openlane && $(MAKE) openlane

#### Not sure if the targets following are of any use

# Create symbolic links to caravel's main files
.PHONY: simlink
simlink: check-caravel
### Symbolic links relative path to $CARAVEL_ROOT
	$(eval MAKEFILE_PATH := $(shell realpath --relative-to=openlane $(CARAVEL_ROOT)/openlane/Makefile))
	$(eval PIN_CFG_PATH  := $(shell realpath --relative-to=openlane/user_project_wrapper $(CARAVEL_ROOT)/openlane/user_project_wrapper_empty/pin_order.cfg))
	mkdir -p openlane
	mkdir -p openlane/user_project_wrapper
	cd openlane &&\
	ln -sf $(MAKEFILE_PATH) Makefile
	cd openlane/user_project_wrapper &&\
	ln -sf $(PIN_CFG_PATH) pin_order.cfg

# Update Caravel
.PHONY: update_caravel
update_caravel: check-caravel
	cd $(CARAVEL_ROOT)/ && git checkout $(CARAVEL_TAG) && git pull

# Uninstall Caravel
.PHONY: uninstall
uninstall:
	rm -rf $(CARAVEL_ROOT)


# Install Pre-check
# Default installs to the user home directory, override by "export PRECHECK_ROOT=<precheck-installation-path>"
.PHONY: precheck
precheck:
	@git clone --depth=1 --branch $(MPW_TAG) https://github.com/efabless/mpw_precheck.git $(PRECHECK_ROOT)
	@docker pull efabless/mpw_precheck:latest

.PHONY: run-precheck
run-precheck: check-pdk check-precheck
	$(eval INPUT_DIRECTORY := $(shell pwd))
	cd $(PRECHECK_ROOT) && \
	docker run -v $(PRECHECK_ROOT):$(PRECHECK_ROOT) \
	-v $(INPUT_DIRECTORY):$(INPUT_DIRECTORY) \
	-v $(PDK_ROOT):$(PDK_ROOT) \
	-e INPUT_DIRECTORY=$(INPUT_DIRECTORY) \
	-e PDK_PATH=$(PDK_ROOT)/$(PDK) \
	-e PDK_ROOT=$(PDK_ROOT) \
	-e PDKPATH=$(PDKPATH) \
	-u $(shell id -u $(USER)):$(shell id -g $(USER)) \
	efabless/mpw_precheck:latest bash -c "cd $(PRECHECK_ROOT) ; python3 mpw_precheck.py --input_directory $(INPUT_DIRECTORY) --pdk_path $(PDK_ROOT)/$(PDK)"



.PHONY: clean
clean:
	cd ./verilog/dv/ && \
		$(MAKE) -j$(THREADS) clean

check-caravel:
	@if [ ! -d "$(CARAVEL_ROOT)" ]; then \
		echo "Caravel Root: "$(CARAVEL_ROOT)" doesn't exists, please export the correct path before running make. "; \
		exit 1; \
	fi

check-precheck:
	@if [ ! -d "$(PRECHECK_ROOT)" ]; then \
		echo "Pre-check Root: "$(PRECHECK_ROOT)" doesn't exists, please export the correct path before running make. "; \
		exit 1; \
	fi

check-pdk:
	@if [ ! -d "$(PDK_ROOT)" ]; then \
		echo "PDK Root: "$(PDK_ROOT)" doesn't exists, please export the correct path before running make. "; \
		exit 1; \
	fi

check-coremark_repo:
	@if [ ! -d "$(COREMARK_DIR)" ]; then \
		echo "Installing Core Mark Repo.."; \
		git clone $(COREMARK_REPO) $(COREMARK_DIR); \
		cd $(COREMARK_DIR); git checkout $(COREMARK_BRANCH); \
	fi

check-riscv_comp_repo:
	@if [ ! -d "$(RISCV_COMP_DIR)" ]; then \
		echo "Installing Risc V Complance Repo.."; \
		git clone $(RISCV_COMP_REPO) $(RISCV_COMP_DIR); \
		cd $(RISCV_COMP_DIR); git checkout $(RISCV_COMP_BRANCH); \
	fi

check-riscv_test_repo:
	@if [ ! -d "$(RISCV_TEST_DIR)" ]; then \
		echo "Installing RiscV Test Repo.."; \
		git clone $(RISCV_TEST_REPO) $(RISCV_TEST_DIR); \
		cd $(RISCV_TEST_DIR); git checkout $(RISCV_TEST_BRANCH); \
	fi

zip:
	gzip -f -r lef/*
	gzip -f -r gds/*
	gzip -f -r spef/*
	gzip -f -r spi/lvs/*
	gzip -f -r verilog/gl/*

unzip:
	gzip -d -r lef/*
	gzip -d -r gds/*
	gzip -d -r spef/*
	gzip -d -r spi/lvs/*
	gzip -d -r verilog/gl/*

.PHONY: help
help:
	cd $(CARAVEL_ROOT) && $(MAKE) help
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'


export CUP_ROOT=$(shell pwd)
export TIMING_ROOT?=$(shell pwd)/deps/timing-scripts
export PROJECT_ROOT=$(CUP_ROOT)
timing-scripts-repo=https://github.com/efabless/timing-scripts.git

$(TIMING_ROOT):
	@mkdir -p $(CUP_ROOT)/deps
	@git clone $(timing-scripts-repo) $(TIMING_ROOT)

.PHONY: setup-timing-scripts
setup-timing-scripts: $(TIMING_ROOT)
	@( cd $(TIMING_ROOT) && git pull )
	@#( cd $(TIMING_ROOT) && git fetch && git checkout $(MPW_TAG); )
	@python3 -m venv ./venv 
		. ./venv/bin/activate && \
		python3 -m pip install --upgrade pip && \
		python3 -m pip install -r $(TIMING_ROOT)/requirements.txt && \
		deactivate

./verilog/gl/user_project_wrapper.v:
	$(error you don't have $@)

./env/spef-mapping.tcl: 
	@echo "run the following:"
	@echo "make extract-parasitics"
	@echo "make create-spef-mapping"
	exit 1

.PHONY: create-spef-mapping
create-spef-mapping: ./verilog/gl/user_project_wrapper.v
	@. ./venv/bin/activate && \
		python3 $(TIMING_ROOT)/scripts/generate_spef_mapping.py \
			-i ./verilog/gl/user_project_wrapper.v \
			-o ./env/spef-mapping.tcl \
			--pdk-path $(PDK_ROOT)/$(PDK) \
			--macro-parent mprj \
			--project-root "$(CUP_ROOT)" && \
		deactivate

.PHONY: extract-parasitics
extract-parasitics: ./verilog/gl/user_project_wrapper.v
	@. ./venv/bin/activate && \
		python3 $(TIMING_ROOT)/scripts/get_macros.py \
		-i ./verilog/gl/user_project_wrapper.v \
		-o ./tmp-macros-list \
		--project-root "$(CUP_ROOT)" \
		--pdk-path $(PDK_ROOT)/$(PDK) && \
		deactivate
		@cat ./tmp-macros-list | cut -d " " -f2 \
			| xargs -I % bash -c "$(MAKE) -C $(TIMING_ROOT) \
				-f $(TIMING_ROOT)/timing.mk rcx-% || echo 'Cannot extract %. Probably no def for this macro'"
	@$(MAKE) -C $(TIMING_ROOT) -f $(TIMING_ROOT)/timing.mk rcx-user_project_wrapper
	@cat ./tmp-macros-list
	@rm ./tmp-macros-list
	
.PHONY: caravel-sta
caravel-sta: ./env/spef-mapping.tcl
	@$(MAKE) -C $(TIMING_ROOT) -f $(TIMING_ROOT)/timing.mk caravel-timing-typ
	@$(MAKE) -C $(TIMING_ROOT) -f $(TIMING_ROOT)/timing.mk caravel-timing-fast
	@$(MAKE) -C $(TIMING_ROOT) -f $(TIMING_ROOT)/timing.mk caravel-timing-slow
	@echo "You can find results for all corners in $(CUP_ROOT)/signoff/caravel/openlane-signoff/timing/"

#Added by Dinesh-A for Klayout Based DRC check
.PHONY: run-drc
run-drc: 
	@echo "run kalyout DRC checks"
	mkdir -p signoff/user_project_wrapper/openlane-signoff/drc
	docker run -ti --rm  -v $(PROJECT_ROOT):/project riscduino/openlane:mpw7  sh -c "cd /project && ./scripts/klayout_drc.sh user_project_wrapper "

