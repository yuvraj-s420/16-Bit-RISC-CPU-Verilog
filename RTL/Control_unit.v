module Control_unit(
    input clk,
    reg [15:0] instruction,
    
);


opcode = instruction[15:12];        // CPU OPCODE to be extracted 
Rd = instruction[11:9];             // Destination register
Rs1 = instruction[8:6];             // 1st source register
Rs2 = instruction[5:3]              // 2nd source register
immediate1 = instruction[5:0];       // Immediates for instructions that use Rd, Rs1, but no Rs2
                                    // EX: ADDI, SUBI, LSL, LSR, LOADI
immediate2 = instruction[8:0];
immediate3 = instruction[8:0];
    
endmodule
