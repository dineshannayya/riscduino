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
// SPDX-FileContributor: Created by Dinesh Annayya <dinesh.annayya@gmail.com>
//
//////////////////////////////////////////////////////////////////////
module pwm_core (

	input  logic          h_reset_n         ,
	input  logic          mclk              ,

// Reg Bus Interface Signal
    input logic           reg_cs            ,
    input logic           reg_wr            ,
    input logic [1:0]     reg_addr          ,
    input logic [31:0]    reg_wdata         ,
    input logic [3:0]     reg_be            ,

    // Outputs
    output logic [31:0]   reg_rdata         ,
    output logic          reg_ack           ,

    input   logic         cfg_pwm_enb       , // pwm operation enable
    input   logic         cfg_pwm_run       , // pwm operation Run
    input   logic         cfg_pwm_dupdate   , // Disable Config update
    input   logic [7:0]   pad_gpio          ,
	output  logic         pwm_wfm_o         ,
	output  logic         pwm_os_done          ,
	output  logic         pwm_ovflow        ,
    output  logic         gpio_tgr          



);

logic [3:0]               cfg_pwm_scale     ; // pwm clock scaling
logic                     cfg_pwm_oneshot   ; // pwm OneShot mode
logic                     cfg_pwm_frun      ; // pwm is free running
logic                     cfg_pwm_gpio_enb  ; // pwm gpio based trigger
logic                     cfg_pwm_gpio_edge ; // pwm gpio based trigger edge
logic [2:0]               cfg_pwm_gpio_sel  ; // gpio Selection
logic                     cfg_pwm_hold      ; // Hold data pwm data During pwm Disable
logic                     cfg_pwm_inv       ; // invert output
logic                     cfg_pwm_zeropd    ; // Reset on pmw_cnt match to period
logic [1:0]               cfg_pwm_mode      ; // pwm Pulse Generation mode
logic                     cfg_comp0_center  ; // Compare cnt at comp0 center
logic                     cfg_comp1_center  ; // Compare cnt at comp1 center
logic                     cfg_comp2_center  ; // Compare cnt at comp2 center
logic                     cfg_comp3_center  ; // Compare cnt at comp3 center
logic [15:0]              cfg_pwm_period    ; // pwm period
logic [15:0]              cfg_pwm_comp0     ; // compare0
logic [15:0]              cfg_pwm_comp1     ; // compare1
logic [15:0]              cfg_pwm_comp2     ; // compare2
logic [15:0]              cfg_pwm_comp3     ; // compare3




pwm_blk_reg  u_reg (
		               .mclk                (mclk                ),
                       .h_reset_n           (h_reset_n           ),
                                                               
                       .reg_cs              (reg_cs              ),
                       .reg_wr              (reg_wr              ),
                       .reg_addr            (reg_addr            ),
                       .reg_wdata           (reg_wdata           ),
                       .reg_be              (reg_be              ),
                                                               
                       .reg_rdata           (reg_rdata           ),
                       .reg_ack             (reg_ack             ),
                                                               
                       .cfg_pwm_enb         (cfg_pwm_enb         ), // PWM operation enable
                       .cfg_pwm_dupdate     (cfg_pwm_dupdate     ), // Disable Config update
                       .pwm_cfg_update      (pwm_ovflow          ), // Update the pwm config on roll-over or completion
                                                               
                       .cfg_pwm_scale       (cfg_pwm_scale       ), // clock scaling
                       .cfg_pwm_oneshot     (cfg_pwm_oneshot     ), // PWM OneShot mode
                       .cfg_pwm_frun        (cfg_pwm_frun        ), // PWM is free running
                       .cfg_pwm_gpio_enb    (cfg_pwm_gpio_enb    ), // PWM GPIO based trigger enable
                       .cfg_pwm_gpio_edge   (cfg_pwm_gpio_edge   ), // PWM GPIO based trigger edge
                       .cfg_pwm_gpio_sel    (cfg_pwm_gpio_sel    ), // GPIO Selection
                       .cfg_pwm_hold        (cfg_pwm_hold        ), // Hold data PWM data During PWM Disable
                       .cfg_pwm_inv         (cfg_pwm_inv         ), // invert output
                       .cfg_pwm_zeropd      (cfg_pwm_zeropd      ), // Reset on pmw_cnt match to period
                       .cfg_pwm_mode        (cfg_pwm_mode        ), // PWM Pulse Generation mode
                       .cfg_comp0_center    (cfg_comp0_center    ), // Compare cnt at comp0 center
                       .cfg_comp1_center    (cfg_comp1_center    ), // Compare cnt at comp1 center
                       .cfg_comp2_center    (cfg_comp2_center    ), // Compare cnt at comp2 center
                       .cfg_comp3_center    (cfg_comp3_center    ), // Compare cnt at comp3 center
                       .cfg_pwm_period      (cfg_pwm_period      ), // PWM period
                       .cfg_pwm_comp0       (cfg_pwm_comp0       ), // compare0
                       .cfg_pwm_comp1       (cfg_pwm_comp1       ), // compare1
                       .cfg_pwm_comp2       (cfg_pwm_comp2       ), // compare2
                       .cfg_pwm_comp3       (cfg_pwm_comp3       )  // compare3

                ); 



pwm  u_pwm     (
	                   .h_reset_n             (h_reset_n             ),
	                   .mclk                  (mclk                  ),
                                                                    
	                   .pwm_wfm_o             (pwm_wfm_o             ),
	                   .pwm_os_done           (pwm_os_done           ),
	                   .pwm_ovflow_pe         (pwm_ovflow            ),
                       .gpio_tgr              (gpio_tgr              ),
                                                                    
                       .pad_gpio              (pad_gpio              ),
                                                                    
                       .cfg_pwm_enb           (cfg_pwm_enb           ), 
                       .cfg_pwm_run           (cfg_pwm_run           ), 
                       .cfg_pwm_scale         (cfg_pwm_scale         ), 
                       .cfg_pwm_oneshot       (cfg_pwm_oneshot       ), 
                       .cfg_pwm_frun          (cfg_pwm_frun          ), 
                       .cfg_pwm_gpio_enb      (cfg_pwm_gpio_enb      ), 
                       .cfg_pwm_gpio_edge     (cfg_pwm_gpio_edge     ), 
                       .cfg_pwm_gpio_sel      (cfg_pwm_gpio_sel      ), 
                       .cfg_pwm_hold          (cfg_pwm_hold          ), 
                       .cfg_pwm_inv           (cfg_pwm_inv           ), 
                       .cfg_pwm_zeropd        (cfg_pwm_zeropd        ), 
                       .cfg_pwm_mode          (cfg_pwm_mode          ), 
                       .cfg_comp0_center      (cfg_comp0_center      ), 
                       .cfg_comp1_center      (cfg_comp1_center      ), 
                       .cfg_comp2_center      (cfg_comp2_center      ), 
                       .cfg_comp3_center      (cfg_comp3_center      ), 
                       .cfg_pwm_period        (cfg_pwm_period        ), 
                       .cfg_pwm_comp0         (cfg_pwm_comp0         ), 
                       .cfg_pwm_comp1         (cfg_pwm_comp1         ), 
                       .cfg_pwm_comp2         (cfg_pwm_comp2         ), 
                       .cfg_pwm_comp3         (cfg_pwm_comp3         )  
              );

endmodule
