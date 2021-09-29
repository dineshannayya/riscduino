module DAC_8BIT (
`ifdef USE_POWER_PINS
    input wire vdd,	// User area 1 1.8V supply
    input wire gnd,	// User area 1 digital ground
`endif
    input wire d0,
    input wire d1,
    input wire d2,
    input wire d3,
    input wire d4,
    input wire d5,
    input wire d6,
    input wire d7,
    
    input wire inp1,
    input wire inp2, 

    output wire out_v
);

// Dummy behavirol model to verify the DAC connection with the user_project_wrapper
assign out_v = d0 | d1 | d2 | d3 | d4 | d5 | d6 | d7 ;

endmodule