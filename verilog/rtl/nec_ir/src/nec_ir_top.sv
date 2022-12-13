
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
                                                              
          NEC IR Top                                                  
                                                                      
          This file is part of the riscduino cores project            
          https://github.com/dineshannayya/riscduino.git              
                                                                      
          Description:                                                 
              This block integrate
                A. NEC IR Transmitter
                B. NEC IR Reciver
                C. Prescalar
                D. Register Block
                E. FIFO Block
                                                                      
          To Do:                                                      
            nothing                                                   
                                                                      
          Author(s):                                                  
              - Dinesh Annayya, dinesh.annayya@gmail.com                 
                                                                      
          Revision :                                                  
            0.1 - 11 Dec 2022, Dinesh A                               
                  initial version                                     
            0.2 - 13 Dec 2022, Dinesh A
                  A. Bug fix, Read access clearing the register content
                  B. FIFO Occpancy added
                  C. Support for IR Transmitter
***************************************************************************/
/*************************************************************************************
Documentation Collection by Dinesh-A - dinesh.annayya@gmail.com
Reference: https://techdocs.altium.com/display/FPGA/NEC+Infrared+Transmission+Protocol

The NEC IR transmission protocol uses pulse distance encoding of the message bits. Each pulse burst (mark – RC transmitter ON) is 
562.5µs in length, at a carrier frequency of 38kHz (26.3µs). Logical bits are transmitted as follows:
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

Repeat Codes

If the key on the remote controller is kept depressed, a repeat code will be issued, typically around 40ms after 
the pulse burst that signified the end of the message. A repeat code will continue to be sent out at 108ms intervals, 
until the key is finally released. The repeat code consists of the following, in order:

    * 9ms leading pulse burst
    * 2.25ms space
    * 562.5µs pulse burst to mark the end of the space (and hence end of the transmitted repeat code).



*************************************************************************************/

module nec_ir_top #(
  parameter NB_STAGES =  3     , // Number of metastability filter stages
  parameter PSIZE     = 32     , // Size of prescaler counter(bits)
  parameter DSIZE     = 32     , // Size of delay counter (bits)
  parameter ASIZE     =  3     , // FIFO size (FIFO_size=(2**ASIZE)-1)
  parameter DP        =  8       // FIFO DEPTH = 2**SIZE
)(

  input  logic        rst_n     , // Asynchronous reset (active low)
  input  logic        clk       , // Clock (rising edge)

  // Wishbone bus
  input  logic        wbs_cyc_i , // Wishbone strobe/request
  input  logic        wbs_stb_i , // Wishbone strobe/request
  input  logic [4:0]  wbs_adr_i , // Wishbone address
  input  logic        wbs_we_i  , // Wishbone write (1:write, 0:read)
  input  logic [31:0] wbs_dat_i , // Wishbone data output
  input  logic [3:0]  wbs_sel_i , // Wishbone byte enable
  output logic [31:0] wbs_dat_o , // Wishbone data input
  output logic        wbs_ack_o , // Wishbone acknowlegement

  input  logic        ir_rx     ,
  output logic       ir_tx     ,

  output logic        irq         // Interrupt

);

//-----------------------------------------------
// Reg Interface
//------------------------------------------------
  logic             cfg_ir_en          ;
  logic             cfg_ir_tx_en       ;
  logic             cfg_ir_rx_en       ;
  logic             cfg_repeat_en      ;
  logic             cfg_tx_polarity       ;
  logic             cfg_rx_polarity       ;
  logic [PSIZE-1:0] cfg_multiplier     ;
  logic [PSIZE-1:0] cfg_divider        ;
  logic [DSIZE-1:0] reload_offset      ;
  logic [DSIZE-1:0] delay_mask         ;

//---------------------------------------------
// Prescal Output
//----------------------------------------------
  logic             tick8              ; // 562.5µs/8 Pulse
  logic             tick1              ; // 562.5µs pulse

//---------------------------------------------
// FIFO RX I/F
// <IR RECEIVER> => <RX FIFO> => WB
//----------------------------------------------
  logic             fifo_rx_full       ;
  logic             fifo_rx_empty      ;
  logic             fifo_rx_write      ;
  logic [16:0]      fifo_rx_wdata      ;
  logic [16:0]      fifo_rx_rdata      ;
  logic             fifo_rx_read       ;
  logic [ASIZE:0]   fifo_rx_occ        ;

//---------------------------------------------
// FIFO TX I/F
// <WB> => <TX FIFO> =>  <IR Transmitter>
//----------------------------------------------
  logic             fifo_tx_full       ;
  logic             fifo_tx_empty      ;
  logic             fifo_tx_write      ;
  logic [15:0]      fifo_tx_wdata      ;
  logic [15:0]      fifo_tx_rdata      ;
  logic             fifo_tx_read       ;
  logic [ASIZE:0]   fifo_tx_occ        ;

// ---   Prescaler   ---
  prescaler #(
    .BITS(PSIZE)
  ) i_prescaler (
    .rst_n           (rst_n                 ),
    .clk             (clk                   ),
    .clear_n         (cfg_ir_en             ),
    .multiplier      (cfg_multiplier        ),
    .divider         (cfg_divider           ),
    .tick            (tick8                 )
  );

// ---   Register   ---

  nec_ir_regs #(
    .PSIZE(PSIZE),
    .DSIZE(DSIZE),
    .ASIZE(ASIZE)
  ) i_ir_regs (
    .rst_n             (rst_n              ),
    .clk               (clk                ),

   // Configuration
    .cfg_ir_en         (cfg_ir_en          ),
    .cfg_ir_tx_en      (cfg_ir_tx_en       ),
    .cfg_ir_rx_en      (cfg_ir_rx_en       ),
    .cfg_repeat_en     (cfg_repeat_en      ),
    .cfg_tx_polarity   (cfg_tx_polarity    ),
    .cfg_rx_polarity   (cfg_rx_polarity    ),
    .cfg_multiplier    (cfg_multiplier     ),
    .cfg_divider       (cfg_divider        ),
    .reload_offset     (reload_offset      ),
    .delay_mask        (delay_mask         ),

    // Wishbone bus
    .wbs_cyc_i         (wbs_cyc_i          ),
    .wbs_stb_i         (wbs_stb_i          ),
    .wbs_adr_i         (wbs_adr_i          ),
    .wbs_we_i          (wbs_we_i           ),
    .wbs_dat_i         (wbs_dat_i          ),
    .wbs_sel_i         (wbs_sel_i          ),
    .wbs_dat_o         (wbs_dat_o          ),
    .wbs_ack_o         (wbs_ack_o          ),

   // <IR RECEIVER> => <RX FIFO> => WB
    .rx_frame_new      (fifo_rx_write      ),
    .fifo_rx_full      (fifo_rx_full       ),
    .fifo_rx_rdata     (fifo_rx_rdata      ),
    .fifo_rx_read      (fifo_rx_read       ),
    .fifo_rx_occ       (fifo_rx_occ        ),

  // <WB> => <TX FIFO> =>  <IR Transmitter>
    .fifo_tx_full      (fifo_tx_full       ),
    .fifo_tx_wdata     (fifo_tx_wdata      ),
    .fifo_tx_write     (fifo_tx_write      ),
    .fifo_tx_occ       (fifo_tx_occ        ),

    // Interrupt
    .irq               (irq               )

  );


// ---  RX FIFO   ---

  sync_fifo_occ #(
    .DP(DP),
    .WD(17),
    .AW(ASIZE)
  ) i_rx_fifo (
    .reset_n     (rst_n                ),
    .clk         (clk                  ),
    .sreset_n    (cfg_ir_en            ),
    .wr_data     (fifo_rx_wdata        ),
    .wr_en       (fifo_rx_write        ),
    .full        (fifo_rx_full         ),
    .empty       (fifo_rx_empty        ),
    .rd_data     (fifo_rx_rdata        ),
    .rd_en       (fifo_rx_read         ),
    .occupancy   (fifo_rx_occ          )
  );


// ---   IR Receiver  ---

nec_ir_rx #(
      .NB_STAGES (NB_STAGES), // Number of metastability filter stages
      .PSIZE     (PSIZE    ), // Size of prescaler counter(bits)
      .DSIZE     (DSIZE    ), // Size of delay counter (bits)
      .ASIZE     (ASIZE    )  // FIFO size (FIFO_size=(2**ASIZE)-1)
) u_ir_rx (

  .rst_n             (rst_n                ), // Asynchronous reset (active low)
  .clk               (clk                  ), // Clock (rising edge)
                                  
  .ir_rx             (ir_rx                ),
  .tick8             (tick8                ),
  .cfg_receiver_en   (cfg_ir_rx_en         ),
  .cfg_polarity      (cfg_rx_polarity      ), 
  .cfg_repeat_en     (cfg_repeat_en        ),
  .reload_offset     (reload_offset        ),
  .delay_mask        (delay_mask           ),
  .fifo_rx_wdata     (fifo_rx_wdata        ),
  .fifo_rx_write     (fifo_rx_write        ) 

);

// ---  IR Transmitter ----

// Div8 module
nec_div8 u_div8 (
       .rst_n         (rst_n                ), // Asynchronous reset (active low)
       .clk           (clk                  ), // Clock (rising edge)
       .tick          (tick8                ),
       .tick_div8     (tick1                )
    );


nec_ir_tx u_ir_tx(
  .rst_n         (rst_n                ), // Asynchronous reset (active low)
  .clk           (clk                  ), // Clock (rising edge)

  // Configuration Input
  .tx_en         (cfg_ir_tx_en         ), // Transmitter enable
  .tx_event      (tick1                ), // Transmit event at every 562.5µs 
  .p_polarity    (cfg_tx_polarity      ),

  // FIFO Interface
  .fifo_valid    (!fifo_tx_empty       ),  
  .fifo_tx_rdata (fifo_tx_rdata        ),
  .fifo_read     (fifo_tx_read         ),

  // To Pad
  .ir_tx          (ir_tx               )     

);

// ---  TX FIFO   ---

  sync_fifo_occ #(
    .DP(DP),
    .WD(16),
    .AW(ASIZE)
  ) i_tx_fifo (
    .reset_n     (rst_n                ),
    .clk         (clk                  ),
    .sreset_n    (cfg_ir_en            ),
    .wr_data     (fifo_tx_wdata        ),
    .wr_en       (fifo_tx_write        ),
    .full        (fifo_tx_full         ),
    .empty       (fifo_tx_empty        ),
    .rd_data     (fifo_tx_rdata        ),
    .rd_en       (fifo_tx_read         ),
    .occupancy   (fifo_tx_occ          )
  );


endmodule
