/*
 * Copyright (c) 2024 adaptableCoder
 * tt_adaptableCoder.v - Adaptable traffic light controller for FPGA
 * SPDX-License-Identifier: Apache-2.0
 */
`default_nettype none

module tt_um_adaptableCoder (
    input  wire [7:0] ui_in,    // Dedicated inputs (used for green duration)
    output wire [7:0] uo_out,   // Dedicated outputs (traffic lights mapped here)
    input  wire [7:0] uio_in,   // IOs: Input path (used for yellow duration)
    output wire [7:0] uio_out,  // IOs: Output path (unused)
    output wire [7:0] uio_oe,   // IOs: Enable path (unused)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // Internal active-high reset for existing submodules
    wire reset = ~rst_n;

    // Map durations: use ui_in for green, uio_in for yellow
    wire [7:0] green_duration  = ui_in;
    wire [7:0] yellow_duration = uio_in;

    // 1-second tick between modules
    wire sec_tick;

    // Timebase instance: adjust CLK_FREQ parameter as required
    timebase_1s #(
        .CLK_FREQ(20)
    ) timebase_inst (
        .clk(clk),
        .reset(reset),
        .sec_tick(sec_tick)
    );

    // Traffic light controller instance
    wire ns_red, ns_yellow, ns_green;
    wire ew_red, ew_yellow, ew_green;

    traffic_light_controller traffic_ctrl_inst (
        .clk(clk),
        .reset(reset),
        .sec_tick(sec_tick),

        .green_duration(green_duration),
        .yellow_duration(yellow_duration),

        .ns_red(ns_red),
        .ns_yellow(ns_yellow),
        .ns_green(ns_green),
        .ew_red(ew_red),
        .ew_yellow(ew_yellow),
        .ew_green(ew_green)
    );

    // Map traffic outputs into dedicated output bus (lower 6 bits)
    // bit mapping: [0]=ns_red, [1]=ns_yellow, [2]=ns_green,
    //              [3]=ew_red, [4]=ew_yellow, [5]=ew_green
    assign uo_out = {2'b00, ew_green, ew_yellow, ew_red, ns_green, ns_yellow, ns_red};

    // Drive unused IO buses to 0 and OE to inputs
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // List all unused inputs to prevent synthesis warnings
    wire _unused = &{ena, 1'b0};

endmodule