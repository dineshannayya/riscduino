//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Single SPI Master Interface Module                          ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
////     Subbport Single Bit SPI Master                           ////
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
/*******************************************************************
SPI Mode:
     Mode 0 (the default)− Clock is normally low (CPOL = 0), and Data sampled on rising edge and shifted out on the falling edge.  (CPHA = 0). - Supported
     Mode 1              − Clock is normally low (CPOL = 0), and Data sampled on the falling edge and shifted out on the rising edge. (CPHA = 1). - Not Supported
     Mode 2              − Clock is normally high (CPOL = 1), and Data sampled on the rising edge and shifted out on the falling edge. (CPHA = 0). - Supported
     Mode 3              − Clock is normally high (CPOL = 1), and Data sampled on the falling edge and shifted out on the rising edge (CPHA = 1). - Not Supported


********************************************************************/


module sspim_cfg (
              input  logic          mclk               ,
              input  logic          reset_n            ,
              
              output logic [1:0]    cfg_tgt_sel        ,

              output logic          cfg_cpol           , // spi clock idle phase
              output logic          cfg_cpha           , // spi data sample and lanch phase
              output logic          cfg_bit_order      , // SPI TX/RX Bit Order,  1 -> LSBFIRST or  0 -> MSBFIRST
              output logic          cfg_op_req         , // SPI operation request
	          output logic          cfg_endian         , // Endian selection
              output logic [1:0]    cfg_op_type        , // SPI operation type
              output logic [1:0]    cfg_transfer_size  , // SPI transfer size
              output logic [5:0]    cfg_sck_period     , // sck clock period
              output logic [4:0]    cfg_sck_cs_period  , // cs setup/hold period
              output logic [7:0]    cfg_cs_byte        , // cs bit information
              output logic [31:0]   cfg_datain         , // data for transfer
              input  logic [31:0]   cfg_dataout        , // data for received
              input  logic          hware_op_done      , // operation done
              
              //---------------------------------
              // Reg Bus Interface Signal
              //---------------------------------
              input logic           reg_cs             ,
              input logic           reg_wr             ,
              input logic [7:0]     reg_addr           ,
              input logic [31:0]    reg_wdata          ,
              input logic [3:0]     reg_be             ,
              
              // Outputs
              output logic [31:0]   reg_rdata          ,
              output logic          reg_ack            


        );



//-----------------------------------------------------------------------
// Internal Wire Declarations
//-----------------------------------------------------------------------
logic           sw_rd_en               ;
logic           sw_wr_en;
logic   [1:0]   sw_addr; // addressing 16 registers
logic   [3:0]   wr_be  ;
logic           reg_cs_l;
logic           reg_cs_2l;

logic  [31:0]    reg_0;  // Software_Reg_0
logic  [31:0]    reg_1;  // Software-Reg_1
logic  [31:0]    reg_2;  // Software-Reg_2
logic  [31:0]    reg_out;
logic  [1:0]     cfg_spi_mode;

//-----------------------------------------------------------------------
// Main code starts here
//-----------------------------------------------------------------------

//-----------------------------------------------------------------------
// Internal Logic Starts here
//-----------------------------------------------------------------------
    assign sw_addr       = reg_addr [3:2];
    assign sw_rd_en      = reg_cs & !reg_wr;
    assign sw_wr_en      = reg_cs & reg_wr;
    assign wr_be         = reg_be;

//-----------------------------------------------------------------------
// Read path mux
//-----------------------------------------------------------------------

always @ (posedge mclk or negedge reset_n)
begin : preg_out_Seq
   if (reset_n == 1'b0)
   begin
      reg_rdata  <= 'h0;
      reg_ack    <= 1'b0;
   end
   else if (sw_rd_en && !reg_ack) 
   begin
      reg_rdata  <= reg_out;
      reg_ack    <= 1'b1;
   end
   else if (sw_wr_en && !reg_ack) 
      reg_ack    <= 1'b1;
   else
   begin
      reg_ack    <= 1'b0;
   end
end

//-----------------------------------------------------------------------
// register read enable and write enable decoding logic
//-----------------------------------------------------------------------
wire   sw_wr_en_0   = sw_wr_en & (sw_addr == 2'h0);
wire   sw_rd_en_0   = sw_rd_en & (sw_addr == 2'h0);
wire   sw_wr_en_1   = sw_wr_en & (sw_addr == 2'h1);
wire   sw_rd_en_1   = sw_rd_en & (sw_addr == 2'h1);
wire   sw_wr_en_2   = sw_wr_en & (sw_addr == 2'h2);
wire   sw_rd_en_2   = sw_rd_en & (sw_addr == 2'h2);
wire   sw_wr_en_3   = sw_wr_en & (sw_addr == 2'h3);
wire   sw_rd_en_3   = sw_rd_en & (sw_addr == 2'h3);


always @( *)
begin : preg_sel_Com

  reg_out [31:0] = 32'd0;

  case (sw_addr [1:0])
    2'b00 : reg_out [31:0] = reg_0 [31:0];     
    2'b01 : reg_out [31:0] = reg_1 [31:0];    
    2'b10 : reg_out [31:0] = reg_2 [31:0];     
    default : reg_out [31:0] = 32'h0;
  endcase
end



//-----------------------------------------------------------------------
// Individual register assignments
//-----------------------------------------------------------------------
// Logic for Register 0 : SPI Control Register
//-----------------------------------------------------------------------

assign cfg_cpha = cfg_spi_mode[0];
assign cfg_cpol = cfg_spi_mode[1];

assign    cfg_op_req         = reg_0[31];    // cpu request
assign    cfg_bit_order      = reg_0[28];    //  1 -> LSBFIRST or  0 -> MSBFIRST
assign    cfg_spi_mode       = reg_0[27:26]; // spi mode
assign    cfg_endian         = reg_0[25];    // Endian, 0 - little, 1 - Big
assign    cfg_tgt_sel        = reg_0[24:23]; // target chip select
assign    cfg_op_type        = reg_0[22:21]; // SPI operation type
assign    cfg_transfer_size  = reg_0[20:19]; // SPI transfer size
assign    cfg_sck_period     = reg_0[18:13]; // sck clock period
assign    cfg_sck_cs_period  = reg_0[12:8];  // cs setup/hold period
assign    cfg_cs_byte        = reg_0[7:0];   // cs bit information

generic_register #(8,0  ) u_spi_ctrl_be0 (
	      .we            ({8{sw_wr_en_0 & 
                                 wr_be[0]   }}  ),		 
	      .data_in       (reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_0[7:0]        )
          );

generic_register #(8,0  ) u_spi_ctrl_be1 (
	      .we            ({8{sw_wr_en_0 & 
                                wr_be[1]   }}  ),		 
	      .data_in       (reg_wdata[15:8]  ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_0[15:8]       )
          );

generic_register #(8,0  ) u_spi_ctrl_be2 (
	      .we            ({8{sw_wr_en_0 & 
                                wr_be[2]   }}  ),		 
	      .data_in       (reg_wdata[23:16] ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_0[23:16]       )
          );

generic_register #(7,0  ) u_spi_ctrl_be3 (
	      .we            ({7{sw_wr_en_0 & 
                                wr_be[3]   }}  ),		 
	      .data_in       (reg_wdata[30:24] ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_0[30:24]       )
          );


req_register #(0  ) u_spi_ctrl_req (
	      .cpu_we       ({sw_wr_en_0 & 
                             wr_be[3]   }       ),		 
	      .cpu_req      (reg_wdata[31]      ),
	      .hware_ack    (hware_op_done      ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_0[31]         )
          );




//-----------------------------------------------------------------------
// Logic for Register 1 : SPI Data In Register
//-----------------------------------------------------------------------
assign   cfg_datain        = reg_1[31:0]; 

generic_register #(8,0  ) u_spi_din_be0 (
	      .we            ({8{sw_wr_en_1 & 
                                wr_be[0]   }}  ),		 
	      .data_in       (reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_1[7:0]        )
          );

generic_register #(8,0  ) u_spi_din_be1 (
	      .we            ({8{sw_wr_en_1 & 
                                wr_be[1]   }}  ),		 
	      .data_in       (reg_wdata[15:8]   ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_1[15:8]       )
          );

generic_register #(8,0  ) u_spi_din_be2 (
	      .we            ({8{sw_wr_en_1 & 
                                wr_be[2]   }}  ),		 
	      .data_in       (reg_wdata[23:16]  ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_1[23:16]      )
          );


generic_register #(8,0  ) u_spi_din_be3 (
	      .we            ({8{sw_wr_en_1 & 
                                wr_be[3]   }}  ),		 
	      .data_in       (reg_wdata[31:24]  ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_1[31:24]      )
          );


//-----------------------------------------------------------------------
// Logic for Register 2 : SPI Data output Register
//-----------------------------------------------------------------------
assign  reg_2 = cfg_dataout; 



endmodule
