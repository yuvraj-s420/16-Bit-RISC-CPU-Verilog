module Register_file(

    // Clock signal
    input clk,

    // Addresses
    input [2:0] Rd_address,
    input [2:0] Rs1_address,
    input [2:0] Rs2_address,
    
    // Register write enable
    input reg_w,

    // Data to writeback to register if write enabled
    input [15:0] writeback_data,

    // Output data
    output reg [15:0] out_1,
    output reg [15:0] out_2
);



endmodule