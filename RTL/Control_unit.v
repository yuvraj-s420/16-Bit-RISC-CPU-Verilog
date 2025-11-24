module Control_unit(
    input clk,
    reg [15:0] instruction,

    // Control signals
    output reg reg_w,
    output reg mem_r,
    output reg mem_w,
    output reg [2:0] alu_OP,
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

assign OPCODE = instruction[15:12];     // CPU OPCODE to be extracted 

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

    case (OPCODE)
        4'b0000: begin // HALT (Stop execution)
        end
        4'b0001: begin // ADD (R-type: Rd = Rs1 + Rs2)
            alu_OP = 3'b001;
        end
        4'b0010: begin // ADDI (I-type: Rd = Rs1 + imm)
            alu_OP = 3'b001;
        end
        4'b0011: begin // SUB (R-type: Rd = Rs1 - Rs2)
            alu_OP = 3'b010;
        end
        
        4'b0100: begin // SUBI (I-type: Rd = Rs1 - imm)
            alu_OP = 3'b010;
        end
        4'b0101: begin // AND (R-type: Rd = Rs1 & Rs2)
            alu_OP = 3'b100;
        end
        4'b0110: begin // OR (R-type: Rd = Rs1 | Rs2)
            alu_OP = 3'b101;
        end
        4'b0111: begin // NOT (R-type: Rd = ~Rs1)
            alu_OP = 3'b011;
        end
        
        4'b1000: begin // LSL (I-type: Rd = Rd << imm)
            alu_OP = 3'b110;
        end
        4'b1001: begin // LSR (I-type: Rd = Rd >> imm)
            alu_OP = 3'b111;
        end
        4'b1010: begin // LOAD (I-type: Rd = Mem[address], implied Rs1 + imm)
        
        end
        4'b1011: begin // LOADI (I-type: Rd = immediate)

        end
        
        4'b1100: begin // STORE (I-type: Mem[address] = Rd, implied Rs1 + imm)

        end
        4'b1101: begin // JUMP (J-type: PC = address)

        end
        4'b1110: begin // BEQ (I-type: if Rs1 == Rs2, PC += offset)
            alu_OP = 3'b010;    // Subtract to determine zero_flag
        end
        4'b1111: begin // RESERVED or NOP

        end
        
        default: begin
            // Default case ensures all control signals are explicitly handled
            // Set to NOP or HALT to ensure safe operation
        end
    endcase

end


    
endmodule
