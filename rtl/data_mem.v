// Data Memory: 64 x 32-bit synchronous write, asynchronous read
module data_mem (
    input         clk, rst,
    input         MemRead, MemWrite,
    input  [31:0] address,
    input  [31:0] write_data,
    output [31:0] read_data
);
    reg [31:0] D_mem [0:63];
    integer k;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (k = 0; k < 64; k = k + 1)
                D_mem[k] <= 32'b0;
        end else if (MemWrite) begin
            D_mem[address[7:2]] <= write_data;   // word-aligned indexing
        end
    end

    assign read_data = (MemRead) ? D_mem[address[7:2]] : 32'b0;
endmodule
