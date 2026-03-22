// Control Unit
// Decodes the 7-bit opcode and drives all datapath control signals.
module control_unit (
    input  [6:0] opcode,
    output reg Branch,
    output reg MemRead,
    output reg MemtoReg,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite,
    output reg LUI_en,
    output reg AUIPC_en,
    output reg JAL_en,
    output reg JALr_en,
    output reg [1:0] ALUOp
);
    // Signal order: {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch,
    //                LUI_en, AUIPC_en, JAL_en, JALr_en, ALUOp[1:0]}
    always @(*) begin
        case(opcode)
            7'b0110011: // R-type
                {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,LUI_en,AUIPC_en,JAL_en,JALr_en,ALUOp} = 12'b0_0_1_0_0_0_0_0_0_0_10;
            7'b0010011: // I-type (ADDI, etc.)
                {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,LUI_en,AUIPC_en,JAL_en,JALr_en,ALUOp} = 12'b1_0_1_0_0_0_0_0_0_0_10;
            7'b0000011: // Load
                {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,LUI_en,AUIPC_en,JAL_en,JALr_en,ALUOp} = 12'b1_1_1_1_0_0_0_0_0_0_00;
            7'b0100011: // Store
                {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,LUI_en,AUIPC_en,JAL_en,JALr_en,ALUOp} = 12'b1_0_0_0_1_0_0_0_0_0_00;
            7'b1100011: // BEQ
                {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,LUI_en,AUIPC_en,JAL_en,JALr_en,ALUOp} = 12'b0_0_0_0_0_1_0_0_0_0_01;
            7'b0110111: // LUI
                {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,LUI_en,AUIPC_en,JAL_en,JALr_en,ALUOp} = 12'b1_0_1_0_0_0_1_0_0_0_00;
            7'b0010111: // AUIPC
                {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,LUI_en,AUIPC_en,JAL_en,JALr_en,ALUOp} = 12'b1_0_1_0_0_0_0_1_0_0_10;
            7'b1101111: // JAL
                {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,LUI_en,AUIPC_en,JAL_en,JALr_en,ALUOp} = 12'b1_0_1_0_0_0_0_0_1_0_10;
            7'b1100111: // JALR
                {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,LUI_en,AUIPC_en,JAL_en,JALr_en,ALUOp} = 12'b1_1_1_0_0_0_0_0_0_1_10;
            default:
                {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,LUI_en,AUIPC_en,JAL_en,JALr_en,ALUOp} = 12'b0;
        endcase
    end
endmodule
