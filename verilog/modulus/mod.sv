module novel_mod_operator #(
    parameter N = 32
) (
    input  logic              clk,
    input  logic              rst,      // Active-high synchronous reset
    input  logic              start,    // Start the modulus operation
    input  logic [N-1:0]      A,        // Dividend
    input  logic [N-1:0]      B,        // Divisor
    output logic [N-1:0]      result,   // Remainder (A mod B)
    output logic              done      // Pulses high when operation is finished
);

    // Define the FSM states as an enum
    typedef enum logic [1:0] {
        IDLE,      // Waiting for start signal
        ALIGN,     // Align the divisor with the dividend by left shifts
        SUBTRACT,  // Iteratively subtract and shift the divisor right
        FINISH     // Latch the result and assert 'done'
    } state_t;

    state_t state, next_state;

    // Internal registers for the algorithm
    logic [N-1:0] dividend, next_dividend;
    logic [N-1:0] divisor,  next_divisor;
    // A counter to keep track of how many shifts have been performed.
    // Width: enough bits to count up to N.
    logic [$clog2(N+1)-1:0] shift, next_shift;

    // FSM state update and registers update
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            dividend  <= '0;
            divisor   <= '0;
            shift     <= '0;
            result    <= '0;
            done      <= 1'b0;
        end else begin
            state     <= next_state;
            dividend  <= next_dividend;
            divisor   <= next_divisor;
            shift     <= next_shift;
            // In FINISH state, latch the result and assert done for one cycle.
            if (state == FINISH) begin
                result <= dividend;
                done   <= 1'b1;
            end else begin
                done   <= 1'b0;
            end
        end
    end

    // Combinational next-state and datapath logic
    always_comb begin
        // Default assignments: hold current values.
        next_state     = state;
        next_dividend  = dividend;
        next_divisor   = divisor;
        next_shift     = shift;
        
        case (state)
            IDLE: begin
                if (start) begin
                    // Initialize the algorithm with inputs
                    next_dividend = A;
                    next_divisor  = B;
                    next_shift    = '0;
                    next_state    = ALIGN;
                end
            end

            ALIGN: begin
                // In the ALIGN state, left-shift divisor until either
                //   (i) divisor > dividend, or
                //   (ii) the MSB of divisor becomes 1, or
                //   (iii) shift count reaches N.
                // Condition: if divisor ≤ dividend, the MSB of divisor is 0,
                // and shift count < N, then keep shifting.
                //if ((divisor <= dividend) && ((divisor & (1 << (N-1))) == 0) && (shift < N)) begin
                if (((divisor << 1) <= dividend) && ((divisor & (1 << (N-1))) == 0) && (shift < N)) begin
                    next_divisor = divisor << 1;
                    next_shift   = shift + 1;
                    next_state   = ALIGN;
                end else begin
                    next_state   = SUBTRACT;
                end
            end


            SUBTRACT: begin : SUBTRACT_BLOCK
                // If we have reached the last bit position (shift == 0),
                // perform the final subtraction (if dividend >= divisor) and finish.
                if (shift == 0) begin
                    if (dividend >= divisor)
                        next_dividend = dividend - divisor;
                    else
                        next_dividend = dividend;
                    // Keep divisor and shift unchanged (they’re no longer used).
                    next_divisor  = divisor;
                    next_shift    = shift;
                    next_state    = FINISH;
                end else begin
                    // Normal subtract-and-shift operation:
                    logic [N-1:0] new_dividend;
                    logic [N-1:0] new_divisor;
                    logic [$clog2(N+1)-1:0] new_shift;
                    
                    // Subtract if possible.
                    if (dividend >= divisor)
                        new_dividend = dividend - divisor;
                    else
                        new_dividend = dividend;
                    
                    // Right-shift the divisor and decrement the shift counter.
                    new_divisor = divisor >> 1;
                    new_shift   = shift - 1;
                    
                    next_dividend = new_dividend;
                    next_divisor  = new_divisor;
                    next_shift    = new_shift;
                    
                    // Always continue the subtraction phase until we reach the last bit.
                    next_state = SUBTRACT;
                end
            end

            FINISH: begin
                // In FINISH state, result is latched and done is asserted.
                // On the next clock the state will revert to IDLE.
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

endmodule

