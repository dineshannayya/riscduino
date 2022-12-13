
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
/**********************************************************************
                                                              
          NEC IR Transmitter                                                  
                                                                      
          This file is part of the riscduino cores project            
          https://github.com/dineshannayya/riscduino.git              
                                                                      
          To Do:                                                      
            nothing                                                   
                                                                      
          Author(s):                                                  
              - Dinesh Annayya, dinesh.annayya@gmail.com                 
                                                                      
          Revision :                                                  
            0.1 - 12 Dec 2022, Dinesh A                               
                  initial version                                     
***************************************************************************/

/************************************************
https://techdocs.altium.com/display/FPGA/NEC+Infrared+Transmission+Protocol
The NEC IR transmission protocol uses pulse distance encoding of the message bits. Each pulse burst (mark – RC transmitter ON) is 562.5µs in length, 
at a carrier frequency of 38kHz (26.3µs). Logical bits are transmitted as follows:

    Logical '0' – a 562.5µs pulse burst followed by a 562.5µs space, with a total transmit time of 1.125ms
    Logical '1' – a 562.5µs pulse burst followed by a 1.6875ms space, with a total transmit time of 2.25ms

When a key is pressed on the remote controller, the message transmitted consists of the following, in order:

    * 9ms leading pulse burst (16 times the pulse burst length used for a logical data bit)
    * 4.5ms space
    * the 8-bit address for the receiving device
    * the 8-bit logical inverse of the address
    * the 8-bit command
    * the 8-bit logical inverse of the command
    * final 562.5µs pulse burst to signify the end of message transmission.

*************************************************************************************************************/


module nec_ir_tx (
  input  logic         rst_n          , // Asynchronous reset (active low)
  input  logic         clk            , // Clock (rising edge)

  // Configuration Input
  input  logic         tx_en          , // Transmitter enable
  input  logic         tx_event       , // Transmit event at every 562.5µs 
  input  logic         p_polarity     ,

  // FIFO Interface
  input  logic         fifo_valid     ,  
  input  logic  [15:0] fifo_tx_rdata  , // Frame address
  output logic         fifo_read      ,

  // To Pad
  output logic         ir_tx      

);


// FSM STATE
parameter S_IDLE            = 3'b000;
parameter S_START_BURST     = 3'b001;
parameter S_START_SPACE     = 3'b010;
parameter S_DATA_BURST      = 3'b011;
parameter S_DATA_SPACE      = 3'b100;
parameter S_STOP            = 3'b101;

// Data Phase
parameter P_TX_ADDR     = 2'b00;
parameter P_TX_INV_ADDR = 2'b01;
parameter P_TX_DATA     = 2'b10;
parameter P_TX_INV_DATA = 2'b11;

logic [7:0] tx_data;
logic [2:0] s_state;
logic [1:0] s_data_phase;
logic [3:0] tick_cnt;
logic [2:0] bit_cnt;

wire [7:0] addr_cmd = fifo_tx_rdata[15:8];
wire [7:0] data_cmd = fifo_tx_rdata[7:0];


assign tx_data = (s_data_phase ==  P_TX_ADDR)     ? addr_cmd  :     // Transmit Address
                 (s_data_phase ==  P_TX_INV_ADDR) ? ~addr_cmd :     // logical inverse of the address
                 (s_data_phase ==  P_TX_DATA)     ? data_cmd  :     // Transmit Data 
                 (s_data_phase ==  P_TX_INV_DATA) ? ~data_cmd :     // logical inverse of the data
                 'h0;


always @(negedge rst_n or posedge clk) begin
   if (rst_n == 1'b0) begin
      ir_tx       <= 0;
      tick_cnt    <= 0;
      bit_cnt     <= 0;
      fifo_read   <= 0;
      s_data_phase <= P_TX_ADDR;
      s_state     <= S_IDLE;
   end else begin
      if (tx_en == 1'b0) begin
        s_state   <= S_IDLE;
        ir_tx     <= ~p_polarity;
        tick_cnt  <= 0;
        bit_cnt   <= 0;
        fifo_read <= 0;
      end else if (tx_event == 1'b1) begin
         case(s_state        )
            S_IDLE: begin
               if(fifo_valid == 1'b1) begin
                  s_state         <= S_START_BURST;
                  ir_tx           <= p_polarity;
                  tick_cnt        <= 0;
               end else begin
                  ir_tx           <= ~p_polarity;
               end
            end
            // 9ms leading pulse burst (16 times the pulse burst length used for a logical data bit)
            S_START_BURST: begin
               if(tick_cnt == 15) begin
                  ir_tx           <= ~p_polarity;
                  s_state         <= S_START_SPACE;
                  tick_cnt        <= 0;
               end else begin
                  tick_cnt <= tick_cnt + 1;
               end
            end
            // 4.5ms space
            S_START_SPACE: begin
               if(tick_cnt == 7) begin
                  ir_tx           <= p_polarity;
                  s_state         <= S_DATA_BURST;
                  tick_cnt        <= 0;
                  bit_cnt         <= 0;
                  s_data_phase    <= P_TX_ADDR;
               end else begin
                  tick_cnt <= tick_cnt + 1;
               end
            end
            S_DATA_BURST: begin
               ir_tx           <=  ~p_polarity;
               s_state         <=  S_DATA_SPACE;
               tick_cnt       <= 0;
            end
            S_DATA_SPACE: begin
                  //Logical '0' – a 562.5µs pulse burst followed by a 562.5µs space, with a total transmit time of 1.125ms
                  //Logical '1' – a 562.5µs pulse burst followed by a 1.6875ms space, with a total transmit time of 2.25ms
                  if(tx_data[bit_cnt] == 1'b1 && tick_cnt == 2) begin
                     ir_tx     <= p_polarity;
                     if(bit_cnt == 7) begin
                         case(s_data_phase)
                         P_TX_ADDR:     begin s_data_phase <= P_TX_INV_ADDR; s_state <= S_DATA_BURST; end
                         P_TX_INV_ADDR: begin s_data_phase <= P_TX_DATA;     s_state <= S_DATA_BURST; end
                         P_TX_DATA:     begin s_data_phase <= P_TX_INV_DATA; s_state <= S_DATA_BURST; end
                         P_TX_INV_DATA: begin fifo_read    <= 1;             s_state <= S_STOP;       end
                         endcase
                         bit_cnt  <= 0;
                     end else begin
                        bit_cnt   <= bit_cnt+1;
                        s_state   <=  S_DATA_BURST;
                     end
                  end else if(tx_data[bit_cnt] == 1'b0 && tick_cnt == 0) begin
                     ir_tx     <= p_polarity;
                     if(bit_cnt == 7) begin
                         case(s_data_phase)
                         P_TX_ADDR:     begin s_data_phase <= P_TX_INV_ADDR; s_state  <= S_DATA_BURST; end
                         P_TX_INV_ADDR: begin s_data_phase <= P_TX_DATA;     s_state  <= S_DATA_BURST; end
                         P_TX_DATA:     begin s_data_phase <= P_TX_INV_DATA; s_state  <= S_DATA_BURST; end
                         P_TX_INV_DATA: begin fifo_read    <= 1;             s_state  <= S_STOP;       end
                         endcase
                         bit_cnt  <= 0;
                     end else begin
                        bit_cnt   <= bit_cnt+1;
                        s_state    <=  S_DATA_BURST;
                     end
                  end else begin
                      tick_cnt <= tick_cnt+1;
                  end
            end
            S_STOP: begin
               ir_tx           <=  ~p_polarity;
               fifo_read       <=  0;
               s_state         <=  S_IDLE;
            end
            default : s_state         <=  S_IDLE;
         endcase
      end else begin
         fifo_read       <=  0;
      end
   end
end


endmodule
