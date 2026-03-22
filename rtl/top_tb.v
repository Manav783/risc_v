`include "top.v"
`timescale 1ns/1ps

module top_tb();
    reg clk, rst;
    integer i;

    // Connect the CPU
    top DUT (
        .clk(clk),
        .rst(rst)
    );

    // Load the C-compiled program
    initial begin
        // Initialize memory to 0
        for (i = 0; i < 64; i = i + 1)
            DUT.inst_mem.mem[i] = 32'b0;

        // Load your hex file
        $readmemh("../sw/c_fixed.hex", DUT.inst_mem.mem);
    end

    // Clock Generation (10ns period)
    always #5 clk = ~clk;

    // Reset and Simulation Control
    initial begin
        clk = 0;
        rst = 1;
        #20 rst = 0;      // Hold reset for 2 cycles
        
        #5000;            // Increased time to allow C code to finish
        $display("Simulation finished at time %t", $time);
        $finish;
    end

    // Waveform Export
    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
    end

    // --- NEW: THE TERMINAL OUTPUT MONITOR ---
    // This watches Register x10 (a0), where C 'return' values are stored.
    always @(posedge clk) begin
        if (DUT.regFile.reg_write && DUT.regFile.rd == 5'd10) begin
            $display(">>> CPU EVENT: Register a0 (x10) updated to: %d (Hex: %h) at time %t", 
                     DUT.regFile.write_data, DUT.regFile.write_data, $time);
        end
    end

endmodule