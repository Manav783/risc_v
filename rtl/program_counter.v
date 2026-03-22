// Program Counter: updates on rising clock edge, resets to 0
module program_counter (
    input         clk, rst,
    input  [31:0] PC_in,
    output reg [31:0] PC_out
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            PC_out <= 32'b0;
        else
            PC_out <= PC_in;
    end
endmodule
