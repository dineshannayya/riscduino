
`timescale 1 ns / 1 ns

module bfm_ws281x #(
              parameter PORT_ID = 0,
              parameter MODE    = 0) (
                      input logic       reset_n,
                      input logic       clk,
                      input logic       enb,
                      input logic       rxd
                  );

//---------------------------------------------------
// Parameter decleration
//---------------------------------------------------
parameter WS2811_LS  = 0;
parameter WS2811_HS  = 1;
parameter WS2812_HS  = 2;
parameter WS2812S_HS = 3;
parameter WS2812B_HS = 4;


parameter WS281X_LS_PERIOD =  2500 ;  // 400Khz - 2.5us 
parameter WS281X_HS_PERIOD =  1250 ; // 800Khz - 1.25us

parameter WS2811_LS_TOH    =  500    ;// 0.5us - 500ns
parameter WS2811_LS_T1H    =  1200   ;// 1.2us - 1200ns

parameter WS2811_HS_TOH    = 250     ;// 0.25us - 250ns
parameter WS2811_HS_T1H    = 600     ;// 0.6us  - 600ns

parameter WS2812_HS_TOH   = 350      ;// 0.35us - 350ns
parameter WS2812_HS_T1H   = 700      ;// 0.7us  - 700ns

parameter WS2812S_HS_TOH  = 350      ;// 0.35us  - 350ns
parameter WS2812S_HS_T1H  = 700      ;// 0.7us   - 700ns

parameter WS2812B_HS_TOH  = 350     ;// 0.35us   - 350ns
parameter WS2812B_HS_T1H  = 900     ;// 0.9us    - 900ns

parameter WS281X_TOLERENCE = 150 ; // 150ns

parameter WS281X_RST   = 50000      ;// 50us - 50000ns

parameter WS281X_PERIOD = (MODE == WS2811_LS)  ? WS281X_LS_PERIOD :
                          (MODE == WS2811_HS)  ? WS281X_HS_PERIOD :                        
                          (MODE == WS2812_HS)  ? WS281X_HS_PERIOD :                        
                          (MODE == WS2812S_HS) ? WS281X_HS_PERIOD :                        
                          (MODE == WS2812B_HS) ? WS281X_HS_PERIOD : WS281X_LS_PERIOD;

parameter WS281X_TOH = (MODE == WS2811_LS)  ? WS2811_LS_TOH :
                       (MODE == WS2811_HS)  ? WS2811_HS_TOH :                        
                       (MODE == WS2812_HS)  ? WS2812S_HS_TOH :                        
                       (MODE == WS2812S_HS) ? WS2812S_HS_TOH :                        
                       (MODE == WS2812B_HS) ? WS2812B_HS_TOH : WS2811_LS_TOH;
                       
parameter WS281X_T1H = (MODE == WS2811_LS)  ? WS2811_LS_T1H :
                       (MODE == WS2811_HS)  ? WS2811_HS_T1H :                        
                       (MODE == WS2812_HS)  ? WS2812S_HS_T1H :                        
                       (MODE == WS2812S_HS) ? WS2812S_HS_T1H :                        
                       (MODE == WS2812B_HS) ? WS2812B_HS_T1H : WS2811_LS_T1H;


//---------------------------------------------------------
// FSM State
//---------------------------------------------------------
parameter  STATE_RESET         = 3'b000;
parameter  STATE_WAIT_POS_EDGE = 3'b001;
parameter  STATE_WAIT_NEG_EDGE = 3'b010;
parameter  STATE_DATA0_LOW     = 3'b011;
parameter  STATE_DATA1_LOW     = 3'b100;

//---------------------------------------------------
// Variable decleration
//---------------------------------------------------
logic [15:0] rx_wcnt       ;
logic [15:0] clk_cnt      ;
logic [7:0]  bit_cnt      ;
logic [15:0] check_sum    ;
logic [23:0] led_data     ;
time         neg_edge_time ;
time         pos_edge_time ;
time         time_ref     ;
logic [2:0]  state        ;


always @(negedge rxd) begin
 neg_edge_time = $time;
end 

always @(posedge rxd) begin
 pos_edge_time = $time;
end 


always @ (posedge clk) begin
  if(reset_n == 0) begin
       rx_wcnt      = 0;  // rx word count
       bit_cnt      = 0;  // bit count
       clk_cnt      = 0;  // clock edge count
       check_sum    = 0;
       state        = STATE_RESET;
       time_ref     = $time;
       led_data     = 0;
  end else begin
      if(enb == 0) begin
          state        = STATE_RESET;
      end else begin
         case(state)
         STATE_RESET: begin
            if(rxd == 0) begin
               if(($time - time_ref) > WS281X_RST) begin
                  $display("STATUS-WS281X-%0d: RESET PHASE DETECTED",PORT_ID);
                  state = STATE_WAIT_POS_EDGE;
               end
            end else begin
                time_ref     = $time;
                $display("ERROR-WS281X-%0d: Out of Spec Positive Pulse Width Detected at Reset Phase : %t",PORT_ID,$time);
                #1000;
                $stop;
            end
         end
         STATE_WAIT_POS_EDGE: begin
            if(rxd == 1) begin
               state = STATE_WAIT_NEG_EDGE;
            end
         end
         STATE_WAIT_NEG_EDGE: begin
            if(rxd == 0) begin
               if(((neg_edge_time-pos_edge_time) > (WS281X_TOH-WS281X_TOLERENCE)) &&
                  ((neg_edge_time-pos_edge_time) < (WS281X_TOH+WS281X_TOLERENCE))) begin
                   // Check of the Width Match with Data-0: High Pulse width
                   state = STATE_DATA0_LOW;
               end else if(((neg_edge_time-pos_edge_time) > (WS281X_T1H-WS281X_TOLERENCE)) &&
                            (neg_edge_time-pos_edge_time) < (WS281X_T1H+WS281X_TOLERENCE)) begin
                   // Check of the Width Match with Data-1: High Pulse width
                   state = STATE_DATA1_LOW;
               end else begin
                    $display("ERROR-WS281X-%0d: Out of Spec Positive Pulse Width Detected : %t",PORT_ID,neg_edge_time-pos_edge_time);
                    #1000;
                    $stop;
               end
            end else if(($time-pos_edge_time) > (WS281X_T1H+WS281X_TOLERENCE)) begin
                $display("ERROR-WS281X-%0d: Out of Spec Positive Pulse Width Detected : %t",PORT_ID,$time);
                #1000;
                $stop;
            end
         end

          // Check Data low period for DATA-0
          STATE_DATA0_LOW: begin
            if(rxd == 1) begin
               if(((pos_edge_time-neg_edge_time) > (WS281X_PERIOD-WS281X_TOH-WS281X_TOLERENCE)) &&
                  ((pos_edge_time-neg_edge_time) < (WS281X_PERIOD-WS281X_TOH+WS281X_TOLERENCE))) begin
                   // Check of the Width Match with Data-0: Neg Pulse width
                   led_data = led_data << 1; // Data is zero
                   bit_cnt  = bit_cnt+1;
                   if(bit_cnt == 24) begin
                      bit_cnt  = 0;
                      rx_wcnt = rx_wcnt+1;
                      $display("STATUS-WS281X-%0d: Word Cnt: %d Green: %x Red: %x Blue: %x",PORT_ID,rx_wcnt,led_data[23:16],led_data[15:8],led_data[7:0]);
                      check_sum = check_sum+{led_data[23:16],led_data[15:8],led_data[7:0]};
                   end
                   state = STATE_WAIT_POS_EDGE;
               end else begin
                    $display("ERROR-WS281X-%0d: Data-0 => Out of Spec Negative Pulse Width Detected : %t",PORT_ID,pos_edge_time-neg_edge_time);
                    #1000;
                    $stop;
               end
            end else begin
               if((($time-neg_edge_time) > (WS281X_PERIOD-WS281X_TOH+WS281X_TOLERENCE))) begin
                   led_data = led_data << 1; // Data is zero
                   bit_cnt  = bit_cnt+1;
                   if(bit_cnt != 24) begin
                      $display("ERROR-WS281X-%0d: Partial Data Detected , Rx Count: %d Bit count: %d",PORT_ID,rx_wcnt,bit_cnt);
                      #1000;
                      $stop;
                   end
                   rx_wcnt = rx_wcnt+1;
                   $display("STATUS-WS281X-%0d: Word Cnt: %d Green: %x Red: %x Blue: %x",PORT_ID,rx_wcnt,led_data[23:16],led_data[15:8],led_data[7:0]);
                   check_sum = check_sum+{led_data[23:16],led_data[15:8],led_data[7:0]};
                   time_ref  = $time;
                   state     = STATE_RESET;
                end
            end
          end
          // Check Data low period for DATA-1
          STATE_DATA1_LOW: begin
            if(rxd == 1) begin
               if(((pos_edge_time-neg_edge_time) > (WS281X_PERIOD-WS281X_T1H-WS281X_TOLERENCE)) &&
                  ((pos_edge_time-neg_edge_time) < (WS281X_PERIOD-WS281X_T1H+WS281X_TOLERENCE))) begin
                   // Check of the Width Match with Data-0: Neg Pulse width
                   led_data = (led_data << 1) | 1'b1; // Data is high
                   bit_cnt  = bit_cnt+1;
                   if(bit_cnt == 24) begin
                      bit_cnt  = 0;
                      rx_wcnt = rx_wcnt+1;
                      $display("STATUS-WS281X-%0d: Word Cnt: %d Green: %x Red: %x Blue: %x",PORT_ID,rx_wcnt,led_data[23:16],led_data[15:8],led_data[7:0]);
                      check_sum = check_sum+{led_data[23:16],led_data[15:8],led_data[7:0]};
                   end
                   state = STATE_WAIT_POS_EDGE;
               end else begin
                  if((($time-neg_edge_time) > (WS281X_PERIOD-WS281X_T1H+WS281X_TOLERENCE))) begin
                      led_data = (led_data << 1) | 1'b1; // Data is Hih
                      bit_cnt  = bit_cnt+1;
                      if(bit_cnt != 24) begin
                         $display("ERROR-WS281X-%0d: Partial Data Detected , Rx Count: %d Bit count: %d",PORT_ID,rx_wcnt,bit_cnt);
                         #1000;
                         $stop;
                      end
                      rx_wcnt = rx_wcnt+1;
                      $display("STATUS-WS281X-%0d: Word Cnt: %d Green: %x Red: %x Blue: %x",PORT_ID,rx_wcnt,led_data[23:16],led_data[15:8],led_data[7:0]);
                      check_sum = check_sum+{led_data[23:16],led_data[15:8],led_data[7:0]};
                      time_ref  = $time;
                      state     = STATE_RESET;
                   end
               end
            end
          end
         endcase
      end
   end
end

endmodule
