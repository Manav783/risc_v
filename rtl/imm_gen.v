module imm_gen (
  input  [6:0] opcode,
  input  [31:0] instructions,
  output reg [31:0] ImmExt
);

  always @(*) begin
    case(opcode)
      // I-type (addi, etc.)
      7'b0010011 : ImmExt = {{20{instructions[31]}}, instructions[31:20]}; 
      // Load
      7'b0000011 : ImmExt = {{20{instructions[31]}}, instructions[31:20]};     
      // S-type (store)
      7'b0100011 : ImmExt = {{20{instructions[31]}}, instructions[31:25], instructions[11:7]};
      // B-type (branch)
      7'b1100011 : ImmExt = {{19{instructions[31]}}, instructions[31], instructions[7],instructions[30:25], instructions[11:8], 1'b0};
      // U-type (LUI)
      7'b0110111 : ImmExt = {instructions[31:12], 12'b0};
      // U-type (AUIPC)
      7'b0010111 : ImmExt = {instructions[31:12], 12'b0};
      // J-type (JAL)
      7'b1101111 : ImmExt = {{11{instructions[31]}}, instructions[31], instructions[19:12],instructions[20], instructions[30:21], 1'b0};
      // I-type (JALR)
      7'b1100111 : ImmExt = {{20{instructions[31]}}, instructions[31:20]};
      default : ImmExt = 32'b0;
    endcase
  end

endmodule

// immediate generation is the process of sign extension taht we are about to receive.
// we will use the opcode, which we will recceive from instruction[6:0]
