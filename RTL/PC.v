module PC (
    input clk,                          // Clock
    input [8:0] instr_curr_addr,        // Current address
    input [8:0] imm,                    // Immediate to be used by JUMP/ BEQ (already sign extended)
    input [1:0] pc_src,                 // Control signal to select instr_next
    input zero_f                        // Zero flag to enable BEQ
    output reg [8:0] instr_next_addr    // Next address
);

// Synchronous updating
always @(posedge clk) begin
    
    case (pc_src)

        2'b00: begin            // Normal increment
            instr_next_addr <= instr_curr_addr + 9'b000000001;
        end

        2'b01: begin            // JUMP to immediate
            instr_next_addr <= imm;
        end

        2'b10: begin            // BEQ with signed offset
            if (zero_f) begin
                instr_next_addr <= instr_curr_addr + imm;
            end else begin
                instr_next_addr <= instr_curr_addr + 9'b000000001;
            end
        end

        2'b11: begin            // HALT by stopping increment
            instr_next_addr <= instr_curr_addr;
        end

    endcase

end
    
endmodule