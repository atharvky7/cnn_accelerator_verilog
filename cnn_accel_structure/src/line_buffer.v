`timescale 1ns/1ps
`include "cnn_params.vh"

// line_buffer.v
// Simple 3-line buffer for streaming pixels row by row.
// For IMG_WIDTH-wide image, accepts one pixel per cycle with in_valid.
// After at least 3 rows have been received, it outputs 3 pixels per cycle:
// row0_px, row1_px, row2_px at the current column position.
//
// This is a simplified educational implementation.

module line_buffer #(
    parameter DATA_WIDTH = `DATA_WIDTH,
    parameter IMG_WIDTH  = `IMG_WIDTH
)(
    input  wire                       clk,
    input  wire                       reset,
    input  wire                       in_valid,
    input  wire signed [DATA_WIDTH-1:0] pixel_in,

    output reg                        out_valid,
    output reg signed [DATA_WIDTH-1:0] row0_px,
    output reg signed [DATA_WIDTH-1:0] row1_px,
    output reg signed [DATA_WIDTH-1:0] row2_px
);

    // We keep 3 shift-register rows.
    reg signed [DATA_WIDTH-1:0] row0 [0:IMG_WIDTH-1];
    reg signed [DATA_WIDTH-1:0] row1 [0:IMG_WIDTH-1];
    reg signed [DATA_WIDTH-1:0] row2 [0:IMG_WIDTH-1];

    integer i;
    reg [15:0] col_cnt;
    reg [15:0] row_cnt;

    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < IMG_WIDTH; i = i + 1) begin
                row0[i] <= 0;
                row1[i] <= 0;
                row2[i] <= 0;
            end
            col_cnt  <= 0;
            row_cnt  <= 0;
            out_valid <= 1'b0;
            row0_px  <= 0;
            row1_px  <= 0;
            row2_px  <= 0;
        end else if (in_valid) begin
            // Shift row2 into row1, row1 into row0 only when starting a new row.
            // This is a simplified approach—REAL designs use BRAM + line addressing.
            if (col_cnt == 0) begin
                for (i = 0; i < IMG_WIDTH; i = i + 1) begin
                    row0[i] <= row1[i];
                    row1[i] <= row2[i];
                end
                row_cnt <= row_cnt + 1;
            end

            // Insert new pixel into row2
            row2[col_cnt] <= pixel_in;

            // Increase column counter
            if (col_cnt == IMG_WIDTH-1)
                col_cnt <= 0;
            else
                col_cnt <= col_cnt + 1;

            // Valid output only after 3 rows are available
            if (row_cnt >= 2) begin
                out_valid <= 1'b1;
                row0_px   <= row0[col_cnt];
                row1_px   <= row1[col_cnt];
                row2_px   <= row2[col_cnt];
            end else begin
                out_valid <= 1'b0;
            end
        end else begin
            out_valid <= 1'b0;
        end
    end

endmodule
