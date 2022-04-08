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

#SHELL = sh -xv
BLOCKS = $(shell find * -maxdepth 0 -type d)
CONFIG = $(foreach block,$(BLOCKS), ./$(block)/config.tcl)
CLEAN = $(foreach block,$(BLOCKS), clean-$(block))

OPENLANE_TAG = mpw5
OPENLANE_IMAGE_NAME = riscduino/openlane:$(OPENLANE_TAG)
OPENLANE_BASIC_COMMAND = "cd /project/openlane && flow.tcl -design ./$* -save_path .. -save -tag $* -overwrite"
OPENLANE_INTERACTIVE_COMMAND = "cd /project/openlane && flow.tcl -it -file ./$*/interactive.tcl -design ./$* -save_path .. -save -tag $* -overwrite"

all: $(BLOCKS)

$(CONFIG) :
	@echo "Missing $@. Please create a configuration for that design"
	@exit 1

$(BLOCKS) : % : ./%/config.tcl FORCE
	@echo "###############################################"
	@sleep 1

	@if [ -f ./$*/interactive.tcl ]; then\
		docker run -it  \
		-v $(PWD)/..:/project \
		-u $(shell id -u $(USER)):$(shell id -g $(USER)) \
		$(OPENLANE_IMAGE_NAME) sh -c $(OPENLANE_INTERACTIVE_COMMAND);\
	else\
		docker run -it  \
		-v $(PWD)/..:/project \
		-u $(shell id -u $(USER)):$(shell id -g $(USER)) \
		$(OPENLANE_IMAGE_NAME) sh -c $(OPENLANE_BASIC_COMMAND);\
	fi
	mkdir -p ../signoff/$*/
	cp $*/runs/$*/OPENLANE_VERSION ../signoff/$*/
	cp $*/runs/$*/PDK_SOURCES ../signoff/$*/
	cp $*/runs/$*/reports/final_summary_report.csv ../signoff/$*/

FORCE:

clean:
	@echo "Use clean_all to clean everything :)"

clean_all: $(CLEAN)

$(CLEAN): clean-% :
	rm -rf runs/$*
	rm -rf ../gds/$**
	rm -rf ../mag/$**
	rm -rf ../lef/$**
