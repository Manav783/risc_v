// ALU Control Unit
// Generates 4-bit ALU operation signal based on ALUOp from Control Unit
// and funct3/funct7 fields from the instruction.
module ALU_control(
    input  [1:0] ALUop,       // From control unit
    input        fun7,         // Bit [30] of instruction
    input  [2:0] fun3,         // Bits [14:12] of instruction
    output reg [3:0] control_out
);
    always @(*) begin
        case({ALUop, fun7, fun3})
            6'b00_0_000 : control_out = 4'b0010; // Load / Store  -> ADD
            6'b01_0_000 : control_out = 4'b0110; // BEQ           -> SUB
            6'b10_0_000 : control_out = 4'b0010; // ADD
            6'b10_1_000 : control_out = 4'b0110; // SUB
            6'b10_0_111 : control_out = 4'b0000; // AND  (funct3=111)
            6'b10_0_110 : control_out = 4'b0001; // OR   (funct3=110)
            default     : control_out = 4'b0010; // Default: ADD
        endcase
    end
endmodule
