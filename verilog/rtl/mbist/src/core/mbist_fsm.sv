///////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2021 , Dinesh Annayya                          
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
// SPDX-FileContributor: Created by Dinesh Annayya <dinesha@opencores.org>
//
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  MBIST Main control FSM                                      ////
////                                                              ////
////  This file is part of the mbist_ctrl cores project           ////
////  https://github.com/dineshannayya/mbist_ctrl.git             ////
////                                                              ////
////  Description                                                 ////
////  MBIST Main control FSM to control Command, Address, Write   ////
////   and Read compare phase                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.0 - 11th Oct 2021, Dinesh A                             ////
////          Initial integration                                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
module mbist_fsm 
     #(  parameter BIST_ADDR_WD           = 9,
	 parameter BIST_DATA_WD           = 32,
	 parameter BIST_ADDR_START        = 9'h000,
	 parameter BIST_ADDR_END          = 9'h1F8,
	 parameter BIST_REPAIR_ADDR_START = 9'h1FC,
	 parameter BIST_RAD_WD_I          = BIST_ADDR_WD,
	 parameter BIST_RAD_WD_O          = BIST_ADDR_WD) (

	output logic cmd_phase,    // Command Phase
	output logic cmp_phase,    // Compare Phase
	output logic run_op,       // Move to Next Operation
	output logic run_addr,     // Move to Next Address
	output logic run_sti,      // Move to Next Stimulus
	output logic run_pat,      // Move to next pattern
	output logic bist_done,    // Bist Test Done


	input logic  clk,          // Clock
	input logic  rst_n,        // Reset
	input logic  bist_run,     // Bist Run
	input logic  bist_error,   // Bist Error
	input logic  op_reverse,   // Address Reverse in Next Cycle
	input logic  last_op,      // Last Operation
	input logic  last_addr,    // Last Address
	input logic  last_sti,     // Last Stimulus
	input logic  last_pat      // Last Pattern


);

parameter FSM_PHASE1 = 2'b00;
parameter FSM_PHASE2 = 2'b01;
parameter FSM_EXIT   = 2'b10;

logic [1:0]  state;



always @(posedge clk or negedge rst_n)
begin
   if(!rst_n) begin
      cmd_phase       <= 0;
      cmp_phase       <= 0;
      run_op         <= 0;
      run_addr       <= 0;
      run_sti        <= 0;
      run_pat        <= 0;
      bist_done      <= 0;
      state          <= FSM_PHASE1;
   end else if(bist_run) begin
      case(state)
         FSM_PHASE1  :  
         begin
            cmd_phase <= 1;
            cmp_phase <= 0;
            run_op    <= 0;
            run_addr  <= 0;
            run_sti   <= 0;
            run_pat   <= 0;
            state     <= FSM_PHASE2;
          end
         FSM_PHASE2  :  
         begin
            if((last_addr && last_op && last_sti && last_pat) || bist_error)  begin
               cmd_phase  <= 0;
               cmp_phase  <= 0;
               run_op     <= 0;
               run_addr   <= 0;
               run_sti    <= 0;
               run_pat    <= 0;
               state      <= FSM_EXIT;
            end else begin
               cmd_phase   <= 0;
               cmp_phase   <= 1;
               run_op      <= 1;
               if(last_op && !(last_addr && op_reverse))
                  run_addr <= 1;
               if(last_addr && last_op) 
                  run_sti  <= 1;
               if(last_addr && last_op && last_sti) 
                  run_pat  <= 1;
               state    <= FSM_PHASE1;
	    end
         end
	 FSM_EXIT: bist_done  <= 1;
	 default:  state      <= FSM_PHASE1;
      endcase
   end else begin
      cmd_phase <= 0;
      cmp_phase <= 0;
      run_op    <= 0;
      run_addr  <= 0;
      run_sti   <= 0; 
      run_pat   <= 0;
      state     <= FSM_PHASE1;
   end
end



endmodule
