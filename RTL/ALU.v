module ALU(

    input [2:0] alu_OP,          // ALU OPCODE
    input [15:0] in1,           // Input 1 (Always a register's data)
    input [15:0] in2,           // Input 2 (Another register or an immediate value)
    output reg [15:0] out,      // ALU output
    
    // Flags
    output reg overflow_f,      
    output reg zero_f
);

reg [16:0] temp_sum;                    // 17 bit width additions carried out to determine C_in and C_out for MSB for overflow detection
wire [3:0] shift_ammount = in2[3:0];    // Use last 4 bits of in2 to determine number of shifts (max 15)

// Asynchronous updating
always @* begin
    
    /* Executes instruction based on the ALU's input OPCODE. This opcode is different from the opcode 
    in the original instruction, and is determined by the control unit once the instruction is fetched */
    case (alu_OP)
        3'b001: begin                                               // ADD
            temp_sum = {1'b0, in1} + {1'b0, in2};
            overflow_f = temp_sum[16] ^ temp_sum[15];
            out = temp_sum[15:0];
        end             
        3'b010: begin                                               // SUB
            temp_sum = {1'b0, in1} + {1'b0, ~in2} + 1'b1;
            overflow_f = temp_sum[16] ^ temp_sum[15];
            out = temp_sum[15:0];
        end
        3'b011: out = ~in1;                                         // NOT
        3'b100: out = in1 && in2;                                   // AND
        3'b101: out = in1 | in2;                                    // OR

        // Multiple shifting operations within a single cycle
        // Compiler will infer the use of a barrel shifter
        3'b110: out = in1 << shift_ammount;                         // LSL  
        3'b111: out = in1 >> shift_ammount;                         // LSR
        
        // Default assignments
        default: begin
            out = 16'h0000;
            overflow_f = 1'b0;
        end

    endcase

    // Set zero flag
    if (out == 16'h0000) begin
        zero_f = 1'b1;
    end else begin
        zero_f = 1'b0;
    end

end

endmodule
