module CPU_top_level (

    // External ports
    input clk,
    input cpu_rst
);

// ============= Internal wires used to connect ports between modules ============= 

// Instruction
wire [8:0] instruction_addr;
wire [15:0] instruction_data;

// Control signals
wire reg_w_ctrl, mem_r_ctrl, mem_w_ctrl, alu_src_ctrl, reg_src_ctrl, imm_src_ctrl;
wire [1:0] reg_w_from_ctrl, pc_src_ctrl;
wire [2:0] alu_OP_ctrl;

// Register address wires and immediate
wire [2:0] Rd_addr_ctrl, Rs1_addr_ctrl, Rs2_addr_ctrl;
wire [8:0] immediate;

// Register data
wire [15:0] Rs1_data_out, Rs2_data_out, Rd_data_out;

// Ram data
wire [15:0] ram_data_out;

// ALU inputs
wire [15:0] alu_in_1, alu_in_2;

// ALU outputs
wire [15:0] alu_out_data;
wire zero_f_alu, overflow_f_alu;

// Writeback data
wire [15:0] Rd_writeback_data;


// ========================== Module Instantiations ==========================

// Outputs instruction data based on address
Instruction_file if1(
   .clk (clk),
   .addr (instruction_addr),
   .instr_out (instruction_data)
);

// Decodes instructions, generates control signals
Control_unit cu1(
    .instruction (instruction_data),
    .reg_w (reg_w_ctrl),
    .mem_r (mem_r_ctrl),
    .mem_w (mem_w_ctrl),
    .alu_src (alu_src_ctrl),
    .reg_src (reg_src_ctrl),
    .reg_w_from (reg_w_from_ctrl),
    .pc_src (pc_src_ctrl),
    .alu_OP (alu_OP_ctrl),
    .imm_src (imm_src_ctrl),
    .Rd_addr (Rd_addr_ctrl),
    .Rs1_addr (Rs1_addr_ctrl),
    .Rs2_addr (Rs2_addr_ctrl),
    .imm (immediate)
);

// Retrieve data from register addresses and store writeback data upon write enable
Register_file rf1(
    .clk (clk),
    .Rd_addr (Rd_addr_ctrl),
    .Rs1_addr (Rs2_addr_ctrl),
    .Rs2_addr (Rs2_addr_ctrl),
    .reg_w (reg_w_ctrl),
    .writeback_data (Rd_writeback_data),
    .out_1 (Rs1_data_out),
    .out_2 (Rs2_data_out),
    .Rd_out (Rd_data_out)
);

// Addresses or updates RAM
Memory_file mf1(
    .clk (clk),
    .addr (immediate),
    .write_data (Rd_data_out),
    .mem_r (mem_r_ctrl),
    .mem_w (mem_w_ctrl),
    .out (ram_data_out)
);

// MUX to select alu_in_2 from Rs2 data and immediate
alu_src_MUX asm1(
    .Rs2_data (Rs2_data_out),
    .imm (immediate),
    .alu_src (alu_src_ctrl),
    .out (alu_in_2)
);

assign alu_in_1 = Rs1_data_out;     // First input is always Rs1

// ALU generates output and flags
ALU ALU1(
    .alu_OP (alu_OP_ctrl),
    .in1 (alu_in_1),
    .in2 (alu_in_2),
    .out (alu_out_data),
    .overflow_f (overflow_f_alu),
    .zero_f (zero_f_alu)
);

// MUX to select writeback data to Register_file
Writeback_MUX wbm1(
    .alu_out (alu_out_data),
    .imm (immediate),
    .ram_out (ram_data_out),
    .reg_w_from (reg_w_from_ctrl),
    .out (Rd_writeback_data)
);

// Program counter which determines next instruction address 
PC pc1(
    .clk (clk),
    .instr_curr_addr (instruction_addr),
    .imm (immediate),
    .pc_src (pc_src_ctrl),
    .zero_f (zero_f_alu),
    .instr_next_addr (instruction_addr)
);
    
endmodule