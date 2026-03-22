// Generic 2-to-1 Multiplexer (32-bit)
module mux (
    input        sel,
    input  [31:0] A, B,
    output [31:0] mux_out
);
    assign mux_out = sel ? B : A;
endmodule
