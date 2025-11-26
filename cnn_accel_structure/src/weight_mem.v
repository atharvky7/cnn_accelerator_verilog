`timescale 1ns/1ps
`include "cnn_params.vh"

// weight_mem.v
// Stores NUM_FILTERS x 3x3 weights in a flat array.
//
// Index = filter_idx*9 + tap_idx

module weight_mem #(
    parameter DATA_WIDTH  = `DATA_WIDTH,
    parameter NUM_FILTERS = `NUM_FILTERS
)(
    input  wire [$clog2(NUM_FILTERS)-1:0] filter_idx,
    input  wire [3:0]                     tap_idx,    // 0..8
    output reg  signed [DATA_WIDTH-1:0]   w_out
);

    localparam TOTAL_WEIGHTS = NUM_FILTERS * 9;

    reg signed [DATA_WIDTH-1:0] mem [0:TOTAL_WEIGHTS-1];

    initial begin
        // For example:
        // $readmemh("data/weights.hex", mem);
    end

    wire [$clog2(TOTAL_WEIGHTS)-1:0] addr = filter_idx * 9 + tap_idx;

    always @* begin
        w_out = mem[addr];
    end

endmodule
