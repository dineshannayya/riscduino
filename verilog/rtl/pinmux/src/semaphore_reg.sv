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
////  Semaphore Register                                          ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
//// A semaphore is a variable or abstract data type that         ////
//// provides a simple but useful abstraction for controlling     ////
//// access by multiple processes to a common resource in a       ////
//// parallel programming or multi-user environment.              ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 15th Aug 2022, Dinesh A                             ////
////          initial version                                     ////
//////////////////////////////////////////////////////////////////////
//
/***************************************************************
  Special Semaphore Register Implementation
  Read access from 0 to 14 will return corresponsonding bit lock status. 
     If lock is free, then it return '1' and also lock the corresponding bit
     If lock is busy, then it return '0' 
  Write & Read access with address 15 does normal write and read access, 
   this location should used for only debug purpose

*****************************************************************/
module semaphore_reg  #(parameter DW = 16,         // DATA WIDTH
                        parameter AW = $clog2(DW), // ADDRESS WIDTH
                        parameter BW = $clog2(AW)  // BYTE WIDTH
                ) (
                       // System Signals
                       // Inputs
		               input logic           mclk,
                       input logic           h_reset_n,

		               // Reg Bus Interface Signal
                       input logic           reg_cs,
                       input logic           reg_wr,
                       input logic [AW-1:0]  reg_addr,
                       input logic [DW-1:0]  reg_wdata,
                       input logic [BW-1:0]  reg_be,

                       // Outputs
                       output logic [DW-1:0] reg_rdata,
                       output logic          reg_ack

                ); 

//-----------------------------------------------------------------------
// Internal Wire Declarations
//-----------------------------------------------------------------------

logic          sw_rd_en        ;
logic          sw_wr_en        ;
logic [AW-1:0] sw_addr         ; // addressing 16 registers
logic [DW-1:0] sw_reg_wdata    ;
logic [BW-1:0] sw_be           ;

logic [DW-1:0] reg_out         ;
logic [DW-1:0] reg_0           ; 
logic          sw_wr_en_0      ;

assign       sw_addr       = reg_addr;
assign       sw_rd_en      = reg_cs & !reg_wr;
assign       sw_wr_en      = reg_cs & reg_wr;


always @ (posedge mclk or negedge h_reset_n)
begin : preg_out_Seq
   if (h_reset_n == 1'b0) begin
      reg_rdata  <= 'h0;
      reg_ack    <= 1'b0;
   end else if (reg_cs && !reg_ack) begin
      reg_rdata  <= reg_out[DW-1:0] ;
      reg_ack    <= 1'b1;
   end else begin
      reg_ack    <= 1'b0;
   end
end

/***************************************************************
  Special Semaphore Register Implementation
  Read access from 0 to 30 will return corresponsonding bit lock status. 
     If lock is free, then it return '1' and lock the corresponding bit
     If lock is busy, then it return '0' and lock the corresponding bit
*****************************************************************/

gen_16b_reg  #('h0) u_reg_0	(
	      //List of Inputs
	      .reset_n    (h_reset_n             ),
	      .clk        (mclk                  ),
	      .cs         (sw_wr_en_0            ),
	      .we         (sw_be[BW-1:0]         ),		 
	      .data_in    (sw_reg_wdata[DW-1:0]  ),
	      
	      //List of Outs
	      .data_out   (reg_0                 )
	      );


//-----------------------------------------------------------------------
// Register Write Data
//-----------------------------------------------------------------------

always_comb
begin 
  sw_reg_wdata  = 'h0;
  sw_wr_en_0    = 'b0;
  sw_be         = 'h0;

   // Address 0xF, is Simple Write Register
   if(sw_addr == {AW {1'b1}}) begin 
      sw_reg_wdata = reg_0;
      sw_wr_en_0   = sw_wr_en & reg_ack;
      sw_be        = reg_be[BW-1:0];
   end else begin // 0 to 0xE is Semaphore Register
       if(sw_rd_en) begin  // Read will always lock the bit '1'
          sw_reg_wdata = (reg_0   | ( 1 << sw_addr)) ; 
       end else begin // To release the Lock Write with '1'
          sw_reg_wdata  = (reg_0  ^ ((reg_wdata [DW-1:0] & 'h1)  << sw_addr)) ; 
       end
       sw_wr_en_0 = reg_ack;
       sw_be      = {BW{1'b1}};
    end
end

//-----------------------------------------------------------------------
// Register Read Path Multiplexer instantiation
//-----------------------------------------------------------------------

always_comb
begin 
  if(sw_addr == {AW {1'b1}}) begin 
     reg_out = reg_0;
  end else begin
     reg_out = (reg_0 >> sw_addr ) ^ 'h1; 
  end
end


endmodule
