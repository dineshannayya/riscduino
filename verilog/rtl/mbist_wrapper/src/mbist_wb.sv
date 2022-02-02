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
// SPDX-FileContributor: Created by Dinesh Annayya <dinesha@opencores.org>
//
//////////////////////////////////////////////////////////////////////
//   
//   MBIST wishbone Burst access to SRAM Write and Read access
//   Note: BUSRT crossing the SRAM boundary is not supported due to sram
//   2 cycle pipe line delay
//////////////////////////////////////////////////////////////////////

module mbist_wb
     #(  
         parameter BIST_NO_SRAM           = 4,
	 parameter BIST_ADDR_WD           = 9,
	 parameter BIST_DATA_WD           = 32) (

`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif


	input  logic                            rst_n,


        // WB I/F
        input   logic                          wb_clk_i,  // System clock
        input   logic                          wb_stb_i,  // strobe/request
        input   logic [BIST_ADDR_WD-1:0]       wb_adr_i,  // address
        input   logic [(BIST_NO_SRAM+1)/2-1:0] wb_cs_i,   // address
        input   logic                          wb_we_i ,  // write
        input   logic [BIST_DATA_WD-1:0]       wb_dat_i,  // data output
        input   logic [BIST_DATA_WD/8-1:0]     wb_sel_i,  // byte enable
        input   logic [9:0]                    wb_bl_i,   // Burst Length
        input   logic                          wb_bry_i,  // Burst Ready
        output  logic [BIST_DATA_WD-1:0]       wb_dat_o,  // data input
        output  logic                          wb_ack_o,  // acknowlegement
        output  logic                          wb_lack_o, // acknowlegement
        output  logic                          wb_err_o,  // error

	output  logic                          mem_req,
	output  logic [(BIST_NO_SRAM+1)/2-1:0] mem_cs,
	output  logic [BIST_ADDR_WD-1:0]       mem_addr,
	output  logic [31:0]                   mem_wdata,
	output  logic                          mem_we,
	output  logic [3:0]                    mem_wmask,
	input   logic [31:0]                   mem_rdata




);

parameter IDLE          = 2'b00;
parameter WRITE_ACTION  = 2'b01;
parameter READ_ACTION1  = 2'b10;
parameter READ_ACTION2  = 2'b11;


logic [9:0]                mem_bl_cnt     ;
logic                      wb_ack_l       ;
logic [BIST_ADDR_WD-1:0]   mem_next_addr;
logic [1:0]                state;
logic                      mem_hval;   // Mem Hold Data valid
logic [31:0]               mem_hdata;  // Mem Hold Data


assign  mem_wdata    = wb_dat_i;

always @(negedge rst_n, posedge wb_clk_i) begin
    if (~rst_n) begin
       mem_bl_cnt       <= 'h0;
       mem_addr         <= 'h0;
       mem_next_addr    <= 'h0;
       wb_ack_l         <= 'b0;
       wb_dat_o         <= 'h0;
       mem_req          <= 'b0;
       mem_cs           <= 'b0;
       mem_wmask        <= 'h0;
       mem_we           <= 'h0;
       mem_hval         <= 'b0;
       mem_hdata        <= 'h0;
       state            <= IDLE;
    end else begin
	case(state)
	 IDLE: begin
	       mem_bl_cnt  <=  'h1;
	       wb_ack_o    <=  'b0;
	       wb_lack_o   <=  'b0;
	       if(wb_stb_i && wb_bry_i && ~wb_we_i && !wb_lack_o) begin
	          mem_cs      <=  wb_cs_i;
	          mem_addr    <=  wb_adr_i;
	          mem_req     <=  'b1;
		  mem_we      <=  'b0;
	          state       <=  READ_ACTION1;
	       end else if(wb_stb_i && wb_bry_i && wb_we_i && !wb_lack_o) begin
	          mem_cs      <=  wb_cs_i;
	          mem_next_addr<=  wb_adr_i;
		  mem_we      <=  'b1;
                  mem_wmask   <=  wb_sel_i;
	          state       <=  WRITE_ACTION;
	       end else begin
	          mem_req      <=  1'b0;
               end
	    end

         WRITE_ACTION: begin
	    if (wb_stb_i && wb_bry_i ) begin
	       wb_ack_o     <=  'b1;
	       mem_req      <=  1'b1;
	       mem_addr     <=  mem_next_addr;
	       if((wb_stb_i && wb_bry_i ) && (wb_bl_i == mem_bl_cnt)) begin
	           wb_lack_o   <=  'b1;
	           state       <= IDLE;
	       end else begin
	          mem_bl_cnt   <= mem_bl_cnt+1;
	          mem_next_addr<=  mem_next_addr+1;
	       end
            end else begin 
	       wb_ack_o     <=  'b0;
	       mem_req      <=  1'b0;
            end
         end
       READ_ACTION1: begin
	   mem_addr   <=  mem_addr +1;
           mem_hval   <= 1'b0;
	   wb_ack_l   <=  'b1;
	   mem_bl_cnt <=  'h1;
	   state      <=  READ_ACTION2;
       end

       // Wait for Ack from application layer
       READ_ACTION2: begin
           // If the not the last ack, update memory pointer
           // accordingly
	   wb_ack_l    <= wb_ack_o;
	   if (wb_stb_i && wb_bry_i ) begin
	      wb_ack_o   <= 1'b1;
	      mem_bl_cnt <= mem_bl_cnt+1;
	      mem_addr   <=  mem_addr +1;
	      if(wb_ack_l || wb_ack_o ) begin // If back to back ack 
                 wb_dat_o     <= mem_rdata;
                 mem_hval     <= 1'b0;
	      end else begin // Pick from previous holding data
                 mem_hval     <= 1'b1;
                 wb_dat_o     <= mem_hdata;
                 mem_hdata    <= mem_rdata;
	      end
	      if((wb_stb_i && wb_bry_i ) && (wb_bl_i == mem_bl_cnt)) begin
		  wb_lack_o   <= 1'b1;
	          state       <= IDLE;
	      end
           end else begin
	      wb_ack_o   <= 1'b0;
	      if(!mem_hval) begin
                 mem_hdata  <= mem_rdata;
                 mem_hval   <= 1'b1;
	      end
           end
       end
       endcase
   end
end

endmodule
