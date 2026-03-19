module program_counter(
  input clk,rst,
  input [31:0] PC_in,
  output reg [31:0] PC_out
);

  always @(posedge clk or posedge rst) begin
      PC_out <= rst ? 32'b00 : PC_in;
  end
  
endmodule

// PC_next should go to the same instruction after completing set of instructions
// PC_next will give us the address of the next PC_out
