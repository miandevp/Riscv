
# RISC-V 5-Stage Pipeline Processor

Implementation of a 32-bit **RISC-V (RV32I)** pipelined processor in Verilog.

This project was developed as part of the Computer Architecture course. It implements the base RV32I instruction set using a classic **5-stage pipeline** with forwarding, stalling, and hazard detection.

---

## Features

- 32-bit RV32I ISA
- Five-stage pipeline
  - Instruction Fetch (IF)
  - Instruction Decode (ID)
  - Execute (EX)
  - Memory Access (MEM)
  - Write Back (WB)
- Register File
- Instruction Memory
- Data Memory
- Immediate Generator
- ALU Control Unit
- Hazard Detection Unit
- Data Forwarding
- Pipeline Flush for branches and jumps

---

## Pipeline Architecture

```
          +---------+
          |   IF    |
          +---------+
                |
                v
          +---------+
          |   ID    |
          +---------+
                |
                v
          +---------+
          |   EX    |
          +---------+
                |
                v
          +---------+
          |  MEM    |
          +---------+
                |
                v
          +---------+
          |   WB    |
          +---------+
```

---

## Project Structure

```
design/
│
├── alu.v                 // Arithmetic Logic Unit
├── aludec.v              // ALU Decoder
├── controller.v          // Main Control Unit
├── dmem.v                // Data Memory
├── hazard_unit.v         // Hazard Detection & Forwarding
├── imem.v                // Instruction Memory
├── immext.v              // Immediate Generator
├── instrdec.v            // Immediate Type Decoder
├── regfile.v             // Register File
└── riscv_pipeline.v      // Top-Level Pipeline

simulation/
│
├── *.asm                 // Assembly programs
├── *.mem                 // Machine code programs
└── tb_*.v                // Testbenches
```

---

## Implemented Instructions

### Load

- lw

### Store

- sw

### R-Type

- add
- sub
- sll
- slt
- xor
- srl
- sra
- or
- and

### I-Type

- addi
- slli
- slti
- xori
- srli
- srai
- ori
- andi

### Upper Immediate

- lui

### Branch

- beq
- bne
- blt
- bge

### Jump

- jal
- jalr

---

## Pending Instructions

The following RV32I instructions are planned for future implementation:

- lb
- lh
- lbu
- lhu
- sb
- sh
- sltu
- sltiu
- bltu
- bgeu
- auipc

---

## Verification

The processor has been validated using several simulation programs:

- Instruction execution
- Data forwarding
- Hazard detection
- Pipeline stalling
- Pipeline flushing

Each functionality includes its corresponding Verilog testbench.

---

## Tools

- Verilog HDL
- Xilinx Vivado
- RISC-V RV32I ISA

---

## Author

Michael Antonio
Computer Architecture Project