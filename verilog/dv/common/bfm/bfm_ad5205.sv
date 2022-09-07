module bfm_ad5205 (
              input  logic       sck      ,
              input  logic       sdi      ,
              input  logic       ssn      ,

              output logic [2:0] channel  ,
              output logic [7:0] position 
           );


logic [10:0] shift_reg;
logic [10:0] load_reg;


always @(posedge ssn)
   load_reg = shift_reg;


always @(posedge sck)
    shift_reg = {shift_reg[9:0],sdi};


assign channel  = load_reg[10:8];
assign position = load_reg[7:0];


endmodule

