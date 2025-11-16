# 16-Bit-RISC-CPU-Verilog

A multi-phase project to design and implement a **16-bit RISC CPU** in Verilog with a custom instruction set architecture (ISA).

Future extensions include:
- Python assembler
- UART support for FPGA-based live instruction loading
- GPU-like arithmetic co-processor for matrix/AI operations


---

## Architecture Overview

### Design Goals
- 16-bit **RISC-style** CPU
- Custom ISA based on **MIPS**
- **Harvard architecture**
  - Separate instruction and data memory
  - Independent busses for parallel fetch + data access
- Single-cycle CPU (pipelining planned for additions)

### Registers
- 8 general-purpose registers (`R0–R7`)
- 3-bit register addresses
- Internal registers:
  - **PC** — Program Counter (16-bit)
  - **IR** — Instruction Register (16-bit)

---

## Instruction Formats

### R-Type (Register Instructions)

#### ALU: `ADD`, `SUB`, `AND`, `OR`, `XOR`
```
[4-bit OP] [3-bit Rd] [3-bit Rs1] [6-bit unused/Rs2]
```

#### Unary / Shifts: `NOT`, `LSL`, `LSR`
```
[4-bit OP] [3-bit Rd] [9-bit immediate/shift amount]
```

---

### I-Type (Immediate / Memory Instructions)

#### LOAD — load RAM into register
```
[4-bit OP] [3-bit Rd] [9-bit RAM address]
```

#### STORE — store register into RAM
```
[4-bit OP] [3-bit Rs] [9-bit RAM address]
```

#### LOADI — load immediate into register
```
[4-bit OP] [3-bit Rd] [9-bit immediate]
```

---

### J-Type (Jump / Branch Instructions)

#### JUMP — unconditional
```
[4-bit OP] [12-bit instruction address]
```

#### BEQ — branch if Rs1 == Rs2
```
[4-bit OP] [3-bit Rs1] [3-bit Rs2] [6-bit signed offset]
```
Offset range: **−32 to +31**.

---

### HALT
```
[4-bit OP = 1111] [12-bit unused]
```

---

## Instruction Opcode Table

| Opcode | Instruction | Description |
|--------|-------------|-------------|
| 0000 | ADD | Rd = Rd + Rs |
| 0001 | SUB | Rd = Rd - Rs |
| 0010 | AND | Rd = Rd & Rs |
| 0011 | OR | Rd = Rd \| Rs |
| 0100 | XOR | Rd = Rd ^ Rs |
| 0101 | NOT | Rd = ~Rd |
| 0110 | LSL | Rd = Rd << imm |
| 0111 | LSR | Rd = Rd >> imm |
| 1000 | LOAD | Rd = Mem[address] |
| 1001 | STORE | Mem[address] = Rd |
| 1010 | LOADI | Rd = immediate |
| 1011 | JUMP | PC = address |
| 1100 | BEQ | if Rs1 == Rs2, PC += offset |
| 1101 | - | - |
| 1110 | - | - |
| 1111 | HALT | Stop execution |

---

## Memory Architecture

Because the LOAD, STORE, and JUMP instructions in our ISA use a 9-bit immediate field, the CPU can directly address 2⁹ = 512 memory locations. Each location stores a 16-bit WORD, so the instruction memory can hold 512 instructions, and the RAM provides 512 words = 1024 bytes = 1 KiB of addressable data. This is more than sufficient for the scope of this project and also leaves room for Memory-Mapped I/O (MMIO) to interface with peripherals or external co-processors.

Since the CPU uses a Harvard architecture, instruction memory and data memory are on separate busses. Therefore, any I-type instruction that uses an immediate value as an address will always refer to data memory (RAM), not instruction memory. The single exception is the JUMP instruction, whose immediate value is interpreted as a program counter address and therefore targets instruction memory instead.



---
