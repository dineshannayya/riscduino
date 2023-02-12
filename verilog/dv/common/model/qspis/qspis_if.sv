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
////////////////////////////////////////////////////////////////////////////////////
////                                                                            ////
////  QSPIS Interface                                                           ////
////                                                                            ////
////  This file is part of the riscduino cores project                          ////
////  https://github.com/dineshannayya/riscduino.git                            ////
////                                                                            ////
////  Description : This module contains SPI interface                          ////
////                 state machine                                              ////
////  This module only spi mode-0/2                                             ////
////    SPI Mode 0, CPOL = 0, CPHA = 0: CLK idle state = low,                   ////
////        data sampled on rising edge and shifted on falling edge.            ////
////    SPI Mode 2, CPOL = 1, CPHA = 0: CLK idle state = high,                  ////
///         data sampled on the rising edge and shifted on the falling edge.    ////
////                                                                            ////   
////  To Do:                                                                    ////
////    nothing                                                                 ////
////                                                                            ////
////  Author(s):                                                                ////
////      - Dinesh Annayya, dinesh.annayya@gmail.com                            ////
////                                                                            ////
////  Revision :                                                                ////
////    0.1 - 11th Feb 2023, Dinesh A                                           ////
////          Initial version                                                   ////
////                                                                            ////
////////////////////////////////////////////////////////////////////////////////////
/*********************************************************************
   CMD Decoding [7:0]
             [7:4] = 4'b1 - READ  REGISTER
                   = 4'b2 - WRITE REGISTER
             [3:0] = Byte Enable valid only during Write Command
*********************************************************************/

module qspis_if (

	     input  logic         sys_clk         ,
	     input  logic         rst_n           ,

         input  logic         sclk            ,
         input  logic         ssn             ,
         input  logic [3:0]   sdin            ,
         output logic [3:0]   sdout           ,
         output logic         sdout_oen       ,

         //spi_sm Interface
         output logic         reg_wr          , // write request
         output logic         reg_rd          , // read request
         output logic [23:0]  reg_addr        , // address
         output logic  [3:0]  reg_be          , // Byte enable
         output logic [31:0]  reg_wdata       , // write data
         input  logic [31:0]  reg_rdata       , // read data
         input  logic         reg_ack           // read valid
             );


//--------------------------------------------------------
// Wire and reg definitions
// -------------------------------------------------------

reg  [5:0]     bitcnt           ;
reg  [7:0]     cmd_reg          ;
reg  [31:0]    RegSdOut         ;
reg [2:0]      spi_if_st        ;

parameter    S_IDLE     = 3'b000,
             S_CMD      = 3'b001,
             S_ADDR     = 3'b010,
             S_WRITE    = 3'b011,
             S_DUMMY    = 3'b100,
             S_READ     = 3'b101,
             S_EXIT     = 3'b110;

parameter C_WREN        = 8'h06, // Write Enable
	      C_WRDS        = 8'h04, // Write Disable
	      C_RSR1        = 8'h05, // Read Status Reg-1
	      C_RSR2        = 8'h35, // Read Status Reg-2
	      C_RSR3        = 8'h15, // Read Status Reg-3
	      C_WSR1        = 8'h01, // Write Status Reg-1
	      C_WSR2        = 8'h31, // Write Status Reg-2
	      C_WSR3        = 8'h11, // Write Status Reg-3
	      C_RD          = 8'h03, // Read Data
	      C_FRD         = 8'h0B, // Fast Read Data
	      C_FDRD        = 8'h3B, // Fast Dual Read
          C_FQRD        = 8'h6B, // Fast Quad Read
	      C_FRDIO       = 8'hBB, // Fast Dual IO Read
	      C_FRQIO       = 8'hEB, // Fast Quad IO Read
	      C_PWDN        = 8'hB9, // Power Down
	      C_RMID        = 8'h90, // Read Manufacture ID
	      C_RMIDDIO     = 8'h92, // Read Manufacture ID, Dual -IO
	      C_RMIDQIO     = 8'h94, // Read Manufacture ID, Quad -IO
	      C_RJEDEC      = 8'h9F, // Read JEDEC ID
	      C_PPGM        = 8'h02, // Page Write
	      C_QPPGM       = 8'h32; // Quad Page Write


parameter P_SINGLE = 2'b00,
          P_DUAL   = 2'b01,
          P_QUAD   = 2'b10,
          P_DDR    = 2'b11;

parameter P_WRITE  = 1'b0,
          P_READ   = 1'b1;
    
logic       spi_cpol           ; // SCLK Inactive phase; 0 => Low, 1 => High 
logic       cfg_spi_phase      ; // Write/Read Phase
logic [1:0] cfg_spi_amode      ; // Address transmit mode
logic [1:0] cfg_spi_dmode      ; // Data Transmit Mode
logic       cfg_wren           ; // Allow Write
logic       dummy_enb          ; // Insert Dummy cycle
logic       addr_inc           ; // Increment address by 4
logic [3:0] sdin_l             ;


wire cmd_phase     = (spi_if_st == S_CMD );
wire adr_phase     = (spi_if_st == S_ADDR);
wire dummy_phase   = (spi_if_st == S_DUMMY );
wire wr_phase      = (spi_if_st == S_WRITE);
wire rd_phase      = (spi_if_st == S_READ);



// sclk pos and ned edge generation
logic     sck_l0,sck_l1,sck_l2;

wire sck_pdetect = (!sck_l2 && sck_l1) ? 1'b1: 1'b0;
wire sck_ndetect = (sck_l2 && !sck_l1) ? 1'b1: 1'b0;
reg  sck_pdetect_d;
reg  sck_ndetect_d;


always @ (posedge sys_clk or negedge rst_n) begin
if (!rst_n) begin
      sck_l0 <= 1'b1;
      sck_l1 <= 1'b1;
      sck_l2 <= 1'b1;
      sck_pdetect_d <= 1'b0;
      sck_ndetect_d <= 1'b0;
   end
   else begin
      sck_l0 <= sclk;
      sck_l1 <= sck_l0; // double sync
      sck_l2 <= sck_l1;
      sck_pdetect_d <= sck_pdetect;
      sck_ndetect_d <= sck_ndetect;
   end
end

// SSN double sync
logic     ssn_l0,ssn_l1, ssn_ss;

assign ssn_ss = ssn_l1;

always @ (posedge sys_clk or negedge rst_n) begin
if (!rst_n) begin
      ssn_l0 <= 1'b1;
      ssn_l1 <= 1'b1;
   end
   else begin
      ssn_l0 <= ssn;
      ssn_l1 <= ssn_l0; // double sync
   end
end


// Latch the Input at scl low phase
always_latch begin
   if(sclk == 0)
      sdin_l <= sdin;
end


//command register accumation
assign reg_be = 4'hF; // Need to cross-check Dinesh?

always @(negedge rst_n or posedge sys_clk)
begin
  if (!rst_n)
     cmd_reg[7:0] <= 8'b0;
  else if (cmd_phase & (sck_pdetect))
     cmd_reg[7:0] <= {cmd_reg[6:0], sdin_l[0]};
end


// address accumation at posedge sclk
always @(negedge rst_n or posedge sys_clk)
begin
  if (!rst_n)
     reg_addr[23:0] <= 24'b0;
  else if (adr_phase & (sck_pdetect)) begin
     case(cfg_spi_amode) // address mode
     P_SINGLE: reg_addr[23:0] <= {reg_addr[22:0], sdin_l[0]};
     P_DUAL:   reg_addr[23:0] <= {reg_addr[21:0], sdin_l[1:0]};
     P_QUAD:   reg_addr[23:0] <= {reg_addr[19:0], sdin_l[3:0]};
     default:  reg_addr[23:0] <= {reg_addr[22:0], sdin_l[0]};
     endcase
   end else if(addr_inc) begin
      reg_addr[23:0] <= reg_addr+4;
   end
     
end 

// write data accumation at posedge sclk
always @(negedge rst_n or posedge sys_clk)
begin
  if (!rst_n)
     reg_wdata[31:0] <= 32'b0;
  else if (wr_phase & (sck_pdetect)) begin
     case(cfg_spi_dmode) // data mode
     P_SINGLE:  reg_wdata[31:0] <= {reg_wdata[30:0], sdin_l[0]};
     P_DUAL:    reg_wdata[31:0] <= {reg_wdata[29:0], sdin_l[1:0]};
     P_QUAD:    reg_wdata[31:0] <= {reg_wdata[28:0], sdin_l[3:0]};
     default:   reg_wdata[31:0] <= {reg_wdata[30:0], sdin_l[0]};
     endcase
   end
end



// drive sdout at negedge sclk 
always @(negedge rst_n or posedge sys_clk)
begin
  if (!rst_n) begin
     sdout          <= 4'b0;
  end else begin
	  if(reg_ack) begin
          RegSdOut <= reg_rdata;
      end else begin
         if((rd_phase && sck_ndetect)) begin
            case(cfg_spi_dmode) // data mode
            P_SINGLE: begin
               sdout[0]   <= RegSdOut[31];
               sdout[3:1] <= 3'b111;
               RegSdOut <= {RegSdOut[30:0], 1'b0};
            end
            P_DUAL: begin
               sdout[0] <= RegSdOut[30];
               sdout[1] <= RegSdOut[31];
               sdout[3:2] <= 2'b11;
               RegSdOut <= {RegSdOut[29:0], 2'b0};
            end
            P_QUAD: begin
               sdout[0] <= RegSdOut[28];
               sdout[1] <= RegSdOut[29];
               sdout[2] <= RegSdOut[30];
               sdout[3] <= RegSdOut[31];
               RegSdOut <= {RegSdOut[27:0], 4'b0};
            end
            default: begin
               sdout[0]   <= RegSdOut[31];
               sdout[3:1] <= 3'b111;
               RegSdOut <= {RegSdOut[30:0], 1'b0};
            end
            endcase
         end
     end
   end
end


// SPI State Machine

always @(negedge rst_n or posedge sys_clk)
begin
   if (!rst_n) begin
      dummy_enb    <= 1'b0;
      reg_wr       <= 1'b0;
      reg_rd       <= 1'b0;
      addr_inc     <= 1'b0;
      sdout_oen    <= 1'b1;
      bitcnt       <= 6'b000111;
      cfg_wren     <= 1'b0;
      spi_cpol     <= 1'b0;
      spi_if_st    <= S_IDLE;
   end else if(ssn_ss)    begin
      dummy_enb     <= 1'b0;
      reg_wr        <= 1'b0;
      reg_rd        <= 1'b0;
      sdout_oen     <= 1'b1;
      bitcnt        <= 6'b000111;
      spi_cpol      <= sck_l1; // Hold the last sck inactive phase
	  spi_if_st     <= S_IDLE; 
   end else begin
       case (spi_if_st)
          S_IDLE  : begin // Idle State
             reg_wr       <= 1'b0;
             reg_rd       <= 1'b0;
             sdout_oen    <= 1'b1;
             bitcnt       <= 6'b000111;
             if (ssn_ss == 1'b0 && !spi_cpol) begin // SCLK Active Low inactive phase
                spi_if_st <= S_CMD ;
             end else if (ssn_ss == 1'b0 && spi_cpol && sck_ndetect) begin
                spi_if_st <= S_CMD ;
             end 
          end

          S_CMD  : begin // Command State
             if (ssn_ss == 1'b1) begin
                spi_if_st <= S_IDLE;
            end else if (sck_pdetect_d) begin
                if(bitcnt   == 6'b0)  begin
    	            case(cmd_reg)
    	            C_WREN: begin // 0x06 Write Enable
    	               cfg_wren  <= 1'b1;
                       spi_if_st <= S_EXIT;
    	            end
    	            C_WRDS: begin // 0x04 Write Disable
    	               cfg_wren  <= 1'b0;
                       spi_if_st <= S_EXIT;
    	            end
    	            C_RSR1: begin // 0x05 - Read Status Register-1
                       spi_if_st <= S_EXIT;
    	            end
    	            C_RSR2: begin // 0x35 - Read Status Register-2
                       spi_if_st <= S_EXIT;
    	            end
    	            C_RSR3: begin // 0x15 - Read Status Register-3
                       spi_if_st <= S_EXIT;
    	            end
    	            C_WSR1: begin // 0x01 - Write Status Register-1
                       spi_if_st <= S_EXIT;
    	            end
    	            C_WSR2: begin // 0x31 - Write Status Register-2
                       spi_if_st <= S_EXIT;
    	            end
    	            C_WSR3: begin // 0x11 - Write Status Register-3
                       spi_if_st <= S_EXIT;
    	            end
    	            C_RD: begin // Read Data - 0x03
    	               dummy_enb     <= 1'b0;
    	               cfg_spi_phase <= P_READ; 
                       bitcnt        <= 6'b10111;
    	               cfg_spi_amode <= P_SINGLE; // Address Single Bit Mode
    	               cfg_spi_dmode <= P_SINGLE; // Data Single Bit Mode
                       spi_if_st     <= S_ADDR;
    	            end
    	            C_FRD: begin // Fast Read Data - 0x0B
    	               dummy_enb     <= 1'b1;
    	               cfg_spi_phase <= P_READ; 
                       bitcnt        <= 6'b10111;
    	               cfg_spi_amode <= P_SINGLE; // Address Single Bit Mode
    	               cfg_spi_dmode <= P_SINGLE; // Data Single Bit Mode
                       spi_if_st     <= S_ADDR;
    	            end
    	            C_FDRD: begin // Fast Dual Read Data - 0x3B
    	               dummy_enb     <= 1'b1;
    	               cfg_spi_phase <= P_READ; 
    	               cfg_spi_amode <= P_SINGLE; // Address Single Bit Mode
                       bitcnt        <= 6'b10111;
    	               cfg_spi_dmode <= P_DUAL;   // Data Dual Bit Mode
                       spi_if_st     <= S_ADDR;
    	            end
    	            C_FQRD: begin // Fast Quad Read Data - 0x6B
    	               dummy_enb     <= 1'b1;
    	               cfg_spi_phase <= P_READ; 
    	               cfg_spi_amode <= P_SINGLE; // Address Single Bit Mode
                       bitcnt        <= 6'b10111;
    	               cfg_spi_dmode <= P_QUAD  ; // Data Dual Bit Mode
                       spi_if_st     <= S_ADDR;
    	            end
    	            C_FRDIO: begin // Fast Read Dual IO - 0xBB
    	               dummy_enb     <= 1'b1;
    	               cfg_spi_phase <= P_READ; 
    	               cfg_spi_amode <= P_DUAL; // Address Dual Bit Mode
                       bitcnt        <= 6'b01011;
    	               cfg_spi_dmode <= P_DUAL;   // Data Dual Bit Mode
                       spi_if_st     <= S_ADDR;
    	            end
    	            C_FRQIO: begin // Fast Read Quad IO - 0xEB
    	               dummy_enb     <= 1'b1;
    	               cfg_spi_phase <= P_READ; 
    	               cfg_spi_amode <= P_QUAD; // Address Dual Bit Mode
                       bitcnt        <= 6'b00101;
    	               cfg_spi_dmode <= P_QUAD;   // Data Dual Bit Mode
                       spi_if_st     <= S_ADDR;
    	            end
    	            C_PWDN: begin // Power Down - 0xB9
                       spi_if_st     <= S_EXIT;
    	            end
    	            C_RMID: begin // Read Manufacture Id
    	               cfg_spi_amode <= P_SINGLE; 
    	               cfg_spi_dmode <= P_SINGLE;  
                       spi_if_st     <= S_EXIT;
    	            end
    	            C_RMIDDIO: begin // Read Manufacture Id-Dual IO
    	               cfg_spi_amode <= P_DUAL; 
    	               cfg_spi_dmode <= P_DUAL;  
                       spi_if_st     <= S_EXIT;
    	            end
    	            C_RMIDQIO: begin // Read Manufacture Id-Quad IO
    	               cfg_spi_amode <= P_QUAD; 
    	               cfg_spi_dmode <= P_QUAD;  
                       spi_if_st     <= S_EXIT;
    	            end
    	            C_RJEDEC: begin // Read JEDEC ID
    	               cfg_spi_amode <= P_SINGLE; 
    	               cfg_spi_dmode <= P_SINGLE;  
                       spi_if_st     <= S_EXIT;
    	            end
    	            C_PPGM: begin // SINGLE WRITE
    	               cfg_spi_phase <= P_WRITE; 
    	               cfg_spi_amode <= P_SINGLE; 
                       bitcnt        <= 6'b10111;
    	               cfg_spi_dmode <= P_SINGLE;  
                       spi_if_st     <= S_ADDR;
    
                        end
    	            C_QPPGM: begin // QUAD WRITE
    	               cfg_spi_phase <= P_WRITE; 
    	               cfg_spi_amode <= P_SINGLE; 
                       bitcnt        <= 6'b10111;
    	               cfg_spi_dmode <= P_QUAD;  
                       spi_if_st     <= S_ADDR;
    
                    end
    	            default: begin
                        spi_if_st <= S_EXIT;
    	            end
                    endcase
                end else begin
                    bitcnt       <= bitcnt -1;
                end
             end
           end

          S_ADDR : begin // Address Phase
             reg_wr       <= 1'b0;
             reg_rd       <= 1'b0;
             if (ssn_ss == 1'b1) begin
                spi_if_st <= S_IDLE;
             end else if (sck_pdetect_d) begin
                if (bitcnt   == 6'b0) begin
                   bitcnt    <= 6'b0;
                   if(dummy_enb) begin
                      // Dummy Cycles based on Address Phase Mode
                      case(cmd_reg) // address mode, 8 Bit Mode + 16 Bit dummy cycle for 0xEB , 8 bit 0x6B
                      C_FRD:    bitcnt       <= 6'b000111;
                      C_FDRD:   bitcnt       <= 6'b000111;
                      C_FRDIO:  bitcnt       <= 6'b000111;
                      C_FRDIO:  bitcnt       <= 6'b000011;
                      C_FRQIO:  bitcnt       <= 6'b000101; // 8 Bit Mode + 16 Bit Dummy
                      default:  bitcnt       <= 6'b000111;
                      endcase
                      spi_if_st <= S_DUMMY;
                   end else begin
                      case(cfg_spi_dmode) // data mode
                      P_SINGLE: bitcnt       <= 6'b011111;
                      P_DUAL:   bitcnt       <= 6'b001111;
                      P_QUAD:   bitcnt       <= 6'b000111;
                      default:  bitcnt       <= 6'b011111;
                      endcase
                      if(cfg_spi_phase == P_READ) spi_if_st  <= S_READ;
                      else if(cfg_spi_phase == P_WRITE) spi_if_st <= S_WRITE;
                  end
                end else begin
                    bitcnt       <= bitcnt  -1;
                end
             end
          end
          S_DUMMY : begin // Address Phase
             if (ssn_ss == 1'b1) begin
                spi_if_st <= S_IDLE;
             end else if (sck_pdetect_d) begin
                if (bitcnt   == 6'b00) begin
                   case(cfg_spi_dmode) // data mode
                   P_SINGLE: bitcnt       <= 6'b011111;
                   P_DUAL:   bitcnt       <= 6'b001111;
                   P_QUAD:   bitcnt       <= 6'b000111;
                   default:  bitcnt       <= 6'b011111;
                   endcase
                   if(cfg_spi_phase == P_READ) begin
                      spi_if_st  <= S_READ;
                      reg_rd     <= 1;
                      sdout_oen  <= 1'b0;
                   end else if(cfg_spi_phase == P_WRITE) spi_if_st <= S_WRITE;
                end else begin
                    bitcnt       <= bitcnt  -1;
                end
             end
          end

          S_WRITE   : begin // Write State
             if (ssn_ss == 1'b1) begin
                reg_wr    <= 0;
                addr_inc  <= 0;
                spi_if_st <= S_IDLE;
	         end else if(reg_ack) begin
                 reg_wr       <= 0;
                 addr_inc     <= 1;
             end else if (sck_pdetect_d) begin
                reg_wr       <= 0;
                addr_inc     <= 0;
                if (bitcnt   == 6'b0) begin
                   reg_wr     <= 1;
                   case(cfg_spi_dmode) // data mode
                   P_SINGLE: bitcnt       <= 6'b011111;
                   P_DUAL:   bitcnt       <= 6'b001111;
                   P_QUAD:   bitcnt       <= 6'b000111;
                   default:  bitcnt       <= 6'b011111;
                   endcase
                end else begin
                    reg_wr       <= 0;
                    addr_inc     <= 0;
                    bitcnt       <= bitcnt  -1;
                end
             end else begin
                 addr_inc     <= 0;
             end
          end

          S_READ : begin // Send Data to SPI 
             if (ssn_ss == 1'b1) begin
                reg_rd    <= 0;
                addr_inc  <= 0;
                spi_if_st <= S_IDLE;
	         end else if(reg_ack) begin
                 reg_rd       <= 0;
                 addr_inc     <= 1;
             end else if (sck_pdetect_d) begin
                addr_inc     <= 0;
                if (bitcnt   == 6'b0) begin
                   reg_rd     <= 1;
                   sdout_oen  <= 1'b0;
                   case(cfg_spi_dmode) // data mode
                   P_SINGLE: bitcnt       <= 6'b011111;
                   P_DUAL:   bitcnt       <= 6'b001111;
                   P_QUAD:   bitcnt       <= 6'b000111;
                   default:  bitcnt       <= 6'b011111;
                   endcase
                end else begin
                    addr_inc     <= 0;
                    bitcnt       <= bitcnt  -1;
                end
             end else begin
                 addr_inc     <= 0;
             end
          end
          S_EXIT : begin // Wait for SSN = 1
             if (ssn_ss == 1'b1) begin
                spi_if_st <= S_IDLE;
	         end
	      end
          default      : spi_if_st <= S_IDLE;
       endcase
   end
end

endmodule
