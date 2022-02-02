///////////////////////////////////////////////////////////////////////
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
////                                                              ////
////  MBIST Address Repair                                        ////
////                                                              ////
////  This file is part of the mbist_ctrl cores project           ////
////  https://github.com/dineshannayya/mbist_ctrl.git             ////
////                                                              ////
////  Description                                                 ////
////      This block integrate mbist address repair               ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.0 - 11th Oct 2021, Dinesh A                             ////
////          Initial integration                                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////


// BIST address Repair Logic

`include "mbist_def.svh"

module mbist_repair_addr 
     #(  parameter BIST_ADDR_WD           = 9,
	 parameter BIST_DATA_WD           = 32,
	 parameter BIST_ADDR_START        = 9'h000,
	 parameter BIST_ADDR_END          = 9'h1F8,
	 parameter BIST_REPAIR_ADDR_START = 9'h1FC,
	 parameter BIST_RAD_WD_I          = BIST_ADDR_WD,
	 parameter BIST_RAD_WD_O          = BIST_ADDR_WD) (
	
    output logic [BIST_RAD_WD_O-1:0] AddressOut,
    output logic                     Correct,
    output  logic                    sdo,         //  scan data output

    input logic [BIST_RAD_WD_I-1:0]  AddressIn,
    input logic                      clk,
    input logic                      rst_n,
    input logic                      Error,
    input logic [BIST_RAD_WD_I-1:0]  ErrorAddr,
    input logic                      bist_load,
    input logic                      bist_shift,  //  shift scan input
    input logic                      sdi          //  scan data input 


);

logic [3:0]   ErrorCnt; // Assumed Maximum Error correction is less than 16

logic [BIST_RAD_WD_I-1:0] RepairMem [0:BIST_ERR_LIMIT-1];
integer i;


always@(posedge clk or negedge rst_n)
begin
   if(!rst_n) begin
     ErrorCnt    <= '0;
     Correct <= '0;
     // Initialize the Repair RAM for SCAN purpose
     for(i =0; i < BIST_ERR_LIMIT; i = i+1) begin
        RepairMem[i] = 'h0;
     end
   end else if(Error) begin
      if(ErrorCnt <= BIST_ERR_LIMIT) begin
          ErrorCnt            <= ErrorCnt+1;
          RepairMem[ErrorCnt] <= ErrorAddr;
          Correct         <= 1'b1;
      end else begin
          Correct         <= 1'b0;
      end
   end
end

integer index;

always_comb
begin
   AddressOut = AddressIn;
   for(index=0; index < BIST_ERR_LIMIT; index=index+1) begin
      if(ErrorCnt > index && AddressIn == RepairMem[index]) begin
	  AddressOut = BIST_REPAIR_ADDR_START+index;
	  $display("STATUS: MBIST ADDRESS REPAIR: %m => Old Addr: %x Nex Addr: %x",AddressIn,AddressOut);
      end
   end
end

/********************************************
* Serial shifting the Repair address
* *******************************************/
integer j;
logic [0:BIST_ERR_LIMIT-1] sdi_in;
logic [0:BIST_ERR_LIMIT-1] sdo_out;
// Daisy chain the Serial In/OUT 
always_comb begin
   for(j =0; j < BIST_ERR_LIMIT; j=j+1) begin
      sdi_in[j] =(j==0) ?  sdi :  sdo_out[j-1];
   end
end

assign  sdo = sdo_out[BIST_ERR_LIMIT-1];

genvar no;
generate 
for (no = 0; $unsigned(no) < BIST_ERR_LIMIT; no=no+1) begin : num

 ser_shift
     #(.WD(16)) u_shift(

    // Master Port
       .rst_n       (rst_n         ),
       .clk         (clk           ), 
       .load        (bist_load     ),
       .shift       (bist_shift    ),
       .load_data   (RepairMem[no] ), 
       .sdi         (sdi_in[no]    ),  
       .sdo         (sdo_out[no]   )  


    );
end
endgenerate

endmodule






