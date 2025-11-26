module Instruction_file (

    input clk,
    input [8:0] addr,           // Address of instruction (from PC)
    output [15:0] instruction   // output instruction
);
    
reg [15:0] instruction_mem [511:0];  // 512 lines of 16 bit instructions

always @(posedge clk) begin
    instruction = instruction_mem[addr];
end

endmodule