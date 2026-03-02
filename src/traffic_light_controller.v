module traffic_light_controller (
    input  clk,
    input  reset,
    input  sec_tick,
    
    input [7:0] green_duration, yellow_duration,
    
    output reg ns_red, ns_yellow, ns_green,
    ew_red, ew_yellow, ew_green
);

    // State encoding
    parameter NS_GREEN  = 2'd0;
    parameter NS_YELLOW = 2'd1;
    parameter EW_GREEN  = 2'd2;
    parameter EW_YELLOW = 2'd3;

    reg  [1:0] present_state, next_state;
    reg  [7:0] state_timer;          // counts seconds
    wire [7:0] state_duration;       // duration of current state
    wire       timer_done;

    // -------------------------
    // State register
    // -------------------------
    always @(posedge clk) begin
        if (reset)
            present_state <= NS_GREEN;
        else
            present_state <= next_state;
    end

    // -------------------------
    // Timer register
    // -------------------------
    always @(posedge clk) begin
        if (reset)
            state_timer <= 8'd0;
        else if (present_state != next_state)
            state_timer <= 8'd0;
        else if (sec_tick)
            state_timer <= state_timer + 1'b1;
    end

    // -------------------------
    // State duration logic
    // -------------------------
    assign state_duration =
        (present_state == NS_GREEN  || present_state == EW_GREEN)  ? green_duration :
        (present_state == NS_YELLOW || present_state == EW_YELLOW) ? yellow_duration  :
                                                                     8'd0;

    // -------------------------
    // Timer done condition
    // -------------------------
    assign timer_done = (state_timer == state_duration);
    // Edge Case: if duration=0 => 
    // timer_done is true immediately & FSM will skip the state instantly

    // -------------------------
    // Next-state logic
    // -------------------------
    always @(*) begin
        next_state = present_state;

        if (timer_done) begin
            case (present_state)
                NS_GREEN:   next_state = NS_YELLOW;
                NS_YELLOW:  next_state = EW_GREEN;
                EW_GREEN:   next_state = EW_YELLOW;
                EW_YELLOW:  next_state = NS_GREEN;
                default:    next_state = NS_GREEN;
            endcase
        end
    end
    
    // -------------------------
    // Output Combinational Logic
    // -------------------------
    always @(*) begin
        {ns_red, ns_yellow, ns_green, ew_red, ew_yellow, ew_green} = 6'b000000;
        
        case (present_state)
            NS_GREEN:  {ns_red, ns_yellow, ns_green, ew_red, ew_yellow, ew_green} = 6'b001100;
            NS_YELLOW: {ns_red, ns_yellow, ns_green, ew_red, ew_yellow, ew_green} = 6'b010100;
            EW_GREEN:  {ns_red, ns_yellow, ns_green, ew_red, ew_yellow, ew_green} = 6'b100001;
            EW_YELLOW: {ns_red, ns_yellow, ns_green, ew_red, ew_yellow, ew_green} = 6'b100010;
            default: {ns_red, ns_yellow, ns_green, ew_red, ew_yellow, ew_green} = 6'b100100;
        endcase
    end
endmodule