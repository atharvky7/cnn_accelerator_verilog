`timescale 1ns/1ps
`include "cnn_params.vh"

// feature_mem_in.v
// Simple input feature map memory (1D flattened).
// Reads are combinational based on address.
//
// In simulation, contents can be loaded using $readmemh.

module feature_mem_in #(
    parameter DATA_WIDTH = `DATA_WIDTH,
    parameter IMG_WIDTH  = `IMG_WIDTH,
    parameter IMG_HEIGHT = `IMG_HEIGHT
)(
    input  wire [$clog2(IMG_WIDTH*IMG_HEIGHT)-1:0] addr,
    output reg  signed [DATA_WIDTH-1:0]            dout
);

    localparam MEM_SIZE = IMG_WIDTH * IMG_HEIGHT;

    reg signed [DATA_WIDTH-1:0] mem [0:MEM_SIZE-1];

    initial begin
        // You can override this file name or use it in tb:
        // $readmemh("data/input_image.hex", mem);
    end

    always @* begin
        dout = mem[addr];
    end

endmodule
