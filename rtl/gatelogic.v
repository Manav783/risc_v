module gatelogic (
  input Branch, zero,
  output and_out
);
  assign and_out = Branch & zero;
endmodule

// mainly used for the selection purpose in the PC_Branch.
// is used in the select lines of mux
