// matrix vector multiplier
module mvm #(
    parameter MATRIX_ROWS = 6,      // determines the number of ROWS in the matrix
    parameter SHARED_DIM = 3,       // determines the number of columns in the matrix and rows in the vector
    parameter WIDTH = 8             // determines the width of data inside the matrix and the vector
) (
    input wire clk, reset, start,
    input wire [MATRIX_ROWS * SHARED_DIM * WIDTH - 1:0] matrix,
    input wire [SHARED_DIM * WIDTH - 1:0] vector,
    output reg [MATRIX_ROWS * SHARED_DIM * WIDTH - 1:0] result_vector
);

    wire [SHARED_DIM  * WIDTH - 1:0] a, out;
    wire [WIDTH - 1:0] b;

    reg [SHARED_DIM - 1:0] shared_idx;          // keeps track of current column in the matrix and current row in the vector

    // slices the matrix and vector to get the current values for the vector scalar multiplier
    genvar i;
    generate
        for (i = 0; i < MATRIX_ROWS; i = i + 1) begin : a_b_slice_loop                                                                // a and b are current values for the vector scalar multiplier
            assign a = matrix[(((MATRIX_ROWS - shared_idx) * WIDTH) - 1) - (i * WIDTH) -: WIDTH];
            assign b = vector[WIDTH * (SHARED_DIM - shared_idx) - 1 -: WIDTH];
        end
    endgenerate

    wire vsmac_done;                        // done signal from the vector scalar multiplier

    // vector scalar multiplier with proper parameters
    vsmac #(
        .SIZE(MATRIX_ROWS),
        .WIDTH(WIDTH),
        .ACCUMULATIONS(SHARED_DIM)
    ) vsm (
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .out(out),
        .done(vsmac_done)
    );

    // define states for state machine
    parameter IDLE = 2'b00;
    parameter CALCULATE = 2'b01;
    parameter DONE = 2'b10;

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
        end else if (current_state == CALCULATE) begin
            shared_idx <= shared_idx + 1;
        end else begin
            shared_idx <= 0;
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
                    next_state = DONE;
                else
                    next_state = CALCULATE;
            end
            DONE: begin
                if (vsmac_done)
                    next_state = IDLE;
                else
                    next_state = DONE;
            end
            default: next_state = IDLE;
        endcase
    end

    // // output logic
    // always @(*) begin
    //     case (current_state)
    //         IDLE: begin
    //             done = 0;
    //         end
    //         CALCULATE: begin
    //             done = 0;
    //         end
    //         DONE: begin
    //             done = 1;
    //             // handle output
    //         end
    //         default: 
    //     endcase
    // end

endmodule