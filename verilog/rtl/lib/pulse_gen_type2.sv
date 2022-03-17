
//------------------------------------------------------------------------
// This module is used to generate 1us based on config value
//------------------------------------------------------------------------

module pulse_gen_type2 #(parameter WD = 10)
    (
	output logic           clk_pulse_o,

	input logic            clk,
        input logic            reset_n,
	input logic [WD-1:0]   cfg_max_cnt
);


logic [WD-1:0]  cnt;


always @ (posedge clk or negedge reset_n)
begin
   if (reset_n == 1'b0) begin 
      cnt             <= 'b0;
      clk_pulse_o     <= 'b0;
   end else begin 
      if(cnt == cfg_max_cnt) begin
          cnt         <= 0;
          clk_pulse_o <= 1'b1;
      end else begin
          cnt         <= cnt +1;
          clk_pulse_o   <= 1'b0;
      end
   end
end

endmodule

