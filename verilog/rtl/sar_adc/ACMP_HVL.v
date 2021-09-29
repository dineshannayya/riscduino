/*
    An analog comparator using HVL cells
*/

module ACMP_HVL(
`ifdef USE_POWER_PINS
    input wire vccd2,	
    input wire vssd2,	
`endif
    input   wire clk,
    input   wire INP,
    input   wire INN,
    output  wire Q    
);
    wire clkb;
    wire Q1b, Q1;
    wire Q2b, Q2;
    wire Qb;

    sky130_fd_sc_hvl__inv_1 x0 (
        .Y(clkb),
        .A(clk)
    );    

    sky130_fd_sc_hvl__nor3_1 x5(
        .Y(Q),
        .A(Q1b),
        .B(Q2b),
        .C(Qb)
    );

    sky130_fd_sc_hvl__nor3_1 x6(
        .Y(Qb),
        .A(Q1),
        .B(Q2),
        .C(Q)
    );

    latch_nand3 x1 (
        .CLK(clk), 
        .VP(INP), 
        .VN(INN),
        .Q(Q1),
        .Qb(Q1b) 
    );

    latch_nor3 x2 (
        .CLK(clkb), 
        .VP(INP), 
        .VN(INN),
        .Q(Q2),
        .Qb(Q2b) 
    );

endmodule

module latch_nor3 (
    input   wire CLK, 
    input   wire VP, 
    input   wire VN,
    output  wire Q,
    output  wire Qb 
);

    sky130_fd_sc_hvl__nor3_1 x1(
        .Y(Qb),
        .A(CLK),
        .B(VP),
        .C(Q)
    );
    sky130_fd_sc_hvl__nor3_1 x2(
        .Y(Q),
        .A(CLK),
        .B(VN),
        .C(Qb)
    );
    
endmodule

module latch_nand3 (
    input   wire CLK, 
    input   wire VP, 
    input   wire VN,
    output  wire Q,
    output  wire Qb 
);
    wire Q0, Q0b;

    sky130_fd_sc_hvl__nand3_1 x1(
        .Y(Q0b),
        .A(CLK),
        .B(VP),
        .C(Q0)
    );
    sky130_fd_sc_hvl__nand3_1 x2(
        .Y(Q0),
        .A(CLK),
        .B(VN),
        .C(Q0b)
    );

    sky130_fd_sc_hvl__inv_4 x3 (
        .Y(Qb),
        .A(Q0)
    ); 

    sky130_fd_sc_hvl__inv_4 x4 (
        .Y(Q),
        .A(Q0b)
    ); 
    
endmodule