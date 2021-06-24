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
`define USE_POWER_PINS

`ifdef GL
      `include "libs.ref/sky130_fd_sc_hd/verilog/primitives.v"
      `include "libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v"
      `include "libs.ref/sky130_fd_sc_hvl/verilog/primitives.v"
      `include "libs.ref/sky130_fd_sc_hvl/verilog/sky130_fd_sc_hvl.v"

      `include "digital_core/src/digital_core.sv"
      `include "glbl_cfg.v"
      `include "sdram.v"
      `include "spi_master.v"
      `include "syntacore.v"
      `include "uart.v"
      `include "wb_interconnect.v"
`else
     `include "spi_master/src/spim_top.sv"
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
     `include "digital_core/src/digital_core.sv"

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
     `include "syntacore/scr1/src/top/scr1_top_wb.sv"
     `include "lib/sync_fifo.sv"
`endif
