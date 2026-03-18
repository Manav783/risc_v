module Branch_adder (
  input [31:0] plus4_addr, ImmAddr,
  output [31:0] mux_in_addr
);
  assign mux_in_addr = plus4_addr + ImmAddr;
endmodule

// this will add current PC value and immediate value generated from ImmGen.v
