//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Single SPI Master Interface Module                          ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////      V.0  - 06 Oct 2021                                      ////
////          Initial SpI Module picked from                      ////
////             http://www.opencores.org/cores/turbo8051/        ////
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

module sspim_if
          (
          input  logic       clk,
          input  logic       reset_n,
          input  logic       sck_int,
          input  logic       cs_int_n,
          input  logic       cfg_bit_order, // 1 -> LSBFIRST or  0 -> MSBFIRST
          
          input  logic       load_byte,
          input  logic [1:0] cfg_tgt_sel,

          input  logic [7:0] byte_out,
          input  logic       sck_active,
          input  logic       shift,
          input  logic       sample,

          output logic  [7:0]byte_in,
          output logic       sck,
          output logic       so,
          output logic  [3:0]cs_n,
          input  logic       si
           );



  logic [7:0]    so_reg;
  logic [7:0]    si_reg;


   wire shift_out = shift & sck_active;
   wire sample_in  = sample & sck_active;

  //Output Shift Register

  always @(posedge clk or negedge reset_n) begin
     if(!reset_n) begin
        so_reg <= 8'h00;
        so <= 1'b0;
     end
     else begin
        if(load_byte) begin
           so_reg <= byte_out;
           if(shift_out) begin 
              // Handling backto back case : 
              // Last Transfer bit + New Trasfer Load
              if(cfg_bit_order) so <= so_reg[0]; // LSB FIRST
              else              so <= so_reg[7]; // MSB FIRST
           end
        end // if (load_byte)
        else begin
           if(shift_out) begin
              if(cfg_bit_order) begin // LSB FIRST
                 so     <= so_reg[0];
                 so_reg <= {1'b0,so_reg[7:1]};
              end else begin
                 so     <= so_reg[7];
                 so_reg <= {so_reg[6:0],1'b0};
              end
           end // if (shift_out)
        end // else: !if(load_byte)
     end // else: !if(!reset_n)
  end // always @ (posedge clk or negedge reset_n)


// Input shift register
  always @(posedge clk or negedge reset_n) begin
     if(!reset_n) begin
        si_reg <= 8'h0;
     end else begin
        if(sample_in) begin
           if(cfg_bit_order) begin // LSB FIRST
               si_reg[7:0] <= {si,si_reg[7:1]};
           end else begin // MSB FIRST
               si_reg[7:0] <= {si_reg[6:0],si};
           end
        end // if (sample_in)
     end // else: !if(!reset_n)
  end // always @ (posedge clk or negedge reset_n)


  assign byte_in[7:0] = si_reg[7:0];
  assign cs_n[0] = (cfg_tgt_sel[1:0] == 2'b00) ? cs_int_n : 1'b1;
  assign cs_n[1] = (cfg_tgt_sel[1:0] == 2'b01) ? cs_int_n : 1'b1;
  assign cs_n[2] = (cfg_tgt_sel[1:0] == 2'b10) ? cs_int_n : 1'b1;
  assign cs_n[3] = (cfg_tgt_sel[1:0] == 2'b11) ? cs_int_n : 1'b1;
  assign sck = sck_int;

endmodule
