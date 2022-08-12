//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Single SPI Master Interface Module                          ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
////      SPI Control module                                      ////
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



module sspim_ctl
       ( 
  input  logic          clk,
  input  logic          reset_n,
  input  logic          cfg_cpol,
  input  logic          cfg_op_req,
  input  logic          cfg_endian,
  input  logic [1:0]    cfg_op_type,
  input  logic [1:0]    cfg_transfer_size,
  input  logic [4:0]    cfg_sck_cs_period, 
    
  input  logic [7:0]    cfg_cs_byte,
  input  logic [31:0]   cfg_datain,
  output logic [31:0]   cfg_dataout,

  output logic [7:0]    byte_out, // Byte out for Serial Shifting out
  input  logic [7:0]    byte_in,  // Serial Received Byte
  output logic          cs_int_n,
  input logic           shift,
  input logic           sample,

  output logic          sck_active,
  output logic          load_byte,
  output logic          op_done
         
         );

 //*************************************************************************

 parameter LITTLE_ENDIAN  = 1'b0;
 parameter BIG_ENDIAN     = 1'b1;
 
 parameter SPI_WR         = 2'b00;
 parameter SPI_RD         = 2'b01;
 parameter SPI_WR_RD      = 2'b10;

  logic [5:0]       sck_cnt;

  logic [3:0]       spiif_cs;

  logic [2:0]       byte_cnt;


  `define SPI_IDLE   4'b0000
  `define SPI_CS_SU  4'b0001
  `define SPI_DATA   4'b0010
  `define SPI_CS_HLD 4'b0011
  `define SPI_WAIT   4'b0100



wire [1:0] cs_data =  (byte_cnt == 2'b00) ? cfg_cs_byte[7:6]  :
                      (byte_cnt == 2'b01) ? cfg_cs_byte[5:4]  :
                      (byte_cnt == 2'b10) ? cfg_cs_byte[3:2]  : cfg_cs_byte[1:0] ;

assign byte_out =     (cfg_endian == LITTLE_ENDIAN) ? 
	                   ((byte_cnt == 2'b00) ? cfg_datain[7:0] :
                            (byte_cnt == 2'b01) ? cfg_datain[15:8] :
                            (byte_cnt == 2'b10) ? cfg_datain[23:16]  : cfg_datain[31:24]) :
	                   ((byte_cnt == 2'b00) ? cfg_datain[31:24] :
                            (byte_cnt == 2'b01) ? cfg_datain[23:16] :
                            (byte_cnt == 2'b10) ? cfg_datain[15:8]  : cfg_datain[7:0]) ;
         
         

always @(posedge clk or negedge reset_n) begin
   if(!reset_n) begin
      spiif_cs    <= `SPI_IDLE;
      sck_cnt     <= 6'h0;
      byte_cnt    <= 2'b00;
      cs_int_n    <= 1'b1;
      cfg_dataout <= 32'h0;
      load_byte   <= 1'b0;
      sck_active  <= 1'b0;
   end
   else begin
      case(spiif_cs)
      `SPI_IDLE   : 
      begin
          sck_active  <= 1'b0;
          load_byte   <= 1'b0;
          op_done     <= 0;
          if(cfg_op_req) 
          begin
              cfg_dataout <= 32'h0;
              spiif_cs    <= `SPI_CS_SU;
           end else begin
              spiif_cs <= `SPI_IDLE;
           end 
      end 

      `SPI_CS_SU  : 
       begin
          if(shift) begin
            cs_int_n <= cs_data[1];
            if(sck_cnt == cfg_sck_cs_period) begin
               sck_cnt <=  'h0;
               if((cfg_op_type == SPI_WR) || (cfg_op_type == SPI_WR_RD )) begin // Write Mode
                  load_byte   <= 1'b1;
               end 
               spiif_cs    <= `SPI_DATA;
            end else begin 
               sck_cnt <=  sck_cnt + 1 ;
            end
         end
      end 

      `SPI_DATA : 
       begin 
         load_byte   <= 1'b0;
         if((shift && (cfg_cpol == 1)) || (sample && (cfg_cpol == 0)) ) begin
               sck_active  <= 1'b1;
         end else if((sample && (cfg_cpol == 1)) || (shift && (cfg_cpol == 0)) ) begin
            if(sck_cnt == 4'h8 )begin
               sck_active  <= 1'b0;
               sck_cnt     <=  'h0;
               spiif_cs    <= `SPI_CS_HLD;
            end
            else begin
               sck_active  <= 1'b1;
               sck_cnt     <=  sck_cnt + 1 ;
            end
         end
      end 

      `SPI_CS_HLD : begin
         if(shift) begin
             cs_int_n <= cs_data[0];
            if(sck_cnt == cfg_sck_cs_period) begin
               if((cfg_op_type == SPI_RD) || (cfg_op_type == SPI_WR_RD)) begin // Read Mode
                  cfg_dataout <= (cfg_endian == LITTLE_ENDIAN) ?
			         ((byte_cnt[1:0] == 2'b00) ? { cfg_dataout[31:8],byte_in } :
                                  (byte_cnt[1:0] == 2'b01) ? { cfg_dataout[31:16], byte_in, cfg_dataout[7:0] } :
                                  (byte_cnt[1:0] == 2'b10) ? { cfg_dataout[31:24], byte_in, cfg_dataout[15:0]  } :
                                                             { byte_in,cfg_dataout[23:0]}) :
			         ((byte_cnt[1:0] == 2'b00) ? { byte_in,cfg_dataout[23:0] } :
                                  (byte_cnt[1:0] == 2'b01) ? { cfg_dataout[31:24], byte_in, cfg_dataout[15:0] } :
                                  (byte_cnt[1:0] == 2'b10) ? { cfg_dataout[31:16], byte_in, cfg_dataout[7:0]  } :
                                                             { cfg_dataout[31:8],byte_in}) ;
               end
               sck_cnt     <=  'h0;
               if(byte_cnt == cfg_transfer_size) begin
                  spiif_cs <= `SPI_WAIT;
                  byte_cnt <= 0;
                  op_done  <= 1;
               end else begin
                  byte_cnt <= byte_cnt +1;
                  spiif_cs <= `SPI_CS_SU;
               end
            end
            else begin
                sck_cnt     <=  sck_cnt + 1 ;
            end
         end 
      end // case: `SPI_CS_HLD    
      `SPI_WAIT : begin
          if(!cfg_op_req) // Wait for Request de-assertion
             spiif_cs <= `SPI_IDLE;
       end
    endcase // casex(spiif_cs)
   end
end // always @(sck_ne

endmodule
