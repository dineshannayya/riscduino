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
/*********************************************************************
                                                              
  SYNC FIFO
                                                              
  This file is part of the yifive project
  https://github.com/dineshannayya/yifive_r0.git           
                                                              
  Description: SYNC FIFO 
                                                              
  To Do:                                                      
    nothing                                                   
                                                              
  Author(s):  Dinesh Annayya, dinesha@opencores.org                 
                                                             
 Copyright (C) 2000 Authors and OPENCORES.ORG                
                                                             
 This source file may be used and distributed without         
 restriction provided that this copyright statement is not    
 removed from the file and that any derivative work contains  
 the original copyright notice and the associated disclaimer. 
                                                              
 This source file is free software; you can redistribute it   
 and/or modify it under the terms of the GNU Lesser General   
 Public License as published by the Free Software Foundation; 
 either version 2.1 of the License, or (at your option) any   
later version.                                               
                                                              
 This source is distributed in the hope that it will be       
 useful, but WITHOUT ANY WARRANTY; without even the implied   
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
 PURPOSE.  See the GNU Lesser General Public License for more 
 details.                                                     
                                                              
 You should have received a copy of the GNU Lesser General    
 Public License along with this source; if not, download it   
 from http://www.opencores.org/lgpl.shtml                     
                                                              
*******************************************************************/

//-------------------------------------------
// sync FIFO
//-----------------------------------------------
//`timescale  1ns/1ps

module qspim_fifo (clk,
                   reset_n,
		   flush,
                   wr_en,
                   wr_data,
                   full,                 
                   afull,                 
                   rd_en,
                   empty,                
                   aempty,                
                   rd_data);

   parameter W = 4'd8;
   parameter DP = 3'd4;
   parameter WR_FAST = 1'b1;
   parameter RD_FAST = 1'b1;
   parameter FULL_DP = DP;
   parameter EMPTY_DP = 1'b0;

   parameter AW = (DP == 2)   ? 1 : 
		  (DP == 4)   ? 2 :
                  (DP == 8)   ? 3 :
                  (DP == 16)  ? 4 :
                  (DP == 32)  ? 5 :
                  (DP == 64)  ? 6 :
                  (DP == 128) ? 7 :
                  (DP == 256) ? 8 : 0;

   output [W-1 : 0]  rd_data;
   input [W-1 : 0]   wr_data;
   input             clk, reset_n, wr_en,flush,
                     rd_en;
   output            full, empty;
   output            afull, aempty;       // about full and about to empty


   // synopsys translate_off

   initial begin
      if (AW == 0) begin
         $display ("%m : ERROR!!! Fifo depth %d not in range 2 to 256", DP);
      end // if (AW == 0)
   end // initial begin

   // synopsys translate_on

   reg [W-1 : 0]    mem[DP-1 : 0];

   /*********************** write side ************************/
   reg [AW:0] wr_ptr;
   reg full_q;
   wire full_c;
   wire afull_c;
   wire [AW:0] wr_ptr_inc = wr_ptr + 1'b1;
   wire [AW:0] wr_cnt = get_cnt(wr_ptr, rd_ptr);

   assign full_c  = (wr_cnt == FULL_DP) ? 1'b1 : 1'b0;
   assign afull_c = (wr_cnt == FULL_DP-1) ? 1'b1 : 1'b0;


   always @(posedge clk or negedge reset_n) begin
	if (!reset_n) begin
	   wr_ptr <= 0;
	   full_q <= 0;	
	end
	else begin
	   if(flush) begin
		wr_ptr <= 0;
		full_q <= 0;	
	   end else if (wr_en) begin
	   	wr_ptr <= wr_ptr_inc;
	   	if (wr_cnt == (FULL_DP-1)) begin
	   		full_q <= 1'b1;
	   	end
	   end else begin
	       	if (full_q && (wr_cnt<FULL_DP)) begin
	   		full_q <= 1'b0;
	        end
	   end
       end
    end

    assign full  = (WR_FAST == 1) ? full_c : full_q;
    assign afull = afull_c;

    always @(posedge clk) begin
        if (wr_en) begin
           mem[wr_ptr[AW-1:0]] <= wr_data;
        end
    end


   /************************ read side *****************************/
   reg [AW:0] rd_ptr;
   reg empty_q;
   wire empty_c;
   wire aempty_c;
   wire [AW:0] rd_ptr_inc = rd_ptr + 1'b1;
   wire [AW:0] rd_cnt = get_cnt(wr_ptr, rd_ptr);
 
   assign empty_c  = (rd_cnt == 0) ? 1'b1 : 1'b0;
   assign aempty_c = (rd_cnt == 1) ? 1'b1 : 1'b0;

   always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
            rd_ptr <= 0;
            empty_q <= 1'b1;
      end
      else begin
	 if(flush) begin
           rd_ptr <= 0;
	   empty_q <= 1'b1;
	 end else if (rd_en) begin
               rd_ptr <= rd_ptr_inc;
               if (rd_cnt==(EMPTY_DP+1)) begin
                  empty_q <= 1'b1;
               end
         end else begin
            if (empty_q && (rd_cnt!=EMPTY_DP)) begin
	      empty_q <= 1'b0;
	    end
         end
       end
    end

    assign empty  = (RD_FAST == 1) ? empty_c : empty_q;
    assign aempty = aempty_c;

    reg [W-1 : 0]  rd_data_q;

   wire [W-1 : 0] rd_data_c = mem[rd_ptr[AW-1:0]];
   always @(posedge clk) begin
	rd_data_q <= rd_data_c;
   end
   assign rd_data  = (RD_FAST == 1) ? rd_data_c : rd_data_q;


function [AW:0] get_cnt;
input [AW:0] wr_ptr, rd_ptr;
begin
	if (wr_ptr >= rd_ptr) begin
		get_cnt = (wr_ptr - rd_ptr);	
	end
	else begin
		get_cnt = DP*2 - (rd_ptr - wr_ptr);
	end
end
endfunction

// synopsys translate_off
always @(posedge clk) begin
   if (wr_en && full) begin
      $display($time, "%m Error! afifo overflow!");
      $stop;
   end
end

always @(posedge clk) begin
   if (rd_en && empty) begin
      $display($time, "%m error! afifo underflow!");
      $stop;
   end
end
// synopsys translate_on

endmodule
