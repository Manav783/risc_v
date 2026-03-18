 // ALU will be present in the exicution state and will recieve comand from ALU_control 

module ALU_control(
  input [1:0] ALUop,    // will be sent from control unit 
  input fun7,           // received from instruction directly
  input [2:0] fun3,     // 
  output reg [3:0] control_out    // sent ALU 
);

  always @(*) begin 
    case({ALUop, fun7, fun3}) 
      6'b00_0_000 : control_out <= 4'b0010; // Load or store
      6'b01_0_000 : control_out <= 4'b0110; // BEQ - (subract)branch if equal
      6'b10_0_000 : control_out <= 4'b0010; // ADD
      6'b10_1_000 : control_out <= 4'b0110; // SUB
      6'b10_0_111 : control_out <= 4'b0001; // OR
    endcase
  end

endmodule

// for fun7 we only consider 1 bit, as only one bit of change takes place, it there is change it means its a new op o/w same old op
// 30th bit of instruction is taken as fun7
// 
