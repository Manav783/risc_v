// Register File: 32 x 32-bit registers
// x0 is hardwired to zero (writes to x0 are ignored).
module reg_file (
    input         clk, rst, reg_write,
    input  [4:0]  rs1, rs2, rd,
    input  [31:0] write_data,
    output [31:0] read_data_1, read_data_2
);
    reg [31:0] registers [0:31];
    integer k;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (k = 0; k < 32; k = k + 1)
                registers[k] <= 32'b0;
        end else if (reg_write && rd != 5'b0) begin
            registers[rd] <= write_data;
        end
    end

    // Asynchronous read; x0 always returns 0
    assign read_data_1 = (rs1 == 5'b0) ? 32'b0 : registers[rs1];
    assign read_data_2 = (rs2 == 5'b0) ? 32'b0 : registers[rs2];
endmodule
