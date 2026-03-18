// a simple adder, that will add 4 to the current PC_value

module PC_inc (
  input [31:0] fromPC,
  output [31:0] toPC
);
  assign toPC = 4 + fromPC;

endmodule
