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

end


    
endmodule
