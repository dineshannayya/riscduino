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
                                                              
                   FPU Register Interface matching to RISCV DMEM i/f
                                                              
  Description:                                                 
     
  To Do:                                                      
                                                              
  Author(s):                                                  
      - Dinesh Annayya, dinesh.annayya@gmail.com                 
                                                              
  Revision :                                                  
     0.0  - Nov 9, 2022
            Initial Version
           
                                                              
************************************************************************************/

module fpu_reg (

        input  logic           mclk           ,
        input  logic           rst_n          ,


        input   logic          dmem_req       ,
        input   logic          dmem_cmd       ,
        input   logic [1:0]    dmem_width     ,
        input   logic [4:0]    dmem_addr      , 
        input   logic [31:0]   dmem_wdata     ,
        output  logic          dmem_req_ack   ,
        output  logic [31:0]   dmem_rdata     ,
        output  logic [1:0]    dmem_resp      ,


      // Encription Reg Interface
        output  logic          cfg_fpu_val    ,
        input   logic          fpu_done       ,
        output  logic [3:0]    cfg_fpu_cmd    ,
        output  logic [31:0]   cfg_fpu_din1   ,
        output  logic [31:0]   cfg_fpu_din2   ,
        input   logic [31:0]   fpu_result     ,

        output  logic          idle          


      );

//-----------------------------------------------------------------------
// Internal Wire Declarations
//-----------------------------------------------------------------------

logic          sw_cs           ;
logic          sw_rd_en        ;
logic          sw_wr_en        ;
logic [2:0]    sw_addr         ; 
logic [31:0]   sw_reg_wdata    ;
logic [3:0]    sw_be           ;

logic [31:0]   reg_out         ;
logic [31:0]   reg_0           ; 
logic [31:0]   reg_1           ; 
logic [31:0]   reg_2           ; 
logic [31:0]   reg_3           ; 
logic          cfg_fpu_req     ;
logic          cfg_fpu_req_l   ;
logic [1:0]    dmem_addr_l     ;
logic [1:0]    dmem_width_l    ;


//---------------------
// FPU Idle generation
//---------------------
assign idle = !cfg_fpu_req;

//Generate Byte Select
function automatic logic[3:0] conv_bsel (
    input   logic [1:0] hwidth,
    input   logic [1:0] haddr
);
    logic   [3:0]  bsel;
begin
    bsel = 'x;
    case (hwidth)
        2'b00 : begin
            case (haddr)
                2'b00 : bsel     = 4'b0001;
                2'b01 : bsel     = 4'b0010;
                2'b10 : bsel     = 4'b0100;
                2'b11 : bsel     = 4'b1000;
            endcase
        end
        2'b01 : begin
            case (haddr[1])
                1'b0 : bsel      = 4'b0011;
                1'b1 : bsel      = 4'b1100;
            endcase
        end
        2'b10 : begin
            bsel      = 4'b1111;
        end
        default : begin
        end
    endcase
    conv_bsel = bsel;
end
endfunction


//Generate wdata based on width and address[1:0]
function automatic logic[31:0] conv_wdata (
    input   logic [1:0]     dmem_width,
    input   logic [1:0]     dmem_addr,
    input   logic [31:0]    dmem_wdata
);
    logic   [31:0]  tmp;
begin
    tmp = 'x;
    case (dmem_width)
        2'b00 : begin
            case (dmem_addr)
                2'b00 : begin
                   tmp[7:0]   = dmem_wdata[7:0];
                end
                2'b01 : begin
                   tmp[15:8]  = dmem_wdata[7:0];
                end
                2'b10 : begin
                   tmp[23:16] = dmem_wdata[7:0];
                end
                2'b11 : begin
                   tmp[31:24] = dmem_wdata[7:0];
                end
                default : begin
                end
            endcase
        end
        2'b01 : begin
            case (dmem_addr[1])
                1'b0 : begin
                   tmp[15:0]  = dmem_wdata[15:0];
                end
                1'b1 : begin
                   tmp[31:16] = dmem_wdata[15:0];
                end
                default : begin
                end
            endcase
        end
        2'b10 : begin
            tmp = dmem_wdata;
        end
        default : begin
        end
    endcase
    conv_wdata = tmp;
end
endfunction

//Generate rdata based on width and address[1:0]
function automatic logic[31:0] conv_rdata (
    input   logic [1:0]                 hwidth,
    input   logic [1:0]                 haddr,
    input   logic [31:0]  hrdata
);
    logic   [31:0]  tmp;
begin
    tmp = 'x;
    case (hwidth)
        2'b00 : begin
            case (haddr)
                2'b00 : tmp[7:0] = hrdata[7:0];
                2'b01 : tmp[7:0] = hrdata[15:8];
                2'b10 : tmp[7:0] = hrdata[23:16];
                2'b11 : tmp[7:0] = hrdata[31:24];
                default : begin
                end
            endcase
        end
        2'b01 : begin
            case (haddr[1])
                1'b0 : tmp[15:0] = hrdata[15:0];
                1'b1 : tmp[15:0] = hrdata[31:16];
                default : begin
                end
            endcase
        end
        2'b10 : begin
            tmp = hrdata;
        end
        default : begin
        end
    endcase
    conv_rdata = tmp;
end
endfunction


always_ff @(negedge rst_n, posedge mclk) begin
    if (~rst_n) begin
       sw_cs          <= '0;
       dmem_req_ack   <= '0;
       sw_rd_en       <= '0;
       sw_wr_en       <= '0;
       sw_addr        <= '0;
       sw_be          <= '0;
       sw_reg_wdata   <= '0;
       dmem_addr_l    <= '0;
       dmem_width_l   <= '0;
    end else begin
       sw_cs          <= (dmem_req) && (dmem_req_ack == 0) ;
       dmem_req_ack   <= dmem_req & (dmem_req_ack ==0) ;
       sw_rd_en       <= (dmem_cmd == 0);
       sw_wr_en       <= (dmem_cmd == 1);
       sw_addr        <= dmem_addr[4:2];
       dmem_addr_l    <= dmem_addr[1:0];
       dmem_width_l   <= dmem_width[1:0];
       sw_be          <= conv_bsel(dmem_width,dmem_addr[1:0]);
       sw_reg_wdata   <= conv_wdata(dmem_width,dmem_addr[1:0],dmem_wdata);
    end
end

//-----------------------------------------------------------------------
// register read enable and write enable decoding logic
//-----------------------------------------------------------------------
wire   sw_wr_en_0 = sw_cs & sw_wr_en  & (sw_addr == 3'h0);
wire   sw_wr_en_1 = sw_cs & sw_wr_en  & (sw_addr == 3'h1);
wire   sw_wr_en_2 = sw_cs & sw_wr_en  & (sw_addr == 3'h2);
wire   sw_wr_en_3 = sw_cs & sw_wr_en  & (sw_addr == 3'h3);

wire   sw_rd_en_0 = sw_cs & sw_rd_en  & (sw_addr == 3'h0);
wire   sw_rd_en_1 = sw_cs & sw_rd_en  & (sw_addr == 3'h1);
wire   sw_rd_en_2 = sw_cs & sw_rd_en  & (sw_addr == 3'h2);
wire   sw_rd_en_3 = sw_cs & sw_rd_en  & (sw_addr == 3'h3);



always @ (posedge mclk or negedge rst_n)
begin : preg_out_Seq
   if (rst_n == 1'b0) begin
      dmem_resp   <= 2'b00;
      dmem_rdata  <= 'h0;
   end else if (sw_cs && sw_rd_en) begin
      dmem_rdata  <= conv_rdata(dmem_width_l,dmem_addr_l[1:0],reg_out);
      dmem_resp   <= 2'b01;
   end else if (sw_cs && sw_wr_en) begin
      dmem_resp   <= 2'b01;
   end else begin
      dmem_resp   <= 2'b00;
   end
end

//-----------------------------------------------------------------------
// Register Read Path Multiplexer instantiation
//-----------------------------------------------------------------------

always_comb
begin 
  reg_out [31:0] = 32'h0;

  case (sw_addr [2:0])
    3'b000    : reg_out [31:0] = reg_0 [31:0];
    3'b001    : reg_out [31:0] = reg_1 [31:0];    
    3'b010    : reg_out [31:0] = reg_2 [31:0];     
    3'b011    : reg_out [31:0] = reg_3 [31:0];    
    default   : reg_out [31:0] = 32'h0;
  endcase
end


assign cfg_fpu_val = (cfg_fpu_req && !cfg_fpu_req_l);

always @ (posedge mclk or negedge rst_n)
begin
   if (rst_n == 1'b0) begin
     cfg_fpu_req_l <= 1'b0;
   end else begin
     cfg_fpu_req_l <= cfg_fpu_req;
   end
end
assign reg_0[31]       = cfg_fpu_req;
assign reg_0[30:4]     = 'h0;
assign reg_0[3:0]      = cfg_fpu_cmd;


assign cfg_fpu_din1    = reg_1;
assign cfg_fpu_din2    = reg_2;
assign reg_3           = fpu_result;

//  Register-0 
generic_register #(4,0 ) u_reg0_3_0 (
	      .we            ({4{sw_wr_en_0 & 
                             sw_be[0]   }}  ),
	      .data_in       (sw_reg_wdata[3:0] ),
	      .reset_n       (rst_n             ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (cfg_fpu_cmd       )
          );

req_register #(0  ) u_reg0_31 (
	      .cpu_we       ({sw_wr_en_0 & 
                             sw_be[3]   }),		 
	      .cpu_req      (sw_reg_wdata[31] ),
	      .hware_ack    (fpu_done         ),
	      .reset_n      (rst_n           ),
	      .clk          (mclk            ),
	      
	      //List of Outs
	      .data_out     (cfg_fpu_req     )
          );
 

//  Register-1 
gen_32b_reg  #(32'h0) u_reg_1	(
	      //List of Inputs
	      .reset_n    (rst_n         ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_1    ),
	      .we         (sw_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_1         )
	      );

//  Register-2 
gen_32b_reg  #(32'h0) u_reg_2	(
	      //List of Inputs
	      .reset_n    (rst_n         ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_2    ),
	      .we         (sw_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_2         )
	      );


endmodule
