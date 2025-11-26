`timescale 1ns/1ps
`include "../src/cnn_params.vh"

module tb_cnn_top;

    reg clk;
    reg reset;
    reg start;
    wire done;

    cnn_top DUT (
        .clk   (clk),
        .reset (reset),
        .start (start),
        .done  (done)
    );

    // Clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1'b1;
        start = 1'b0;

        #20;
        reset = 1'b0;

        // In a full setup, you'd $readmemh inside conv_core for in_mem and w_mem.

        #20;
        start = 1'b1;
        @(posedge clk);
        start = 1'b0;

        // Wait for done
        wait(done == 1'b1);
        $display("CNN core signaled done.");

        // Here you could dump pool_mem via hierarchical reference, e.g.:
        // $writememh("data/hw_pooled.hex", DUT.CORE.pool_mem);

        #20;
        $finish;
    end

endmodule
