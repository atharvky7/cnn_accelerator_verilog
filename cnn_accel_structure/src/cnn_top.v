`timescale 1ns/1ps
`include "cnn_params.vh"

// cnn_top.v
// Top-level CNN accelerator wrapper.
// Instantiates conv_core and exposes start/done interface.

module cnn_top (
    input  wire clk,
    input  wire reset,
    input  wire start,
    output wire done
);

    conv_core #(
        .DATA_WIDTH (`DATA_WIDTH),
        .FRAC_BITS  (`FRAC_BITS),
        .IMG_WIDTH  (`IMG_WIDTH),
        .IMG_HEIGHT (`IMG_HEIGHT),
        .NUM_FILTERS(`NUM_FILTERS)
    ) CORE (
        .clk   (clk),
        .reset (reset),
        .start (start),
        .done  (done)
    );

endmodule
