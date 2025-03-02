# RISC-V CPU Core (Plastic Project)

## Overview

This repository contains a SystemVerilog implementation of a basic 5-stage pipeline RISC-V processor. The processor includes a register file, ALU, control unit, instruction memory, and data memory. It is designed to run simple assembly programs and includes optimizations for performance such as hazard detection, forwarding, and branch prediction.

## Features

- **5-Stage Pipeline**: Fetch, Decode, Execute, Memory, and Writeback stages.
- **Hazard Detection and Forwarding**: Optimized for performance with hazard detection and forwarding units.
- **Instruction Memory**: Preloaded with a simple assembly program.
- **Data Memory**: Supports load and store operations.
- **Testbench**: Includes a testbench for simulation and verification.

## Files

- `riscv_cpu.sv`: Top-level module that integrates all pipeline stages.
- `fetch_stage.sv`: Fetch stage with instruction memory.
- `decode_stage.sv`: Decode stage with register file and control unit.
- `execute_stage.sv`: Execute stage with ALU.
- `memory_stage.sv`: Memory stage with data memory.
- `writeback_stage.sv`: Writeback stage.
- `hazard_detection.sv`: Hazard detection unit.
- `forwarding_unit.sv`: Forwarding unit.
- `riscv_cpu_tb.sv`: Testbench for simulation and verification.

## Design Architecture

The RISC-V CPU consists of several key components:

1. **Fetch Stage**: Fetches instructions from the instruction memory.
2. **Decode Stage**: Decodes instructions and reads operands from the register file.
3. **Execute Stage**: Executes instructions using the ALU.
4. **Memory Stage**: Handles load and store operations.
5. **Writeback Stage**: Writes the result back to the register file.
6. **Hazard Detection Unit**: Detects and resolves data hazards.
7. **Forwarding Unit**: Implements forwarding to reduce pipeline stalls.
