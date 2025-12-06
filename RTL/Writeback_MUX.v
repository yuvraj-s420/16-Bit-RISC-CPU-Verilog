module Writeback_MUX (
    
    // MUX inputs
    input [15:0] alu_out,           
    input [8:0] imm,
    input [15:0] ram_out,

    // Select
    input [1:0] reg_w_from,

    // Output data to be sent to Register_file
    output reg [15:0] out
);
    
// Asynchronous updating
always @* begin
    case (reg_w_from)                   // Select which data line to send to Register_file

        2'b00: out = alu_out;           // ADD, ADDI, SUB, SUBI, AND, OR, NOT, LSL, LSR
        2'b01: out = ram_out;           // LOAD
        2'b10: begin                    // LOADI
            out = {{7{imm[8]}}, imm};     // Sign extend immediate to 16 bits 
        end
        default: out = 16'h0000;         // 2'b11 Unused, set out to 0 for safety
        
    endcase
end

endmodule