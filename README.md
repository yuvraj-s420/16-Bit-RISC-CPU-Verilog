# 16-bit RISC CPU Verilog

A multi-phase project to design and implement a **16-bit RISC CPU** in Verilog with a custom instruction set architecture (ISA).

Future extensions include:
- Python assembler
- UART support for FPGA-based live instruction loading
- Pipelining
- GPU-like arithmetic co-processor for matrix/AI operations

---

## 1. General Architecture and Design 

### 1.1 Architecture Overview

| Feature | Description | Details |
| :--- | :--- | :--- |
| **Architecture Type** | **Harvard Architecture** | Separate instruction memory (ROM) and data memory (RAM), allowing for simultaneous fetching of instructions and loading/storing of data. |
| **Word Size** | 16 bits | All data, registers, and memory locations are 16 bits wide. |
| **Instruction Set** | MIPS-like RISC | Supports **R-type** (Register), **I-type** (Immediate), and **J-type** (Jump) instructions. |
| **Pipelining** | **Single-Cycle** | Currently implemented as a single-cycle design, with future potential for pipelining. |

### 1.2 Number System & Arithmetic

* **Signed Numbers:** All signed numbers (including in registers and immediate values) are encoded using **2's Complement**.
* **ALU Operations:** The use of 2's complement simplifies the Arithmetic Logic Unit (ALU) design, as addition logic works for both signed and unsigned numbers.
* **Subtraction:** Subtraction is performed by adding the **2's complement** of the subtrahend (B input) to the minuend (A input). This involves inverting the B input and setting the carry-in to the LSB to 1.
* **Overflow Detection:** Overflow in signed arithmetic is detected by checking if the carry-in to the Most Significant Bit (MSB, or sign bit) is different from the final carry-out.

---

## 2. Instruction Set Architecture (ISA) 

### 2.1 Instruction Encoding

The 16-bit instruction format is partitioned as follows:

| Field | Bits | Purpose | Notes |
| :--- | :--- | :--- | :--- |
| **OPCODE (OP)** | 4 | Specifies the operation. | Supports $2^4 = 16$ possible commands. |
| **Register Addresses** | 3 each | Used for source and destination registers (Rd, Rs1, Rs2). | Supports $2^3 = 8$ general-purpose registers. |
| **Immediate/Address** | Varies | Data or address offset, 6-bit or 9-bit. | Used in I-type and J-type instructions. |

### 2.2 Register Files and Control

* **Registers:** The CPU uses 8 **general-purpose** 16-bit registers.
* **Control Unit Registers:**
    * **PC (Program Counter):** A 16-bit register holding the address of the **next** instruction.
    * **IR (Instruction Register):** A 16-bit register holding the **current** instruction being executed.

### 2.3 Instruction Format Variations

### R-Type (Standard ALU)
```
[ OP | Rd | Rs1 | Rs2 | unused ]
```

### R-Type (NOT, LSL, LSR)
```
[ OP | Rd | Rs1 | shift_amount ]
```

### I-Type
```
[ OP | Rd | Rs1 | immediate ]
```

### J-Type (JUMP)
```
[ OP | unused | 9-bit address ]
```

### J-Type (BEQ)
```
[ OP | Rs2 | Rs1 | 6-bit signed offset ]
```

### 2.4 Complete Instruction Table

| Opcode | Instruction | Format | Description |
| :--- | :--- | :--- | :--- |
| **0000** | **HALT** | N/A | Stop CPU execution. |
| **0001** | **ADD** | R-Type | $R_d = R_{s1} + R_{s2}$ |
| **0010** | **ADDI** | I-Type | $R_d = R_{s1} + \text{imm}$ |
| **0011** | **SUB** | R-Type | $R_d = R_{s1} - R_{s2}$ |
| **0100** | **SUBI** | I-Type | $R_d = R_{s1} - \text{imm}$ |
| **0101** | **AND** | R-Type | $R_d = R_{s1} \land R_{s2}$ |
| **0110** | **OR** | R-Type | $R_d = R_{s1} \lor R_{s2}$ |
| **0111** | **NOT** | R-Type | $R_d =  \\sim R_{s1}$ |
| **1000** | **LSL** | R-Type | $R_d = R_d \ll \text{imm}$ |
| **1001** | **LSR** | R-Type | $R_d = R_d \gg \text{imm}$ |
| **1010** | **LOAD** | I-Type | $R_d = \text{Mem[address]}$ |
| **1011** | **LOADI** | I-Type | $R_d = \text{immediate}$ |
| **1100** | **STORE** | I-Type | $\text{Mem[address]} = R_d$ |
| **1101** | **JUMP** | J-Type | $\text{PC} = \text{address}$ |
| **1110** | **BEQ** | J-Type | $\text{if } R_{s1} == R_{s2}, \text{ PC} += \text{offset}$ |

---

## 3. Memory Subsystem 

### 3.1 Memory Capacity and Addressing

The ISA's use of a 9-bit address/immediate field for memory access dictates the memory capacity.

* **Addressable Locations:** $2^9 = 512$ locations.
* **Word Size:** 16 bits.
* **RAM Data Memory:** 512 words, totaling $512 \times 2 = 1024$ bytes (1 KiB).
* **Instruction Memory (ROM):** 512 instructions.
* **Value Range:** A 16-bit signed word in RAM can store values from **-32,768 to +32,767**.
* **Addressing:** The system is **word-addressable**.

### 3.2 Memory Mapping

Since the CPU is Harvard architecture, instruction and data are on separate buses.

* I-type instructions (LOAD, STORE) with an immediate address always target **Data Memory (RAM)**.
* The **JUMP** instruction is the **only exception**, where its immediate value is interpreted as a **Program Counter (PC) address** targeting **Instruction Memory**.
* The memory space allows for future **Memory-Mapped I/O (MMIO)** for peripherals.

---

## 4. Control Unit and Data Path 

### 4.1 Control Signals

The **Control Unit** decodes the Instruction Register (IR) and generates the necessary control signals to manage the CPU's datapath components (Register File, ALU, Memory, and PC).

| Signal (MIPS Equivalent) | Description | Values / Use Case |
| :--- | :--- | :--- |
| **reg\_w (RegWrite)** | Enables writing the data back into the **Register File**. | Used by: ADD, ADDI, SUB, SUBI, AND, OR, NOT, LSL, LSR, LOAD, LOADI. |
| **reg\_w\_from (MemToReg)** | Selects the **source** of data to be written into the destination register ($R_d$). | **00**: Write from ALU output. **01**: Write from RAM data\_out (for LOAD). **10**: Write the immediate value (for LOADI). **11**: Unused (future extension). |
| **mem\_r (MemRead)** | Enables reading data from **RAM** (Data Memory). | Set for **LOAD** instruction. |
| **mem\_w (MemWrite)** | Enables writing data to **RAM** (Data Memory). | Set for **STORE** instruction. |
| **alu\_src (ALUSrc)** | Selects the source for the **ALU's 'B' input**. | **0**: Register $R_{s2}$. **1**: Immediate value (used by ADDI, SUBI, LSL, LSR). |
| **reg\_src** | Selects which bit field is used to address the **second Register Data Bus** (for $R_{s2}$ read). | **0**: Bits [5:3] (Standard for most instructions, including $R_d$). **1**: Bits [11:9] (Used specifically by **BEQ** to select $R_{s2}$, since it takes the place of $R_d$ in the instruction format). |
| **Imm\_src** | Selects the required **bit slice** for the immediate value. | **0**: 6 bits [5:0] (Used for ADDI, SUBI, BEQ offset). **1**: 9 bits [8:0] (Used for LOAD, LOADI, STORE, JUMP address). |
| **PC\_src (PCSrc)** | Selects the **next value** for the Program Counter (PC). | **00**: PC + 1 (Normal sequential fetch). **01**: Direct jump address from immediate value (JUMP). **10**: PC + sign-extended offset (BEQ). |

### 4.2 Immediate Value Extension

Immediate values (6-bit for ADDI, SUBI, BEQ; 9-bit for JUMP, LOAD, STORE, LOADI) must be extended to the 16-bit word length.

* **Sign Extension:** Used for **signed** immediates (**ADDI, SUBI, LOADI, BEQ**) to preserve the negative/positive value when performing arithmetic. The MSB (sign bit) is propagated to fill the higher bits.
* **Zero Extension:** Unsigned values (like JUMP/LOAD/STORE addresses) are conceptually zero-extended, but since the immediate fields are used for memory addresses within the 512-word limit, the highest bits of the 16-bit address are always zero, making a dedicated zero-extension circuit redundant for this design.

### 4.3 ALU Operations

The 3-bit **ALU\_OPCODE** signal selects the operation performed by the ALU:

| alu\_OP2| alu\_OP1 | alu\_OP0 | Description |
| :--- | :--- | :--- | :--- |
| **0** | **0** | **0** | unused |
| **0** | **0** | **1** | $\text{ADD}$ |
| **0** | **1** | **0** | $\text{SUB}$ |
| **0** | **1** | **1** | $\text{NOT}$ |
| **1** | **0** | **0** | $\text{AND}$ |
| **1** | **0** | **1** | $\text{OR}$ |
| **1** | **1** | **0** | $\text{LSL (Logical Shift Left)}$ |
| **1** | **1** | **1** | $\text{LSR (Logical Shift Right)}$ |

### 4.4 Program Counter (PC) Logic

The Program Counter (PC) manages instruction sequencing by holding the address of the next instruction in memory.

* **Addressing:** Since the instruction memory is **word-addressable** (not byte-addressable), each address points to a full 16-bit instruction word.
* **Normal Operation:** Under sequential execution, the PC is incremented by **1** each clock cycle ($PC = PC + 1$), resulting in the CPU fetching instructions sequentially.
* **Control Flow:** Branch and Jump instructions modify the PC's value, requiring it to select from three possible sources, as dictated by the 2-bit **`PC_src`** control signal:
    1.  **PC + 1** (Sequential Fetch)
    2.  **Immediate Value** (Direct jump target for **JUMP**)
    3.  **PC + Offset** (Conditional jump for **BEQ**)
* **Hardware Implementation:** The PC's next value is selected by a **Multiplexer (MUX)**. This logic utilizes **two ripple adders**: 
    1.  One adder calculates the simple increment ($PC + 1$).
    2.  The second adder calculates the branch target address ($PC + \text{offset}$), which adds the incremented PC value to the sign-extended offset derived from the current instruction's immediate field.
