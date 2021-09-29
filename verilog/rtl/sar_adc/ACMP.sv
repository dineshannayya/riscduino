module ACMP(
`ifdef USE_POWER_PINS
    input wire vccd2,
    input wire vssd2, 
`endif 
    input   wire clk,
    input   wire INP,
    input   wire INN,
    input   wire VDD,
    input   wire VSS,
    output  wire Q    
);

`ifdef ACMP_FUNCTIONAL

    assign Q = INP > INN ;
`else 

    wire    clkb;
    wire    net1, 
            net2,
            net3,
            net4,
            net5,
            net6,
            net7;
    
    sky130_fd_sc_hd__inv_1 x15 (
    `ifdef USE_POWER_PINS
        .VPWR(VPWR),
        .VGND(VGND), 
        .VPB(VPWR),
        .VNB(VGND),
    `endif 
        .A(clk), .Y(clkb));
    sky130_fd_sc_hd__a221oi_1 x7 (
    `ifdef USE_POWER_PINS
        .VPWR(VPWR),
        .VGND(VGND), 
        .VPB(VPWR),
        .VNB(VGND),
    `endif 
        .A1(INP), .A2(INP), .B1(clkb), .B2(VDD), .C1(net2), .Y(net1));     
    sky130_fd_sc_hd__a221oi_1 x8 (
    `ifdef USE_POWER_PINS
        .VPWR(VPWR),
        .VGND(VGND), 
        .VPB(VPWR),
        .VNB(VGND),
    `endif 
        .A1(INN), .A2(INN), .B1(clkb), .B2(VDD), .C1(net1), .Y(net2));  
    sky130_fd_sc_hd__inv_1 x2 (
    `ifdef USE_POWER_PINS
        .VPWR(VPWR),
        .VGND(VGND), 
        .VPB(VPWR),
        .VNB(VGND),
    `endif 
        .A(net3), .Y(net6));
    sky130_fd_sc_hd__inv_1 x3 (
    `ifdef USE_POWER_PINS
        .VPWR(VPWR),
        .VGND(VGND), 
        .VPB(VPWR),
        .VNB(VGND),
    `endif 
        .A(net4), .Y(net5));
    sky130_fd_sc_hd__o221ai_1 x6 (
    `ifdef USE_POWER_PINS
        .VPWR(VPWR),
        .VGND(VGND), 
        .VPB(VPWR),
        .VNB(VGND),
    `endif 
        .A1(INP), .A2(INP), .B1(clk), .B2(VSS), .C1(net4), .Y(net3));
    sky130_fd_sc_hd__o221ai_1 x9 (
    `ifdef USE_POWER_PINS
        .VPWR(VPWR),
        .VGND(VGND), 
        .VPB(VPWR),
        .VNB(VGND),
    `endif 
        .A1(INN), .A2(INN), .B1(clk), .B2(VSS), .C1(net3), .Y(net4));
    sky130_fd_sc_hd__nor3_1 x10 (
    `ifdef USE_POWER_PINS
        .VPWR(VPWR),
        .VGND(VGND), 
        .VPB(VPWR),
        .VNB(VGND),
    `endif 
        .A(net5), .B(net1), .C(net7), .Y(Q));
    sky130_fd_sc_hd__nor3_1 x11 (
    `ifdef USE_POWER_PINS
        .VPWR(VPWR),
        .VGND(VGND),
        .VPB(VPWR),
        .VNB(VGND), 
    `endif 
        .A(Q), .B(net6), .C(net2), .Y(net7));
    
`endif

endmodule