////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2022 , <Julien OURY/Dinesh Annayya>
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
// SPDX-FileContributor: Created by Julien OURY <julien.oury@outlook.fr>
// and Dinesh Annayya <dinesh.annayya@gmail.com>
//
////////////////////////////////////////////////////////////////////////////
/**********************************************************************
                                                              
          NEC IR Register
                                                                      
          This file is part of the riscduino cores project            
          https://github.com/dineshannayya/riscduino.git              
                                                                      
                                                                      
          To Do:                                                      
            nothing                                                   
                                                                      
          Author(s): 
              - Julien OURY <julien.oury@outlook.fr>                                                 
              - Dinesh Annayya <dinesh.annayya@gmail.com>
                                                                      
          Revision :                                                  
            0.1 - 11 Dec 2022, Dinesh A                               
                  initial version picked from 
                  https://github.com/JulienOury/ChristmasTreeController                                    
            0.2 - 13 Dec 2022, Dinesh A
                  A. Bug fix, Read access clearing the register content
                  B. FIFO Occpancy added
                  C. Support for IR Transmitter
                     
***************************************************************************/

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Registers
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module nec_ir_regs #(
  parameter PSIZE = 32 , // Size of prescaler counter(bits)
  parameter DSIZE = 32 , // Size of delay counter (bits)
  parameter ASIZE = 3    // MEMORY ADDRESS POINTER SIZE
)(

  input logic               rst_n             , // Asynchronous reset (active low)
  input logic               clk               , // Clock (rising edge)

  // Configuration
  output logic              cfg_ir_en         , // IR Global Enable
  output logic              cfg_ir_tx_en      , // Transmitter enable
  output logic              cfg_ir_rx_en      , // Receiver enable
  output logic              cfg_repeat_en     , // Repeat enable
  output logic              cfg_tx_polarity   , // Polarity (value of idle state)
  output logic              cfg_rx_polarity   , // Polarity (value of idle state)
  output logic  [PSIZE-1:0] cfg_multiplier    , // frequency multiplier
  output logic  [PSIZE-1:0] cfg_divider       , // frequency divider
  output logic  [DSIZE-1:0] reload_offset     , // Delay counter reload offset
  output logic  [DSIZE-1:0] delay_mask        , // Mask delay

  // Wishbone bus
  input  logic              wbs_cyc_i         , // Wishbone strobe/request
  input  logic              wbs_stb_i         , // Wishbone strobe/request
  input  logic [4:0]        wbs_adr_i         , // Wishbone address
  input  logic              wbs_we_i          , // Wishbone write (1:write, 0:read)
  input  logic [31:0]       wbs_dat_i         , // Wishbone data output
  input  logic [ 3:0]       wbs_sel_i         , // Wishbone byte enable
  output logic  [31:0]      wbs_dat_o         , // Wishbone data input
  output logic              wbs_ack_o         , // Wishbone acknowlegement

  // Input frame interface
  // <IR RECEIVER> => <RX FIFO> => WB
  input  logic             rx_frame_new       , // New frame received
  input  logic             fifo_rx_full       , // RX FIFO full
  input  logic [16:0]      fifo_rx_rdata      , // RX FIFO Read Data
  output logic             fifo_rx_read       , // RX FIFO Read
  input  logic [ASIZE:0]   fifo_rx_occ        , // RX FIFO Occupancy

  // <WB> => <TX FIFO> =>  <IR Transmitter>
  input  logic             fifo_tx_full       , // Tx FIFO full
  output logic [15:0]      fifo_tx_wdata      , // TX FIFO Wdata
  output logic             fifo_tx_write      , // TX FIFO Write
  input  logic [ASIZE:0]   fifo_tx_occ        , // FIFO TX Occpancy

  // Interrupt
  output reg              irq               // Interrupt

 );

  localparam
    IR_CFG_CMD          = 3'b000,
    IR_CFG_MULTIPLIER   = 3'b001,
    IR_CFG_DIVIDER      = 3'b010,
    IR_CFG_RX_DATA      = 3'b011,
    IR_CFG_TX_DATA      = 3'b100;


  logic        valid;
  logic        rstrb;
  logic [2:0]  addr;

  logic  [1:0]  cfg_tolerance;
  logic         cfg_irq_en;
  logic         frame_lost;
  logic         ready;


  assign valid     = wbs_cyc_i && wbs_stb_i;
  assign rstrb     = ~wbs_we_i;
  assign addr      = wbs_adr_i[4:2];
  assign wbs_ack_o = ready;

  wire [7:0] rx_frame_data   = fifo_rx_rdata[7:0];
  wire [7:0] rx_frame_addr   = fifo_rx_rdata[15:8];
  wire       rx_frame_repeat = fifo_rx_rdata[16];
  wire       fifo_rx_available = (fifo_rx_occ > 0);

  always @(negedge rst_n or posedge clk) begin
    if (rst_n == 1'b0) begin
      ready       <= 1'b0;
      wbs_dat_o   <= 'h0;
      cfg_tolerance   <= 2'b01;
      cfg_multiplier  <= {PSIZE{1'b0}};
      cfg_divider     <= {PSIZE{1'b0}};
      cfg_ir_en       <= 1'b0;
      cfg_ir_tx_en    <= 1'b0;
      cfg_ir_rx_en    <= 1'b0;
      cfg_repeat_en   <= 1'b0;
      cfg_irq_en      <= 1'b0;
      cfg_tx_polarity <= 1'b0;
      cfg_rx_polarity <= 1'b0;
      frame_lost      <= 1'b0;
      irq             <= 1'b0;
      fifo_tx_write   <= 1'b0;
      fifo_rx_read    <= 1'b0;
    end else begin

      if (valid && !ready) begin

        //Write
        case (addr)
          IR_CFG_CMD : begin
            wbs_dat_o[31]   <= cfg_ir_en        ; if (wbs_sel_i[3] && wbs_we_i) cfg_ir_en       <= wbs_dat_i[31];
            wbs_dat_o[30]   <= cfg_ir_tx_en     ; if (wbs_sel_i[3] && wbs_we_i) cfg_ir_tx_en    <= wbs_dat_i[30];
            wbs_dat_o[29]   <= cfg_ir_rx_en     ; if (wbs_sel_i[3] && wbs_we_i) cfg_ir_rx_en    <= wbs_dat_i[29];
            wbs_dat_o[28]   <= cfg_repeat_en    ; if (wbs_sel_i[3] && wbs_we_i) cfg_repeat_en   <= wbs_dat_i[28];
            wbs_dat_o[27]   <= cfg_irq_en       ; if (wbs_sel_i[3] && wbs_we_i) cfg_irq_en      <= wbs_dat_i[27];
            wbs_dat_o[26]   <= cfg_rx_polarity  ; if (wbs_sel_i[3] && wbs_we_i) cfg_rx_polarity <= wbs_dat_i[26];
            wbs_dat_o[25]   <= cfg_tx_polarity  ; if (wbs_sel_i[3] && wbs_we_i) cfg_tx_polarity <= wbs_dat_i[25];
            wbs_dat_o[24]   <= cfg_tolerance[1] ; if (wbs_sel_i[3] && wbs_we_i) cfg_tolerance[1]<= wbs_dat_i[24];
            wbs_dat_o[23]   <= cfg_tolerance[0] ; if (wbs_sel_i[2] && wbs_we_i) cfg_tolerance[0]<= wbs_dat_i[23];
            wbs_dat_o[22:8] <= 'b0;
            wbs_dat_o[7:4]  <= fifo_tx_occ;
            wbs_dat_o[3:0]  <= fifo_rx_occ;
          end
          IR_CFG_MULTIPLIER : begin
             wbs_dat_o    <= cfg_multiplier;
            if(wbs_sel_i[0] && wbs_we_i) cfg_multiplier[7:0]   <= wbs_dat_i[7:0];
            if(wbs_sel_i[1] && wbs_we_i) cfg_multiplier[15:8]  <= wbs_dat_i[15:8];
            if(wbs_sel_i[2] && wbs_we_i) cfg_multiplier[23:16] <= wbs_dat_i[23:16];
            if(wbs_sel_i[3] && wbs_we_i) cfg_multiplier[31:24] <= wbs_dat_i[31:24];
          end
          IR_CFG_DIVIDER : begin
            wbs_dat_o <= cfg_divider;
            if(wbs_sel_i[0] && wbs_we_i) cfg_divider[7:0]   <= wbs_dat_i[7:0];
            if(wbs_sel_i[1] && wbs_we_i) cfg_divider[15:8]  <= wbs_dat_i[15:8];
            if(wbs_sel_i[2] && wbs_we_i) cfg_divider[23:16] <= wbs_dat_i[23:16];
            if(wbs_sel_i[3] && wbs_we_i) cfg_divider[31:24] <= wbs_dat_i[31:24];
          end
          IR_CFG_RX_DATA : begin
             if (fifo_rx_available == 1'b1 && !wbs_we_i) begin
               wbs_dat_o[31]    <= 1'b1;
               wbs_dat_o[30]    <= rx_frame_repeat;
               wbs_dat_o[29]    <= frame_lost;
               wbs_dat_o[28:16] <= 13'b0;
               wbs_dat_o[15:8]  <= rx_frame_addr;
               wbs_dat_o[7:0]   <= rx_frame_data;
               fifo_rx_read     <= 1'b0;
             end else begin
               wbs_dat_o[31:0]  <= 'b0;
             end
          end
          IR_CFG_TX_DATA : begin
             if (fifo_tx_full == 1'b0 && wbs_we_i) begin
                fifo_tx_wdata <= wbs_dat_i[15:0];
                fifo_tx_write <= 1'b1;
             end 
          end
          default:  wbs_dat_o[31:0]  <= 'b0;
        endcase

        ready <= 1'b1;
      end else begin
        fifo_tx_write <= 1'b0;
        fifo_rx_read  <= 1'b0;
        ready <= 1'b0;
      end

      if ((rx_frame_new == 1'b1) && (fifo_rx_full == 1'b1)) begin
         frame_lost <= 1'b1;
      end else if (valid && !ready && rstrb && (addr == IR_CFG_RX_DATA)) begin
         frame_lost <= 1'b0;
      end

      if (valid && !ready && rstrb && (addr == IR_CFG_RX_DATA) && fifo_rx_available) begin
         fifo_rx_read <= 1'b1;
      end else begin
         fifo_rx_read <= 1'b0;
      end

      if ((cfg_irq_en == 1'b1) && (rx_frame_new == 1'b1)) begin
         irq <= 1'b1;
      end else begin
         irq <= 1'b0;
      end

    end
  end

  always @(*) begin
    case (cfg_tolerance)
      2'b00 : begin
        reload_offset = {{(DSIZE-3){1'b0}}, 3'b001};
        delay_mask    = {{(DSIZE-3){1'b1}}, 3'b110};
      end
      2'b01 : begin
        reload_offset = {{(DSIZE-3){1'b0}}, 3'b010};
        delay_mask    = {{(DSIZE-3){1'b1}}, 3'b100};
      end
      default : begin
        reload_offset = {{(DSIZE-3){1'b0}}, 3'b100};
        delay_mask    = {{(DSIZE-3){1'b1}}, 3'b000};
      end
    endcase
  end

endmodule
