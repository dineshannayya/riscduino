
module ctech_mux2x1 (
	input  logic A0,
	input  logic A1,
	input  logic S ,
	output logic X);

`ifndef SYNTHESIS
assign X = (S) ? A1 : A0;
`else 
sky130_fd_sc_hd__mux2_8 u_mux (.A0 (A0), .A1 (A1), .S  (S), .X (X));
`endif

endmodule

module ctech_mux2x1_2 (
	input  logic A0,
	input  logic A1,
	input  logic S ,
	output logic X);

`ifndef SYNTHESIS
assign X = (S) ? A1 : A0;
`else 
sky130_fd_sc_hd__mux2_2 u_mux (.A0 (A0), .A1 (A1), .S  (S), .X (X));
`endif

endmodule

module ctech_mux2x1_4 (
	input  logic A0,
	input  logic A1,
	input  logic S ,
	output logic X);

`ifndef SYNTHESIS
assign X = (S) ? A1 : A0;
`else 
sky130_fd_sc_hd__mux2_4 u_mux (.A0 (A0), .A1 (A1), .S  (S), .X (X));
`endif

endmodule

module ctech_buf (
	input  logic A,
	output logic X);

`ifndef SYNTHESIS
assign X = A;
`else
    sky130_fd_sc_hd__bufbuf_8 u_buf  (.A(A),.X(X));
`endif

endmodule

module ctech_clk_buf (
	input  logic A,
	output logic X);

`ifndef SYNTHESIS
assign X = A;
`else
    sky130_fd_sc_hd__clkbuf_8 u_buf  (.A(A),.X(X));
`endif

endmodule

module ctech_delay_buf (
	input  logic A,
	output logic X);

`ifndef SYNTHESIS
    assign X = A;
`else
     sky130_fd_sc_hd__dlygate4sd3_1 u_dly (.X(X),.A(A));
`endif

endmodule

module ctech_delay_clkbuf (
	input  logic A,
	output logic X);

`ifndef SYNTHESIS
    assign X = A;
`else
     sky130_fd_sc_hd__clkdlybuf4s15_2 u_dly (.X(X),.A(A));
`endif

endmodule
