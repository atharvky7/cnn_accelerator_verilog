`timescale 1ns/1ps
`include "cnn_params.vh"

// window_buffer.v
// Builds a 3x3 window from 3-pixel vertical inputs coming from a line buffer.
// Accepts row0_px, row1_px, row2_px (one column at a time), and shifts them
// into a 3x3 window:
//
// [px0 px1 px2]
// [px3 px4 px5]
// [px6 px7 px8]
//
// Output valid once at least 3 columns have been processed.

module window_buffer #(
    parameter DATA_WIDTH = `DATA_WIDTH
)(
    input  wire                       clk,
    input  wire                       reset,
    input  wire                       in_valid,
    input  wire signed [DATA_WIDTH-1:0] row0_px,
    input  wire signed [DATA_WIDTH-1:0] row1_px,
    input  wire signed [DATA_WIDTH-1:0] row2_px,

    output reg                        win_valid,
    output reg signed [DATA_WIDTH-1:0] px0,
    output reg signed [DATA_WIDTH-1:0] px1,
    output reg signed [DATA_WIDTH-1:0] px2,
    output reg signed [DATA_WIDTH-1:0] px3,
    output reg signed [DATA_WIDTH-1:0] px4,
    output reg signed [DATA_WIDTH-1:0] px5,
    output reg signed [DATA_WIDTH-1:0] px6,
    output reg signed [DATA_WIDTH-1:0] px7,
    output reg signed [DATA_WIDTH-1:0] px8
);

    // Shift registers for three rows, width 3
    reg signed [DATA_WIDTH-1:0] r0 [0:2];
    reg signed [DATA_WIDTH-1:0] r1 [0:2];
    reg signed [DATA_WIDTH-1:0] r2 [0:2];

    integer i;
    reg [1:0] col_count;

    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 3; i = i + 1) begin
                r0[i] <= 0;
                r1[i] <= 0;
                r2[i] <= 0;
            end
            col_count <= 0;
            win_valid <= 1'b0;
            {px0, px1, px2, px3, px4, px5, px6, px7, px8} <= 0;
        end else if (in_valid) begin
            // Shift left
            r0[0] <= r0[1];
            r0[1] <= r0[2];
            r1[0] <= r1[1];
            r1[1] <= r1[2];
            r2[0] <= r2[1];
            r2[1] <= r2[2];

            // Insert new column at the right
            r0[2] <= row0_px;
            r1[2] <= row1_px;
            r2[2] <= row2_px;

            if (col_count < 2)
                col_count <= col_count + 1;

            if (col_count >= 2) begin
                win_valid <= 1'b1;
                px0 <= r0[0]; px1 <= r0[1]; px2 <= r0[2];
                px3 <= r1[0]; px4 <= r1[1]; px5 <= r1[2];
                px6 <= r2[0]; px7 <= r2[1]; px8 <= r2[2];
            end else begin
                win_valid <= 1'b0;
            end
        end else begin
            win_valid <= 1'b0;
        end
    end

endmodule
