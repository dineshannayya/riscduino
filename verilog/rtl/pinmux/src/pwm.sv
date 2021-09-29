
//-------------------------------------------------------------------
// PWM waveform period:  1000/((cfg_pwm_high+1) + (cfg_pwm_low+1))
// For 1 Second with Duty cycle 50 =   1000/((499+1) + (499+1))
// For 1 Second with 1ms On and 999ms Off =  1000/((0+1) + (998+1))
// Timing Run's with 1 Milisecond pulse
//-------------------------------------------------------------------

module pwm(
	output  logic         waveform,

	input  logic         h_reset_n,
	input  logic         mclk,
	input  logic         pulse1m_mclk,
	input  logic         cfg_pwm_enb,
	input  logic [15:0]  cfg_pwm_high,
	input  logic [15:0]  cfg_pwm_low
);

logic [15:0]  pwm_cnt  ; // PWM on/off counter


always @(posedge mclk or negedge h_reset_n)
begin 
   if ( ~h_reset_n )
   begin
      pwm_cnt  <= 16'h0;
      waveform <= 1'b0;
   end
   else if ( pulse1m_mclk  && cfg_pwm_enb)
   begin 
      if ( pwm_cnt == 16'h0 && waveform  == 1'b0) begin
         pwm_cnt       <= cfg_pwm_high;
         waveform      <= ~waveform;
      end else if ( pwm_cnt == 16'h0 && waveform  == 1'b1) begin
         pwm_cnt       <= cfg_pwm_low;
         waveform      <= ~waveform;
      end else begin
     	   pwm_cnt <= pwm_cnt - 1;
      end
   end
end 

endmodule
