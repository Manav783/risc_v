`include "ALU_control.v"
`include "ALU_unit.v"
`include "branch_adder.v"
`include "control_unit.v"
`include "data_mem.v"
`include "gatelogic.v"
`include "ImmGen.v"
`include "instruction_mem.v"
`include "mux.v"
`include "PC_inc.v"
`include "program_counter.v"
`include "reg_file.v"

// ============================================================
// RISC-V Single-Cycle Processor — Top-Level
// Supports: R-type, I-type, Load, Store, BEQ, LUI, AUIPC, JAL, JALR
// ============================================================
module top (
    input clk, rst          // FIX: removed trailing comma
);

    // ---- Wire declarations ----
    wire [31:0] instruction_top;            // FIX: was missing
    wire [31:0] PC_top, PC_plused_top;
    wire [31:0] ImmExt_top;
    wire [31:0] RD1_top, RD2_top;
    wire [31:0] pc_sel_mux_out;             // AUIPC mux out (A input to ALU)
    wire [31:0] ALU_mux_out_top;            // B input to ALU
    wire [31:0] ALU_out_top;
    wire [31:0] branch_target_top;          // PC + Imm (branch adder out)
    wire [31:0] PC_addr_mux_out_top;        // After branch mux
    wire [31:0] JAL_mux_out_top;            // After JAL mux
    wire [31:0] PC_next_mux_out;            // Final PC_in (after JALR mux)
    wire [31:0] data_mem_read_out_top;
    wire [31:0] data_mem_mux_out_top;
    wire [31:0] mux_out_write_data;

    wire [3:0]  ALU_ctrl_top;
    wire [1:0]  ALUOp_top;

    wire        RegWrite_top, ALUSrc_top, MemtoReg_top;
    wire        MemRead_top, MemWrite_top, Branch_top;
    wire        LUI_en_top, AUIPC_en_top, JAL_en_top, JALr_en_top;
    wire        zero_top, and_out_top;

    // ---- Program Counter ----
    program_counter PC (
        .clk(clk), .rst(rst),
        .PC_in(PC_next_mux_out),
        .PC_out(PC_top)
    );

    // ---- PC + 4 ----
    PC_inc PC_adder (
        .fromPC(PC_top),
        .toPC(PC_plused_top)
    );

    // ---- Instruction Memory ----
    instruction_mem inst_mem (
        .read_address(PC_top),
        .instruction_out(instruction_top)
    );

    // ---- Control Unit ----
    control_unit ctrl_unit (
        .opcode(instruction_top[6:0]),
        .Branch(Branch_top),
        .MemRead(MemRead_top),
        .MemtoReg(MemtoReg_top),
        .MemWrite(MemWrite_top),
        .ALUSrc(ALUSrc_top),
        .RegWrite(RegWrite_top),
        .LUI_en(LUI_en_top),
        .AUIPC_en(AUIPC_en_top),
        .JAL_en(JAL_en_top),
        .JALr_en(JALr_en_top),
        .ALUOp(ALUOp_top)
    );

    // ---- Immediate Generator ----
    ImmGen Imm (
        .opcode(instruction_top[6:0]),
        .instructions(instruction_top),
        .ImmExt(ImmExt_top)
    );

    // ---- Write-back mux: LUI bypasses normal write-back with raw immediate ----
    mux write_reg_mux (
        .sel(LUI_en_top),
        .A(data_mem_mux_out_top),
        .B(ImmExt_top),
        .mux_out(mux_out_write_data)
    );

    // ---- Register File ----
    reg_file regFile (
        .clk(clk), .rst(rst),
        .reg_write(RegWrite_top),
        .rs1(instruction_top[19:15]),
        .rs2(instruction_top[24:20]),
        .rd(instruction_top[11:7]),
        .write_data(mux_out_write_data),
        .read_data_1(RD1_top),
        .read_data_2(RD2_top)
    );

    // ---- AUIPC mux: selects PC (for AUIPC) or RD1 as ALU A-input ----
    mux pc_sel_mux_U (
        .sel(AUIPC_en_top),
        .A(RD1_top),
        .B(PC_top),
        .mux_out(pc_sel_mux_out)
    );

    // ---- ALUSrc mux: selects RD2 or Immediate as ALU B-input ----
    mux ALU_mux (
        .sel(ALUSrc_top),           // FIX: was ALUsrc_top (wrong case)
        .A(RD2_top),
        .B(ImmExt_top),
        .mux_out(ALU_mux_out_top)
    );

    // ---- ALU Control ----
    ALU_control ALUctrl (
        .ALUop(ALUOp_top),
        .fun7(instruction_top[30]),
        .fun3(instruction_top[14:12]),
        .control_out(ALU_ctrl_top)
    );

    // ---- ALU ----
    ALU_unit ALU (
        .A(pc_sel_mux_out),
        .B(ALU_mux_out_top),
        .control_in(ALU_ctrl_top),
        .zero(zero_top),
        .ALU_out(ALU_out_top)
    );

    // ---- Branch Adder: PC + Imm ----
    Branch_adder BranchAdd (
        .plus4_addr(PC_top),
        .ImmAddr(ImmExt_top),
        .mux_in_addr(branch_target_top)   // FIX: was .mux_in_order
    );

    // ---- Gate Logic: branch taken only when Branch=1 AND zero=1 ----
    gatelogic gate (
        .Branch(Branch_top),
        .zero(zero_top),
        .and_out(and_out_top)
    );

    // ---- Branch mux: PC+4 vs branch target ----
    // FIX: this mux was completely missing in original top.v
    mux branch_mux (
        .sel(and_out_top),
        .A(PC_plused_top),
        .B(branch_target_top),
        .mux_out(PC_addr_mux_out_top)
    );

    // ---- JAL mux ----
    mux pc_sel_mux_J (
        .sel(JAL_en_top),
        .A(PC_addr_mux_out_top),
        .B(ALU_out_top),
        .mux_out(JAL_mux_out_top)
    );

    // ---- JALR mux ----
    mux pc_sel_mux_Jr (
        .sel(JALr_en_top),
        .A(JAL_mux_out_top),
        .B(ALU_out_top),
        .mux_out(PC_next_mux_out)
    );

    // ---- Data Memory ----
    data_mem datamem_unit (
        .clk(clk), .rst(rst),
        .MemRead(MemRead_top),
        .MemWrite(MemWrite_top),
        .address(ALU_out_top),
        .write_data(RD2_top),
        .read_data(data_mem_read_out_top)
    );

    // ---- Write-back mux: ALU result vs memory data ----
    mux data_mem_mux (
        .sel(MemtoReg_top),
        .A(ALU_out_top),
        .B(data_mem_read_out_top),
        .mux_out(data_mem_mux_out_top)
    );

endmodule
