// Instruction Memory: 64 x 32-bit ROM, word-addressed
// Load your hex program via $readmemh in the testbench.
module instruction_mem (
    input  [31:0] read_address,
    output [31:0] instruction_out
);
    reg [31:0] mem [0:63];

    // Word-aligned read: divide byte address by 4
    assign instruction_out = mem[read_address >> 2];
endmodule
