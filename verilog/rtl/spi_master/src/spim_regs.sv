//////////////////////////////////////////////////////////////////////
////                                                              ////
////  SPI WishBone Register I/F Module                            ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  http://www.opencores.org/cores/yifive/                      ////
////                                                              ////
////  Description                                                 ////
////     SPI WishBone I/F module                                  ////
////     This block support following functionality               ////
////        1. Direct SPI Read memory support for address rang    ////
////             0x0000 to 0x0FFF_FFFF - Use full for Instruction ////
////             Data Memory fetch                                ////
////        2. SPI Local Register Access                          ////
////        3. Indirect register way to access SPI Memory         ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////     V.0  -  June 8, 2021                                     //// 
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////


module spim_regs #( parameter WB_WIDTH = 32) (
    input  logic                         mclk,
    input  logic                         rst_n,

    input  logic                         wbd_stb_i, // strobe/request
    input  logic   [WB_WIDTH-1:0]        wbd_adr_i, // address
    input  logic                         wbd_we_i,  // write
    input  logic   [WB_WIDTH-1:0]        wbd_dat_i, // data output
    input  logic   [3:0]                 wbd_sel_i, // byte enable
    output logic   [WB_WIDTH-1:0]        wbd_dat_o, // data input
    output logic                         wbd_ack_o, // acknowlegement
    output logic                         wbd_err_o,  // error

    output logic                   [7:0] spi_clk_div,
    output logic                         spi_clk_div_valid,
    input logic                    [7:0] spi_status,

    // Towards SPI TX/RX FSM


    output logic                          spi_req,
    output logic                   [31:0] spi_addr,
    output logic                    [5:0] spi_addr_len,
    output logic                   [7:0]  spi_cmd,
    output logic                    [5:0] spi_cmd_len,
    output logic                   [7:0]  spi_mode_cmd,
    output logic                          spi_mode_cmd_enb,
    output logic                    [3:0] spi_csreg,
    output logic                   [15:0] spi_data_len,
    output logic                   [15:0] spi_dummy_rd_len,
    output logic                   [15:0] spi_dummy_wr_len,
    output logic                          spi_swrst,
    output logic                          spi_rd,
    output logic                          spi_wr,
    output logic                          spi_qrd,
    output logic                          spi_qwr,
    output logic                   [31:0] spi_wdata,
    input logic                   [31:0]  spi_rdata,
    input logic                           spi_ack

    );

//----------------------------
// Register Decoding
// ---------------------------
parameter REG_CTRL     = 4'b0000;
parameter REG_CLKDIV   = 4'b0001;
parameter REG_SPICMD   = 4'b0010;
parameter REG_SPIADR   = 4'b0011;
parameter REG_SPILEN   = 4'b0100;
parameter REG_SPIDUM   = 4'b0101;
parameter REG_SPIWDATA = 4'b0110;
parameter REG_SPIRDATA = 4'b0111;
parameter REG_STATUS   = 4'b1000;

// Init FSM
parameter SPI_INIT_IDLE     = 3'b000;
parameter SPI_INIT_CMD_WAIT = 3'b001;
parameter SPI_INIT_WRR_CMD  = 3'b010;
parameter SPI_INIT_WRR_WAIT = 3'b011;

//---------------------------------------------------------
// Variable declartion
// -------------------------------------------------------
logic                 spi_init_done  ;
logic   [2:0]         spi_init_state ;
logic                spim_mem_req   ;
logic                spim_reg_req   ;


logic                 spim_wb_req    ;
logic                 spim_wb_req_l  ;
logic [WB_WIDTH-1:0]  spim_wb_wdata  ;
logic [WB_WIDTH-1:0]  spim_wb_addr   ;
logic                 spim_wb_ack    ;
logic                 spim_wb_we     ;
logic [3:0]           spim_wb_be     ;
logic [WB_WIDTH-1:0]  spim_reg_rdata ;
logic [WB_WIDTH-1:0]  spim_wb_rdata  ;
logic  [WB_WIDTH-1:0] reg_rdata      ;

// Control Signal Generated from Reg to SPI Access
logic                 reg2spi_req;
logic         [31:0]  reg2spi_addr;
logic          [5:0]  reg2spi_addr_len;
logic         [31:0]  reg2spi_cmd;
logic          [5:0]  reg2spi_cmd_len;
logic          [3:0]  reg2spi_csreg;
logic         [15:0]  reg2spi_data_len;
logic                 reg2spi_mode_enb; // mode enable
logic         [7:0]   reg2spi_mode;     // mode 
logic         [15:0]  reg2spi_dummy_rd_len;
logic         [15:0]  reg2spi_dummy_wr_len;
logic                 reg2spi_swrst;
logic                 reg2spi_rd;
logic                 reg2spi_wr;
logic                 reg2spi_qrd;
logic                 reg2spi_qwr;
logic         [31:0]  reg2spi_wdata;
//------------------------------------------------------------------   
// Priority given to mem2spi request over Reg2Spi

    assign  spi_req           =  (spim_mem_req && !spim_wb_we) ? 1'b1                           : reg2spi_req;      
    assign  spi_addr          =  (spim_mem_req && !spim_wb_we) ? {spim_wb_addr[23:0],8'h0}      : reg2spi_addr;      
    assign  spi_addr_len      =  (spim_mem_req && !spim_wb_we) ? 24                             : reg2spi_addr_len;  
    assign  spi_cmd           =  (spim_mem_req && !spim_wb_we) ? 8'hEB                          : reg2spi_cmd;       
    assign  spi_cmd_len       =  (spim_mem_req && !spim_wb_we) ? 8                              : reg2spi_cmd_len;   
    assign  spi_mode_cmd      =  (spim_mem_req && !spim_wb_we) ? 8'h00                          : reg2spi_mode;       
    assign  spi_mode_cmd_enb  =  (spim_mem_req && !spim_wb_we) ? 1                              : reg2spi_mode_enb;   
    assign  spi_csreg         =  (spim_mem_req && !spim_wb_we) ? '1                             : reg2spi_csreg;     
    assign  spi_data_len      =  (spim_mem_req && !spim_wb_we) ? 'h10                           : reg2spi_data_len;  
    assign  spi_dummy_rd_len  =  (spim_mem_req && !spim_wb_we) ? 16                             : reg2spi_dummy_rd_len;  
    assign  spi_dummy_wr_len  =  (spim_mem_req && !spim_wb_we) ? 0                              : reg2spi_dummy_wr_len;  
    assign  spi_swrst         =  (spim_mem_req && !spim_wb_we) ? 0                              : reg2spi_swrst;     
    assign  spi_rd            =  (spim_mem_req && !spim_wb_we) ? 0                              : reg2spi_rd;        
    assign  spi_wr            =  (spim_mem_req && !spim_wb_we) ? 0                              : reg2spi_wr;        
    assign  spi_qrd           =  (spim_mem_req && !spim_wb_we) ? 1                              : reg2spi_qrd;       
    assign  spi_qwr           =  (spim_mem_req && !spim_wb_we) ? 0                              : reg2spi_qwr;       
    assign  spi_wdata         =  (spim_mem_req && !spim_wb_we) ? 0                              : reg2spi_wdata;       




  //---------------------------------------------------------------
  // Address Decoding
  // 0x0000_0000 - 0x0FFF_FFFF  - SPI FLASH MEMORY ACCESS - 256MB
  // 0x1000_0000 -              - SPI Register Access
  // --------------------------------------------------------------

  assign spim_mem_req = ((spim_wb_req) && spim_wb_addr[31:28] == 4'b0000);
  assign spim_reg_req = ((spim_wb_req) && spim_wb_addr[31:28] == 4'b0001);


  assign wbd_dat_o  =  spim_wb_rdata;
  assign wbd_ack_o  =  spim_wb_ack;
  assign wbd_err_o  =  1'b0;

  // To reduce the load/Timing Wishbone I/F, all the variable are registered
always_ff @(negedge rst_n or posedge mclk) begin
    if ( rst_n == 1'b0 ) begin
        spim_wb_req   <= '0;
        spim_wb_req_l <= '0;
        spim_wb_wdata <= '0;
        spim_wb_rdata <= '0;
        spim_wb_addr  <= '0;
        spim_wb_be    <= '0;
        spim_wb_we    <= '0;
        spim_wb_ack   <= '0;
   end else begin
        spim_wb_req   <= wbd_stb_i;
        spim_wb_req_l <= spim_wb_req;
        spim_wb_wdata <= wbd_dat_i;
        spim_wb_addr  <= wbd_adr_i;
        spim_wb_be    <= wbd_sel_i;
        spim_wb_we    <= wbd_we_i;


	// If there is Reg2Spi read Access, Register the Read Data
	if(reg2spi_req && (reg2spi_rd || reg2spi_qrd ) && spi_ack) 
             spim_reg_rdata <= spi_rdata;

	if(!spim_wb_we && spim_wb_req && spi_ack) 
           spim_wb_rdata <= spi_rdata;
        else
           spim_wb_rdata <= reg_rdata;

        // For safer design, we have generated ack after 2 cycle latter to 
	// cross-check current request is towards SPI or not
        spim_wb_ack   <= (spi_req) ? spi_ack :
		         ((spim_wb_ack==0) && spim_wb_req && spim_wb_req_l) ;
   end
end

  integer byte_index;
  always_ff @(negedge rst_n or posedge mclk) begin
    if ( rst_n == 1'b0 ) begin
      reg2spi_swrst         <= 1'b0;
      reg2spi_rd            <= 1'b0;
      reg2spi_wr            <= 1'b0;
      reg2spi_qrd           <= 1'b0;
      reg2spi_qwr           <= 1'b0;
      reg2spi_cmd           <=  'h0;
      reg2spi_addr          <=  'h0;
      reg2spi_cmd_len       <=  'h0;
      reg2spi_addr_len      <=  'h0;
      reg2spi_data_len      <=  'h0;
      reg2spi_wdata         <=  'h0;
      reg2spi_mode_enb      <=  'h0;
      reg2spi_mode          <=  'h0;
      reg2spi_dummy_rd_len  <=  'h0;
      reg2spi_dummy_wr_len  <=  'h0;
      reg2spi_csreg         <=  'h0;
      reg2spi_req           <=  'h0;
      spi_clk_div_valid     <= 1'b0;
      spi_clk_div           <=  'h2;
      spi_init_done         <=  'h0;
      spi_init_state        <=  SPI_INIT_IDLE;
    end
    else if (spi_init_done == 0) begin
       case(spi_init_state)
	   SPI_INIT_IDLE:
	   begin
              reg2spi_rd        <= 'h0;
              reg2spi_wr        <= 'h1; // SPI Write Req
              reg2spi_qrd       <= 'h0;
              reg2spi_qwr       <= 'h0;
              reg2spi_swrst     <= 'h0;
              reg2spi_csreg     <= 'h1;
              reg2spi_cmd[7:0]  <= 'h6; // WREN command
              reg2spi_mode[7:0] <= 'h0;
              reg2spi_cmd_len   <= 'h8;
              reg2spi_addr_len  <= 'h0;
              reg2spi_data_len  <= 'h0;
              reg2spi_wdata     <= 'h0;
	      reg2spi_req       <= 'h1;
              spi_init_state    <=  SPI_INIT_CMD_WAIT;
	   end
	   SPI_INIT_CMD_WAIT:
	   begin
	      if(spi_ack)   begin
	         reg2spi_req      <= 1'b0;
                 spi_init_state    <=  SPI_INIT_WRR_CMD;
	      end
	   end
	   SPI_INIT_WRR_CMD:
	   begin
              reg2spi_rd        <= 'h0;
              reg2spi_wr        <= 'h1; // SPI Write Req
              reg2spi_qrd       <= 'h0;
              reg2spi_qwr       <= 'h0;
              reg2spi_swrst     <= 'h0;
              reg2spi_csreg     <= 'h1;
              reg2spi_cmd[7:0]  <= 'h1; // WRR command
              reg2spi_mode[7:0] <= 'h0;
              reg2spi_cmd_len   <= 'h8;
              reg2spi_addr_len  <= 'h0;
              reg2spi_data_len  <= 'h10;
              reg2spi_wdata     <= {8'h0,8'h2,16'h0}; // <sr1[7:0]><<cr1[7:0]><16'h0> cr1[1] = 1 indicate quad mode
	      reg2spi_req       <= 'h1;
              spi_init_state    <=  SPI_INIT_WRR_WAIT;
	   end
	   SPI_INIT_WRR_WAIT:
	   begin
	      if(spi_ack)   begin
	         reg2spi_req      <= 1'b0;
                 spi_init_done    <=  'h1;
	      end
	   end
       endcase
    end else if (spim_reg_req & spim_wb_we )
    begin
      case(spim_wb_addr[7:4])
        REG_CTRL:
        begin
          if ( spim_wb_be[0] == 1 )
          begin
            reg2spi_rd    <= spim_wb_wdata[0];
            reg2spi_wr    <= spim_wb_wdata[1];
            reg2spi_qrd   <= spim_wb_wdata[2];
            reg2spi_qwr   <= spim_wb_wdata[3];
            reg2spi_swrst <= spim_wb_wdata[4];
	    reg2spi_req   <= 1'b1;
          end
          if ( spim_wb_be[1] == 1 )
          begin
            reg2spi_csreg <= spim_wb_wdata[11:8];
          end
        end
        REG_CLKDIV:
          if ( spim_wb_be[0] == 1 )
          begin
            spi_clk_div <= spim_wb_wdata[7:0];
            spi_clk_div_valid <= 1'b1;
          end
        REG_SPICMD: begin
          if ( spim_wb_be[0] == 1 )
              reg2spi_cmd[7:0] <= spim_wb_wdata[7:0];
          if ( spim_wb_be[1] == 1 )
              reg2spi_mode[7:0] <= spim_wb_wdata[15:8];
          end
        REG_SPIADR:
          for (byte_index = 0; byte_index < 4; byte_index = byte_index+1 )
            if ( spim_wb_be[byte_index] == 1 )
              reg2spi_addr[byte_index*8 +: 8] <= spim_wb_wdata[(byte_index*8) +: 8];
        REG_SPILEN:
        begin
          if ( spim_wb_be[0] == 1 ) begin
               reg2spi_mode_enb <= spim_wb_wdata[6];
               reg2spi_cmd_len  <= spim_wb_wdata[5:0];
          end
          if ( spim_wb_be[1] == 1 )
            reg2spi_addr_len <= spim_wb_wdata[13:8];
          if ( spim_wb_be[2] == 1 )
            reg2spi_data_len[7:0] <= spim_wb_wdata[23:16];
          if ( spim_wb_be[3] == 1 )
            reg2spi_data_len[15:8] <= spim_wb_wdata[31:24];
        end
        REG_SPIDUM:
        begin
          if ( spim_wb_be[0] == 1 )
            reg2spi_dummy_rd_len[7:0]  <= spim_wb_wdata[7:0];
          if ( spim_wb_be[1] == 1 )
            reg2spi_dummy_rd_len[15:8] <= spim_wb_wdata[15:8];
          if ( spim_wb_be[2] == 1 )
            reg2spi_dummy_wr_len[7:0]  <= spim_wb_wdata[23:16];
          if ( spim_wb_be[3] == 1 )
            reg2spi_dummy_wr_len[15:8] <= spim_wb_wdata[31:24];
        end
	REG_SPIWDATA: begin
           reg2spi_wdata     <= spim_wb_wdata;
	end
      endcase
    end
    else
    begin
      if(spi_ack && spim_reg_req)   
	 reg2spi_req <= 1'b0;
    end
  end 


  // implement slave model register read mux
  always_comb
    begin
      reg_rdata = '0;
      case(spim_wb_addr[7:4])
        REG_CTRL:
                reg_rdata[31:0] =  { 20'h0, 
		                     reg2spi_csreg,
		                     3'b0,
		                     reg2spi_swrst,
		                     reg2spi_qwr,
		                     reg2spi_qrd,
		                     reg2spi_wr,
		                     reg2spi_rd};

        REG_CLKDIV:
                reg_rdata[31:0] = {24'h0,spi_clk_div};
        REG_SPICMD:
                reg_rdata[31:0] = {16'h0,reg2spi_mode,reg2spi_cmd};
        REG_SPIADR:
                reg_rdata[31:0] = reg2spi_addr;
        REG_SPILEN:
                reg_rdata[31:0] = {reg2spi_data_len,2'b00,reg2spi_addr_len,1'b0,reg2spi_mode_enb,reg2spi_cmd_len};
        REG_SPIDUM:
                reg_rdata[31:0] = {reg2spi_dummy_wr_len,reg2spi_dummy_rd_len};
        REG_SPIWDATA:
                reg_rdata[31:0] = reg2spi_wdata;
        REG_SPIRDATA:
                reg_rdata[31:0] = spim_reg_rdata;
        REG_STATUS:
                reg_rdata[31:0] = {24'h0,spi_status};
      endcase
    end 


endmodule
