
module ctech_mux2x1 (
	input  logic A0,
	input  logic A1,
	input  logic S ,
	output logic X);

sky130_fd_sc_hd__mux2_8 u_mux (.A0 (A0), .A1 (A1), .S  (S), .X (X));

endmodule
