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
    
endmodule