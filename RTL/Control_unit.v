module Control_unit(
    input clk,
    reg [15:0] instruction,

    // Control signals
    output reg reg_w,
    output reg mem_r,
    output reg mem_w,
    output reg alu_src,
    output reg reg_src,
    output reg imm_src,
    output reg [1:0] reg_w_from,
    output reg [1:0] pc_src,

    // Register addresses
    output reg [2:0] Rd,
    output reg [2:0] Rs1,
    output reg [2:0] Rs2,
    
    // Immediate
    output reg [8:0] imm
);

assign opcode = instruction[15:12];     // CPU OPCODE to be extracted 

// Default register addresses
assign Rd = instruction[11:9];          // Destination register
assign Rs1 = instruction[8:6];          // 1st source register
assign Rs2 = instruction[5:3];          // 2nd source register

// Internal immediate slices
wire imm6 = instruction[5:0];   // For instructions that use Rd, Rs1, but no Rs2 (EX: ADDI, SUBI, BEQ)            
wire imm9 = instruction[8:0];   // For instructions that use only Rd or JUMP (LOAD, LOADI, STORE, JUMP)

always @* begin
    
    // Deafult control signals
    reg_w = 1'b0;           // Don't write
    mem_r = 1'b0;           // Don't read
    mem_w = 1'b0;           // Dont't write
    alu_src = 1'b0;         // in2 is Rs2
    //reg_src = 1'b0; might not need
    imm_src = 1'b1;         // Use 9 bit slice
    reg_w_from = 2'b00;     // Write from ALU
    pc_src = 2'b00;         // Basic increment (PC = PC + !)

    case (opcode)
        4'b0000: begin // ADD R-type (Rd = Rs1 + Rs2)
            // CONTROL SIGNALS FOR ADD GO HERE
        end
        4'b0001: begin // SUB R-type (Rd = Rs1 - Rs2)
            // CONTROL SIGNALS FOR SUB GO HERE
        end
        4'b0010: begin // AND R-type (Rd = Rs1 & Rs2)
            // CONTROL SIGNALS FOR AND GO HERE
        end
        4'b0011: begin // OR R-type (Rd = Rs1 | Rs2)
            // CONTROL SIGNALS FOR OR GO HERE
        end
        
        4'b0100: begin // NOT R-type (Rd = ~Rs1)
            // CONTROL SIGNALS FOR NOT GO HERE
        end
        4'b0101: begin // LSL I-type (Logical Shift Left: Rd = Rs1 << imm)
            // CONTROL SIGNALS FOR LSL GO HERE
        end
        4'b0110: begin // LSR I-type (Logical Shift Right: Rd = Rs1 >> imm)
            // CONTROL SIGNALS FOR LSR GO HERE
        end
        4'b0111: begin // ADDI I-type (Rd = Rs1 + imm)
            // CONTROL SIGNALS FOR ADDI GO HERE
        end
        
        4'b1000: begin // SUBI I-type (Rd = Rs1 - imm)
            // CONTROL SIGNALS FOR SUBI GO HERE
        end
        4'b1001: begin // LOAD I-type (Rd = Mem[Rs1 + imm])
            // CONTROL SIGNALS FOR LOAD GO HERE
        end
        4'b1010: begin // LOADI I-type (Rd = Mem[imm]) -- Special case, use PC/Zero for Rs1
            // CONTROL SIGNALS FOR LOADI GO HERE
        end
        4'b1011: begin // STORE R-type (Mem[Rs1 + Rs2] = Rd)
            // CONTROL SIGNALS FOR STORE GO HERE
        end
        
        4'b1100: begin // JUMP J-type (PC = Target Address)
            // CONTROL SIGNALS FOR JUMP GO HERE
        end
        4'b1101: begin // BEQ I-type (Branch Equal: If Rs1 == Rs2, PC = PC + offset)
            // CONTROL SIGNALS FOR BEQ GO HERE
        end
        4'b1110: begin // HALT J-type (Stop Clock/PC)
            // CONTROL SIGNALS FOR HALT GO HERE
        end
        4'b1111: begin // RESERVED or NOP
            // CONTROL SIGNALS FOR RESERVED/NOP GO HERE
        end
        
        default: begin
            // Safety measure: Treat unknown opcodes as a HALT or NOP.
            // CONTROL SIGNALS FOR DEFAULT GO HERE (HALT or NOP)
        end
    endcase

end


    
endmodule
