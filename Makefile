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

CARAVEL_ROOT?=$(PWD)/caravel
PRECHECK_ROOT?=${HOME}/mpw_precheck
SIM ?= RTL
DUMP ?= OFF

# Install lite version of caravel, (1): caravel-lite, (0): caravel
CARAVEL_LITE?=1

ifeq ($(CARAVEL_LITE),1) 
	CARAVEL_NAME := caravel-lite
	CARAVEL_REPO := https://github.com/efabless/caravel-lite 
	CARAVEL_TAG := 'mpw-5a'
else
	CARAVEL_NAME := caravel
	CARAVEL_REPO := https://github.com/efabless/caravel 
	CARAVEL_TAG := 'mpw-5a'
endif

# Install caravel as submodule, (1): submodule, (0): clone
SUBMODULE?=1

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

# Include Caravel Makefile Targets
.PHONY: % : check-caravel
%: 
	export CARAVEL_ROOT=$(CARAVEL_ROOT) && $(MAKE) -f $(CARAVEL_ROOT)/Makefile $@

# Verify Target for running simulations
.PHONY: verify
verify:
	cd ./verilog/dv/ && \
	export SIM=${SIM} DUMP=${DUMP} && \
		$(MAKE) -j$(THREADS)

# Install DV setup
.PHONY: simenv
simenv:
	docker pull dineshannayya/dv_setup:latest

PATTERNS=$(shell cd verilog/dv && find * -maxdepth 0 -type d)
DV_PATTERNS = $(foreach dv, $(PATTERNS), verify-$(dv))
TARGET_PATH=$(shell pwd)
PDK_PATH=${PDK_ROOT}/sky130A
VERIFY_COMMAND="cd ${TARGET_PATH}/verilog/dv/$* && export SIM=${SIM} DUMP=${DUMP} && make"
$(DV_PATTERNS): verify-% : ./verilog/dv/% check-coremark_repo check-riscv_comp_repo check-riscv_test_repo
	docker run -v ${TARGET_PATH}:${TARGET_PATH} -v ${PDK_PATH}:${PDK_PATH} \
                -v ${CARAVEL_ROOT}:${CARAVEL_ROOT} \
                -e TARGET_PATH=${TARGET_PATH} -e PDK_PATH=${PDK_PATH} \
                -e CARAVEL_ROOT=${CARAVEL_ROOT} \
                -u $(id -u $$USER):$(id -g $$USER) dineshannayya/dv_setup:mpw5 \
                sh -c $(VERIFY_COMMAND)
				
# Openlane Makefile Targets
BLOCKS = $(shell cd openlane && find * -maxdepth 0 -type d)
.PHONY: $(BLOCKS)
$(BLOCKS): %:
	export CARAVEL_ROOT=$(CARAVEL_ROOT) && cd openlane && $(MAKE) $*

# Install caravel
.PHONY: install
install:
ifeq ($(SUBMODULE),1)
	@echo "Installing $(CARAVEL_NAME) as a submodule.."
# Convert CARAVEL_ROOT to relative path because .gitmodules doesn't accept '/'
	$(eval CARAVEL_PATH := $(shell realpath --relative-to=$(shell pwd) $(CARAVEL_ROOT)))
	@if [ ! -d $(CARAVEL_ROOT) ]; then git submodule add --name $(CARAVEL_NAME) $(CARAVEL_REPO) $(CARAVEL_PATH); fi
	@git submodule update --init
	@cd $(CARAVEL_ROOT); git checkout $(CARAVEL_BRANCH)
	$(MAKE) simlink
else
	@echo "Installing $(CARAVEL_NAME).."
	@git clone -b $(CARAVEL_TAG) $(CARAVEL_REPO) $(CARAVEL_ROOT)
endif

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

# Install Openlane
.PHONY: openlane
openlane: 
	cd openlane && $(MAKE) openlane

# Install Pre-check
# Default installs to the user home directory, override by "export PRECHECK_ROOT=<precheck-installation-path>"
.PHONY: precheck
precheck:
	@git clone --depth=1 --branch mpw-5 https://github.com/efabless/mpw_precheck.git $(PRECHECK_ROOT)
	@docker pull efabless/mpw_precheck:mpw5

.PHONY: run-precheck
run-precheck: check-precheck check-pdk check-caravel
	$(eval INPUT_DIRECTORY := $(shell pwd))
	cd $(PRECHECK_ROOT) && \
	docker run -e INPUT_DIRECTORY=$(INPUT_DIRECTORY) -e PDK_ROOT=$(PDK_ROOT) -v $(PRECHECK_ROOT):$(PRECHECK_ROOT) -v $(INPUT_DIRECTORY):$(INPUT_DIRECTORY) -v $(PDK_ROOT):$(PDK_ROOT) \
	-u $(shell id -u $(USER)):$(shell id -g $(USER)) efabless/mpw_precheck:latest bash -c "cd $(PRECHECK_ROOT) ; python3 mpw_precheck.py --pdk_root $(PDK_ROOT) --input_directory $(INPUT_DIRECTORY)"

# Clean 
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

.PHONY: help
help:
	cd $(CARAVEL_ROOT) && $(MAKE) help 
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
