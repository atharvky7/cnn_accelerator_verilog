`timescale 1ns/1ps
`include "cnn_params.vh"

// relu.v
// ReLU activation: y = max(0, x)

module relu #(
    parameter DATA_WIDTH = `DATA_WIDTH
)(
    input  wire signed [DATA_WIDTH-1:0] x,
    output wire signed [DATA_WIDTH-1:0] y
);

    assign y = (x < 0) ? {DATA_WIDTH{1'b0}} : x;

endmodule
