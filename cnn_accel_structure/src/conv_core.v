`timescale 1ns/1ps
`include "cnn_params.vh"

// conv_core.v
// Sequential CNN core:
// - Internal memory for input image (single-channel).
// - Internal memory for weights: NUM_FILTERS x 3x3.
// - Computes 3x3 valid convolution for each filter (one output per window).
// - Applies ReLU.
// - Performs 2x2 max pooling per filter.
// - Stores pooled outputs in internal memory.
// - Asserts 'done' when complete.
//
// NOTE: This is written with simulation in mind. For clarity,
//       memories are internal and initialized via $readmemh.

module conv_core #(
    parameter DATA_WIDTH  = `DATA_WIDTH,
    parameter FRAC_BITS   = `FRAC_BITS,
    parameter IMG_WIDTH   = `IMG_WIDTH,
    parameter IMG_HEIGHT  = `IMG_HEIGHT,
    parameter NUM_FILTERS = `NUM_FILTERS
)(
    input  wire clk,
    input  wire reset,
    input  wire start,
    output reg  done
);

    localparam IMG_SIZE      = IMG_WIDTH * IMG_HEIGHT;
    localparam OUT_CONV_W    = IMG_WIDTH  - 2;
    localparam OUT_CONV_H    = IMG_HEIGHT - 2;
    localparam OUT_CONV_SIZE = OUT_CONV_W * OUT_CONV_H;

    localparam OUT_POOL_W    = OUT_CONV_W / 2;
    localparam OUT_POOL_H    = OUT_CONV_H / 2;
    localparam OUT_POOL_SIZE = OUT_POOL_W * OUT_POOL_H;

    // Internal memories
    reg signed [DATA_WIDTH-1:0] in_mem   [0:IMG_SIZE-1];                     // input image
    reg signed [DATA_WIDTH-1:0] w_mem    [0:NUM_FILTERS*9-1];                // weights
    reg signed [DATA_WIDTH-1:0] conv_mem [0:NUM_FILTERS*OUT_CONV_SIZE-1];    // conv+ReLU outputs
    reg signed [DATA_WIDTH-1:0] pool_mem [0:NUM_FILTERS*OUT_POOL_SIZE-1];    // pooled outputs

    integer i;

    initial begin
        // You should create these files in data/:
        // For example:
        // $readmemh("data/input_image.hex", in_mem);
        // $readmemh("data/weights.hex",     w_mem);

        for (i = 0; i < IMG_SIZE; i = i + 1)
            in_mem[i] = 0;
        for (i = 0; i < NUM_FILTERS*9; i = i + 1)
            w_mem[i] = 0;
        for (i = 0; i < NUM_FILTERS*OUT_CONV_SIZE; i = i + 1)
            conv_mem[i] = 0;
        for (i = 0; i < NUM_FILTERS*OUT_POOL_SIZE; i = i + 1)
            pool_mem[i] = 0;
    end

    // FSM states
    localparam S_IDLE      = 3'd0;
    localparam S_CONV      = 3'd1;
    localparam S_POOL      = 3'd2;
    localparam S_DONE      = 3'd3;

    reg [2:0] state, next_state;

    // Loop indices
    reg [$clog2(IMG_HEIGHT)-1:0] row;
    reg [$clog2(IMG_WIDTH)-1:0]  col;
    reg [$clog2(NUM_FILTERS)-1:0] filter;

    // For pooling
    reg [$clog2(OUT_CONV_H)-1:0] prow;
    reg [$clog2(OUT_CONV_W)-1:0] pcol;

    // Common fixed-point multiply-accumulate
    reg signed [DATA_WIDTH-1:0] acc;

    // Helper: get in_mem index for (r,c)
    function integer idx_in;
        input integer r;
        input integer c;
        begin
            idx_in = r*IMG_WIDTH + c;
        end
    endfunction

    // Helper: get index in conv_mem for (filter, r, c)
    function integer idx_conv;
        input integer f;
        input integer r;
        input integer c;
        begin
            idx_conv = f*OUT_CONV_SIZE + r*OUT_CONV_W + c;
        end
    endfunction

    // Helper: get index in pool_mem for (filter, r, c)
    function integer idx_pool;
        input integer f;
        input integer r;
        input integer c;
        begin
            idx_pool = f*OUT_POOL_SIZE + r*OUT_POOL_W + c;
        end
    endfunction

    // FSM state register
    always @(posedge clk) begin
        if (reset) begin
            state  <= S_IDLE;
            done   <= 1'b0;
            row    <= 0;
            col    <= 0;
            filter <= 0;
            prow   <= 0;
            pcol   <= 0;
            acc    <= 0;
        end else begin
            state <= next_state;
        end
    end

    // FSM next-state and datapath
    always @* begin
        next_state = state;
        done       = 1'b0;
    end

    // Main sequential datapath
    always @(posedge clk) begin
        if (reset) begin
            // Already handled above, but keep safe defaults
            row    <= 0;
            col    <= 0;
            filter <= 0;
            prow   <= 0;
            pcol   <= 0;
            acc    <= 0;
        end else begin
            case (state)
                S_IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        // In a real design, you'd load in_mem and w_mem here or before.
                        // Start convolution loops.
                        row    <= 0;
                        col    <= 0;
                        filter <= 0;
                        next_state <= S_CONV;
                    end
                end

                S_CONV: begin
                    // Compute one 3x3 conv result for (filter, row, col)
                    // using a simple unrolled MAC inside this clock.
                    // For more realistic hardware, you would pipeline this
                    // over multiple cycles.

                    integer r0,c0;
                    integer idx;
                    integer wbase;
                    signed [2*DATA_WIDTH-1:0] sum_ext;
                    signed [2*DATA_WIDTH-1:0] prod;

                    sum_ext = 0;
                    wbase   = filter * 9;

                    // 3x3 window loops (unrolled manually for clarity)
                    // (0,0)
                    r0 = row; c0 = col;
                    prod   = in_mem[idx_in(r0,c0)] * w_mem[wbase+0];
                    sum_ext = sum_ext + prod;
                    // (0,1)
                    r0 = row; c0 = col+1;
                    prod   = in_mem[idx_in(r0,c0)] * w_mem[wbase+1];
                    sum_ext = sum_ext + prod;
                    // (0,2)
                    r0 = row; c0 = col+2;
                    prod   = in_mem[idx_in(r0,c0)] * w_mem[wbase+2];
                    sum_ext = sum_ext + prod;
                    // (1,0)
                    r0 = row+1; c0 = col;
                    prod   = in_mem[idx_in(r0,c0)] * w_mem[wbase+3];
                    sum_ext = sum_ext + prod;
                    // (1,1)
                    r0 = row+1; c0 = col+1;
                    prod   = in_mem[idx_in(r0,c0)] * w_mem[wbase+4];
                    sum_ext = sum_ext + prod;
                    // (1,2)
                    r0 = row+1; c0 = col+2;
                    prod   = in_mem[idx_in(r0,c0)] * w_mem[wbase+5];
                    sum_ext = sum_ext + prod;
                    // (2,0)
                    r0 = row+2; c0 = col;
                    prod   = in_mem[idx_in(r0,c0)] * w_mem[wbase+6];
                    sum_ext = sum_ext + prod;
                    // (2,1)
                    r0 = row+2; c0 = col+1;
                    prod   = in_mem[idx_in(r0,c0)] * w_mem[wbase+7];
                    sum_ext = sum_ext + prod;
                    // (2,2)
                    r0 = row+2; c0 = col+2;
                    prod   = in_mem[idx_in(r0,c0)] * w_mem[wbase+8];
                    sum_ext = sum_ext + prod;

                    // Scale back to fixed-point (Q format)
                    sum_ext = sum_ext >>> FRAC_BITS;

                    // Clip to DATA_WIDTH
                    acc = sum_ext[DATA_WIDTH-1:0];

                    // Apply ReLU
                    if (acc < 0)
                        acc <= 0;

                    // Store in conv_mem
                    conv_mem[idx_conv(filter, row, col)] <= acc;

                    // Increment indices: col -> row -> filter
                    if (col == OUT_CONV_W-1) begin
                        col <= 0;
                        if (row == OUT_CONV_H-1) begin
                            row <= 0;
                            if (filter == NUM_FILTERS-1) begin
                                // Finished convolution for all filters
                                filter <= 0;
                                // Move to pooling
                                prow <= 0;
                                pcol <= 0;
                                next_state <= S_POOL;
                            end else begin
                                filter <= filter + 1;
                            end
                        end else begin
                            row <= row + 1;
                        end
                    end else begin
                        col <= col + 1;
                    end
                end

                S_POOL: begin
                    // 2x2 max pooling over conv_mem into pool_mem

                    integer r1, c1;
                    integer f;
                    signed [DATA_WIDTH-1:0] a00, a01, a10, a11;
                    signed [DATA_WIDTH-1:0] max0, max1, maxv;

                    f  = filter;
                    r1 = 2*prow;
                    c1 = 2*pcol;

                    a00 = conv_mem[idx_conv(filter, r1,   c1  )];
                    a01 = conv_mem[idx_conv(filter, r1,   c1+1)];
                    a10 = conv_mem[idx_conv(filter, r1+1, c1  )];
                    a11 = conv_mem[idx_conv(filter, r1+1, c1+1)];

                    max0 = (a00 > a01) ? a00 : a01;
                    max1 = (a10 > a11) ? a10 : a11;
                    maxv = (max0 > max1) ? max0 : max1;

                    pool_mem[idx_pool(filter, prow, pcol)] <= maxv;

                    // Increment pooling indices
                    if (pcol == OUT_POOL_W-1) begin
                        pcol <= 0;
                        if (prow == OUT_POOL_H-1) begin
                            prow <= 0;
                            if (filter == NUM_FILTERS-1) begin
                                // All pooling done
                                next_state <= S_DONE;
                            end else begin
                                filter <= filter + 1;
                            end
                        end else begin
                            prow <= prow + 1;
                        end
                    end else begin
                        pcol <= pcol + 1;
                    end
                end

                S_DONE: begin
                    done       <= 1'b1;
                    next_state <= S_IDLE;
                end

                default: begin
                    next_state <= S_IDLE;
                end
            endcase
        end
    end

endmodule
