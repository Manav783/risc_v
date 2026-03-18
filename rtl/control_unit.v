//this specifies the operation based on the opcode
//mainly determines the ALUOp

module control_unit (
    input [6:0] opcode,        // recieved from instruction
    output reg Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite,
    output reg LUI_en, AUIPC_en, JAL_en, JALr_en,  // enable signals for I and J type signals
    output reg [1:0] ALUOp
);

  always @(*) begin
      case(opcode)
          // R - Types
          7'b0110011: {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch,LUI_en, AUIPC_en, JAL_en, JALr_en, ALUOp} <= 12'b001000000010;
          // I - Type
          7'b0010011: {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch,LUI_en, AUIPC_en, JAL_en, JALr_en, ALUOp} <= 12'b101000000010;
          // Load
          7'b0000011: {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch,LUI_en, AUIPC_en, JAL_en, JALr_en, ALUOp} <= 12'b111100000000;
          // Store
          7'b0100011: {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch,LUI_en, AUIPC_en, JAL_en, JALr_en, ALUOp} <= 12'b100010000000;
          // beq
          7'b1100011: {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch,LUI_en, AUIPC_en, JAL_en, JALr_en, ALUOp} <= 12'b000001000001;
          // U-type LUI
          7'b0110111: {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch,LUI_en, AUIPC_en, JAL_en, JALr_en, ALUOp} <= 12'b100000010000;
          // U-type AUIP
          7'b0010111: {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch,LUI_en, AUIPC_en, JAL_en, JALr_en, ALUOp} <= 12'b100000010000;
          // J-type JAL
          7'b1101111: {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch,LUI_en, AUIPC_en, JAL_en, JALr_en, ALUOp} <= 12'b100000001110;
          // J-type JALr
          7'b1100111: {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch,LUI_en, AUIPC_en, JAL_en, JALr_en, ALUOp} <= 12'b110000000001;
          default: {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch,LUI_en, AUIPC_en, JAL_en, JALr_en, ALUOp} <= 12'b000000000000;
      endcase
  end

endmodule

// outputs for assigned according to the instruction set
