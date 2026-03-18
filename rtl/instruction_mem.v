module instruction_men (
  input clk, rst,
  input [31:0] read_address,
  output [31:0] instruction_out
);

  reg [31:0] mem [0:63];
  assign instruction_out = mem[read_address >> 2];
  
endmodule 

// it will read the instruction from memory and will give it out
