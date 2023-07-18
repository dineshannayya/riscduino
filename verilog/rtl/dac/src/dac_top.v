module dac_top (
    VOUT0,
    VOUT1,
    VOUT2,
    VOUT3,
    VREFH,
    VDDA,  // User area 1 3.3V supply
    VSSA,  // User area 1 3.3V analog ground
    VCCD,  // User area 1 1.8V Digital
    VSSD,  // User area 1 1.8V Digital ground
    Din0,
    Din1,
    Din2,
    Din3);
 output VOUT0;
 output VOUT1;
 output VOUT2;
 output VOUT3;
 input VREFH;
 inout VDDA;
 inout VSSA;
 inout VCCD;
 inout VSSD;
 input [7:0] Din0;
 input [7:0] Din1;
 input [7:0] Din2;
 input [7:0] Din3;

endmodule
