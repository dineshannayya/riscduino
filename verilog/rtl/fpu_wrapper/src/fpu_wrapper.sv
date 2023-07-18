/*********************************************************************************
 SPDX-FileCopyrightText: 2021 , Dinesh Annayya                          
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 SPDX-License-Identifier: Apache-2.0
 SPDX-FileContributor: Created by Dinesh Annayya <dinesh.annayya@gmail.com>

***********************************************************************************/
/**********************************************************************************
                                                              
                   FPU Wrapper
                                                              
  Description                                                 
     This module includes fpu register and FPU Single Point Computing logic 
     
  To Do:                                                      
                                                              
  Author(s):                                                  
      - Dinesh Annayya, dinesh.annayya@gmail.com                 
                                                              
  Revision :                                                  
     0.0  - Nov 9, 2022 
            Initial Version
           
                                                              
************************************************************************************/


module fpu_wrapper #( parameter WB_WIDTH = 32) (
`ifdef USE_POWER_PINS
    input logic                          vccd1,    // User area 1 1.8V supply
    input logic                          vssd1,    // User area 1 digital ground
`endif

    input  logic                         mclk,
    input  logic                         rst_n,

    input  logic   [3:0]                 cfg_cska,
    input  logic                         wbd_clk_int,
    output logic                         wbd_clk_out,

    input   logic                        dmem_req,
    input   logic                        dmem_cmd,
    input   logic [1:0]                  dmem_width,
    input   logic [4:0]                  dmem_addr,
    input   logic [31:0]                 dmem_wdata,
    output  logic                        dmem_req_ack,
    output  logic [31:0]                 dmem_rdata,
    output  logic [1:0]                  dmem_resp,


    output  logic                        idle
);


logic rst_ss_n;

// FPU local variable
logic         cfg_fpu_val  ;                   
logic         fpu_done     ; 
logic [3:0]   cfg_fpu_cmd  ;                   
logic [31:0]  cfg_fpu_din1 ;
logic [31:0]  cfg_fpu_din2 ;
logic [31:0]  fpu_result   ;



//###################################
// Clock Skey for WB clock
//###################################
clk_skew_adjust u_skew
       (
`ifdef USE_POWER_PINS
           .vccd1      (vccd1                      ),// User area 1 1.8V supply
           .vssd1      (vssd1                      ),// User area 1 digital ground
`endif
	       .clk_in     (wbd_clk_int                ), 
	       .sel        (cfg_cska                   ), 
	       .clk_out    (wbd_clk_out                ) 
       );

//###################################
// Application Reset Synchronization
//###################################
reset_sync  u_app_rst (
	         .scan_mode  (1'b0                     ),
             .dclk       (mclk                     ), // Destination clock domain
	         .arst_n     (rst_n                    ), // active low async reset
             .srst_n     (rst_ss_n                 )
          );


//###################################
// FPU Register
//###################################
fpu_reg u_reg(
        .mclk                           (mclk                         ),
        .rst_n                          (rst_ss_n                     ),

        .dmem_req                       (dmem_req                     ), 
        .dmem_cmd                       (dmem_cmd                     ), 
        .dmem_width                     (dmem_width                   ), 
        .dmem_addr                      (dmem_addr                    ), 
        .dmem_wdata                     (dmem_wdata                   ), 
        .dmem_req_ack                   (dmem_req_ack                 ), 
        .dmem_rdata                     (dmem_rdata                   ), 
        .dmem_resp                      (dmem_resp                    ), 

      // FPU Reg Interface
        .cfg_fpu_val                    (cfg_fpu_val                  ),
        .fpu_done                       (fpu_done                     ),
        .cfg_fpu_cmd                    (cfg_fpu_cmd                  ),
        .cfg_fpu_din1                   (cfg_fpu_din1                 ),
        .cfg_fpu_din2                   (cfg_fpu_din2                 ),
        .fpu_result                     (fpu_result                   ),

        .idle                           (idle                         )

      );

//###################################
// FPU Single Point Precsion 
//###################################
fpu_sp_top   u_fpu_core(
        .clk                            (mclk                        ),
        .rst_n                          (rst_ss_n                    ),
	    .cmd                            (cfg_fpu_cmd                 ),
        .din1                           (cfg_fpu_din1                ),
        .din2                           (cfg_fpu_din2                ),
        .dval                           (cfg_fpu_val                 ),
        .result                         (fpu_result                  ),
        .rdy                            (fpu_done                    )
);


endmodule


