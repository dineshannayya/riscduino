
/*************************************************************
  This block added to block abort changing of config during PWM config.
  pwm config will be update only in following condition
  1. When pwm is in disable condition
  2. When disable_update = 0 and cfg_update = 1
*************************************************************/


module pwm_cfg_dglitch  (
                       // System Signals
                       // Inputs
		               input  logic        mclk           ,
                       input  logic        h_reset_n      ,
                       input  logic        enb            , // Operation Enable 
                       input  logic        cfg_update     , // Update config
                       input  logic        cfg_dupdate    , // Disable config update
                       input  logic [31:0] reg_in         ,
                       output logic [31:0] reg_out            

                       );



always @(posedge mclk or negedge h_reset_n) begin 
   if ( ~h_reset_n ) begin
        reg_out <= 'h0;
   end else begin
       if(!cfg_dupdate) begin
          if(!enb || cfg_update) begin
             reg_out <= reg_in;
          end
       end 
   end
end

endmodule
