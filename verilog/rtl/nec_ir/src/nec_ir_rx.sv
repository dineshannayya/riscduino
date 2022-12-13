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
                                                              
          NEC IR RX                                                  
                                                                      
          This file is part of the riscduino cores project            
          https://github.com/dineshannayya/riscduino.git              
                                                                      
          Description:                                                 
              This block integrate
                A. metastability_filter
                B. pulse_filter
                C. nec_ir_event_catcher
                                                                      
          To Do:                                                      
            nothing                                                   
                                                                      
          Author(s): 
              - Julien OURY <julien.oury@outlook.fr>                                                 
              - Dinesh Annayya <dinesh.annayya@gmail.com>
                                                                      
          Revision :                                                  
            0.1 - 11 Dec 2022, Dinesh A                               
                  initial version picked from 
                  https://github.com/JulienOury/ChristmasTreeController                                    
***************************************************************************/

module nec_ir_rx #(
  parameter NB_STAGES =  3          , // Number of metastability filter stages
  parameter PSIZE     = 32          , // Size of prescaler counter(bits)
  parameter DSIZE     = 32          , // Size of delay counter (bits)
  parameter ASIZE     =  3            // FIFO size (FIFO_size=(2**ASIZE)-1)
)(

  input  logic             rst_n         , // Asynchronous reset (active low)
  input  logic             clk           , // Clock (rising edge)

  input  logic             ir_rx         ,
  input  logic             tick8         ,
  input  logic             cfg_receiver_en   ,
  input  logic             cfg_polarity  , 
  input  logic             cfg_repeat_en     ,
  input  logic [DSIZE-1:0] reload_offset ,
  input  logic [DSIZE-1:0] delay_mask    ,
 
  output logic[16:0]       fifo_rx_wdata    ,
  output logic             fifo_rx_write    

);

  logic [DSIZE-1:0] event_delay    ;
  wire             ir_meta_f       ;
  wire             ir_meta         ;
  wire             value           ;
  wire             new_sample      ;
  wire             event_new       ;
  wire             event_type      ;
  wire             event_timeout   ;
  wire [7:0]       frame_addr      ;
  wire [7:0]       frame_data      ;
  wire             frame_repeat    ;

  metastability_filter #(
    .NB_STAGES(NB_STAGES)
  ) i_metastability_filter (
    .rst_n      (rst_n      ),
    .clk        (clk        ),
    .i_raw      (ir_rx      ),
    .o_filtered (ir_meta_f  )
  );

  // Invert polarity if needed
  assign ir_meta = (cfg_polarity==0) ? ir_meta_f : ~ir_meta_f;

  pulse_filter i_pulse_filter (
    .rst_n   (rst_n      ),
    .clk     (clk        ),
    .clear_n (cfg_receiver_en),
    .i_value (ir_meta    ),
    .i_valid (tick8      ),
    .o_value (value      ),
    .o_valid (new_sample )
  );

  nec_ir_event_catcher #(
    .DBITS(DSIZE)
  ) i_event_catcher (
    .rst_n         (rst_n        ),
    .clk           (clk          ),
    .clear_n       (cfg_receiver_en  ),
    .reload_offset (reload_offset),
    .i_value       (value        ),
    .i_valid       (new_sample   ),
    .event_new     (event_new    ),
    .event_type    (event_type   ),
    .event_delay   (event_delay  ),
    .event_timeout (event_timeout)
  );

  nec_ir_frame_decoder #(
    .DBITS(DSIZE)
  ) i_frame_decoder (
    .rst_n         (rst_n        ),
    .clk           (clk          ),

    .receiver_en   (cfg_receiver_en  ),
    .repeat_en     (cfg_repeat_en    ),
    .delay_mask    (delay_mask   ),

    // Input event interface
    .event_new     (event_new    ),
    .event_type    (event_type   ),
    .event_delay   (event_delay  ),
    .event_timeout (event_timeout),

    // Output frame interface
    .frame_addr    (frame_addr   ),
    .frame_data    (frame_data   ),
    .frame_repeat  (frame_repeat ),
    .frame_write   (fifo_rx_write  )
  );

  assign       fifo_rx_wdata = {frame_repeat, frame_addr, frame_data};


endmodule
