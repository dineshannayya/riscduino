/*********************************************************
  This block try to auto detect the baud-16x value for incoming 9600 data.
  Here the System clock is unknown, As in caravel user_clock can be any thing between
  4Mhz to 60Mhz.

  local counter width: 20bit should be good enough the check idle OR struck at low state
  Assumption is 9600 Baud => 0.104ms per bit => 1.04ms per chapter (Assumpting 10 bit per character including start+ parity bit) 
  With System clock 100Mhz, 1.04ms => 1,000,000 clock count, which can be easily check by 20 bit count => 2^20 = 1048576


  1.Input data in double sync with local clock
  2. State: IDLE:  Wait for High to low edge,
                   On Fall edge, STATE = POS_EDGE
  2. State: POS_EDGE1:
                   Wait for Pos edge, If Pos edge detected, STATE= NEG_EDGE1
                   increase local clk_cnt, if counter each 0xF_FFFF without transition, move to State: IDLE
  3. State: NEG_EDGE1:
                   Wait for Neg edge, If Neg edge detected, capture the clk_cnt => ref1_cnt; State: POS_EDGE2
                   if counter reached 0xF_FFFF without transition, then STATE: IDLE

  4. State: POS_EDGE2:
                   Wait for Pos edge, If Pos edge detected, STATE= NEG_EDGE2
                   increase local clk_cnt, if counter each 0xF_FFFF without transition, move to State: IDLE
  5. State: NEG_EDGE2:
                   Wait for Neg edge, If Neg edge detected, capture the clk_cnt => ref2_cnt; State: COMPUTE
                   if counter reached 0xF_FFFF without transition, then STATE: IDLE
  6. State: COMPUTE
                  if difference between ref1_cnt and ref2_cnt less than 16, then average out and divide by 16, Sub by 2, 
                  and update Baud Value and STOP_EDGE
  7. STATE:STOP_EDGE  Wait pos edge, if timeout then go to IDLE, else enable tx/rx 
 ***************************************************************************/
module uart_auto_det (
         input logic         mclk          ,
         input logic         reset_n       ,
         input logic         cfg_auto_det  ,
         input logic         rxd           ,

         output logic [11:0] auto_baud_16x  ,
         output logic        auto_tx_enb    ,
         output logic        auto_rx_enb    

        );

parameter  IDLE      = 3'b000;
parameter  POS_EDGE1 = 3'b001;
parameter  NEG_EDGE1 = 3'b010;
parameter  POS_EDGE2 = 3'b011;
parameter  NEG_EDGE2 = 3'b100;
parameter  COMPUTE   = 3'b101;
parameter  STOP_EDGE = 3'b110;
parameter  AUTO_DONE = 3'b111;


logic [19:0] clk_cnt,ref1_cnt,ref2_cnt,ref_diff,baud_16x;
logic [2:0]  state;
logic [2:0]  rxd_sync;
logic        timeout;
logic        rxd_pedge;
logic        rxd_nedge;

assign timeout = (clk_cnt == 20'hF_FFFF);
assign rxd_pedge = (rxd_sync[2] == 1'b0) & (rxd_sync[1] == 1'b1);
assign rxd_nedge = (rxd_sync[2] == 1'b1) & (rxd_sync[1] == 1'b0);
assign ref_diff  = (ref1_cnt > ref2_cnt) ? (ref1_cnt - ref2_cnt) : (ref2_cnt - ref1_cnt);

assign baud_16x = (((ref1_cnt + ref2_cnt) >> 1) >> 4);

always @(negedge reset_n or posedge mclk)
begin
   if(reset_n == 1'b0) begin
      state         <= IDLE;
      clk_cnt       <= 'b0;
      ref1_cnt      <= 'b0;
      ref1_cnt      <= 'b0;
      auto_baud_16x <= 'b0;
      auto_tx_enb   <= 'b0;
      auto_rx_enb   <= 'b0;
      rxd_sync      <= 'b0;
   end else begin
      rxd_sync  <= {rxd_sync[1:0],rxd};
      case(state)
      IDLE : begin
         if(cfg_auto_det && rxd_nedge) begin
            clk_cnt <= 'h0;
            state   <= POS_EDGE1;
         end
      end
      POS_EDGE1 : begin
         if(rxd_pedge) begin
            clk_cnt  <= 'h0;
            state    <= NEG_EDGE1;
         end else if(timeout) begin
            state   <= IDLE;
         end else begin
            clk_cnt <= clk_cnt + 1;
         end
      end
      NEG_EDGE1 : begin
         if(rxd_nedge) begin
            ref1_cnt <= clk_cnt;
            clk_cnt  <= 'h0;
            state    <= POS_EDGE2;
         end else if(timeout) begin
            state   <= IDLE;
         end else begin
            clk_cnt <= clk_cnt + 1;
         end
      end
      POS_EDGE2 : begin
         if(rxd_pedge) begin
            clk_cnt  <= 'h0;
            state    <= NEG_EDGE2;
         end else if(timeout) begin
            state   <= IDLE;
         end else begin
            clk_cnt <= clk_cnt + 1;
         end
      end
      NEG_EDGE2 : begin
         if(rxd_nedge) begin
            ref2_cnt <= clk_cnt;
            clk_cnt  <= 'h0;
            state    <= COMPUTE;
         end else if(timeout) begin
            state   <= IDLE;
         end else begin
            clk_cnt <= clk_cnt + 1;
         end
      end
      COMPUTE: begin
         if(ref_diff < 16) begin
            // Average it, Generate Div-16 + Additional Sub by 2 is due to clk_ctl module div n implementation
            if(baud_16x > 1)
                auto_baud_16x <= baud_16x -1;
            else 
                auto_baud_16x <= 0;
            state     <= STOP_EDGE;
         end else  begin
            state     <= IDLE;
         end
      end
      STOP_EDGE : begin
         if(rxd_pedge) begin
            state    <= AUTO_DONE;
         end else if(timeout) begin
            state   <= IDLE;
         end else begin
            clk_cnt <= clk_cnt + 1;
         end
      end
      AUTO_DONE: begin
         auto_tx_enb <= 1'b1;
         auto_rx_enb <= 1'b1;
      end
      endcase

   end
end


endmodule
 
                   
