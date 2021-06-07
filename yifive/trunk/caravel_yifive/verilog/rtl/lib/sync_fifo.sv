//////////////////////////////////////////////////////////////////////
////                                                              ////
////  YiFive cores common library Module                          ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
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

module sync_fifo #(
      parameter  DATA_WIDTH  = 32, // Data Width
      parameter  ADDR_WIDTH   = 1,  // Address Width
      parameter  FIFO_DEPTH   = 2 // FIFO DEPTH
	
)(
       output [DATA_WIDTH-1:0] dout,
       input                    rstn,
       input                    clk,
       input                    wr_en, // Write
       input                    rd_en, // Read
       input [DATA_WIDTH-1:0]  din,
       output                  full,
       output                  empty
);


reg [DATA_WIDTH-1:0] ram [FIFO_DEPTH-1:0];
reg [ADDR_WIDTH-1:0]  wptr; // write ptr
reg [ADDR_WIDTH-1:0]  rptr; // write ptr
reg [ADDR_WIDTH:0]    status_cnt; // status counter

 //-----------Variable assignments---------------
 assign full  = (status_cnt == FIFO_DEPTH);
 assign empty = (status_cnt == 0);
 
 //-----------Code Start---------------------------
 always @ (negedge rstn or posedge clk)
 begin : WRITE_POINTER
   if (rstn==1'b0) begin
     wptr <= 0;
   end else if (wr_en ) begin
     wptr <= wptr + 1;
   end
 end

always @ (negedge rstn or posedge clk)
begin : READ_POINTER
  if (rstn==1'b0) begin
    rptr <= 0;
  end else if (rd_en) begin
    rptr <= rptr + 1;
  end
end

always @ (negedge rstn or posedge clk)
begin : STATUS_COUNTER
  if (rstn==1'b0) begin
       status_cnt <= 0;
  // Read but no write.
  end else if (rd_en &&   (!wr_en) && (status_cnt  != 0)) begin
    status_cnt <= status_cnt - 1;
  // Write but no read.
  end else if (wr_en &&  (!rd_en) && (status_cnt  != FIFO_DEPTH)) begin
    status_cnt <= status_cnt + 1;
  end
end


assign dout = ram[rptr];

always @ (posedge clk)
begin
  if (wr_en) ram[wptr] <= din;
end


endmodule
