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
                                                              
  Description: SYNC FIFO with Occupancy
  Parameters:
      WD : Width (integer)
      DP : Depth (integer, power of 2, 4 to 256)
                                                              
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


module sync_fifo_occ  #(parameter WD = 8,parameter DP = 4,
                        parameter AW = (DP == 2)   ? 1 :
	                                   (DP == 4)   ? 2 :
		                               (DP == 8)   ? 3 :
		                               (DP == 16)  ? 4 :
		                               (DP == 32)  ? 5 :
		                               (DP == 64)  ? 6 :
		                               (DP == 128) ? 7 :
		                               (DP == 256) ? 8 : 0) (

       input  logic          clk          , // Clock
	   input  logic          reset_n      , // Reset
       input  logic          sreset_n     , // Synchronous Reset
	   input  logic	         wr_en        , // FIFO Write enable
	   input  logic [WD-1:0] wr_data      , // FIFO Write Data
	   output logic 	     full         , // FIFO Full
       output logic	         empty        , // FIFO Empty
	   input  logic	         rd_en        , // FIFO Read enable
	   output logic [WD-1:0] rd_data      , // FIFO Read Data
       output logic [AW:0]   occupancy      // Show the current FIFO occpancy
                     );


   

   // synopsys translate_off

   initial begin
      if (AW == 0) begin
	 $display ("%m : ERROR!!! Fifo depth %d not in range 4 to 256", DP);
      end // if (AW == 0)
   end // initial begin

   // synopsys translate_on


   reg [WD-1 : 0]   mem[DP-1 : 0];
   reg [AW-1 : 0]   rd_ptr, wr_ptr;


   assign empty =  (occupancy == 0);  
   assign full  =  (occupancy == DP);  

   // occpuancy computation
   always @ (posedge clk or negedge reset_n) 
      if (reset_n == 1'b0) begin
         occupancy <= 'h0;
      end else if(sreset_n == 1'b0) begin
         occupancy <= 'h0;
      end else begin
         if ((wr_en & !full) && (rd_en == 1'b0 )) begin // Write Only
            occupancy <= occupancy + 1'b1 ;
         end else if ((rd_en & !empty) && (wr_en == 1'b0 )) begin // Read Only
            occupancy <= occupancy - 1'b1 ;
         end
      end

   
   always @ (posedge clk or negedge reset_n) 
      if (reset_n == 1'b0) begin
         wr_ptr <= {AW{1'b0}} ;
      end else if(sreset_n == 1'b0) begin
         wr_ptr <= {AW{1'b0}} ;
      end else begin 
         if (wr_en & !full) begin
            wr_ptr <= wr_ptr + 1'b1 ;
         end
      end

   always @ (posedge clk or negedge reset_n) 
      if (reset_n == 1'b0) begin
         rd_ptr <= {AW{1'b0}} ;
      end else if(sreset_n == 1'b0) begin
         rd_ptr <= {AW{1'b0}} ;
      end else begin
         if (rd_en & !empty) begin
            rd_ptr <= rd_ptr + 1'b1 ;
         end
      end

   always @ (posedge clk) 
      if (wr_en)
	       mem[wr_ptr] <= wr_data;

assign  rd_data = mem[rd_ptr];


// synopsys translate_off
   always @(posedge clk) begin
      if (wr_en && full) begin
         $display("%m : Error! sfifo overflow!");
      end
   end

   always @(posedge clk) begin
      if (rd_en && empty) begin
         $display("%m : error! sfifo underflow!");
      end
   end

// synopsys translate_on
//---------------------------------------

endmodule


