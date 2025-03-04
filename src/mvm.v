// matrix vector multiplier
module mvm #(
    parameter MATRIX_ROWS = 6,      // determines the number of ROWS in the matrix
    parameter SHARED_DIM = 3,       // determines the number of columns in the matrix and rows in the vector
    parameter WIDTH = 8,            // determines the width of data inside the matrix and the vector
    parameter INT_BITS = 2          // determines the number of integer bits in the inputs
) (
    input wire clk, reset, start,
    input wire [MATRIX_ROWS * SHARED_DIM * WIDTH - 1:0] matrix,
    input wire [SHARED_DIM * WIDTH - 1:0] vector,
    output reg [MATRIX_ROWS * SHARED_DIM * WIDTH - 1:0] result_vector,
    output wire done
);

    wire [MATRIX_ROWS  * WIDTH - 1:0] a, out;
    wire [WIDTH - 1:0] b;
    
    reg enable;
    reg [SHARED_DIM - 1:0] shared_idx;          // keeps track of current column in the matrix and current row in the vector
    reg [1:0] prop_delay_counter;               // counter to introduce propagation delay

    // slices the matrix and vector to get the current values for the vector scalar multiplier
    assign b = vector[WIDTH * (SHARED_DIM - shared_idx) - 1 -: WIDTH];
        
    genvar i;
    generate
        for (i = 0; i < MATRIX_ROWS; i = i + 1) begin : a_slice_loop
            assign a[((MATRIX_ROWS - i) * WIDTH) - 1 -: WIDTH] = matrix[WIDTH * SHARED_DIM * (MATRIX_ROWS - i) - (WIDTH * shared_idx) - 1 -: WIDTH];
        end
    endgenerate

    // vector scalar multiplier with proper parameters
    vsmac #(
        .SIZE(MATRIX_ROWS),
        .WIDTH(WIDTH),
        .ACCUMULATIONS(SHARED_DIM),
        .INT_BITS(INT_BITS)
    ) vsm (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .a(a),
        .b(b),
        .out(out)
    );

    // define states for state machine
    localparam IDLE = 2'b00;
    localparam CALCULATE = 2'b01;
    localparam DELAY = 2'b10;

    reg [1:0] current_state, next_state, prev_state;

    // state register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;          // initial state
            prev_state <= IDLE;             // initial previous state
        end else begin
            prev_state <= current_state;    // update previous state
            current_state <= next_state;    // update state
        end
    end

    // state transition logic
    always @(*) begin
        case (current_state)
            IDLE: next_state = start ? CALCULATE : IDLE;
            CALCULATE: next_state = (shared_idx == SHARED_DIM - 1) ? DELAY : CALCULATE;
            DELAY: next_state = (prop_delay_counter == 1) ? IDLE : DELAY;
            default: next_state = IDLE;
        endcase
    end

    // enable logic
    always @(*) begin
        enable = (current_state == CALCULATE || current_state == DELAY);
    end

    // counter logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            shared_idx <= 0;
            prop_delay_counter <= 0;
        end else begin
            case (current_state)
                CALCULATE: shared_idx <= (shared_idx == SHARED_DIM - 1) ? 0 : shared_idx + 1;
                DELAY: prop_delay_counter <= (prop_delay_counter == 1) ? 0 : prop_delay_counter + 1;
                default: begin
                    shared_idx <= 0;
                    prop_delay_counter <= 0;
                end
            endcase
        end
    end

    // output logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            result_vector <= 0;
        end else if (current_state == DELAY && next_state == IDLE) begin
            result_vector <= out;
        end
    end

    // done signal logic
    assign done = (prev_state == DELAY && current_state == IDLE);

endmodule