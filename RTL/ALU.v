module ALU(
    input clk,
    reg [2:0] alu_OP
    input in1,
    input in2,
    output out,
    output overflow_f,
    output zero_f,
    output sign_f
)

always @ (posedge clk) begin
    
    /* 
    Executes instruction based on the ALU's input OPCODE. This opcode is different from the opcode 
    in the original instruction, and is determined by the control unit once the instruction is fetched
    */
    case (alu_OP)
        3'b000: 
        3'b001: out = in1 + in2;
        3'b010: out = in1 - in2;
        3'b011: out = ~in1;
        3'b100: out = in1 && in2;
        3'b101: out = in1 | in2;

        // For logical shifts, 1 bit shift would be easiest to implement with a shift register
        // For multiple, design at gate level would be more complicated.
        // Multiple cycles? (want to avoid this). Or, a more sophisticated shifting arrangement. (research)
        3'b110: out = in1 << ____;          
        3'b111: out = in1 >> ____;
    endcase

    // Set flags based on the ALU output data
    // Where are these flags going to be used?


end


endmodule
