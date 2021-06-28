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
////                                                              ////
////  YiFive cores common library Module                          ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  https://github.com/dineshannayya/yifive_r0.git              ////
////  http://www.opencores.org/cores/yifive/                      ////
////                                                              ////
////  Description                                                 ////
////     Sync Fifo with full and empty                            ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision : June 7, 2021                                     //// 
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

module spim_fifo #(
      parameter  DATA_WIDTH  = 32, // Data Width
      parameter  ADDR_WIDTH   = 1, // Address Width
      parameter  FIFO_DEPTH   = 2  // FIFO DEPTH
	
)(
       input                   rstn,
       input                   srst,
       input                   clk,
       input                   wr_en, // Write
       input [DATA_WIDTH-1:0]  din,
       output                  ready_o,

       input                   rd_en, // Read
       output [DATA_WIDTH-1:0] dout,
       output                  valid_o
);


reg [DATA_WIDTH-1:0]  ram [FIFO_DEPTH-1:0];
reg [ADDR_WIDTH-1:0]  wptr; // write ptr
reg [ADDR_WIDTH-1:0]  rptr; // write ptr
reg [ADDR_WIDTH:0]    status_cnt; // status counter
reg                   empty;
reg                   full;

 wire ready_o = ! full;
 wire valid_o = ! empty;

 //-----------Code Start---------------------------
 always @ (negedge rstn or posedge clk)
 begin : WRITE_POINTER
   if (rstn==1'b0) begin
     wptr <= 0;
   end else if (srst ) begin
     wptr <= 0;
   end else if (wr_en ) begin
     wptr <= wptr + 1;
   end
 end

always @ (negedge rstn or posedge clk)
begin : READ_POINTER
  if (rstn==1'b0) begin
    rptr <= 0;
   end else if (srst ) begin
     rptr <= 0;
  end else if (rd_en) begin
    rptr <= rptr + 1;
  end
end

always @ (negedge rstn or posedge clk)
begin : STATUS_COUNTER
  if (rstn==1'b0) begin
       status_cnt <= 0;
  end else if (srst ) begin
       status_cnt <= 0;
  // Read but no write.
  end else if (rd_en &&   (!wr_en) && (status_cnt  != 0)) begin
    status_cnt <= status_cnt - 1;
  // Write but no read.
  end else if (wr_en &&  (!rd_en) && (status_cnt  != FIFO_DEPTH)) begin
    status_cnt <= status_cnt + 1;
  end
end

// underflow is not handled
always @ (negedge rstn or posedge clk)
begin : EMPTY_FLAG
  if (rstn==1'b0) begin
       empty <= 1;
  end else if (srst ) begin
       empty <= 1;
  // Read but no write.
  end else if (rd_en &&   (!wr_en) && (status_cnt  == 1)) begin
    empty <= 1;
  // Write 
  end else if (wr_en) begin
    empty <= 0;
  end else if (status_cnt  == 0) begin
     empty <= 1;
  end
end

// overflow is not handled
always @ (negedge rstn or posedge clk)
begin : FULL_FLAG
  if (rstn==1'b0) begin
       full <= 0;
  end else if (srst ) begin
       full <= 0;
  // Write but no read.
  end else if (wr_en &&  (!rd_en) && (status_cnt  == (FIFO_DEPTH-1))) begin
    full <= 1;
  // Read 
  end else if (rd_en &&  (!wr_en) ) begin
    full <= 0;
  end else if (status_cnt  == FIFO_DEPTH) begin
     full <= 1;
  end
end
assign dout = ram[rptr];

always @ (posedge clk)
begin
  if (wr_en) ram[wptr] <= din;
end


endmodule
