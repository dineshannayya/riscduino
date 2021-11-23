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

BLOCKS = sar_adc wb_interconnect syntacore qspim uart_i2cm_usb_spi pinmux wb_host
DEF = $(foreach block,$(BLOCKS), ../def/$(block).def)
CLEAN = $(foreach block,$(BLOCKS), clean-$(block))

OPENLANE_TAG = mpw3
OPENLANE_IMAGE_NAME = dineshannayya/openlane:$(OPENLANE_TAG)
OPENLANE_NETLIST_COMMAND = "cd /project/sta && openroad -exit scripts/or_write_verilog.tcl | tee logs/$@.log"
OPENLANE_STA_COMMAND = "cd /project/sta && sta scripts/sta.tcl | tee logs/sta.log"

all: $(BLOCKS) run_sta

$(DEF) :
	@echo "Missing $@. Please create a def for that design"
	@exit 1

$(BLOCKS) : % : ../def/%.def  create 
	docker run -it  -v $(PWD)/..:/project -e DESIGN_NAME=$@ -u $(shell id -u $(USER)):$(shell id -g $(USER)) $(OPENLANE_IMAGE_NAME) sh -c $(OPENLANE_NETLIST_COMMAND)

run_sta: $(BLOCKS)
	#sta inside the docker is crashing with segmentation fault, so are running sta outside the docker
	#docker run -it  -v $(PWD)/..:/project -e DESIGN_NAME=$@ -u $(shell id -u $(USER)):$(shell id -g $(USER)) $(OPENLANE_IMAGE_NAME) sh -c $(OPENLANE_STA_COMMAND)
	sta scripts/sta.tcl | tee logs/sta.log

create: clean
	@echo "create temp directory :)"
	mkdir -p netlist
	mkdir -p logs
	mkdir -p reports

clean:
	@echo "clean everything :)"
	rm -rf netlist
	rm -rf logs
	rm -rf reports

