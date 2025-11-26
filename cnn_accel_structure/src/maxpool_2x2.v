`timescale 1ns/1ps
`include "cnn_params.vh"

// maxpool_2x2.v
// 2x2 max pooling (combinational)
//
// Given 4 inputs (2x2 region), output the maximum.

module maxpool_2x2 #(
    parameter DATA_WIDTH = `DATA_WIDTH
)(
    input  wire signed [DATA_WIDTH-1:0] a00,
    input  wire signed [DATA_WIDTH-1:0] a01,
    input  wire signed [DATA_WIDTH-1:0] a10,
    input  wire signed [DATA_WIDTH-1:0] a11,
    output wire signed [DATA_WIDTH-1:0] y
);

    wire signed [DATA_WIDTH-1:0] max0 = (a00 > a01) ? a00 : a01;
    wire signed [DATA_WIDTH-1:0] max1 = (a10 > a11) ? a10 : a11;
    assign y = (max0 > max1) ? max0 : max1;

endmodule
