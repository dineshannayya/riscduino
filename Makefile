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

CARAVEL_ROOT?=$(PWD)/caravel
PRECHECK_ROOT?=${HOME}/mpw_precheck
MCW_ROOT?=$(PWD)/mgmt_core_wrapper
SIM?=RTL
DUMP?=OFF
RISC_CORE ?=0

export SKYWATER_COMMIT=c094b6e83a4f9298e47f696ec5a7fd53535ec5eb
export OPEN_PDKS_COMMIT=7519dfb04400f224f140749cda44ee7de6f5e095
export PDK_MAGIC_COMMIT=7d601628e4e05fd17fcb80c3552dacb64e9f6e7b
export OPENLANE_TAG=2022.02.23_02.50.41

# Install lite version of caravel, (1): caravel-lite, (0): caravel
CARAVEL_LITE?=1

MPW_TAG ?= mpw-5c

ifeq ($(CARAVEL_LITE),1)
	CARAVEL_NAME := caravel-lite
	CARAVEL_REPO := https://github.com/efabless/caravel-lite
	CARAVEL_TAG := $(MPW_TAG)
else
	CARAVEL_NAME := caravel
	CARAVEL_REPO := https://github.com/efabless/caravel
	CARAVEL_TAG := $(MPW_TAG)
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
	docker pull riscduino/dv_setup:mpw6

.PHONY: setup
setup: install check-env install_mcw pdk openlane

# Openlane
blocks=$(shell cd openlane && find * -maxdepth 0 -type d)
.PHONY: $(blocks)
$(blocks): % :
	export CARAVEL_ROOT=$(CARAVEL_ROOT) && cd openlane && $(MAKE) $*


PATTERNS=$(shell cd verilog/dv && find * -maxdepth 0 -type d)
DV_PATTERNS = $(foreach dv, $(PATTERNS), verify-$(dv))
TARGET_PATH=$(shell pwd)
verify_command="cd ${TARGET_PATH}/verilog/dv/$* && export SIM=${SIM} DUMP=${DUMP} RISC_CORE=${RISC_CORE} && make"
$(DV_PATTERNS): verify-% : ./verilog/dv/%  check-coremark_repo check-riscv_comp_repo check-riscv_test_repo
	docker run -v ${TARGET_PATH}:${TARGET_PATH} \
		-e TARGET_PATH=${TARGET_PATH} \
		-e TOOLS=/opt/riscv64i \
		-e DESIGNS=$(TARGET_PATH) \
		-e GCC_PREFIX=riscv64-unknown-elf \
		-u $$(id -u $$USER):$$(id -g $$USER) riscduino/dv_setup:mpw6 \
		sh -c $(verify_command)


.PHONY: verify
verify: 
	cd ./verilog/dv/ && \
	export SIM=${SIM} DUMP=${DUMP} && \
		$(MAKE) -j$(THREADS)


# Install Openlane
.PHONY: openlane
openlane:
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
	@git clone --depth=1 --branch mpw-5a https://github.com/efabless/mpw_precheck.git $(PRECHECK_ROOT)
	@docker pull efabless/mpw_precheck:latest

.PHONY: run-precheck
run-precheck: check-pdk check-precheck
	$(eval INPUT_DIRECTORY := $(shell pwd))
	cd $(PRECHECK_ROOT) && \
	docker run -v $(PRECHECK_ROOT):$(PRECHECK_ROOT) -v $(INPUT_DIRECTORY):$(INPUT_DIRECTORY) -v $(PDK_ROOT):$(PDK_ROOT) -e INPUT_DIRECTORY=$(INPUT_DIRECTORY) -e PDK_ROOT=$(PDK_ROOT) \
	-u $(shell id -u $(USER)):$(shell id -g $(USER)) efabless/mpw_precheck:latest bash -c "cd $(PRECHECK_ROOT) ; python3 mpw_precheck.py --input_directory $(INPUT_DIRECTORY) --pdk_root $(PDK_ROOT)"



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
	gzip -f lef/*
	gzip -f gds/*
	gzip -f spef/*
	gzip -f spi/lvs/*
	gzip -f verilog/gl/*

unzip:
	gzip -d lef/*
	gzip -d gds/*
	gzip -d spef/*
	gzip -d spi/lvs/*
	gzip -d verilog/gl/*

.PHONY: help
help:
	cd $(CARAVEL_ROOT) && $(MAKE) help
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
