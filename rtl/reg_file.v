module reg_file(
  input clk, rst, reg_write,
  input [4:0] rs1,rs2,rd,
  input [31:0] write_data,
  output [31:0] read_data_1, read_data_2
);

  reg [31:0] registers[31:0];
  integer k;

  always @(posedge clk or posedge rst) begin
    if(rst) begin
        for(k=0;k<32;k=k+1) begin
            registers[k] <= k*2;
        end
    end 
    else if (reg_write) begin
      registers[rd] <= write_data;   // from writeback stage and giving it into destination reg
    end
  end

  assign read_data_1 = registers[rs1];
  assign read_data_2 = registers[rs2];
  
endmodule

// the instruction from instruction memory is divided into rs1, rs2 and rd 
// reg_write and write_data will come from other part of the design 
