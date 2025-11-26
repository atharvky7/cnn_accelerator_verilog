`timescale 1ns/1ps
`include "../src/cnn_params.vh"

module tb_mac_3x3;

    localparam DATA_WIDTH = `DATA_WIDTH;
    localparam FRAC_BITS  = `FRAC_BITS;

    reg  signed [DATA_WIDTH-1:0] px0, px1, px2, px3, px4, px5, px6, px7, px8;
    reg  signed [DATA_WIDTH-1:0] w0,  w1,  w2,  w3,  w4,  w5,  w6,  w7,  w8;

    wire signed [DATA_WIDTH-1:0] mac_out;

    mac_3x3 #(
        .DATA_WIDTH(DATA_WIDTH),
        .FRAC_BITS (FRAC_BITS)
    ) DUT (
        .px0(px0), .px1(px1), .px2(px2),
        .px3(px3), .px4(px4), .px5(px5),
        .px6(px6), .px7(px7), .px8(px8),
        .w0(w0), .w1(w1), .w2(w2),
        .w3(w3), .w4(w4), .w5(w5),
        .w6(w6), .w7(w7), .w8(w8),
        .mac_out(mac_out)
    );

    task print_result;
        input [255*8-1:0] label;
        begin
            $display("%s", label);
            $display("  mac_out (raw)   = %0d", mac_out);
            $display("  mac_out (real)  = %0f", mac_out / 1.0 / (1<<FRAC_BITS));
            $display("");
        end
    endtask

    initial begin
        integer one_fp, half_fp;

        one_fp  = 1 << FRAC_BITS;       // 1.0
        half_fp = 1 << (FRAC_BITS - 1); // 0.5

        // Test 1: all ones
        px0 = one_fp; px1 = one_fp; px2 = one_fp;
        px3 = one_fp; px4 = one_fp; px5 = one_fp;
        px6 = one_fp; px7 = one_fp; px8 = one_fp;

        w0  = one_fp; w1  = one_fp; w2  = one_fp;
        w3  = one_fp; w4  = one_fp; w5  = one_fp;
        w6  = one_fp; w7  = one_fp; w8  = one_fp;

        #10;
        print_result("Test 1: px=1.0, w=1.0, expect ~9.0");

        // Test 2: px=1.0, w=0.5
        w0 = half_fp; w1 = half_fp; w2 = half_fp;
        w3 = half_fp; w4 = half_fp; w5 = half_fp;
        w6 = half_fp; w7 = half_fp; w8 = half_fp;

        #10;
        print_result("Test 2: px=1.0, w=0.5, expect ~4.5");

        // Test 3: edge-like filter
        w0 =  one_fp; w1 =  0;       w2 = -one_fp;
        w3 =  one_fp; w4 =  0;       w5 = -one_fp;
        w6 =  one_fp; w7 =  0;       w8 = -one_fp;

        #10;
        print_result("Test 3: edge filter, expect ~0.0");

        $display("MAC 3x3 tests finished.");
        $finish;
    end

endmodule
