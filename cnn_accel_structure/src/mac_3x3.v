`timescale 1ns/1ps
`include "cnn_params.vh"

// mac_3x3.v
// 3x3 Multiply-Accumulate block for CNN convolution.
//
// - Inputs: 9 pixels and 9 weights (signed fixed-point).
// - Internals: 9 parallel products, summed into a 32-bit accumulator.
// - Scaling: arithmetic shift right by FRAC_BITS to maintain Q format.
// - Output: signed fixed-point result, truncated to DATA_WIDTH bits.

module mac_3x3 #(
    parameter DATA_WIDTH = `DATA_WIDTH,
    parameter FRAC_BITS  = `FRAC_BITS
)(
    input  wire signed [DATA_WIDTH-1:0] px0,
    input  wire signed [DATA_WIDTH-1:0] px1,
    input  wire signed [DATA_WIDTH-1:0] px2,
    input  wire signed [DATA_WIDTH-1:0] px3,
    input  wire signed [DATA_WIDTH-1:0] px4,
    input  wire signed [DATA_WIDTH-1:0] px5,
    input  wire signed [DATA_WIDTH-1:0] px6,
    input  wire signed [DATA_WIDTH-1:0] px7,
    input  wire signed [DATA_WIDTH-1:0] px8,

    input  wire signed [DATA_WIDTH-1:0] w0,
    input  wire signed [DATA_WIDTH-1:0] w1,
    input  wire signed [DATA_WIDTH-1:0] w2,
    input  wire signed [DATA_WIDTH-1:0] w3,
    input  wire signed [DATA_WIDTH-1:0] w4,
    input  wire signed [DATA_WIDTH-1:0] w5,
    input  wire signed [DATA_WIDTH-1:0] w6,
    input  wire signed [DATA_WIDTH-1:0] w7,
    input  wire signed [DATA_WIDTH-1:0] w8,

    output wire signed [DATA_WIDTH-1:0] mac_out
);

    // 32-bit products
    wire signed [2*DATA_WIDTH-1:0] p0 = px0 * w0;
    wire signed [2*DATA_WIDTH-1:0] p1 = px1 * w1;
    wire signed [2*DATA_WIDTH-1:0] p2 = px2 * w2;
    wire signed [2*DATA_WIDTH-1:0] p3 = px3 * w3;
    wire signed [2*DATA_WIDTH-1:0] p4 = px4 * w4;
    wire signed [2*DATA_WIDTH-1:0] p5 = px5 * w5;
    wire signed [2*DATA_WIDTH-1:0] p6 = px6 * w6;
    wire signed [2*DATA_WIDTH-1:0] p7 = px7 * w7;
    wire signed [2*DATA_WIDTH-1:0] p8 = px8 * w8;

    wire signed [2*DATA_WIDTH-1:0] sum_products =
          p0 + p1 + p2
        + p3 + p4 + p5
        + p6 + p7 + p8;

    // Scale down to maintain fixed-point format
    wire signed [2*DATA_WIDTH-1:0] scaled = sum_products >>> FRAC_BITS;

    // Truncate to DATA_WIDTH
    assign mac_out = scaled[DATA_WIDTH-1:0];

endmodule
