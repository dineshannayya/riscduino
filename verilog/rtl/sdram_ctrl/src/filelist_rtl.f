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
./top/sdrc_top.v 
./wb2sdrc/wb2sdrc.v 
../../lib/async_fifo.sv  
./core/sdrc_core.v 
./core/sdrc_bank_ctl.v 
./core/sdrc_bank_fsm.v 
./core/sdrc_bs_convert.v 
./core/sdrc_req_gen.v 
./core/sdrc_xfr_ctl.v 
