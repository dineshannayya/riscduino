
//------------------------------------------------------------------------
// This module is used to generate 1ms and 1sec pulse based on 1us trigger
// pulse
//------------------------------------------------------------------------

module pulse_gen_type1(
	output logic clk_pulse_o,

	input logic clk,
        input logic reset_n,
	input logic trigger
);

parameter WD= 10;   // This will count from 0 to 1023
parameter MAX_CNT = 999;

logic [WD-1:0]  cnt;

assign clk_pulse_o = (cnt == 0) && trigger;

always @ (posedge clk or negedge reset_n)
begin
   if (reset_n == 1'b0) begin 
      cnt <= 'b0;
   end else begin 
      if(trigger) begin
          if(cnt >= MAX_CNT)
              cnt <= 0;
          else
              cnt <= cnt +1;
      end
   end
end

endmodule

