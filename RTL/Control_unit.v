module Control_unit(

    // Fetched from IR
    input [15:0] instruction,

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
    output reg [2:0] Rd_addr,
    output reg [2:0] Rs1_addr,
    output reg [2:0] Rs2_addr,
    
    // Immediate
    output reg [8:0] imm
);

// CPU OPCODE to be extracted 
wire [3:0] OPCODE = instruction[15:12];     

// Internal immediate slices
reg [5:0] imm6;   // For instructions that use Rd, Rs1, but no Rs2 (EX: ADDI, SUBI, BEQ)            
reg [8:0] imm9;   // For instructions that use only Rd or JUMP (LOAD, LOADI, STORE, JUMP)

always @* begin
    
    imm6 = instruction[5:0];
    imm9 = instruction[8:0];
    
    // DEFAULT CONTROL SIGNALS
    reg_w = 1'b0;           // Don't write
    mem_r = 1'b0;           // Don't read
    mem_w = 1'b0;           // Don't write
    alu_src = 1'b0;         // in2 is Rs2
    reg_src = 1'b0;         // Rs2 is bits 5:3
    imm_src = 1'b0;         // Use 6 bit slice
    reg_w_from = 2'b00;     // Write from ALU
    pc_src = 2'b00;         // Basic increment (PC = PC + !)

    // Assign control signals based off OPCODE
    case (OPCODE)
        4'b0000: begin // HALT (Stop execution)
            pc_src = 2'b11;
        end

        4'b0001: begin // ADD (R-type: Rd = Rs1 + Rs2)
            alu_OP = 3'b001;
            reg_w = 1'b1;
            reg_w_from = 2'b00;
        end

        4'b0010: begin // ADDI (I-type: Rd = Rs1 + imm)
            alu_OP = 3'b001;
            reg_w = 1'b1;
            alu_src = 1'b1;
            reg_w_from = 2'b00;
        end

        4'b0011: begin // SUB (R-type: Rd = Rs1 - Rs2)
            alu_OP = 3'b010;
            reg_w = 1'b1;
            reg_w_from = 2'b00;
        end
        
        4'b0100: begin // SUBI (I-type: Rd = Rs1 - imm)
            alu_OP = 3'b010;
            reg_w = 1'b1;
            alu_src = 1'b1;
            reg_w_from = 2'b00;
        end

        4'b0101: begin // AND (R-type: Rd = Rs1 & Rs2)
            alu_OP = 3'b100;
            reg_w = 1'b1;
            reg_w_from = 2'b00;
        end

        4'b0110: begin // OR (R-type: Rd = Rs1 | Rs2)
            alu_OP = 3'b101;
            reg_w = 1'b1;
            reg_w_from = 2'b00;
        end

        4'b0111: begin // NOT (R-type: Rd = ~Rs1)
            alu_OP = 3'b011;
            reg_w = 1'b1;
            reg_w_from = 2'b00;
        end
        
        4'b1000: begin // LSL (I-type: Rd = Rd << imm)
            alu_OP = 3'b110;
            reg_w = 1'b1;
            alu_src = 1'b1;
            reg_w_from = 2'b00;
        end

        4'b1001: begin // LSR (I-type: Rd = Rd >> imm)
            alu_OP = 3'b111;
            reg_w = 1'b1;
            alu_src = 1'b1;
            reg_w_from = 2'b00;
        end

        4'b1010: begin // LOAD (I-type: Rd = Mem[address])
            reg_w = 1'b1;
            mem_r = 1'b1;
            imm_src = 1'b1;
            reg_w_from = 2'b01;
        end

        4'b1011: begin // LOADI (I-type: Rd = immediate)
            reg_w = 1'b1;
            imm_src = 1'b1;
            reg_w_from = 2'b10;
        end
        
        4'b1100: begin // STORE (I-type: Mem[address] = Rd)
            mem_w = 1'b1;
            imm_src = 1'b1;
        end

        4'b1101: begin // JUMP (J-type: PC = address)
            imm_src = 1'b1;
            pc_src = 2'b01;
        end

        4'b1110: begin // BEQ (I-type: if Rs1 == Rs2, PC += offset)
            alu_OP = 3'b010;    // Subtract to determine zero_flag
            reg_src = 1'b1;
            pc_src = 2'b10;
        end

        default: begin      // Defaults assigned before switch statement are used
        end

    endcase

    // Default register addresses
    Rd_addr = instruction[11:9];          // Destination register
    Rs1_addr = instruction[8:6];          // 1st source register

    // MUX to choose 2nd source register's bit slice
    if (reg_src == 1'b0) begin
        Rs2_addr = instruction[5:3]; 
    end else if (reg_src == 1'b1) begin      
        Rs2_addr = instruction[11:9];    // Only done for BEQ
    end

    // MUX to determine which immediate slice to output
    if (imm_src == 1'b0) begin
        imm = {{3{imm6[5]}}, imm6};   // Sign extend (copy MSB to the rest of the bits)
    end else begin
        imm = imm9;
    end

end

endmodule
