`timescale 1ns/1ps
`include "cnn_params.vh"

// feature_mem_out.v
// Simple writeable memory for output feature maps.

module feature_mem_out #(
    parameter DATA_WIDTH = `DATA_WIDTH,
    parameter DEPTH      = 256  // override as needed
)(
    input  wire                         clk,
    input  wire                         we,
    input  wire [$clog2(DEPTH)-1:0]     addr,
    input  wire signed [DATA_WIDTH-1:0] din,
    output reg  signed [DATA_WIDTH-1:0] dout
);

    reg signed [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    always @(posedge clk) begin
        if (we)
            mem[addr] <= din;
        dout <= mem[addr];
    end

endmodule
