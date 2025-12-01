module Register_file(

    // Clock signal
    input clk,

    // Addresses
    input [2:0] Rd_addr,
    input [2:0] Rs1_addr,
    input [2:0] Rs2_addr,
    
    // Register write enable
    input reg_w,

    // Data to writeback to register if write enabled
    input [15:0] writeback_data,

    // Output data
    output reg [15:0] out_1,
    output reg [15:0] out_2,
    output reg [15:0] Rd_out
);

reg [15:0] reg_mem [7:0];                   // Array of 8 items each holding 16 bits of data
    
// Synchronous write back 
always @(posedge clk) begin

    if (reg_w) begin                        // reg_w control signal determines whether to write
        reg_mem[Rd_addr] <= writeback_data;
    end
    
end

// Asynchronous reading
always @* begin

    out_1 = reg_mem[Rs1_addr];
    out_2 = reg_mem[Rs2_addr];
    Rd_out = reg_mem[Rd_addr];

end

endmodule