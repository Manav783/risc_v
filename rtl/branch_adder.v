// Branch Adder: computes branch target = PC + sign_extended_immediate
module Branch_adder (
    input  [31:0] plus4_addr,   // Current PC value
    input  [31:0] ImmAddr,      // Sign-extended immediate from ImmGen
    output [31:0] mux_in_addr   // Branch target address
);
    assign mux_in_addr = plus4_addr + ImmAddr;
endmodule
