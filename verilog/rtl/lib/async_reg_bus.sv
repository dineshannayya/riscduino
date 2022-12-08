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

//----------------------------------------------------------------------------------------------
// This block translate the Reg Bus transaction from in_clk clock domain to out_clk clock domain.
// This block also generate and terminate the transfer if 512 cycle transaction is not completed
//  Assumption
//    1. in_reg_cs will be asserted untill ack is received
//    2. reg_addr/reg_wdata/reg_be will be available during reg_cs
//    3. Ever after out_reg_ack de-asserted reg_rdata holds the old data
//----------------------------------------------------------------------------------------------

module async_reg_bus (
    // Initiator declartion
           in_clk                    ,
           in_reset_n                ,
       // Reg Bus Master
          // outputs
          in_reg_rdata               ,
          in_reg_ack                 ,
          in_reg_timeout             ,

          // Inputs
          in_reg_cs                  ,
          in_reg_addr                ,
          in_reg_wdata               ,
          in_reg_wr                  ,
          in_reg_be                  ,

    // Target Declaration
          out_clk                    ,
          out_reset_n                ,
      // Reg Bus Slave
          // output
          out_reg_cs                 ,
          out_reg_addr               ,
          out_reg_wdata              ,
          out_reg_wr                 ,
          out_reg_be                 ,

          // Inputs
          out_reg_rdata              ,
          out_reg_ack
   );
parameter AW = 26         ; // Address width
parameter DW = 32         ; // DATA WIDTH
parameter BEW = 4         ; // Byte enable width
parameter TIMEOUT_ENB = 1 ; // TIMEOUT Generation enabled

//----------------------------------------
// Reg Bus reg inout declration
//----------------------------------------
input              in_clk             ; // Initiator domain clock
input              in_reset_n         ; // Initiator domain reset

input              in_reg_cs          ; // Initiator Chip Select
input  [AW-1:0]    in_reg_addr        ; // Address bus
input  [DW-1:0]    in_reg_wdata       ; // Write data
input              in_reg_wr          ; // Read/write indication, 1-> write
input  [BEW-1:0]   in_reg_be          ; // Byte valid for write

output [DW-1:0]    in_reg_rdata       ; // Read Data
output             in_reg_ack         ; // Reg Access done 
output             in_reg_timeout     ; // Access error indication pulse 
                                        // Genererated if no target ack 
                                        // received
                                        // within 512 cycle 

//---------------------------------------------
// Reg Bus target inout declration
//---------------------------------------------

input              out_clk           ; // Target domain clock
input              out_reset_n       ; // Traget domain reset

input [DW-1:0]     out_reg_rdata     ; // Read data
input              out_reg_ack       ; // target finish

output             out_reg_cs        ; // Target Start indication
output [AW-1:0]    out_reg_addr      ; // Target address
output [DW-1:0]    out_reg_wdata     ; // Target write data
output             out_reg_wr        ; // Target Read/write ind, 1-> Write
output [BEW-1:0]   out_reg_be        ; // Target Byte enable

//-----------------------------------
// Initiator Local Declaration
// ----------------------------------
parameter INI_IDLE             = 2'b00;
parameter INI_WAIT_ACK         = 2'b01;
parameter INI_WAIT_TAR_DONE    = 2'b10;

reg  [1:0]         in_state           ; // reg state
reg  [8:0]         in_timer           ; // reg timout monitor timer
reg                in_flag            ; // reg handshake flag 
reg                in_reg_ack         ; // reg reg access finish ind
reg  [DW-1:0]      in_reg_rdata       ; // reg reg access read data
reg                in_reg_timeout     ; // reg time out error pulse

//-----------------------------------
// Target Local Declaration
// ----------------------------------
parameter TAR_IDLE           = 2'b00;
parameter TAR_WAIT_ACK       = 2'b01;
parameter TAR_WAIT_INI_DONE  = 2'b10;

reg [1:0]     out_state               ; // target state machine
reg           out_flag                ; // target handshake flag
reg           out_reg_cs        ; // Target Start indication

reg [8:0]     inititaor_timer         ; // timeout counter
//-----------------------------------------------
// Double sync local declaration
// ----------------------------------------------

reg           in_flag_s              ; // Initiator handshake flag sync 
                                       // with target clk 
reg           in_flag_ss             ; // Initiator handshake flag sync 
                                       // with target clk

reg           out_flag_s             ; // target handshake flag sync 
                                       // with initiator clk
reg           out_flag_ss            ; // target handshake flag sync 
                                       // with initiator clck




assign  out_reg_addr  = in_reg_addr;
assign  out_reg_wdata = in_reg_wdata;
assign  out_reg_wr    = in_reg_wr;
assign  out_reg_be    = in_reg_be;
//------------------------------------------------------
// Initiator Domain logic
//------------------------------------------------------

always @(negedge in_reset_n or posedge in_clk)
begin
   if(in_reset_n == 1'b0)
   begin
      in_state      <= INI_IDLE;
      in_timer      <= 9'h0;
      in_flag       <= 1'b0;
      in_reg_ack    <= 1'b0;
      in_reg_rdata  <= {DW {1'b0}};
      in_reg_timeout<= 1'b0;
    end
    else 
    begin
       case(in_state)
       INI_IDLE : 
          begin
             in_reg_ack         <= 1'b0;
             in_reg_timeout     <= 1'b0;
	     in_timer           <= 'h0;
             // Wait for Initiator Start Indication
             // Once the reg start is detected
             // Set the reg flag and move to WAIT
             // for ack from Target
             if(in_reg_cs) begin
                in_flag       <= 1'b1;
                in_state      <= INI_WAIT_ACK;
             end
          end
       INI_WAIT_ACK :
          begin
             //--------------------------------------------
             // 1. Wait for Out Flag == 1
             // 2. If the Out Flag =1 is not
             //    detected witin 512 cycle, exit with error indication 
             // 3. If Target flag detected, then de-assert
             //  reg_flag = 0 and move the tar_wait_done state
             // --------------------------------------------- 
             if(out_flag_ss == 1'b1) begin
                in_flag             <= 1'b0;
                in_reg_rdata        <= out_reg_rdata;
		in_reg_ack          <= 1'b1;
                in_state           <= INI_WAIT_TAR_DONE;
             end
             else begin if(TIMEOUT_ENB) begin
                    if(in_timer == 9'h1FF ) begin
                       in_flag          <= 1'b0;
                       in_reg_ack       <= 1'b1;
                       in_reg_rdata     <= 32'h0;
                       in_reg_timeout   <= 1'b1;
                       in_state         <= INI_IDLE;
                    end
                    else begin
                        in_timer       <= in_timer + 1;
                    end
                end
             end
           end
      INI_WAIT_TAR_DONE :
          begin
	     in_reg_ack          <= 1'b0;
             //--------------------------------------------
             // 1. Wait for Target Flag == 0
             // 2. If Target flag = 0 detected, then remove
             //  move the idle state
             // --------------------------------------------- 
             if(out_flag_ss == 1'b0) begin
                in_state      <= INI_IDLE;
             end
           end
        default:
           begin
              in_state         <= INI_IDLE;
              in_timer         <= 9'h0;
              in_flag          <= 1'b0;
              in_reg_rdata     <= {DW {1'b0}};
              in_reg_timeout   <= 1'b0;
           end
      endcase
    end 
end


//------------------------------------------------------
// target Domain logic
//------------------------------------------------------
always @(negedge out_reset_n or posedge out_clk)
begin
   if(out_reset_n == 1'b0)
   begin
      out_state         <= TAR_IDLE;
      out_flag          <= 1'b0;
      out_reg_cs        <= 1'b0;
    end
    else 
    begin
       case(out_state)
       TAR_IDLE : 
          begin
             // 1. Wait for Initiator flag assertion 
             // 2. Once the reg flag = 1 is detected
             //    Set the target_flag and initiate the
	     //    target reg bus access
                out_flag          <= 1'b0;
              if(in_flag_ss) begin
                out_reg_cs        <= 1'b1;
                out_state         <= TAR_WAIT_ACK;
              end
          end
      TAR_WAIT_ACK :
          begin
             //--------------------------------------------
             // 1. Wait for reg Flag == 0
             // 2. If reg flag = 0 detected, then 
             //  move the idle state
             // --------------------------------------------- 
             if(out_reg_ack == 1'b1) 
	     begin
                out_reg_cs         <= 1'b0;
		out_flag           <= 1'b1;   
                out_state          <= TAR_WAIT_INI_DONE;
             end
           end
       TAR_WAIT_INI_DONE :
          begin
             if(in_flag_ss == 1'b0) begin
		out_flag     <= 1'b0;   
                out_state    <= TAR_IDLE;
             end
           end
      default:
           begin
             out_state        <= TAR_IDLE;
             out_reg_cs       <= 1'b0;
             out_flag         <= 1'b0;
           end
      endcase
    end 
end

//-------------------------------------------------------
// Double Sync Logic
// ------------------------------------------------------
always @(negedge in_reset_n or posedge in_clk)
begin
   if(in_reset_n == 1'b0)
   begin
      out_flag_s           <= 1'b0;
      out_flag_ss          <= 1'b0;
   end
   else
   begin
      out_flag_s           <= out_flag;
      out_flag_ss          <= out_flag_s;
   end
end


always @(negedge out_reset_n or posedge out_clk)
begin
   if(out_reset_n == 1'b0)
   begin
      in_flag_s        <= 1'b0;
      in_flag_ss       <= 1'b0;
   end
   else
   begin
      in_flag_s        <= in_flag;
      in_flag_ss       <= in_flag_s;
   end
end


endmodule
