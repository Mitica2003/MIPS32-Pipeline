# MIPS32 Pipeline Processor

## Overview
This project implements a **MIPS32 Pipeline Processor** in VHDL. The processor follows a **5-stage pipeline architecture**, dividing instruction execution into the following stages:

1. **Instruction Fetch (IF)** - Fetches the instruction from memory.
2. **Instruction Decode (ID)** - Decodes the instruction and reads registers.
3. **Execute (EX)** - Performs ALU operations and computes branch targets.
4. **Memory Access (MEM)** - Reads/writes data from/to memory.
5. **Write Back (WB)** - Writes results back to registers.

## Components
The design is modular, with separate VHDL components for each stage and control unit:

- **Instruction Fetch (iFetch)**: Fetches the instruction and calculates the next PC.
- **Instruction Decode (ID)**: Decodes instructions and reads register values.
- **Control Unit (UC)**: Generates control signals based on the instruction opcode.
- **Execution Unit (EX)**: Performs ALU operations and determines branch/jump execution.
- **Memory Unit (MEM)**: Handles data memory access.
- **Write Back Unit (WB)**: Selects and writes data back to registers.
- **Seven-Segment Display (SSD)**: Displays results on a 7-segment display.
- **Mono Pulse Generator (MPG)**: Debounces button presses.

## Pipeline Registers
The processor uses **pipeline registers** to store intermediate results between stages:

- **IF/ID**: Holds fetched instruction and PC value.
- **ID/EX**: Stores register values, immediate values, and control signals.
- **EX/MEM**: Stores ALU results, branch address, and control signals.
- **MEM/WB**: Holds memory read data and ALU results before write back.

## Features
- **Instruction Pipelining** to improve instruction throughput.
- **Branch Handling**: Supports conditional branching (BEQ, BNE, BGTZ).
- **Data Memory Access**: Reads/writes to data memory.
- **Register Write Back**: Writes ALU or memory results to registers.

## Control Signals
The processor's control unit generates the following control signals:

- `RegDst`: Selects destination register.
- `ALUSrc`: Chooses ALU input source.
- `MemtoReg`: Selects write-back data source.
- `RegWrite`: Enables register write.
- `MemWrite`: Enables memory write.
- `Branch`, `Br_ne`, `Br_gtz`: Controls branching.
- `Jump`: Enables jump execution.
- `ALUOp`: Defines ALU operation type.

## Display & Debugging
- The **7-segment display (SSD)** is used to display values from various pipeline stages.
- **LED indicators** display control signals for debugging.
- **Switches (sw[7:5])** allow selecting which pipeline register value is displayed.

## Future Improvements
- Implement **hazard detection** and **forwarding** for better performance.
- Extend instruction support (e.g., floating-point operations).
- Implement a more advanced memory hierarchy.
