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
        `include "sdram.v"
        `include "spi_master.v"
        `include "uart_i2cm_usb.v"
        `include "wb_interconnect.v"
        `include "user_project_wrapper.v"
        `include "syntacore.v"
        `include "wb_host.v"
	`include "clk_skew_adjust.v"

`else
     `include "libs.ref/sky130_fd_sc_hd/verilog/primitives.v"
     `include "libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v"
     `include "libs.ref/sky130_fd_sc_hvl/verilog/primitives.v"
     `include "libs.ref/sky130_fd_sc_hvl/verilog/sky130_fd_sc_hvl.v"


     `include "spi_master/src/spim_top.sv"
     `include "spi_master/src/spim_if.sv"
     `include "spi_master/src/spim_fifo.sv"
     `include "spi_master/src/spim_regs.sv"
     `include "spi_master/src/spim_clkgen.sv"
     `include "spi_master/src/spim_ctrl.sv"
     `include "spi_master/src/spim_rx.sv"
     `include "spi_master/src/spim_tx.sv"

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

     `include "uart_i2c_usb/src/uart_i2c_usb.sv"

     `include "sdram_ctrl/src/top/sdrc_top.v" 
     `include "sdram_ctrl/src/wb2sdrc/wb2sdrc.v" 
     `include "lib/async_fifo.sv"  
     `include "sdram_ctrl/src/core/sdrc_core.v"
     `include "sdram_ctrl/src/core/sdrc_bank_ctl.v"
     `include "sdram_ctrl/src/core/sdrc_bank_fsm.v"
     `include "sdram_ctrl/src/core/sdrc_bs_convert.v"
     `include "sdram_ctrl/src/core/sdrc_req_gen.v"
     `include "sdram_ctrl/src/core/sdrc_xfr_ctl.v"

     `include "lib/registers.v"
     `include "lib/clk_ctl.v"
     `include "digital_core/src/glbl_cfg.sv"

     `include "wb_host/src/wb_host.sv"
     `include "lib/async_wb.sv"

     `include "lib/wb_stagging.sv"
     `include "wb_interconnect/src/wb_arb.sv"
     `include "wb_interconnect/src/wb_interconnect.sv"


     `include "syntacore/scr1/src/core/pipeline/scr1_pipe_hdu.sv"
     `include "syntacore/scr1/src/core/pipeline/scr1_pipe_tdu.sv"
     `include "syntacore/scr1/src/core/pipeline/scr1_ipic.sv"
     `include "syntacore/scr1/src/core/pipeline/scr1_pipe_csr.sv"
     `include "syntacore/scr1/src/core/pipeline/scr1_pipe_exu.sv"
     `include "syntacore/scr1/src/core/pipeline/scr1_pipe_ialu.sv"
     `include "syntacore/scr1/src/core/pipeline/scr1_pipe_idu.sv"
     `include "syntacore/scr1/src/core/pipeline/scr1_pipe_ifu.sv"
     `include "syntacore/scr1/src/core/pipeline/scr1_pipe_lsu.sv"
     `include "syntacore/scr1/src/core/pipeline/scr1_pipe_mprf.sv"
     `include "syntacore/scr1/src/core/pipeline/scr1_pipe_mul.sv"
     `include "syntacore/scr1/src/core/pipeline/scr1_pipe_div.sv"
     `include "syntacore/scr1/src/core/pipeline/scr1_pipe_top.sv"
     `include "syntacore/scr1/src/core/primitives/scr1_reset_cells.sv"
     `include "syntacore/scr1/src/core/primitives/scr1_cg.sv"
     `include "syntacore/scr1/src/core/scr1_clk_ctrl.sv"
     `include "syntacore/scr1/src/core/scr1_tapc_shift_reg.sv"
     `include "syntacore/scr1/src/core/scr1_tapc.sv"
     `include "syntacore/scr1/src/core/scr1_tapc_synchronizer.sv"
     `include "syntacore/scr1/src/core/scr1_core_top.sv"
     `include "syntacore/scr1/src/core/scr1_dm.sv"
     `include "syntacore/scr1/src/core/scr1_dmi.sv"
     `include "syntacore/scr1/src/core/scr1_scu.sv"
      
     `include "syntacore/scr1/src/top/scr1_dmem_router.sv"
     `include "syntacore/scr1/src/top/scr1_dp_memory.sv"
     `include "syntacore/scr1/src/top/scr1_tcm.sv"
     `include "syntacore/scr1/src/top/scr1_timer.sv"
     `include "syntacore/scr1/src/top/scr1_dmem_wb.sv"
     `include "syntacore/scr1/src/top/scr1_imem_wb.sv"
     `include "syntacore/scr1/src/top/scr1_intf.sv"
     `include "syntacore/scr1/src/top/scr1_top_wb.sv"
     `include "lib/sync_fifo.sv"

     `include "user_project_wrapper.v"
     // we are using netlist file for clk_skew_adjust as it has 
     // standard cell + power pin
     `include "gl/clk_skew_adjust.v"
`endif
