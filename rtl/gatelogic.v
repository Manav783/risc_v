// Gate Logic: AND gate for branch decision
// Output goes high only when Branch is asserted AND ALU zero flag is set (A == B)
module gatelogic (
    input  Branch, zero,
    output and_out
);
    assign and_out = Branch & zero;
endmodule
