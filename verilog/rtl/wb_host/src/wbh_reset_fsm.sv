//////////////////////////////////////////////////////////////////////////////
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
// SPDX-FileContributor: Created by Dinesh Annayya <dinesh.annayya@gmail.com>
//
//////////////////////////////////////////////////////////////////////
/*************************************************************************
  This block control the reset sequence

expected Reset removal sequence
   
               _________                 __________________________________________________
                        |                |
e_reset_n               |________________|
               
               ________                           ________________________________________
               XXXXXXXXX                          |
p_reset_n      XXXXXXXXX__________________________|
               
          
                                                                             ____________
              XXXXXXXXX                                                     |
clk_enb       XXXXXXXXX_____________________________________________________|

                                                                                        ____________
               XXXXXXXXX                                                                |
s_reset_n      XXXXXXXXX________________________________________________________________|

************************************************************************************************************/

module wbh_reset_fsm (
	      input  logic    clk                 ,
	      input  logic    e_reset_n           ,  // external reset
          input  logic    cfg_fast_sim        ,
          input  logic    soft_boot_req       ,

	      output logic    p_reset_n           ,  // power-on reset
	      output logic    s_reset_n           ,  // soft reset
          output logic    clk_enb             ,
          output logic    soft_reboot         ,  // Indicate Soft Reboot 
          output logic    force_refclk          // Keep WBS in Ref clock during initial boot to strap loading         

);

logic [2:0]  state;
logic [15:0] clk_cnt;

parameter  FSM_POWER_UP        = 3'b000;
parameter  FSM_POWERON_RESET   = 3'b001;
parameter  FSM_STRAP_LOAD      = 3'b010;
parameter  FSM_STRAP_CLK_ENB   = 3'b011;
parameter  FSM_DEASSERT_FORCE  = 3'b100;
parameter  FSM_SOFT_RESET      = 3'b101;
parameter  FSM_SOFT_BOOT_REQ   = 3'b110;
parameter  FSM_CLK_EN_DEASSERT = 3'b111;

logic boot_req_s,boot_req_ss;

wire [15:0] clk_exit_cnt = (cfg_fast_sim) ? 100 : 60000;

always @ (posedge clk or negedge e_reset_n) begin 
   if (e_reset_n == 1'b0) begin
       boot_req_s    <= 1'b0;
       boot_req_ss   <= 1'b0;
       state         <= FSM_POWER_UP;
       s_reset_n     <= 0;
       p_reset_n     <= 0;
       clk_cnt       <= 0;
       soft_reboot   <= 0;
       clk_enb       <= 0;
       force_refclk  <= 1;
   end else begin
       // Double Sync the incoming signal
       boot_req_s  <= soft_boot_req;
       boot_req_ss <= boot_req_s;
      case(state)
      FSM_POWER_UP : begin
                if(clk_cnt == clk_exit_cnt) begin
                   clk_cnt   <= 0;
                   state     <= FSM_STRAP_CLK_ENB;
                end else begin
                   clk_cnt   <= clk_cnt + 1;
                end
             end
      FSM_STRAP_CLK_ENB : begin
                if(clk_cnt == 15) begin
                   clk_enb      <= 1;
                   clk_cnt      <= 0;
                   state        <= FSM_POWERON_RESET;
                end else begin
                   clk_cnt   <= clk_cnt + 1;
                end
             end
      FSM_POWERON_RESET : begin
                if(clk_cnt == 15) begin
                   p_reset_n <= 1;
                   clk_cnt   <= 0;
                   state     <= FSM_DEASSERT_FORCE;
                end else begin
                   clk_cnt   <= clk_cnt + 1;
                end
             end

      FSM_DEASSERT_FORCE : begin
                if(clk_cnt == 15) begin
                   force_refclk <= 0;
                   clk_cnt   <= 0;
                   state     <= FSM_SOFT_RESET;
                end else begin
                   clk_cnt   <= clk_cnt + 1;
                end
             end

      FSM_SOFT_RESET : begin
                if(clk_cnt == 15) begin
                   s_reset_n <= 1;
                   clk_cnt   <= 0;
                   state     <= FSM_SOFT_BOOT_REQ;
                end else begin
                   clk_cnt   <= clk_cnt + 1;
                end
             end
      FSM_SOFT_BOOT_REQ : begin
                if(boot_req_ss) begin
                   soft_reboot  <= 1;
                   clk_cnt      <= 0;
                   force_refclk <= 1;
                   clk_enb      <= 0;
                   state        <= FSM_CLK_EN_DEASSERT;
                end
             end
      // Disable clock to avoid to block all transation
      FSM_CLK_EN_DEASSERT : begin
                if(clk_cnt == 15) begin
                   s_reset_n  <= 0;
                   clk_enb    <= 1;
                   clk_cnt    <= 0;
                   state      <= FSM_SOFT_RESET;
                end else begin
                   clk_cnt   <= clk_cnt + 1;
                end
             end
        default : state         <= FSM_POWER_UP;

      endcase

   end
end
   


endmodule
