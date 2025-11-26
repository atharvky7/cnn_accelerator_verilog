`timescale 1ns/1ps
`include "../src/cnn_params.vh"

module tb_line_window;

    localparam DATA_WIDTH = `DATA_WIDTH;
    localparam IMG_WIDTH  = 5; // small test image width
    localparam IMG_HEIGHT = 5;

    reg clk;
    reg reset;
    reg in_valid;
    reg signed [DATA_WIDTH-1:0] pixel_in;

    wire out_valid_lb;
    wire signed [DATA_WIDTH-1:0] row0_px, row1_px, row2_px;

    wire win_valid;
    wire signed [DATA_WIDTH-1:0] px0, px1, px2,
                                 px3, px4, px5,
                                 px6, px7, px8;

    // Instantiate line_buffer with IMG_WIDTH=5
    line_buffer #(
        .DATA_WIDTH(DATA_WIDTH),
        .IMG_WIDTH (IMG_WIDTH)
    ) LB (
        .clk      (clk),
        .reset    (reset),
        .in_valid (in_valid),
        .pixel_in (pixel_in),
        .out_valid(out_valid_lb),
        .row0_px  (row0_px),
        .row1_px  (row1_px),
        .row2_px  (row2_px)
    );

    // Instantiate window_buffer
    window_buffer #(
        .DATA_WIDTH(DATA_WIDTH)
    ) WB (
        .clk      (clk),
        .reset    (reset),
        .in_valid (out_valid_lb),
        .row0_px  (row0_px),
        .row1_px  (row1_px),
        .row2_px  (row2_px),
        .win_valid(win_valid),
        .px0(px0), .px1(px1), .px2(px2),
        .px3(px3), .px4(px4), .px5(px5),
        .px6(px6), .px7(px7), .px8(px8)
    );

    // 5x5 test image: pixel values 0 .. 24
    reg signed [DATA_WIDTH-1:0] img [0:IMG_WIDTH*IMG_HEIGHT-1];
    integer i;

    initial begin
        for (i = 0; i < IMG_WIDTH*IMG_HEIGHT; i = i + 1)
            img[i] = i;
    end

    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    integer idx;

    initial begin
        reset    = 1'b1;
        in_valid = 1'b0;
        pixel_in = 0;
        idx      = 0;

        #20;
        reset = 1'b0;

        // Feed the 5x5 image row-wise
        for (idx = 0; idx < IMG_WIDTH*IMG_HEIGHT; idx = idx + 1) begin
            @(posedge clk);
            in_valid <= 1'b1;
            pixel_in <= img[idx];
        end

        @(posedge clk);
        in_valid <= 1'b0;
        pixel_in <= 0;

        // Let pipeline flush
        repeat (20) @(posedge clk);

        $finish;
    end

    always @(posedge clk) begin
        if (win_valid) begin
            $display("3x3 window:");
            $display("  [%0d %0d %0d]", px0, px1, px2);
            $display("  [%0d %0d %0d]", px3, px4, px5);
            $display("  [%0d %0d %0d]", px6, px7, px8);
        end
    end

endmodule
