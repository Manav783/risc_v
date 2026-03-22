// ALU Unit
// Performs arithmetic/logic operations. Sets zero flag when A == B on SUB.
module ALU_unit (
    input  [31:0] A, B,
    input  [3:0]  control_in,
    output reg        zero,
    output reg [31:0] ALU_out
);
    always @(*) begin
        zero = 0;
        case(control_in)
            4'b0000 : ALU_out = A & B;           // AND
            4'b0001 : ALU_out = A | B;           // OR
            4'b0010 : ALU_out = A + B;           // ADD
            4'b0110 : begin
                          ALU_out = A - B;        // SUB
                          zero    = (A == B);
                      end
            default : ALU_out = 32'b0;
        endcase
    end
endmodule
