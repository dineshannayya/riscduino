//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Single SPI Master Interface Module                          ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
////      SPI Clock Gen module                                    ////
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
/*********************************************************************
   Design Implementation Reference
   Reference: https://www.allaboutcircuits.com/technical-articles/spi-serial-peripheral-interface/
*********************************************************************/  


module sspim_clkgen
       ( 
  input  logic          clk,
  input  logic          reset_n,
  input  logic          cfg_op_req,
  input  logic          cfg_cpol,    // CPOL : clock polarity CPOL :0- Clock Idle state low, 1 - Clock idle state high
  input  logic          cfg_cpha,    // CPHA : Clock Phase
    
  input  logic [5:0]    cfg_sck_period,

  input  logic          sck_active,

  output logic          sck_int,  // SCLK
  output logic          shift,    // Data Shift Phase
  output logic          sample,   // Data Sample Phase
  output logic          sck_ne,   // sclk negative phase
  output logic          sck_pe    // sclk positive phase
         
         );

 //*************************************************************************


  logic [5:0]       clk_cnt;
  logic  [5:0]      sck_half_period;


  
  assign sck_ne = (cfg_cpha == 0) ? shift  : sample;
  assign sck_pe = (cfg_cpha == 0) ? sample : shift;

  assign sck_half_period = {1'b0, cfg_sck_period[5:1]};
  // The first transition on the sck_toggle happens one SCK period
  // after op_en or boot_en is asserted
  always @(posedge clk or negedge reset_n) begin
     if(!reset_n) begin
        shift    <= 1'b0;
        sample   <= 1'b0;
        clk_cnt  <= 6'h0;
        sck_int  <= 1'b1;
     end // if (!reset_n)
     else 
     begin
        if(cfg_op_req) 
        begin
           // clock counter
           if(clk_cnt == cfg_sck_period) begin
              clk_cnt <= 'h0;
           end else begin
              clk_cnt <= clk_cnt + 1'b1;
            end

           if(clk_cnt == sck_half_period) 
           begin
              shift  <= 1'b1;
              sample <= 1'b0;
           end // if (clk_cnt == sck_half_period)
           else 
           begin
              if(clk_cnt == cfg_sck_period) 
              begin
                 shift <= 1'b0;
                 sample <= 1'b1;
              end // if (clk_cnt == cfg_sck_period)
              else 
              begin
                 shift  <= 1'b0;
                 sample <= 1'b0;
              end // else: !if(clk_cnt == cfg_sck_period)
           end // else: !if(clk_cnt == sck_half_period)
        end // if (op_en)
        else 
        begin
           clk_cnt   <= 6'h0;
           shift     <= 1'b0;
           sample    <= 1'b0;
        end // else: !if(op_en)
           

        if(sck_active) begin
           if(sck_ne)       sck_int <= 0;
           else if(sck_pe)  sck_int <= 1;
        end else if (cfg_cpol == 0) begin // CPOL :0- Clock Idle state low
           sck_int <= 0;
        end else begin // CPOL :1- Clock Idle state High
           sck_int <= 1;
        end
     end // else: !if(!reset_n)
  end // always @ (posedge clk or negedge reset_n)
  


endmodule
