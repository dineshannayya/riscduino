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

# ---- Test patterns for project striVe ----

.SUFFIXES:
.SILENT: clean all

PATTERNS = user_random user_uart user_uart1 user_risc_boot user_qspi user_sspi user_i2cm user_usb user_gpio user_basic user_spi_isp user_timer user_uart_master  user_sram_exec user_cache_bypass user_pwm user_sema risc_boot uart_master_test1 uart_master_test2 wb_port arduino_arrays arduino_risc_boot arduino_timer_intr arduino_ascii_table arduino_gpio_intr arduino_i2c_wr_rd arduino_string arduino_ws281x arduino_character_analysis arduino_hello_world arduino_multi_serial arduino_switchCase2 user_aes_core user_fpu_core user_aes user_rtc user_ir_tx user_ir_rx step_motor_controller caravel_hkspi user_qspis user_cpu_clkgate arduino_digital_port_control arduino_i2c_scaner

all:  ${PATTERNS}
	echo "################# RTL Test case Summary #####################" > regression.rpt
	xterm -e /usr/bin/watch -n 25 /bin/cat regression.rpt & 
	\rm -rf */*.vvp
	for i in ${PATTERNS}; do \
		( cd $$i && make | tee run.rtl.log && grep Monitor run.rtl.log | grep $$i >> ../regression.rpt) ; \
	done
	#echo "################# GL Test case Summary #####################" >> regression.rpt
	#\rm -rf */*.vvp
	#for i in ${PATTERNS}; do \
	#	( cd $$i && make SIM=GL | tee run.gl.log && grep Monitor run.gl.log | grep $$i >> ../regression.rpt) ; \
	#done
	#echo "################# End of Test case Summary #####################" >> regression.rpt

DV_PATTERNS = $(foreach dv, $(PATTERNS), verify-$(dv))
$(DV_PATTERNS): verify-% : 
	cd $* && make

clean:  ${PATTERNS}
	for i in ${PATTERNS}; do \
		( cd $$i && make clean ) ; \
	done
	rm -rf *.log
	
.PHONY: clean all
