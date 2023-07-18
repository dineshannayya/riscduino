
module ctech_mux2x1 #(parameter WB = 1) (
	input  logic [WB-1:0] A0,
	input  logic [WB-1:0] A1,
	input  logic S ,
	output logic [WB-1:0] X);

`ifndef SYNTHESIS
assign X = (S) ? A1 : A0;
`else 
    generate
       if (WB > 1)
       begin : bus_
         genvar tcnt;
         for (tcnt = 0; $unsigned(tcnt) < WB; tcnt=tcnt+1) begin : bit_
             sky130_fd_sc_hd__mux2_8 u_mux (.A0 (A0[tcnt]), .A1 (A1[tcnt]), .S  (S), .X (X[tcnt]));
         end
       end else begin
          sky130_fd_sc_hd__mux2_8 u_mux (.A0 (A0), .A1 (A1), .S  (S), .X (X));
       end
    endgenerate
`endif

endmodule

module ctech_mux2x1_2 #(parameter WB = 1) (
	input  logic [WB-1:0] A0,
	input  logic [WB-1:0] A1,
	input  logic S ,
	output logic [WB-1:0] X);

`ifndef SYNTHESIS
assign X = (S) ? A1 : A0;
`else 
    generate
       if (WB > 1)
       begin : bus_
         genvar tcnt;
         for (tcnt = 0; $unsigned(tcnt) < WB; tcnt=tcnt+1) begin : bit_
             sky130_fd_sc_hd__mux2_2 u_mux (.A0 (A0[tcnt]), .A1 (A1[tcnt]), .S  (S), .X (X[tcnt]));
         end
       end else begin 
          sky130_fd_sc_hd__mux2_2 u_mux (.A0 (A0), .A1 (A1), .S  (S), .X (X));
       end
    endgenerate
`endif

endmodule

module ctech_mux2x1_4 #(parameter WB = 1) (
	input  logic [WB-1:0] A0,
	input  logic [WB-1:0] A1,
	input  logic S ,
	output logic [WB-1:0] X);

`ifndef SYNTHESIS
assign X = (S) ? A1 : A0;
`else 
    generate
       if (WB > 1)
       begin : bus_
         genvar tcnt;
         for (tcnt = 0; $unsigned(tcnt) < WB; tcnt=tcnt+1) begin : bit_
             sky130_fd_sc_hd__mux2_4 u_mux (.A0 (A0[tcnt]), .A1 (A1[tcnt]), .S  (S), .X (X[tcnt]));
         end
       end else begin
          sky130_fd_sc_hd__mux2_4 u_mux (.A0 (A0), .A1 (A1), .S  (S), .X (X));
       end
    endgenerate
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

wire X1,X2,X3;
`ifndef SYNTHESIS
    assign X = A;
`else
     sky130_fd_sc_hd__clkbuf_1 u_dly0 (.X(X1),.A(A));
     sky130_fd_sc_hd__clkbuf_1 u_dly1 (.X(X2),.A(X1));
     sky130_fd_sc_hd__clkbuf_1 u_dly2 (.X(X3),.A(X2));
     sky130_fd_sc_hd__clkbuf_1 u_dly3 (.X(X),.A(X3));
`endif

endmodule

module ctech_clk_gate (
	input  logic GATE  ,
	input  logic CLK   ,
	output logic GCLK
     );

`ifndef SYNTHESIS
   logic clk_enb;

   assign #1 GCLK  = CLK & clk_enb;
   
   always_latch begin
       if(CLK == 0) begin
            clk_enb <= GATE;
       end
   end

`else
    sky130_fd_sc_hd__dlclkp_2 u_gate(
                                   .GATE    (GATE     ), 
                                   .CLK     (CLK      ), 
                                   .GCLK    (GCLK     )
                                  );
`endif

endmodule

// Double sync High, added ctech cell to easy defining false path at sdc
module ctech_dsync_high #(parameter WB = 1) (
	input  logic [WB-1:0]  in_data,
    input  logic           out_clk,
    input  logic           out_rst_n,
	output  logic [WB-1:0] out_data
	);

`ifndef SYNTHESIS

reg [WB-1:0]     in_data_s  ; // One   Cycle sync 
reg [WB-1:0]     in_data_2s ; // two   Cycle sync 
reg [WB-1:0]     in_data_3s ; // three Cycle sync 

assign out_data =  in_data_3s;

always @(negedge out_rst_n or posedge out_clk)
begin
   if(out_rst_n == 1'b0)
   begin
      in_data_s  <= {WB{1'b0}};
      in_data_2s <= {WB{1'b0}};
      in_data_3s <= {WB{1'b0}};
   end
   else
   begin
      in_data_s  <= in_data;
      in_data_2s <= in_data_s;
      in_data_3s <= in_data_2s;
   end
end
`else 
    wire [WB-1:0]     in_data_s  ; // One   Cycle sync 
    wire [WB-1:0]     in_data_2s ; // two   Cycle sync 
    wire [WB-1:0]     out_data ; // three Cycle sync 
    generate
       if (WB > 1)
       begin : bus_
         genvar tcnt;
         for (tcnt = 0; $unsigned(tcnt) < WB; tcnt=tcnt+1) begin : bit_
             sky130_fd_sc_hd__dfrtp_1 u_dsync0 (.CLK(out_clk),.D(in_data[tcnt]),   .RESET_B(out_rst_n),.Q(in_data_s[tcnt]));
             sky130_fd_sc_hd__dfrtp_1 u_dsync1 (.CLK(out_clk),.D(in_data_s[tcnt]), .RESET_B(out_rst_n),.Q(in_data_2s[tcnt]));
             sky130_fd_sc_hd__dfrtp_1 u_dsync2 (.CLK(out_clk),.D(in_data_2s[tcnt]),.RESET_B(out_rst_n),.Q(out_data[tcnt]));
         end
       end else begin 
             sky130_fd_sc_hd__dfrtp_1 u_dsync0 (.CLK(out_clk),.D(in_data),   .RESET_B(out_rst_n),.Q(in_data_s));
             sky130_fd_sc_hd__dfrtp_1 u_dsync1 (.CLK(out_clk),.D(in_data_s), .RESET_B(out_rst_n),.Q(in_data_2s));
             sky130_fd_sc_hd__dfrtp_1 u_dsync2 (.CLK(out_clk),.D(in_data_2s),.RESET_B(out_rst_n),.Q(out_data));
       end
    endgenerate
`endif

endmodule
