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
//-----------------------------------------------------------------
//                     USB Full Speed (12mbps) Phy
//                              V0.2
//                        Ultra-Embedded.com
//                          Copyright 2015
//
//                 Email: admin@ultra-embedded.com
//
//                         License: LGPL
//-----------------------------------------------------------------
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------

//-----------------------------------------------------------------
//                          Generated File
//-----------------------------------------------------------------

module usb_fs_phy
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
     parameter USB_CLK_FREQ     = 60000000
)

(
    // Inputs
     input           clk_i
    ,input           rstn_i
    ,input  [  7:0]  utmi_data_out_i
    ,input           utmi_txvalid_i
    ,input  [  1:0]  utmi_op_mode_i
    ,input  [  1:0]  utmi_xcvrselect_i
    ,input           utmi_termselect_i
    ,input           utmi_dppulldown_i
    ,input           utmi_dmpulldown_i
    ,input           usb_rx_rcv_i
    ,input           usb_rx_dp_i
    ,input           usb_rx_dn_i
    ,input           usb_reset_assert_i

    // Outputs
    ,output [  7:0]  utmi_data_in_o
    ,output          utmi_txready_o
    ,output          utmi_rxvalid_o
    ,output          utmi_rxactive_o
    ,output          utmi_rxerror_o
    ,output [  1:0]  utmi_linestate_o
    ,output          usb_tx_dp_o
    ,output          usb_tx_dn_o
    ,output          usb_tx_oen_o
    ,output          usb_reset_detect_o
    ,output          usb_en_o
);




//-------------------------------------------------------------------------
// For 60Mhz usb clock, data need to sample at once in 4 cycle (60/4 = 12Mhz)
// For 48Mhz usb clock, data need to sample at once in 3 cycle (48/3 = 12Mhz)
// ------------------------------------------------------------------------
localparam SAMPLE_RATE       = (USB_CLK_FREQ == 60000000) ? 3'd4 : 3'd3;

//-----------------------------------------------------------------
// Wires / Registers
//-----------------------------------------------------------------
reg         rx_en_q;

// Xilinx placement pragmas:
//synthesis attribute IOB of out_dp_q is "TRUE"
//synthesis attribute IOB of out_dn_q is "TRUE"
reg         out_dp_q;
reg         out_dn_q;

wire        in_dp_w;
wire        in_dn_w;
wire        in_rx_w;

wire        in_j_w;
wire        in_k_w;
wire        in_se0_w;
wire        in_invalid_w;

wire        sample_w;

wire        bit_edge_w;
wire        bit_transition_w;

reg [2:0]   bit_count_q;
reg [2:0]   ones_count_q;
reg [7:0]   data_q;
reg         send_eop_q;

reg         sync_j_detected_q;

wire        bit_stuff_bit_w;
wire        next_is_bit_stuff_w;

wire        usb_reset_assert_w = usb_reset_assert_i | 
                                (utmi_xcvrselect_i == 2'b00 && 
                                 utmi_termselect_i == 1'b0  && 
                                 utmi_op_mode_i    == 2'b10 && 
                                 utmi_dppulldown_i && 
                                 utmi_dmpulldown_i);

//-----------------------------------------------------------------
// Resample async signals
//-----------------------------------------------------------------
reg         rx_dp_ms;
reg         rx_dn_ms;
reg         rxd_ms;


always @ (posedge clk_i or negedge rstn_i)
if (!rstn_i)
begin
    rx_dp_ms <= 1'b0;
    rx_dn_ms <= 1'b0;
    rxd_ms   <= 1'b0;
end
else
begin
    rx_dp_ms <= in_dp_w;
    rx_dn_ms <= in_dn_w;
    rxd_ms   <= in_rx_w;
end

//-----------------------------------------------------------------
// Edge Detection
//-----------------------------------------------------------------
reg         rx_dp0_q;
reg         rx_dn0_q;
reg         rx_dp1_q;
reg         rx_dn1_q;
reg         rx_dp_q;
reg         rx_dn_q;
reg         rxd0_q;
reg         rxd1_q;
reg         rxd_q;

always @ (posedge clk_i or negedge rstn_i)
if (!rstn_i)
begin
    rx_dp0_q    <= 1'b0;
    rx_dn0_q    <= 1'b0;
    rx_dp1_q    <= 1'b0;
    rx_dn1_q    <= 1'b0;
    rx_dp_q     <= 1'b0;
    rx_dn_q     <= 1'b0;
    rxd0_q      <= 1'b0;
    rxd1_q      <= 1'b0;
    rxd_q       <= 1'b0;
end
else
begin
    // Glitch free versions
    if (rx_dp0_q & rx_dp1_q)
        rx_dp_q     <= 1'b1;
    else if (!rx_dp0_q & !rx_dp1_q)
        rx_dp_q     <= 1'b0;

    if (rx_dn0_q & rx_dn1_q)
        rx_dn_q     <= 1'b1;
    else if (!rx_dn0_q & !rx_dn1_q)
        rx_dn_q     <= 1'b0;

    if (rxd0_q & rxd1_q)
        rxd_q     <= 1'b1;
    else if (!rxd0_q & !rxd1_q)
        rxd_q     <= 1'b0;

    // Resyncs
    rx_dp1_q    <= rx_dp0_q;
    rx_dp0_q    <= rx_dp_ms;

    rx_dn1_q    <= rx_dn0_q;
    rx_dn0_q    <= rx_dn_ms;

    rxd1_q      <= rxd0_q;
    rxd0_q      <= rxd_ms;
end

// For Full Speed USB:
// SE0 = D+ = 0 && D- = 0
// J   = D+ = 1 && D- = 0
// K   = D+ = 0 && D- = 1

assign in_j_w       = in_se0_w ? 1'b0 :  rxd_q;
assign in_k_w       = in_se0_w ? 1'b0 : ~rxd_q;
assign in_se0_w     = (!rx_dp_q & !rx_dn_q);
assign in_invalid_w = (rx_dp_q & rx_dn_q);

// Line state matches tx outputs if drivers enabled
assign utmi_linestate_o = usb_tx_oen_o ? {rx_dn_q, rx_dp_q} : {usb_tx_dn_o, usb_tx_dp_o};

//-----------------------------------------------------------------
// State Machine
//-----------------------------------------------------------------
localparam STATE_W              = 4;
localparam STATE_IDLE           = 4'd0;
localparam STATE_RX_DETECT      = 4'd1;
localparam STATE_RX_SYNC_J      = 4'd2;
localparam STATE_RX_SYNC_K      = 4'd3;
localparam STATE_RX_ACTIVE      = 4'd4;
localparam STATE_RX_EOP0        = 4'd5;
localparam STATE_RX_EOP1        = 4'd6;
localparam STATE_TX_SYNC        = 4'd7;
localparam STATE_TX_ACTIVE      = 4'd8;
localparam STATE_TX_EOP_STUFF   = 4'd9;
localparam STATE_TX_EOP0        = 4'd10;
localparam STATE_TX_EOP1        = 4'd11;
localparam STATE_TX_EOP2        = 4'd12;
localparam STATE_TX_RST         = 4'd13;

// Current state
reg [STATE_W-1:0] state_q;

reg [STATE_W-1:0] next_state_r;
always @ *
begin
    next_state_r = state_q;

    case (state_q)
    //-----------------------------------------
    // STATE_IDLE
    //-----------------------------------------
    STATE_IDLE :
    begin
        if (in_k_w)
            next_state_r    = STATE_RX_DETECT;
        else if (utmi_txvalid_i)
            next_state_r    = STATE_TX_SYNC;
        else if (usb_reset_assert_w)
            next_state_r    = STATE_TX_RST;
    end
    //-----------------------------------------
    // STATE_RX_DETECT
    //-----------------------------------------
    STATE_RX_DETECT :
    begin
        if (in_k_w && sample_w)
            next_state_r    = STATE_RX_SYNC_K;
        else if (sample_w)
            next_state_r    = STATE_IDLE;
    end
    //-----------------------------------------
    // STATE_RX_SYNC_J
    //-----------------------------------------
    STATE_RX_SYNC_J :
    begin
        if (in_k_w && sample_w)
            next_state_r    = STATE_RX_SYNC_K;
        // K glitch followed by multiple J's - return to idle
        else if ((bit_count_q == 3'd1) && sample_w)
            next_state_r    = STATE_IDLE;
    end
    //-----------------------------------------
    // STATE_RX_SYNC_K
    //-----------------------------------------
    STATE_RX_SYNC_K :
    begin
        // End of SYNC field ends with 2 K's
        // Must have seen at least 1 J state first!
        if (sync_j_detected_q && in_k_w && sample_w)
            next_state_r    = STATE_RX_ACTIVE;
        // No J detected since IDLE, must be an error!
        else if (!sync_j_detected_q && in_k_w && sample_w)
            next_state_r    = STATE_IDLE;
        else if (in_j_w && sample_w)
            next_state_r    = STATE_RX_SYNC_J;
    end
    //-----------------------------------------
    // STATE_RX_ACTIVE
    //-----------------------------------------
    STATE_RX_ACTIVE :
    begin
        if (in_se0_w && sample_w)
            next_state_r    = STATE_RX_EOP0;
        // Error!
        else if (in_invalid_w && sample_w)
            next_state_r    = STATE_IDLE;
    end
    //-----------------------------------------
    // STATE_RX_EOP0
    //-----------------------------------------
    STATE_RX_EOP0 :
    begin
        if (in_se0_w && sample_w)
            next_state_r    = STATE_RX_EOP1;
        // Error!
        else if (sample_w)
            next_state_r    = STATE_IDLE;
    end
    //-----------------------------------------
    // STATE_RX_EOP1
    //-----------------------------------------
    STATE_RX_EOP1 :
    begin
        // Return to idle
        if (in_j_w && sample_w)
            next_state_r    = STATE_IDLE;
        // Error!
        else if (sample_w)
            next_state_r    = STATE_IDLE;
    end
    //-----------------------------------------
    // STATE_TX_SYNC
    //-----------------------------------------
    STATE_TX_SYNC :
    begin
        if (bit_count_q == 3'd7 && sample_w)
            next_state_r    = STATE_TX_ACTIVE;
    end
    //-----------------------------------------
    // STATE_TX_ACTIVE
    //-----------------------------------------
    STATE_TX_ACTIVE :
    begin
        if (bit_count_q == 3'd7 && sample_w && (!utmi_txvalid_i || send_eop_q) && !bit_stuff_bit_w)
        begin
            // Bit stuff required at end of packet?
            if (next_is_bit_stuff_w)
                next_state_r    = STATE_TX_EOP_STUFF;
            else
                next_state_r    = STATE_TX_EOP0;
        end
    end
    //-----------------------------------------
    // STATE_TX_EOP_STUFF
    //-----------------------------------------
    STATE_TX_EOP_STUFF :
    begin
        if (sample_w)
            next_state_r    = STATE_TX_EOP0;
    end
    //-----------------------------------------
    // STATE_TX_EOP0
    //-----------------------------------------
    STATE_TX_EOP0 :
    begin
        if (sample_w)
            next_state_r    = STATE_TX_EOP1;
    end
    //-----------------------------------------
    // STATE_TX_EOP1
    //-----------------------------------------
    STATE_TX_EOP1 :
    begin
        if (sample_w)
            next_state_r    = STATE_TX_EOP2;
    end
    //-----------------------------------------
    // STATE_TX_EOP2
    //-----------------------------------------
    STATE_TX_EOP2 :
    begin
        if (sample_w)
            next_state_r    = STATE_IDLE;
    end
    //-----------------------------------------
    // STATE_TX_RST
    //-----------------------------------------
    STATE_TX_RST :
    begin
        if (!usb_reset_assert_w)
            next_state_r    = STATE_IDLE;
    end
    default:
        ;
   endcase
end

// Update state
always @ (negedge rstn_i or posedge clk_i)
if (!rstn_i)
    state_q   <= STATE_IDLE;
else
    state_q   <= next_state_r;

//-----------------------------------------------------------------
// SYNC detect
//-----------------------------------------------------------------
always @ (posedge clk_i or negedge rstn_i)
if (!rstn_i)
    sync_j_detected_q  <= 1'b0;
// Reset sync detect state in IDLE
else if (state_q == STATE_IDLE)
    sync_j_detected_q  <= 1'b0;
// At least one J detected
else if (state_q == STATE_RX_SYNC_J)
    sync_j_detected_q  <= 1'b1;

//-----------------------------------------------------------------
// Rx Error Detection
//-----------------------------------------------------------------
reg rx_error_q;

always @ (posedge clk_i or negedge rstn_i)
if (!rstn_i)
    rx_error_q  <= 1'b0;
// Rx bit stuffing error
else if (ones_count_q == 3'd7)
    rx_error_q  <= 1'b1;
// Invalid line state detection
else if (in_invalid_w && sample_w)
    rx_error_q  <= 1'b1;
// Detect invalid SYNC sequence
else if ((state_q == STATE_RX_SYNC_K) && !sync_j_detected_q && in_k_w && sample_w)
    rx_error_q  <= 1'b1;
else
    rx_error_q  <= 1'b0;

assign utmi_rxerror_o = rx_error_q;

//-----------------------------------------------------------------
// Edge Detector
//-----------------------------------------------------------------
reg rxd_last_q;

always @ (posedge clk_i or negedge rstn_i)
if (!rstn_i)
    rxd_last_q  <= 1'b0;
else
    rxd_last_q  <= in_j_w;

assign bit_edge_w = rxd_last_q ^ in_j_w;

//-----------------------------------------------------------------
// Sample Timer
//-----------------------------------------------------------------
reg [2:0] sample_cnt_q;
reg       adjust_delayed_q;

always @ (posedge clk_i or negedge rstn_i)
if (!rstn_i) begin
    sample_cnt_q        <= 3'd0;
    adjust_delayed_q    <= 1'b0;
end else begin
   // Delayed adjustment
   if (adjust_delayed_q)
       adjust_delayed_q    <= 1'b0;
   else if (bit_edge_w && (sample_cnt_q != 3'd0) && (state_q < STATE_TX_SYNC))
       sample_cnt_q        <= 3'd0;
   // Can't adjust sampling point now?
   else if (bit_edge_w && (sample_cnt_q == 3'd0) && (state_q < STATE_TX_SYNC)) begin
       // Want to reset sampling point but need to delay adjustment by 1 cycle!
       adjust_delayed_q    <= 1'b1;
       if(sample_cnt_q == SAMPLE_RATE) 
           sample_cnt_q <= 'b0;
        else
          sample_cnt_q  <= sample_cnt_q + 'd1;
   end else begin
     if(sample_cnt_q == SAMPLE_RATE)
         sample_cnt_q   <= 'b0;
     else
         sample_cnt_q   <= sample_cnt_q + 'd1;
   end
end

assign sample_w = (sample_cnt_q == 'd0);

//-----------------------------------------------------------------
// NRZI Receiver
//-----------------------------------------------------------------
reg rxd_last_j_q;

// NRZI:
// 0 = transition between J & K
// 1 = same state
// After 6 consequitive 1's, a 0 is inserted to maintain the transitions

always @ (posedge clk_i or negedge rstn_i)
if (!rstn_i)
    rxd_last_j_q  <= 1'b0;
else if ((state_q == STATE_IDLE) || sample_w)
    rxd_last_j_q  <= in_j_w;

assign bit_transition_w = sample_w ? rxd_last_j_q ^ in_j_w : 1'b0;

//-----------------------------------------------------------------
// Bit Counters
//-----------------------------------------------------------------
always @ (posedge clk_i or negedge rstn_i)
if (!rstn_i)
    ones_count_q <= 3'd1;
// The packet starts with a double K (no transition)
else if (state_q == STATE_IDLE)
    ones_count_q <= 3'd1;
// Rx
else if ((state_q == STATE_RX_ACTIVE) && sample_w)
begin
    if (bit_transition_w)
        ones_count_q <= 3'b0;
    else
        ones_count_q <= ones_count_q + 3'd1;
end
// Tx
else if ((state_q == STATE_TX_ACTIVE) && sample_w)
begin
    // Toggle output data
    if (!data_q[0] || bit_stuff_bit_w)
        ones_count_q <= 3'b0;
    else
        ones_count_q <= ones_count_q + 3'd1;
end

assign bit_stuff_bit_w     = (ones_count_q == 3'd6);
assign next_is_bit_stuff_w = (ones_count_q == 3'd5) && !bit_transition_w;

always @ (posedge clk_i or negedge rstn_i)
if (!rstn_i)
    bit_count_q <= 3'b0;
else if ((state_q == STATE_IDLE) || (state_q == STATE_RX_SYNC_K))
    bit_count_q <= 3'b0;
else if ((state_q == STATE_RX_ACTIVE || state_q == STATE_TX_ACTIVE) && sample_w && !bit_stuff_bit_w)
    bit_count_q <= bit_count_q + 3'd1;
else if (((state_q == STATE_TX_SYNC) || (state_q == STATE_RX_SYNC_J)) && sample_w)
    bit_count_q <= bit_count_q + 3'd1;

//-----------------------------------------------------------------
// Shift register
//-----------------------------------------------------------------
always @ (posedge clk_i or negedge rstn_i)
if (!rstn_i)
    data_q  <= 8'b0;
// Pre-load shift register with SYNC word
else if (state_q == STATE_IDLE)
    data_q  <= 8'b00101010;
else if ((state_q == STATE_RX_ACTIVE) && sample_w && !bit_stuff_bit_w)
    data_q  <= {~bit_transition_w, data_q[7:1]};
else if ((state_q == STATE_TX_SYNC) && sample_w)
begin
    if (bit_count_q == 3'd7)
        data_q  <= utmi_data_out_i;
    else
        data_q  <= {~bit_transition_w, data_q[7:1]};
end    
else if ((state_q == STATE_TX_ACTIVE) && sample_w && !bit_stuff_bit_w)
begin
    if (bit_count_q == 3'd7)
        data_q  <= utmi_data_out_i;
    else
        data_q  <= {~bit_transition_w, data_q[7:1]};
end

// Receive active (SYNC recieved)
assign utmi_rxactive_o = (state_q == STATE_RX_ACTIVE);

assign utmi_data_in_o  = data_q;

//-----------------------------------------------------------------
// Rx Ready
//-----------------------------------------------------------------
reg rx_ready_q;

always @ (posedge clk_i or negedge rstn_i)
if (!rstn_i)
    rx_ready_q <= 1'b0;
else if ((state_q == STATE_RX_ACTIVE) && sample_w && (bit_count_q == 3'd7) && !bit_stuff_bit_w)
    rx_ready_q <= 1'b1;
else
    rx_ready_q <= 1'b0;

assign utmi_rxvalid_o  = rx_ready_q;

//-----------------------------------------------------------------
// Tx Ready
//-----------------------------------------------------------------
reg tx_ready_q;

always @ (posedge clk_i or negedge rstn_i)
if (!rstn_i)
    tx_ready_q <= 1'b0;
else if ((state_q == STATE_TX_SYNC) && sample_w && (bit_count_q == 3'd7))
    tx_ready_q <= 1'b1;
else if ((state_q == STATE_TX_ACTIVE) && sample_w && !bit_stuff_bit_w && (bit_count_q == 3'd7) && !send_eop_q)
    tx_ready_q <= 1'b1;
else
    tx_ready_q <= 1'b0;

assign utmi_txready_o  = tx_ready_q;

//-----------------------------------------------------------------
// EOP pending
//-----------------------------------------------------------------
always @ (negedge rstn_i or negedge clk_i)
if (!rstn_i)
    send_eop_q  <= 1'b0;
else if ((state_q == STATE_TX_ACTIVE) && !utmi_txvalid_i)
    send_eop_q  <= 1'b1;
else if (state_q == STATE_TX_EOP0)
    send_eop_q  <= 1'b0;

//-----------------------------------------------------------------
// Tx
//-----------------------------------------------------------------

always @ (posedge clk_i or negedge rstn_i)
if (!rstn_i)
begin
    out_dp_q <= 1'b0;
    out_dn_q <= 1'b0;
    rx_en_q  <= 1'b1;
end
else if (state_q == STATE_IDLE)
begin
    // IDLE
    out_dp_q <= 1'b1;
    out_dn_q <= 1'b0;

    if (utmi_txvalid_i || usb_reset_assert_w)
        rx_en_q <= 1'b0;
    else
        rx_en_q <= 1'b1;
end
else if ((state_q == STATE_TX_SYNC) && sample_w)
begin
    out_dp_q <= data_q[0];
    out_dn_q <= ~data_q[0];
end
else if ((state_q == STATE_TX_ACTIVE || state_q == STATE_TX_EOP_STUFF) && sample_w)
begin
    // 0 = toggle, 1 = hold
    if (!data_q[0] || bit_stuff_bit_w)
    begin
        out_dp_q <= ~out_dp_q;
        out_dn_q <= ~out_dn_q;
    end
end
else if ((state_q == STATE_TX_EOP0 || state_q == STATE_TX_EOP1) && sample_w)
begin
    // SE0
    out_dp_q <= 1'b0;
    out_dn_q <= 1'b0;
end
else if ((state_q == STATE_TX_EOP2) && sample_w)
begin
    // IDLE
    out_dp_q <= 1'b1;
    out_dn_q <= 1'b0;

    // Set bus to input
    rx_en_q <= 1'b1;
end
else if (state_q == STATE_TX_RST)
begin
    // SE0
    out_dp_q <= 1'b0;
    out_dn_q <= 1'b0;
end

//-----------------------------------------------------------------
// Reset detection
//-----------------------------------------------------------------
reg [6:0] se0_cnt_q;

always @ (posedge clk_i or negedge rstn_i)
if (!rstn_i)
    se0_cnt_q <= 7'b0;
else if (in_se0_w)
begin
    if (se0_cnt_q != 7'd127)
        se0_cnt_q <= se0_cnt_q + 7'd1;
end    
else
    se0_cnt_q <= 7'b0;

assign usb_reset_detect_o = (se0_cnt_q == 7'd127);

//-----------------------------------------------------------------
// Transceiver Interface
//-----------------------------------------------------------------
// Tx output enable (active low)
assign usb_tx_oen_o = rx_en_q;

// Tx +/-
assign usb_tx_dp_o  = out_dp_q;
assign usb_tx_dn_o  = out_dn_q;

// Receive D+/D-
assign in_dp_w = usb_rx_dp_i;
assign in_dn_w = usb_rx_dn_i;

// Receive data
assign in_rx_w = usb_rx_rcv_i;

// USB device pull-up enable
assign usb_en_o = utmi_termselect_i;


endmodule
