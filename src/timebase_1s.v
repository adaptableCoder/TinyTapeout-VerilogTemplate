// ------------------------------------------------------------
// Module: timebase_1s
// Purpose:
//   Generate a 1-second pulse (sec_tick) from a fast FPGA clock
// ------------------------------------------------------------
module timebase_1s #(
    // Clock frequency of the FPGA in Hz
    // Example: 50 MHz -> 50_000_000
    parameter CLK_FREQ = 50_000_000
)(
    input  clk,        // Fast FPGA clock
    input  reset,   
      // Synchronous reset (active high)
    output reg sec_tick // Goes high for 1 clock cycle every 1 second
);

    // Number of bits required to count up to CLK_FREQ
    // Automatically calculated
    // $clog2 means "ceiling of log base 2"
    localparam COUNTER_WIDTH = $clog2(CLK_FREQ);

    // Counter to count FPGA clock cycles
    reg [COUNTER_WIDTH-1:0] clk_counter;

    // --------------------------------------------------------
    // Counter and sec_tick generation logic
    // --------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            // On reset:
            //  - Clear the counter
            //  - Ensure sec_tick is low
            clk_counter <= {COUNTER_WIDTH{1'b0}};
            sec_tick    <= 1'b0;

        end else if (clk_counter == CLK_FREQ - 1) begin
            // One second has completed:
            //  - Reset counter back to zero
            //  - Raise sec_tick for exactly one clock cycle
            clk_counter <= {COUNTER_WIDTH{1'b0}};
            sec_tick    <= 1'b1;

        end else begin
            // Normal operation:
            //  - Keep counting clock cycles
            //  - sec_tick stays low
            clk_counter <= clk_counter + 1'b1;
            sec_tick    <= 1'b0;
        end
    end

endmodule