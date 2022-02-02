// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

// Include caravel global defines for the number of the user project IO pads 
`include "defines.v"
`define USE_POWER_PINS
`define UNIT_DELAY #0.1

`ifdef GL
       `include "libs.ref/sky130_fd_sc_hd/verilog/primitives.v"
       `include "libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v"
       `include "libs.ref/sky130_fd_sc_hvl/verilog/primitives.v"
       `include "libs.ref/sky130_fd_sc_hvl/verilog/sky130_fd_sc_hvl.v"
       `include "libs.ref//sky130_fd_sc_hd/verilog/sky130_ef_sc_hd__fakediode_2.v"

        `include "glbl_cfg.v"
        `include "spi_master.v"
        `include "uart_i2cm.v"
        `include "wb_interconnect.v"
        `include "user_project_wrapper.v"
        `include "yifive.v"
        `include "wb_host.v"
	`include "clk_skew_adjust.v"
	`include "clk_buf.v"

`else
     `include "libs.ref/sky130_fd_sc_hd/verilog/primitives.v"
     `include "libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v"
     `include "libs.ref/sky130_fd_sc_hvl/verilog/primitives.v"
     `include "libs.ref/sky130_fd_sc_hvl/verilog/sky130_fd_sc_hvl.v"

     `include"sar_adc/SAR.sv"
     `include"sar_adc/ACMP.sv"
     `include"sar_adc/sar_adc.sv"
     `include"sar_adc/adc_reg.sv"
     `include"sar_adc/DAC_8BIT.v"


     `include "sram_macros/sky130_sram_2kbyte_1rw1r_32x512_8.v"
     `include "pinmux/src/pinmux.sv"
     `include "pinmux/src/pinmux_reg.sv"
     `include "pinmux/src/gpio_intr.sv"
     `include "pinmux/src/pwm.sv"
     `include "lib/pulse_gen_type1.sv"
     `include "lib/pulse_gen_type2.sv"

     `include "qspim/src/qspim_top.sv"
     `include "qspim/src/qspim_if.sv"
     `include "qspim/src/qspim_fifo.sv"
     `include "qspim/src/qspim_regs.sv"
     `include "qspim/src/qspim_clkgen.sv"
     `include "qspim/src/qspim_ctrl.sv"
     `include "qspim/src/qspim_rx.sv"
     `include "qspim/src/qspim_tx.sv"

     `include "uart/src/uart_core.sv"
     `include "uart/src/uart_cfg.sv"
     `include "uart/src/uart_rxfsm.sv"
     `include "uart/src/uart_txfsm.sv"
     `include "lib/async_fifo_th.sv"  
     `include "lib/reset_sync.sv"  
     `include "lib/double_sync_low.v"  
     `include "lib/clk_buf.v"  

     `include "i2cm/src/core/i2cm_bit_ctrl.v"
     `include "i2cm/src/core/i2cm_byte_ctrl.v"
     `include "i2cm/src/core/i2cm_top.v"

     `include "usb1_host/src/core/usbh_core.sv"
     `include "usb1_host/src/core/usbh_crc16.sv"
     `include "usb1_host/src/core/usbh_crc5.sv"
     `include "usb1_host/src/core/usbh_fifo.sv"
     `include "usb1_host/src/core/usbh_sie.sv"
     `include "usb1_host/src/phy/usb_fs_phy.v"
     `include "usb1_host/src/phy/usb_transceiver.v"
     `include "usb1_host/src/top/usb1_host.sv"

     `include "sspim/src/sspim_top.sv"  
     `include "sspim/src/sspim_ctl.sv"  
     `include "sspim/src/sspim_if.sv"
     `include "sspim/src/sspim_cfg.sv"


     `include "uart_i2c_usb_spi/src/uart_i2c_usb_spi.sv"

     `include "lib/async_fifo.sv"  
     `include "lib/registers.v"
     `include "lib/clk_ctl.v"
     `include "lib/ser_inf_32b.sv"
     `include "lib/ser_shift.sv"
     `include "digital_core/src/glbl_cfg.sv"

     `include "wb_host/src/wb_host.sv"
     `include "lib/async_wb.sv"

     `include "lib/sync_wbb.sv"
     `include "lib/sync_fifo2.sv"
     `include "wb_interconnect/src/wb_arb.sv"
     `include "wb_interconnect/src/wb_interconnect.sv"


     `include "yifive/ycr1c/src/core/pipeline/ycr1_pipe_hdu.sv"
     `include "yifive/ycr1c/src/core/pipeline/ycr1_pipe_tdu.sv"
     `include "yifive/ycr1c/src/core/pipeline/ycr1_ipic.sv"
     `include "yifive/ycr1c/src/core/pipeline/ycr1_pipe_csr.sv"
     `include "yifive/ycr1c/src/core/pipeline/ycr1_pipe_exu.sv"
     `include "yifive/ycr1c/src/core/pipeline/ycr1_pipe_ialu.sv"
     `include "yifive/ycr1c/src/core/pipeline/ycr1_pipe_idu.sv"
     `include "yifive/ycr1c/src/core/pipeline/ycr1_pipe_ifu.sv"
     `include "yifive/ycr1c/src/core/pipeline/ycr1_pipe_lsu.sv"
     `include "yifive/ycr1c/src/core/pipeline/ycr1_pipe_mprf.sv"
     `include "yifive/ycr1c/src/core/pipeline/ycr1_pipe_mul.sv"
     `include "yifive/ycr1c/src/core/pipeline/ycr1_pipe_div.sv"
     `include "yifive/ycr1c/src/core/pipeline/ycr1_pipe_top.sv"
     `include "yifive/ycr1c/src/core/primitives/ycr1_reset_cells.sv"
     `include "yifive/ycr1c/src/core/primitives/ycr1_cg.sv"
     `include "yifive/ycr1c/src/core/ycr1_clk_ctrl.sv"
     `include "yifive/ycr1c/src/core/ycr1_tapc_shift_reg.sv"
     `include "yifive/ycr1c/src/core/ycr1_tapc.sv"
     `include "yifive/ycr1c/src/core/ycr1_tapc_synchronizer.sv"
     `include "yifive/ycr1c/src/core/ycr1_core_top.sv"
     `include "yifive/ycr1c/src/core/ycr1_dm.sv"
     `include "yifive/ycr1c/src/core/ycr1_dmi.sv"
     `include "yifive/ycr1c/src/core/ycr1_scu.sv"
     `include "yifive/ycr1c/src/top/ycr1_imem_router.sv"
     `include "yifive/ycr1c/src/top/ycr1_dmem_router.sv"
     `include "yifive/ycr1c/src/top/ycr1_dp_memory.sv"
     `include "yifive/ycr1c/src/top/ycr1_tcm.sv"
     `include "yifive/ycr1c/src/top/ycr1_timer.sv"
     `include "yifive/ycr1c/src/top/ycr1_dmem_wb.sv"
     `include "yifive/ycr1c/src/top/ycr1_imem_wb.sv"
     `include "yifive/ycr1c/src/top/ycr1_intf.sv"
     `include "yifive/ycr1c/src/top/ycr1_top_wb.sv"
     `include "yifive/ycr1c/src/top/ycr1_icache_router.sv"
     `include "yifive/ycr1c/src/top/ycr1_dcache_router.sv"
     `include "yifive/ycr1c/src/cache/src/core/icache_top.sv"
     `include "yifive/ycr1c/src/cache/src/core/icache_app_fsm.sv"
     `include "yifive/ycr1c/src/cache/src/core/icache_tag_fifo.sv"
     `include "yifive/ycr1c/src/cache/src/core/dcache_tag_fifo.sv"
     `include "yifive/ycr1c/src/cache/src/core/dcache_top.sv"
     `include "yifive/ycr1c/src/lib/ycr1_async_wbb.sv"
     `include "yifive/ycr1c/src/lib/ycr1_arb.sv"

     `include "lib/sync_fifo.sv"

     `include "mbist/src/core/mbist_addr_gen.sv"
     `include "mbist/src/core/mbist_fsm.sv" 
     `include "mbist/src/core/mbist_op_sel.sv" 
     `include "mbist/src/core/mbist_repair_addr.sv" 
     `include "mbist/src/core/mbist_sti_sel.sv" 
     `include "mbist/src/core/mbist_pat_sel.sv"
     `include "mbist/src/core/mbist_mux.sv"
     `include "mbist/src/core/mbist_data_cmp.sv"
     `include "mbist/src/core/mbist_mem_wrapper.sv"

    `include "mbist/src/top/mbist_top.sv" 
    `include "mbist_wrapper/src/mbist_wb.sv" 
    `include "mbist_wrapper/src/mbist_wrapper.sv" 


    `include "uart2wb/src/uart2wb.sv" 
    `include "uart2wb/src/uart2_core.sv" 
    `include "uart2wb/src/uart_msg_handler.v" 
     `include "lib/async_reg_bus.sv"

     `include "user_project_wrapper.v"
     // we are using netlist file for clk_skew_adjust as it has 
     // standard cell + power pin
     `include "clk_skew_adjust/src/clk_skew_adjust.v"
     `include "lib/ctech_cells.sv"
`endif
