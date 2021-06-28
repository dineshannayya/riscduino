//////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2021, Dinesh Annayya
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
// SPDX-FileContributor: Dinesh Annayya <dinesha@opencores.org>
// //////////////////////////////////////////////////////////////////////////
+incdir+../sdram_ctrl/src/defs 
+incdir+../syntacore/scr1/src/includes

../spi_master/src/spim_top.sv
../spi_master/src/spim_regs.sv
../spi_master/src/spim_clkgen.sv
../spi_master/src/spim_ctrl.sv
../spi_master/src/spim_rx.sv
../spi_master/src/spim_tx.sv

../sdram_ctrl/src/top/sdrc_top.v 
../sdram_ctrl/src/wb2sdrc/wb2sdrc.v 
../lib/async_fifo.sv  
../sdram_ctrl/src/core/sdrc_core.v 
../sdram_ctrl/src/core/sdrc_bank_ctl.v 
../sdram_ctrl/src/core/sdrc_bank_fsm.v 
../sdram_ctrl/src/core/sdrc_bs_convert.v 
../sdram_ctrl/src/core/sdrc_req_gen.v 
../sdram_ctrl/src/core/sdrc_xfr_ctl.v 

../lib/wb_crossbar.v
../lib/registers.v
../lib/clk_ctl.v
./src/glbl_cfg.sv
./src/digital_core.sv


../syntacore/scr1/src/core/pipeline/scr1_pipe_hdu.sv
../syntacore/scr1/src/core/pipeline/scr1_pipe_tdu.sv
../syntacore/scr1/src/core/pipeline/scr1_ipic.sv
../syntacore/scr1/src/core/pipeline/scr1_pipe_csr.sv
../syntacore/scr1/src/core/pipeline/scr1_pipe_exu.sv
../syntacore/scr1/src/core/pipeline/scr1_pipe_ialu.sv
../syntacore/scr1/src/core/pipeline/scr1_pipe_idu.sv
../syntacore/scr1/src/core/pipeline/scr1_pipe_ifu.sv
../syntacore/scr1/src/core/pipeline/scr1_pipe_lsu.sv
../syntacore/scr1/src/core/pipeline/scr1_pipe_mprf.sv
../syntacore/scr1/src/core/pipeline/scr1_pipe_top.sv
../syntacore/scr1/src/core/primitives/scr1_reset_cells.sv
../syntacore/scr1/src/core/primitives/scr1_cg.sv
../syntacore/scr1/src/core/scr1_clk_ctrl.sv
../syntacore/scr1/src/core/scr1_tapc_shift_reg.sv
../syntacore/scr1/src/core/scr1_tapc.sv
../syntacore/scr1/src/core/scr1_tapc_synchronizer.sv
../syntacore/scr1/src/core/scr1_core_top.sv
../syntacore/scr1/src/core/scr1_dm.sv
../syntacore/scr1/src/core/scr1_dmi.sv
../syntacore/scr1/src/core/scr1_scu.sv

../syntacore/scr1/src/top/scr1_dmem_router.sv
../syntacore/scr1/src/top/scr1_dp_memory.sv
../syntacore/scr1/src/top/scr1_tcm.sv
../syntacore/scr1/src/top/scr1_timer.sv
../syntacore/scr1/src/top/scr1_dmem_wb.sv
../syntacore/scr1/src/top/scr1_imem_wb.sv
../syntacore/scr1/src/top/scr1_top_wb.sv
../lib/sync_fifo.sv

