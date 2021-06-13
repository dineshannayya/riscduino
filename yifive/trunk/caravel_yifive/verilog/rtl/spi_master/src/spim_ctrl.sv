
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  SPI CTRL I/F Module                                         ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  http://www.opencores.org/cores/yifive/                      ////
////                                                              ////
////  Description                                                 ////
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
module spim_ctrl
(
    input  logic                          clk,
    input  logic                          rstn,
    output logic                          eot,

    input  logic                    [7:0] spi_clk_div,
    input  logic                          spi_clk_div_valid,
    output logic                    [8:0] spi_status,


    input  logic                          spi_req,
    input  logic                   [31:0] spi_addr,
    input  logic                    [5:0] spi_addr_len,
    input  logic                   [7:0]  spi_cmd,
    input  logic                    [5:0] spi_cmd_len,
    input  logic                   [7:0]  spi_mode_cmd,
    input  logic                          spi_mode_cmd_enb,
    input  logic                    [3:0] spi_csreg,
    input  logic                   [15:0] spi_data_len,
    input  logic                   [15:0] spi_dummy_rd_len,
    input  logic                   [15:0] spi_dummy_wr_len,
    input  logic                          spi_swrst, //FIXME Not used at all
    input  logic                          spi_rd,
    input  logic                          spi_wr,
    input  logic                          spi_qrd,
    input  logic                          spi_qwr,
    input  logic                   [31:0] spi_wdata,
    output logic                   [31:0] spi_rdata,
    output logic                          spi_ack,

    output logic                          spi_clk,
    output logic                          spi_csn0,
    output logic                          spi_csn1,
    output logic                          spi_csn2,
    output logic                          spi_csn3,
    output logic                    [1:0] spi_mode,
    output logic                          spi_sdo0,
    output logic                          spi_sdo1,
    output logic                          spi_sdo2,
    output logic                          spi_sdo3,
    input  logic                          spi_sdi0,
    input  logic                          spi_sdi1,
    input  logic                          spi_sdi2,
    input  logic                          spi_sdi3,
    output logic                          spi_en_tx // Spi Direction control
);


parameter  SPI_STD     = 2'b00;
parameter  SPI_QUAD_TX = 2'b01;
parameter  SPI_QUAD_RX = 2'b10;

  logic spi_rise;
  logic spi_fall;

  logic spi_clock_en;

  logic spi_en_rx;

  logic [15:0] counter_tx;
  logic        counter_tx_valid;
  logic [15:0] counter_rx;
  logic        counter_rx_valid;

  logic [31:0] data_to_tx;
  logic        data_to_tx_valid;
  logic        data_to_tx_ready;

  logic en_quad;
  logic en_quad_int;
  logic do_tx; //FIXME NOT USED at all!!
  logic do_rx;

  logic tx_done;
  logic rx_done;

  logic [1:0] s_spi_mode;

  logic ctrl_data_valid;

  logic spi_cs;

  logic tx_clk_en;
  logic rx_clk_en;
  logic en_quad_in;
  

  enum logic [2:0] {DATA_NULL,DATA_EMPTY,DATA_CMD,DATA_ADDR,DATA_MODE,DATA_FIFO} ctrl_data_mux;

  enum logic [4:0] {IDLE,CMD,ADDR,MODE,DUMMY_RX,DUMMY_TX,DATA_TX,DATA_RX,WAIT_EDGE} state,state_next;

  assign en_quad = spi_qrd | spi_qwr | en_quad_int;
  
  
  assign en_quad_in = (s_spi_mode == SPI_STD) ? 1'b0 : 1'b1;

  spim_clkgen u_clkgen
  (
    .clk           ( clk               ),
    .rstn          ( rstn              ),
    .en            ( spi_clock_en      ),
    .cfg_sck_period( spi_clk_div       ),
    .spi_clk       ( spi_clk           ),
    .spi_fall      ( spi_fall          ),
    .spi_rise      ( spi_rise          )
  );

  spim_tx u_txreg
  (
    .clk            ( clk              ),
    .rstn           ( rstn             ),
    .en             ( spi_en_tx        ),
    .tx_edge        ( spi_fall         ),
    .tx_done        ( tx_done          ),
    .sdo0           ( spi_sdo0         ),
    .sdo1           ( spi_sdo1         ),
    .sdo2           ( spi_sdo2         ),
    .sdo3           ( spi_sdo3         ),
    .en_quad_in     ( en_quad_in       ),
    .counter_in     ( counter_tx       ),
    .txdata         ( data_to_tx       ),
    .data_valid     ( data_to_tx_valid ),
    .data_ready     (                  ),
    .clk_en_o       ( tx_clk_en        )
  );
  spim_rx u_rxreg
  (
    .clk            ( clk                    ),
    .rstn           ( rstn                   ),
    .en             ( spi_en_rx              ),
    .rx_edge        ( spi_rise               ),
    .rx_done        ( rx_done                ),
    .sdi0           ( spi_sdi0               ),
    .sdi1           ( spi_sdi1               ),
    .sdi2           ( spi_sdi2               ),
    .sdi3           ( spi_sdi3               ),
    .en_quad_in     ( en_quad_in             ),
    .counter_in     ( counter_rx             ),
    .counter_in_upd ( counter_rx_valid       ),
    .data           ( spi_rdata              ),
    .data_valid     (                        ),
    .data_ready     ( 1'b1                   ),
    .clk_en_o       ( rx_clk_en              )
  );

  
  always_comb
  begin
      data_to_tx       =  'h0;
      data_to_tx_valid = 1'b0;

      case(ctrl_data_mux)
          DATA_NULL:
          begin
              data_to_tx       =  '0;
              data_to_tx_valid = 1'b0;
          end

          DATA_EMPTY:
          begin
              data_to_tx       =  '0;
              data_to_tx_valid = 1'b1;
          end

          DATA_CMD:
          begin
              data_to_tx       = {spi_cmd,24'h0};
              data_to_tx_valid = ctrl_data_valid;
          end
          DATA_MODE:
          begin
              data_to_tx       = {spi_mode_cmd,24'h0};
              data_to_tx_valid = ctrl_data_valid;
          end

          DATA_ADDR:
          begin
              data_to_tx       = spi_addr;
              data_to_tx_valid = ctrl_data_valid;
          end

          DATA_FIFO:
          begin
             data_to_tx             = spi_wdata;
             data_to_tx_valid       = ctrl_data_valid;
          end
      endcase
  end

  always_comb
  begin
    spi_cs           = 1'b1;
    spi_clock_en     = 1'b0;
    counter_tx       =  '0;
    counter_tx_valid = 1'b0;
    counter_rx       =  '0;
    counter_rx_valid = 1'b0;
    state_next       = state;
    ctrl_data_mux    = DATA_NULL;
    ctrl_data_valid  = 1'b0;
    spi_en_rx        = 1'b0;
    spi_en_tx        = 1'b0;
    spi_status       =  '0;
    s_spi_mode       = SPI_QUAD_RX;
    eot              = 1'b0;
    case(state)
      IDLE:
      begin
        spi_status[0] = 1'b1;
        s_spi_mode = SPI_QUAD_RX;
        if (spi_req && spi_fall)
        begin
          spi_cs       = 1'b0;
          spi_clock_en = 1'b1;

          if (spi_cmd_len != 0)
          begin
//            s_spi_mode = (spi_qrd | spi_qwr) ? `SPI_QUAD_TX : `SPI_STD;
            s_spi_mode       = SPI_STD; // COMMAND is always Standard Mode ?
            counter_tx       = {8'h0,spi_cmd_len};
            counter_tx_valid = 1'b1;
            ctrl_data_mux    = DATA_CMD;
            ctrl_data_valid  = 1'b1;
            spi_en_tx        = 1'b1;
            state_next       = CMD;
          end
          else if (spi_addr_len != 0)
          begin
            s_spi_mode = (spi_qrd | spi_qwr) ? SPI_QUAD_TX : SPI_STD;
            counter_tx       = {8'h0,spi_addr_len};
            counter_tx_valid = 1'b1;
            ctrl_data_mux    = DATA_ADDR;
            ctrl_data_valid  = 1'b1;
            spi_en_tx        = 1'b1;
            state_next       = ADDR;
          end
          else if (spi_mode_cmd_enb != 0)
          begin
            s_spi_mode = (spi_qrd | spi_qwr) ? SPI_QUAD_TX : SPI_STD;
            counter_tx       = {8'h0,8'h8};
            counter_tx_valid = 1'b1;
            ctrl_data_mux    = DATA_MODE;
            ctrl_data_valid  = 1'b1;
            spi_en_tx        = 1'b1;
            state_next       = MODE;
          end
          else if (spi_data_len != 0)
          begin
             if (spi_rd || spi_qrd)
             begin
                s_spi_mode = (spi_qrd) ? SPI_QUAD_RX : SPI_STD;
                if(spi_dummy_rd_len != 0)
                begin
                  counter_rx       = en_quad ? {2'b00,spi_dummy_rd_len[13:0]} : spi_dummy_rd_len;
                  counter_rx_valid = 1'b1;
                  spi_en_rx        = 1'b1;
                  ctrl_data_mux    = DATA_EMPTY;
                  spi_clock_en     = rx_clk_en;
                  state_next       = DUMMY_RX;
                end
                else
                begin
                   counter_rx       = spi_data_len;
                   counter_rx_valid = 1'b1;
                   spi_en_rx        = 1'b1;
                   spi_clock_en     = rx_clk_en;
                   state_next       = DATA_RX;
                end
             end
             else
             begin
                s_spi_mode = (spi_qwr) ? SPI_QUAD_TX : SPI_STD;
                if(spi_dummy_wr_len != 0)
                begin
                   counter_tx       = en_quad ? {2'b00,spi_dummy_wr_len[13:0]} : spi_dummy_wr_len;
                   counter_tx_valid = 1'b1;
                   ctrl_data_mux    = DATA_EMPTY;
                   spi_en_tx        = 1'b1;
                   spi_clock_en     = tx_clk_en;
                   state_next       = DUMMY_TX;
                end
                else
                begin
                   counter_tx       = spi_data_len;
                   counter_tx_valid = 1'b1;
                   ctrl_data_mux    = DATA_FIFO;
                   ctrl_data_valid  = 1'b0;
                   spi_en_tx        = 1'b1;
                   spi_clock_en     = tx_clk_en;
                   state_next       = DATA_TX;
                end
             end
          end
        end
        else
        begin
          spi_cs = 1'b1;
          state_next = IDLE;
        end
      end

      CMD:
      begin
        spi_status[1] = 1'b1;
        spi_cs = 1'b0;
        spi_clock_en = 1'b1;
//      s_spi_mode = (en_quad) ? SPI_QUAD_TX : SPI_STD;
        s_spi_mode = SPI_STD; // Command is always Standard Mode ?
        if (tx_done && spi_fall)
        begin
          if (spi_addr_len != 0)
          begin
            s_spi_mode = (en_quad) ? SPI_QUAD_TX : SPI_STD;
            counter_tx       = {8'h0,spi_addr_len};
            counter_tx_valid = 1'b1;
            ctrl_data_mux    = DATA_ADDR;
            ctrl_data_valid  = 1'b1;
            spi_en_tx        = 1'b1;
            state_next       = ADDR;
          end
          else if (spi_mode_cmd_enb != 0)
          begin
            s_spi_mode = (spi_qrd | spi_qwr) ? SPI_QUAD_TX : SPI_STD;
            counter_tx       = {8'h0,8'h8};
            counter_tx_valid = 1'b1;
            ctrl_data_mux    = DATA_MODE;
            ctrl_data_valid  = 1'b1;
            spi_en_tx        = 1'b1;
            state_next       = MODE;
          end
          else if (spi_data_len != 0)
          begin
            if (do_rx)
            begin
              s_spi_mode = (en_quad) ? SPI_QUAD_RX : SPI_STD;
              if(spi_dummy_rd_len != 0)
              begin
                counter_rx       = en_quad ? {2'b00,spi_dummy_rd_len[13:0]} : spi_dummy_rd_len;
                counter_rx_valid = 1'b1;
                spi_en_rx        = 1'b1;
                ctrl_data_mux    = DATA_EMPTY;
                spi_clock_en     = rx_clk_en;
                state_next       = DUMMY_RX;
              end
              else
              begin
                counter_rx       = spi_data_len;
                counter_rx_valid = 1'b1;
                spi_en_rx        = 1'b1;
                spi_clock_en     = rx_clk_en;
                state_next       = DATA_RX;
              end
            end
            else
            begin
              s_spi_mode = (en_quad) ? SPI_QUAD_TX : SPI_STD;
              if(spi_dummy_wr_len != 0)
              begin
                counter_tx       = en_quad ? {2'b00,spi_dummy_wr_len[13:0]} : spi_dummy_wr_len;
                counter_tx_valid = 1'b1;
                ctrl_data_mux    = DATA_EMPTY;
                spi_en_tx        = 1'b1;
                spi_clock_en     = tx_clk_en;
                state_next       = DUMMY_TX;
              end
              else
              begin
                counter_tx       = spi_data_len;
                counter_tx_valid = 1'b1;
                ctrl_data_mux    = DATA_FIFO;
                ctrl_data_valid  = 1'b1;
                spi_en_tx        = 1'b1;
                spi_clock_en     = tx_clk_en;
                state_next       = DATA_TX;
              end
            end
          end
          else
          begin
            spi_en_tx  = 1'b1;
            state_next = WAIT_EDGE;
          end
        end
        else
        begin
          spi_en_tx  = 1'b1;
          state_next = CMD;
        end
      end

      ADDR:
      begin
        spi_en_tx     = 1'b1;
        spi_status[2] = 1'b1;
        spi_cs        = 1'b0;
        spi_clock_en  = 1'b1;
        s_spi_mode    = (en_quad) ? SPI_QUAD_TX : SPI_STD;

        if (tx_done && spi_fall)
        begin
          if (spi_mode_cmd_enb != 0)
          begin
            s_spi_mode = (spi_qrd | spi_qwr) ? SPI_QUAD_TX : SPI_STD;
            counter_tx       = {8'h0,8'h8};
            counter_tx_valid = 1'b1;
            ctrl_data_mux    = DATA_MODE;
            ctrl_data_valid  = 1'b1;
            spi_en_tx        = 1'b1;
            state_next       = MODE;
          end
          else if (spi_data_len != 0)
          begin
            if (do_rx)
            begin
              s_spi_mode = (en_quad) ? SPI_QUAD_RX : SPI_STD;
              if(spi_dummy_rd_len != 0)
              begin
                counter_rx       = en_quad ? {2'b00,spi_dummy_rd_len[13:0]} : spi_dummy_rd_len;
                counter_rx_valid = 1'b1;
                spi_en_rx        = 1'b1;
                ctrl_data_mux    = DATA_EMPTY;
                spi_clock_en     = rx_clk_en;
                state_next       = DUMMY_RX;
              end
              else
              begin
                counter_rx       = spi_data_len;
                counter_rx_valid = 1'b1;
                spi_en_rx        = 1'b1;
                spi_clock_en     = rx_clk_en;
                state_next       = DATA_RX;
              end
            end
            else
            begin
              s_spi_mode = (en_quad) ? SPI_QUAD_TX : SPI_STD;
              spi_en_tx  = 1'b1;

              if(spi_dummy_wr_len != 0) begin
                counter_tx       = en_quad ? {2'b00,spi_dummy_wr_len[13:0]} : spi_dummy_wr_len;
                counter_tx_valid = 1'b1;
                ctrl_data_mux    = DATA_EMPTY;
                spi_clock_en     = tx_clk_en;
                state_next       = DUMMY_TX;
              end else begin
                counter_tx       = spi_data_len;
                counter_tx_valid = 1'b1;
                ctrl_data_mux    = DATA_FIFO;
                ctrl_data_valid  = 1'b1;
                spi_clock_en     = tx_clk_en;
                state_next       = DATA_TX;
              end
            end
          end
          else
          begin
            state_next = WAIT_EDGE;
          end
        end
      end

      MODE:
      begin
        spi_en_tx     = 1'b1;
        spi_status[3] = 1'b1;
        spi_cs        = 1'b0;
        spi_clock_en  = 1'b1;
        s_spi_mode    = (en_quad) ? SPI_QUAD_TX : SPI_STD;
        if (tx_done && spi_fall)
        begin
          if (spi_data_len != 0)
          begin
            if (do_rx)
            begin
              s_spi_mode = (en_quad) ? SPI_QUAD_RX : SPI_STD;
              if(spi_dummy_rd_len != 0)
              begin
                counter_rx       = en_quad ? {2'b00,spi_dummy_rd_len[13:0]} : spi_dummy_rd_len;
                counter_rx_valid = 1'b1;
                spi_en_rx        = 1'b1;
                ctrl_data_mux    = DATA_EMPTY;
                spi_clock_en     = rx_clk_en;
                state_next       = DUMMY_RX;
              end
              else
              begin
                counter_rx       = spi_data_len;
                counter_rx_valid = 1'b1;
                spi_en_rx        = 1'b1;
                spi_clock_en     = rx_clk_en;
                state_next       = DATA_RX;
              end
            end
            else
            begin
              s_spi_mode = (en_quad) ? SPI_QUAD_TX : SPI_STD;
              spi_en_tx  = 1'b1;

              if(spi_dummy_wr_len != 0) begin
                counter_tx       = en_quad ? {2'b00,spi_dummy_wr_len[13:0]} : spi_dummy_wr_len;
                counter_tx_valid = 1'b1;
                ctrl_data_mux    = DATA_EMPTY;
                spi_clock_en     = tx_clk_en;
                state_next       = DUMMY_TX;
              end else begin
                counter_tx       = spi_data_len;
                counter_tx_valid = 1'b1;
                ctrl_data_mux    = DATA_FIFO;
                ctrl_data_valid  = 1'b1;
                spi_clock_en     = tx_clk_en;
                state_next       = DATA_TX;
              end
            end
          end
          else
          begin
            state_next = WAIT_EDGE;
          end
        end
      end

      DUMMY_TX:
      begin
        spi_en_tx     = 1'b1;
        spi_status[4] = 1'b1;
        spi_cs        = 1'b0;
        spi_clock_en  = 1'b1;
        s_spi_mode    = (en_quad) ? SPI_QUAD_RX : SPI_STD;

        if (tx_done && spi_fall) begin
          if (spi_data_len != 0) begin
            if (do_rx) begin
              counter_rx       = spi_data_len;
              counter_rx_valid = 1'b1;
              spi_en_rx        = 1'b1;
              spi_clock_en     = rx_clk_en;
              state_next       = DATA_RX;
            end else begin
              counter_tx       = spi_data_len;
              counter_tx_valid = 1'b1;
              s_spi_mode       = (en_quad) ? SPI_QUAD_TX : SPI_STD;

              spi_clock_en     = tx_clk_en;
              spi_en_tx        = 1'b1;
              state_next       = DATA_TX;
            end
          end
          else
          begin
            eot        = 1'b1;
            state_next = WAIT_EDGE;
          end
        end
        else
        begin
          ctrl_data_mux = DATA_EMPTY;
          spi_en_tx     = 1'b1;
          state_next    = DUMMY_TX;
        end
      end

      DUMMY_RX:
      begin
        spi_en_rx     = 1'b1;
        spi_status[5] = 1'b1;
        spi_cs        = 1'b0;
        spi_clock_en  = 1'b1;
        s_spi_mode    = (en_quad) ? SPI_QUAD_RX : SPI_STD;

        if (rx_done && spi_rise) begin
          if (spi_data_len != 0) begin
            if (do_rx) begin
              counter_rx       = spi_data_len;
              counter_rx_valid = 1'b1;
              spi_en_rx        = 1'b1;
              spi_clock_en     = rx_clk_en;
              state_next       = DATA_RX;
            end else begin
              counter_tx       = spi_data_len;
              counter_tx_valid = 1'b1;
              s_spi_mode       = (en_quad) ? SPI_QUAD_TX : SPI_STD;

              spi_clock_en     = tx_clk_en;
              spi_en_tx        = 1'b1;
              state_next       = DATA_TX;
            end
          end
          else
          begin
            eot        = 1'b1;
            state_next = WAIT_EDGE;
          end
        end
        else
        begin
          ctrl_data_mux = DATA_EMPTY;
          spi_en_tx     = 1'b1;
          spi_clock_en  = rx_clk_en;
          state_next    = DUMMY_RX;
        end
      end
      DATA_TX:
      begin
        spi_status[6]    = 1'b1;
        spi_cs           = 1'b0;
        spi_clock_en     = tx_clk_en;
        ctrl_data_mux    = DATA_FIFO;
        spi_en_tx        = 1'b1;
        s_spi_mode       = (en_quad) ? SPI_QUAD_TX : SPI_STD;

        if (tx_done && spi_fall) begin
          eot          = 1'b1;
          state_next   = WAIT_EDGE;
          spi_clock_en = 1'b0;
        end else begin
          state_next = DATA_TX;
        end
      end

      DATA_RX:
      begin
        spi_status[7] = 1'b1;
        spi_cs        = 1'b0;
        spi_clock_en  = rx_clk_en;
        s_spi_mode    = (en_quad) ? SPI_QUAD_RX : SPI_STD;

        if (rx_done && spi_rise) begin
          state_next = WAIT_EDGE;
        end else begin
          spi_en_rx  = 1'b1;
          state_next = DATA_RX;
        end
      end
      WAIT_EDGE:
      begin
        spi_status[8] = 1'b1;
        spi_cs        = 1'b0;
        spi_clock_en  = 1'b0;
        s_spi_mode    = (en_quad) ? SPI_QUAD_RX : SPI_STD;
        eot           = 1'b1;
        state_next    = IDLE;
      end
    endcase
  end

assign  spi_ack = ((spi_req ==1) && (state == WAIT_EDGE)) ? 1'b1 : 1'b0;


  always_ff @(posedge clk, negedge rstn)
  begin
    if (rstn == 1'b0)
    begin
      state       <= IDLE;
      en_quad_int <= 1'b0;
      do_rx       <= 1'b0;
      do_tx       <= 1'b0;
      spi_mode    <= SPI_QUAD_RX;
    end
    else
    begin
       state <= state_next;
       spi_mode <= s_spi_mode;
      if (spi_qrd || spi_qwr)
        en_quad_int <= 1'b1;
      else if (state_next == IDLE)
        en_quad_int <= 1'b0;

      if (spi_rd || spi_qrd)
      begin
        do_rx <= 1'b1;
        do_tx <= 1'b0;
      end
      else if (spi_wr || spi_qwr)
      begin
        do_rx <= 1'b0;
        do_tx <= 1'b1;
      end
      else if (state_next == IDLE)
      begin
        do_rx <= 1'b0;
        do_tx <= 1'b0;
      end
    end
  end

  assign spi_csn0 = ~spi_csreg[0] | spi_cs;
  assign spi_csn1 = ~spi_csreg[1] | spi_cs;
  assign spi_csn2 = ~spi_csreg[2] | spi_cs;
  assign spi_csn3 = ~spi_csreg[3] | spi_cs;

endmodule

