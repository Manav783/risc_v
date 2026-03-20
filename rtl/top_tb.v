 // ignore include and timescale if you are using Vivado
`include "top.v"  
`timescale 1ps/1ps
module top_tb();
  reg clk, rst;
  integer i;
  
  top DUT(.clk(), .rst());

  initial begin
    // clear memory just in case
    for(i=0; i<64; i=i+1) DUT.inst_mem.mem[i] = 32'b0;

    //valid instruction 
  end

  initial begin
    clk=0; rst=1;
    #5
    rst=0;
  end

  always begin
    #5 clk = ~clk;
  end

  initial begin 
    $dumpfile("top_tb.vcd");   // for GTKWave
    $dumpvarse(0,top_tb);
    #1000
    $finish
  end

endmodule 
