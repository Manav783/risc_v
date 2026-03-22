# RISC-V Single-Cycle Processor

A fully functional 32-bit RISC-V single-cycle CPU implemented in Verilog/SystemVerilog, capable of executing real C programs compiled with the RISC-V GNU Toolchain.

---

## Table of Contents

- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [CPU Architecture](#cpu-architecture)
- [Module Breakdown](#module-breakdown)
- [Supported Instructions](#supported-instructions)
- [Getting Started](#getting-started)
- [Step 1 — Compile C Code to Hex](#step-1--compile-c-code-to-hex)
- [Step 2 — Run the Hardware Simulation](#step-2--run-the-hardware-simulation)
- [Step 3 — Analyze Waveforms with GTKWave](#step-3--analyze-waveforms-with-gtkwave)
- [How the C-to-CPU Pipeline Works](#how-the-c-to-cpu-pipeline-works)

---

## Overview

This project implements a **single-cycle RISC-V RV32I processor** from scratch in Verilog. Every instruction completes in exactly one clock cycle. The design covers the full classic datapath — Fetch, Decode, Execute, Memory, and Write-Back — and supports a practical subset of the RV32I ISA including arithmetic, memory, branch, and jump instructions.

What makes this project unique is the **end-to-end software flow**: you can write real C code, compile it with `riscv-gcc`, and actually run it on this custom hardware in simulation.

---

## Repository Structure

```
RISC_V/
├── rtl/                        # All Verilog hardware source files
│   ├── top.v                   # Top-level: wires all modules together
│   ├── top_tb.v                # Testbench: loads hex and runs simulation
│   ├── program_counter.v       # PC register
│   ├── PC_inc.v                # PC + 4 adder
│   ├── instruction_mem.v       # Instruction memory (ROM)
│   ├── control_unit.v          # Main control signal decoder
│   ├── reg_file.v              # 32 x 32-bit register file
│   ├── ImmGen.v                # Immediate sign-extension
│   ├── ALU_control.v           # ALU operation decoder
│   ├── ALU_unit.v              # Arithmetic & Logic Unit
│   ├── branch_adder.v          # PC + Imm branch target adder
│   ├── data_mem.v              # Data memory (RAM)
│   ├── gatelogic.v             # Branch AND gate (Branch & Zero)
│   ├── mux.v                   # Generic 2-to-1 multiplexer
│   ├── top_tb.vcd              # Waveform dump (generated on simulation)
│   └── top_tb.vvp              # Compiled simulation binary (generated)
│
└── sw/                         # Software: C source and compiled outputs
    ├── code.c                  # Your C program
    ├── link.ld                 # Linker script (memory layout)
    ├── code.elf                # Compiled ELF binary
    ├── code.bin                # Raw binary extracted from ELF
    ├── c_fixed.hex             # Final hex file loaded by the CPU
    └── program.hex             # Alternate hex (manual assembly test)
```

---

## CPU Architecture

This is a **single-cycle** implementation, meaning every instruction — from fetch to write-back — completes within a single clock cycle. The datapath follows the classic 5-stage RISC-V flow, collapsed into one cycle:

( Proper Detailed Diagram will be uploaded soon )

```
        ┌─────────────────────────────────────────────────────────────────┐
        │                                                                 │
  ┌─────▼──────┐   ┌──────────────┐   ┌──────────┐   ┌───────────────┐  │
  │     PC     ├──►│  Inst. Mem   ├──►│ Control  │   │   Reg File    │  │
  └─────┬──────┘   └──────┬───────┘   │  Unit    │   │  (32 x 32b)  │  │
        │                 │           └────┬─────┘   └───────┬───────┘  │
        │  PC+4           │ instruction    │ control signals  │ RD1/RD2  │
        │  ┌──────────┐   │           ┌───▼──────┐  ┌───────▼──────┐   │
        └─►│  PC Inc  │   └──────────►│  ImmGen  │  │     MUXes    │   │
           └──────────┘               └───┬──────┘  └───────┬──────┘   │
                                          │ ImmExt           │          │
                                     ┌────▼──────────────────▼──────┐   │
                                     │            ALU               │   │
                                     │  (ADD/SUB/AND/OR, zero flag) │   │
                                     └────┬─────────────────────────┘   │
                                          │ ALU_out                      │
                                     ┌────▼──────┐                       │
                                     │ Data Mem  │                       │
                                     └────┬──────┘                       │
                                          │                              │
                                     ┌────▼──────┐                       │
                                     │ Write-Back├───────────────────────┘
                                     │   MUX     │  (back to Reg File)
                                     └───────────┘
```

**PC Selection Logic** handles three cases:
- **Normal**: PC ← PC + 4
- **Branch taken** (BEQ): PC ← PC + Imm (via Branch Adder + gate logic)
- **JAL**: PC ← ALU result (PC + Imm)
- **JALR**: PC ← rs1 + Imm (ALU result, overrides JAL mux)

---

## Module Breakdown

| Module | File | Description |
|---|---|---|
| `top` | `top.v` | Instantiates and connects all modules |
| `program_counter` | `program_counter.v` | Holds current PC, updates on clock edge |
| `PC_inc` | `PC_inc.v` | Computes PC + 4 |
| `instruction_mem` | `instruction_mem.v` | 64-word ROM, loaded from `.hex` file |
| `control_unit` | `control_unit.v` | Decodes opcode → all control signals |
| `ImmGen` | `ImmGen.v` | Sign-extends immediates for all instruction types |
| `reg_file` | `reg_file.v` | 32 registers; x0 hardwired to 0 |
| `ALU_control` | `ALU_control.v` | Decodes ALUOp + funct3/funct7 → ALU op |
| `ALU_unit` | `ALU_unit.v` | Executes ADD, SUB, AND, OR; sets zero flag |
| `branch_adder` | `branch_adder.v` | Computes branch target = PC + Imm |
| `gatelogic` | `gatelogic.v` | `and_out = Branch & zero` for BEQ |
| `data_mem` | `data_mem.v` | 64-word synchronous write, async read RAM |
| `mux` | `mux.v` | Reusable 2-to-1 32-bit multiplexer |

---

## Supported Instructions

| Type | Instructions | Description |
|---|---|---|
| **R-type** | `ADD`, `SUB`, `AND`, `OR` | Register-register arithmetic & logic |
| **I-type** | `ADDI` | Immediate arithmetic |
| **Load** | `LW` | Load word from data memory |
| **Store** | `SW` | Store word to data memory |
| **Branch** | `BEQ` | Branch if equal (zero flag) |
| **U-type** | `LUI`, `AUIPC` | Load upper immediate / PC-relative upper |
| **Jump** | `JAL`, `JALR` | Jump and link (J-type and I-type) |

> **Note:** This implements a practical RV32I subset. Instructions like `SLTI`, `XOR`, `SRL`, `SRA`, and system calls (`ECALL`) are not yet implemented but can be added by extending the ALU control and control unit.

---

## Getting Started

### Prerequisites

Install the required tools on Ubuntu/Linux:

```bash
# Icarus Verilog simulator and GTKWave waveform viewer
sudo apt install iverilog gtkwave

# RISC-V GNU cross-compiler toolchain
sudo apt install gcc-riscv64-unknown-elf
```

---

## Step 1 — Compile C Code to Hex

Navigate into the `sw/` directory and run the following three commands in order. This converts your C program into a `.hex` file that the CPU's instruction memory can load.

```bash
cd sw/
```

**1. Compile C to ELF:**

```bash
riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -T link.ld code.c -o code.elf
```

| Flag | Purpose |
|---|---|
| `-march=rv32i` | Target the 32-bit base integer RISC-V ISA |
| `-mabi=ilp32` | Use the 32-bit integer calling convention |
| `-nostdlib` | No standard C library (bare-metal, no OS) |
| `-T link.ld` | Use the custom linker script to control memory layout |

**2. Extract raw binary from ELF:**

```bash
riscv64-unknown-elf-objcopy -O binary code.elf code.bin
```

This strips ELF headers and debug info, leaving only the raw machine code bytes.

**3. Convert binary to hex:**

```bash
hexdump -v -e '1/4 "%08x" "\n"' code.bin > c_fixed.hex
```

This formats the binary as one 32-bit word per line in hexadecimal — exactly the format `$readmemh` expects in the Verilog testbench.

---

## Step 2 — Run the Hardware Simulation

Navigate into the `rtl/` directory.

```bash
cd ../rtl/
```

**1. Compile the Verilog:**

```bash
iverilog -o top_tb.vvp top_tb.v
```

This compiles all Verilog files (pulled in via `` `include `` directives in `top_tb.v`) into a simulation binary.

**2. Run the simulation:**

```bash
vvp top_tb.vvp
```

You will see the CPU execution log in the terminal, showing register updates as the program runs:

```
>>> CPU EVENT: Register a0 (x10) updated to: 10 (Hex: 0000000a) at time 945000
>>> CPU EVENT: Register a0 (x10) updated to: 10 (Hex: 0000000a) at time 1105000
...
Simulation finished at time         5020000
```

The simulation runs for 1000 ns (configurable in `top_tb.v`) then exits cleanly via `$finish`.

---

## Step 3 — Analyze Waveforms with GTKWave

The simulation automatically dumps all internal signals to `top_tb.vcd`. Open it with GTKWave to inspect every wire, register, and clock cycle visually.

```bash
gtkwave top_tb.vcd
```

**Inside GTKWave:**

1. In the left panel, expand `top_tb` → `DUT`
2. Click and drag signals into the waveform view. Useful signals to add:

| Signal | What it shows |
|---|---|
| `clk` | Clock signal |
| `PC_top` | Program counter value each cycle |
| `instruction_top` | Raw 32-bit instruction being executed |
| `ALU_out_top` | ALU result |
| `RD1_top`, `RD2_top` | Register file read values |
| `data_mem_read_out_top` | Value read from data memory |
| `zero_top` | ALU zero flag (used for BEQ) |
| `Branch_top` | Branch control signal |

3. Use **Ctrl+Scroll** to zoom in/out on the timeline.

---

## How the C-to-CPU Pipeline Works

Here is the full journey from C source code to hardware execution:

```
  code.c
    │
    │  riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -T link.ld
    ▼
  code.elf   (ELF binary with RISC-V RV32I machine code)
    │
    │  riscv64-unknown-elf-objcopy -O binary
    ▼
  code.bin   (raw machine code bytes, no headers)
    │
    │  hexdump -v -e '1/4 "%08x" "\n"'
    ▼
  c_fixed.hex  (one 32-bit instruction per line, hex format)
    │
    │  $readmemh("../sw/c_fixed.hex", inst_mem.mem)   ← Verilog testbench
    ▼
  instruction_mem   (64 x 32-bit ROM inside the CPU)
    │
    │  CPU fetches, decodes, and executes each instruction
    ▼
  Simulation output + top_tb.vcd waveform
```

The linker script `link.ld` is critical — it tells the compiler to place code starting at address `0x00000000`, which is where the CPU's instruction memory begins (PC resets to 0 on startup).

---

## Notes

- The instruction memory holds **64 words (256 bytes)**. Programs larger than this will need the memory size increased in `instruction_mem.v` and `top_tb.v`.
- The data memory similarly holds **64 words**. Adjust `data_mem.v` for larger data sets.
- This is a **single-cycle** design — there is no pipelining, so there are no hazards to handle. Each instruction takes exactly one clock cycle regardless of type.
- The `top_tb.vcd` and `top_tb.vvp` files are generated artifacts and do not need to be committed to the repository.
