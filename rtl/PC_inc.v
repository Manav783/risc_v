// PC Incrementer: adds 4 to the current PC value
module PC_inc (
    input  [31:0] fromPC,
    output [31:0] toPC
);
    assign toPC = fromPC + 32'd4;
endmodule
