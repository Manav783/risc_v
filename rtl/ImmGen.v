// Immediate Generator
// Sign-extends the immediate field from the instruction based on opcode/type.
module ImmGen (
    input  [6:0]  opcode,
    input  [31:0] instructions,
    output reg [31:0] ImmExt
);
    always @(*) begin
        case(opcode)
            7'b0010011,          // I-type (ADDI, etc.)
            7'b0000011,          // Load
            7'b1100111:          // JALR
                ImmExt = {{20{instructions[31]}}, instructions[31:20]};

            7'b0100011:          // S-type (Store)
                ImmExt = {{20{instructions[31]}}, instructions[31:25], instructions[11:7]};

            7'b1100011:          // B-type (Branch)
                ImmExt = {{19{instructions[31]}}, instructions[31], instructions[7],
                           instructions[30:25], instructions[11:8], 1'b0};

            7'b0110111,          // U-type LUI
            7'b0010111:          // U-type AUIPC
                ImmExt = {instructions[31:12], 12'b0};

            7'b1101111:          // J-type JAL
                ImmExt = {{11{instructions[31]}}, instructions[31], instructions[19:12],
                           instructions[20], instructions[30:21], 1'b0};

            default: ImmExt = 32'b0;
        endcase
    end
endmodule
