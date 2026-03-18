// a simple memory

module data_mem (
  input clk, rst, MemRead, MemWrite,
  input [31:0] address,
  input [31:0] write_data,
  output [31:0] read_data
);

  reg [31:0] D_mem [63:0];
  integer k;

  always @(posedge clk or posedge rst) begin
    if(rst) begin
      for(k=0; k<64; k=k+1) D_mem[k] <= 32'b00;
    end
    else if (MemWrite)
      D_mem[address] <= write_data;
  end

  assign read_data = (MemRead) ? D_mem[address] : 32'b00;
  
endmodule

// we will recieve the address from ALU, now if write_data is high we will 
// write that data into the address given by address which we will get from ALU.

// if MemRead is high, then we read the data in that address 
// if not high, then read_data is assigned 0

