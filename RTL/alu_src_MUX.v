module alu_src_MUX (
    
    input [15:0] Rs2_data,      // 2nd register input
    input [8:0] imm,            // Immediate from control unit
    input alu_src,              // Select signal

    // Output of MUX, second input to ALU
    output reg [15:0] out
);

// Asynchronous updating
always @* begin

    case (alu_src)
        
        1'b0: out = Rs2_data;
        1'b1: out = {7{imm[8]}, imm};    // Sign extend to ensure matching bit size in ALU operations

    endcase

end
    
endmodule