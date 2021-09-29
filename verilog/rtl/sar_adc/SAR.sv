// file: SAR.v
// A parametrized Successive Approximation Register (SAR)
// The module is so compact; it is only 110 cells for 
// 8-bit SAR using SKY130 HD library
//
// author: Mohamed Shalan (mshalan@aucegypt.edu)

`timescale 1ns/1ns

module SAR  #(parameter SIZE = 8) ( 
    input   wire            clk,    // The clock
    input   wire            reset_n, // Active low reset
    input   wire            start,  // Conversion start 
    input   wire            cmp,    // Analog comparator output
    output  wire [SIZE-1:0] out,    // The output sample
    output  wire [SIZE-1:0] outn,   // Inverted output for active low DAC
    output  wire            done,   // Conversion is done
    output  wire            clkn    // Inverted clock to be used by the clocked analog comparator
);
	
	reg [SIZE-1:0] result;
	reg [SIZE-1:0] shift;
	
    // FSM to handle the SAR operation
    reg [1:0] state, nstate;
	localparam IDLE=0, CONV=1, DONE=2;

	always @*
        case (state)
            IDLE:       if(start) nstate = CONV;
                            else nstate = IDLE;
            CONV:       if(shift == 1'b1) nstate = DONE;
                            else nstate = CONV;
            DONE:       nstate = IDLE;
            default:    nstate = IDLE;
        endcase
	  
	always @(posedge clk or negedge reset_n)
        if(!reset_n)
            state <= IDLE;
        else
            state <= nstate;

    // Shift Register
    always @(posedge clk)
        if(state == IDLE) 
            shift <= 1'b1 << (SIZE-1);
        else if(state == CONV)
            shift<= shift >> 1; 

    // The SAR
    wire [SIZE-1:0] current = (cmp == 1'b0) ? ~shift : {SIZE{1'b1}} ;
    wire [SIZE-1:0] next = shift >> 1;
    always @(posedge clk)
        if(state == IDLE) 
            result <= 1'b1 << (SIZE-1);
        else if(state == CONV)
            result <= (result | next) & current; 
	   
	  assign out = result;
      assign outn = ~result;
      assign clkn = ~clk;
	  assign done = (state==DONE);
	
endmodule
