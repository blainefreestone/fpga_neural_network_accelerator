// matrix vector multiplier
module mvm #(
    parameter MATRIX_ROWS = 6,      // determines the number of ROWS in the matrix
    parameter SHARED_DIM = 3,       // determines the number of columns in the matrix and rows in the vector
    parameter WIDTH = 8             // determines the width of data inside the matrix and the vector
) (
    input wire clk, reset, start,
    input wire [MATRIX_ROWS * SHARED_DIM * WIDTH - 1:0] matrix,
    input wire [SHARED_DIM * WIDTH - 1:0] vector,
    output reg [MATRIX_ROWS * SHARED_DIM * WIDTH - 1:0] result_vector,
    output reg done
);

    wire [MATRIX_ROWS  * WIDTH - 1:0] a, out;
    wire [WIDTH - 1:0] b;
    
    reg enable;

    reg [SHARED_DIM - 1:0] shared_idx;          // keeps track of current column in the matrix and current row in the vector
    reg [1:0] prop_delay_counter;                // counter to introduce propagation delay

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
        .ACCUMULATIONS(SHARED_DIM)
    ) vsm (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .a(a),
        .b(b),
        .out(out)
    );

    // define states for state machine
    parameter IDLE = 2'b00;
    parameter CALCULATE = 2'b01;
    parameter DELAY = 2'b10;
    parameter DONE = 2'b11;
    
    reg [1:0] current_state, next_state;

    // state register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;          // initial state
        end else begin
            current_state <= next_state;    // update state
        end
    end

    // counter logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            shared_idx <= 0;
            prop_delay_counter <= 0;
        end else if (current_state == CALCULATE) begin
            if (shared_idx == SHARED_DIM - 1) begin
                shared_idx <= 0;
            end else begin
                shared_idx <= shared_idx + 1;
            end
        end else if(current_state == DELAY) begin
            if (prop_delay_counter == 1) begin
                prop_delay_counter <= 0;
            end else begin
                prop_delay_counter <= prop_delay_counter + 1;
            end
        end else begin
            shared_idx <= 0;
            prop_delay_counter <= 0;
        end
    end

    // state logic
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (start)
                    next_state = CALCULATE;
                else
                    next_state = IDLE;
            end
            CALCULATE: begin
                if (shared_idx == SHARED_DIM - 1)
                    next_state = DELAY;
                else
                    next_state = CALCULATE;
            end
            DELAY: begin
                if (prop_delay_counter == 1)
                    next_state = DONE;
                else
                    next_state = DELAY;
            end
            default: next_state = IDLE;
        endcase
    end

    // enable logic
    always @(*) begin
        case (current_state)
            IDLE: enable = 0;
            CALCULATE: enable = 1;
            DELAY: enable = 1;
            DONE: enable = 0;
            default: enable = 0;
        endcase
    end

    // output logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            result_vector <= 0;
            done <= 0;
        end else begin
            case (current_state)
                IDLE: begin
                    enable <= 0;
                    done <= 0;
                end
                CALCULATE: begin
                    enable <= 1;
                    done <= 0;
                end
                DELAY: begin
                    enable <= 1;
                    done <= 0;
                end
                DONE: begin
                    enable <= 0;
                    done <= 1;
                    result_vector <= out;
                end
            endcase
        end
    end

endmodule