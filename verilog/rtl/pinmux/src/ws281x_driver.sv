
// 24 bit ws281x led driver

module ws281x_driver (
    input  logic          clk                  ,   // Clock input.
    input  logic          reset_n              ,   // Resets the internal state of the driver

    input  logic[15:0]    cfg_reset_period     ,   // Reset period interm of clk
    input  logic [9:0]    cfg_clk_period       ,   // Total bit clock period
    input  logic [9:0]    cfg_th0_period        ,   // bit-0 drive low period
    input  logic [9:0]    cfg_th1_period        ,   // bit-1 drive low period

    input  logic          port_enb               , 
    input  logic          data_available       , 
    input  logic [7:0]    green_in             ,   // 8-bit green data
    input  logic [7:0]    red_in               ,   // 8-bit red data
    input  logic [7:0]    blue_in              ,   // 8-bit blue data
    output logic          data_rd              ,   // data read
    
    output logic          txd                      // Signal to send to WS2811 chain.
    );
	

   parameter  STATE_RESET    = 1'd0;
   parameter  STATE_TRANSMIT = 1'd1;
   /////////////////////////////////////////////////////////////
   // Timing parameters for the WS2811                        //
   // The LEDs are reset by driving D0 low for at least 50us. //
   // Data is transmitted using a 800kHz signal.              //
   // A '1' is 50% duty cycle, a '0' is 20% duty cycle.       //
   /////////////////////////////////////////////////////////////

   reg [15:0]             clk_cnt       ;   // Clock divider for a cycle
   reg                    state         ;   // FSM state
   reg [23:0]             led_data      ;   // Current byte to send
   reg [4:0]              bit_cnt       ;   // Current bit index to send



   
   always @ (posedge clk or negedge reset_n) begin
      if (reset_n == 1'b0) begin
         state         <= STATE_RESET;
         txd           <= 0;
         data_rd       <= 0;
         bit_cnt       <= 23;
         clk_cnt       <= 0;
         led_data      <= 0;
      end
      else begin
         case (state)
           STATE_RESET: begin
              if(port_enb) begin
                  if (clk_cnt == cfg_reset_period) begin
                     if(data_available) begin
                         led_data      <= {green_in,red_in,blue_in};
                         bit_cnt       <= 23;
                         clk_cnt       <= 0;
                         txd           <= 1;
                         data_rd       <= 1;
                         state         <= STATE_TRANSMIT;
                     end
                  end
                  else begin
                    // De-assert txd       , and wait for 75 us.
                     txd        <= 0;
                     clk_cnt    <= clk_cnt + 1;
                  end
              end else begin
                 txd        <= 0;
                 clk_cnt    <= 0;
              end
           end // case: STATE_RESET
           STATE_TRANSMIT: begin
              // Advance cycle counter
              if (clk_cnt   == cfg_clk_period) begin
                 txd        <= 1;
                 clk_cnt    <= 'h0;
                 if (bit_cnt != 0) begin
                     bit_cnt <= bit_cnt -1;
                     // Start sending next bit of data
                     led_data     <= {led_data [22:0], 1'b0};
                 end else begin
                    if(data_available) begin // if new data available
                        led_data      <= {green_in,red_in,blue_in};
                        bit_cnt       <= 23;
                        data_rd       <= 1;
                    end else begin
                       state   <= STATE_RESET;
                    end

                 end
              end else begin
                  data_rd       <= 0;
                  // De-assert txd   after a certain amount of time, depending on if you're transmitting a 1 or 0.
                  if (led_data[23] == 0 && clk_cnt   >= cfg_th0_period) begin
                     txd   <= 0;
                  end
                  else if (led_data[23] == 1 && clk_cnt   >= cfg_th1_period) begin
                     txd   <= 0;
                  end
                  clk_cnt   <= clk_cnt   + 1;
              end
           end
         endcase
      end
   end
   
endmodule

