# ARMv8 Single-Cycle Processor

A 64-bit single-cycle processor written in Verilog. It implements a subset of the ARMv8 (LEGv8) instruction set and comes with a testbench that runs two test programs and checks their results.

## Supported instructions

| Type | Instructions |
|------|--------------|
| Arithmetic and logic (register) | `ADD`, `SUB`, `AND`, `ORR` |
| Arithmetic (immediate) | `ADDI`, `SUBI` |
| Wide immediate | `MOVZ` (with `LSL` #0, #16, #32 or #48) |
| Memory | `LDUR`, `STUR` |
| Branch | `B`, `CBZ` |

## Files

| File | Module | Description |
|------|--------|-------------|
| `SingleCycleProc.v` | `singlecycle` | Top-level datapath. Connects all of the modules below and holds the PC register, which updates on the falling clock edge. |
| `SingleCycleControl.v` | `control` | Main control unit. Decodes the 11-bit opcode into the datapath control signals (`reg2loc`, `alusrc`, `mem2reg`, `regwrite`, `memread`, `memwrite`, `branch`, `uncond_branch`) plus the ALU operation and the sign-extend mode. |
| `InstructionMemory.v` | `InstructionMemory` | Read-only instruction memory. It holds the machine code for both test programs. |
| `DataMemory.v` | `DataMemory` | 1 KB byte-addressable, big-endian data memory with 64-bit reads and writes. It is preloaded with the constants that test program 1 uses. |
| `RegisterFile.v` | `RegisterFile` | 32 × 64-bit registers with two read ports and one write port. `X31` (XZR) always reads as zero. |
| `ALU.v` | `ALU` | 64-bit ALU supporting AND, OR, ADD, SUB and pass-B. It also outputs a `Zero` flag for `CBZ`. |
| `SignExtender.v` | `SignExtender` | Builds the 64-bit immediate for I, D, B and CB instruction formats, and shifts the 16-bit `MOVZ` immediate into position. |
| `NextPClogic.v` | `NextPClogic` | Computes the next PC: `PC + 4`, or `PC + (imm << 2)` for a taken `CBZ` or a `B`. |
| `SingleCycleProcTest.v` | `SingleCycleProcTest_v` | Testbench. Drives the clock and reset, runs both programs, and checks the results. It also writes a waveform to `singlecycle.vcd`. |

## Control signals

| Instruction | Reg2Loc | ALUSrc | MemtoReg | RegWrite | MemRead | MemWrite | Branch | UncondBranch | ALUOp | SignOp |
|---|---|---|---|---|---|---|---|---|---|---|
| `AND`  | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | `0000` | – |
| `ORR`  | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | `0001` | – |
| `ADD`  | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | `0010` | – |
| `SUB`  | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | `0110` | – |
| `ADDI` | 0 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | `0010` | `000` (I) |
| `SUBI` | 0 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | `0110` | `000` (I) |
| `MOVZ` | – | 1 | 0 | 1 | 0 | 0 | 0 | 0 | `0111` | `100` (MOVZ) |
| `LDUR` | – | 1 | 1 | 1 | 1 | 0 | 0 | 0 | `0010` | `001` (D) |
| `STUR` | 1 | 1 | – | 0 | 0 | 1 | 0 | 0 | `0010` | `001` (D) |
| `CBZ`  | 1 | 0 | – | 0 | 0 | 0 | 1 | 0 | `0111` | `011` (CB) |
| `B`    | – | – | – | 0 | 0 | 0 | – | 1 | – | `010` (B) |

A dash means the signal doesn't matter for that instruction.

## Test programs

**Program 1 (addresses `0x00`–`0x30`)** loads constants from data memory and uses them to exercise `LDUR`, `ORR`, `AND`, `CBZ`, `ADD`, `SUB`, `B` and `STUR`. It builds the mask `0xF`, masks the low bits of a large constant, then counts that value down to zero in a loop. It stores the count and loads it back. **Expected result: `0xF`.**

**Program 2 (addresses `0x34`–`0x58`)** builds the 64-bit constant `0x123456789ABCDEF0` from four `MOVZ` instructions, one per 16-bit chunk. It combines the chunks with `ORR`, stores the value with `STUR` and reads it back with `LDUR`. **Expected result: `0x123456789ABCDEF0`.**

## Running the simulation

You need [Icarus Verilog](https://steveicarus.github.io/iverilog/). [GTKWave](https://gtkwave.sourceforge.net/) is optional, for viewing waveforms.

```sh
iverilog -o singlecycle SingleCycleProcTest.v SingleCycleProc.v SingleCycleControl.v \
    InstructionMemory.v DataMemory.v RegisterFile.v ALU.v SignExtender.v NextPClogic.v
vvp singlecycle
```

Expected output (after the PC trace):

```
Results of Program 1 passed
Results of Program 2 passed
All tests passed
```

To view the waveform:

```sh
gtkwave singlecycle.vcd
```
