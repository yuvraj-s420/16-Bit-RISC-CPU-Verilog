module Memory_file (
    
    // Clock
    input clk,

    // read/write address (9 bit)
    input [8:0] addr,

    // Write data
    input [15:0] write_data,

    // Control signals
    input mem_r,
    input mem_w,

    // Data out
    output reg [15:0] out
);

reg [15:0] mem [511:0];      // RAM consisting of 512 locations of 16 bit words

// Synchronous writing 
always @(posedge clk) begin

    if (mem_w) begin
        mem[addr] <= write_data;
    end

end

// Asynchronous reading
always @* begin

    if (mem_r) begin
        out = mem[addr];
    end

end

endmodule