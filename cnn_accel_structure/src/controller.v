`timescale 1ns/1ps
`include "cnn_params.vh"

// controller.v
// Example FSM controller skeleton for a CNN operation.
// Not wired into cnn_top in this version, but can be extended.
//
// IDLE -> RUN -> DONE

module controller (
    input  wire clk,
    input  wire reset,
    input  wire start,
    output reg  busy,
    output reg  done
);

    localparam S_IDLE = 2'd0;
    localparam S_RUN  = 2'd1;
    localparam S_DONE = 2'd2;

    reg [1:0] state, next_state;

    // Simple counter to emulate work
    reg [15:0] cycle_cnt;

    always @(posedge clk) begin
        if (reset) begin
            state     <= S_IDLE;
            cycle_cnt <= 0;
        end else begin
            state <= next_state;
            if (state == S_RUN)
                cycle_cnt <= cycle_cnt + 1;
            else
                cycle_cnt <= 0;
        end
    end

    always @* begin
        next_state = state;
        busy       = 1'b0;
        done       = 1'b0;

        case (state)
            S_IDLE: begin
                if (start)
                    next_state = S_RUN;
            end
            S_RUN: begin
                busy = 1'b1;
                // Example: pretend operation finishes after some cycles
                if (cycle_cnt == 16'd100)
                    next_state = S_DONE;
            end
            S_DONE: begin
                done       = 1'b1;
                next_state = S_IDLE;
            end
        endcase
    end

endmodule
