module public_key_cache #(
    parameter integer DATA_WIDTH = 12,
    parameter integer NUM_ROWS   = 1024,     // Change to 1024 for larger cache
    parameter integer NUM_COLS   = 4        // The cache always holds 4 columns, but effective columns depend on kyber_k
) (
    input  logic                           clk,
    input  logic                           rst,
    input  logic       [1:0]               mode,         // Modes: 0 or 3 → write; 1 → read
    input  logic       [2:0]               kyber_k,      // Should be either 3 or 4
    input  logic                           encryption_req, // For read mode: when asserted, read one row per clock cycle
    input  logic [NUM_COLS*DATA_WIDTH-1:0] row_in,       // Data to be stored on a write (all four columns are present)
    input  logic [15:0]                    sum_in,
    output logic [NUM_COLS*DATA_WIDTH-1:0] row_out,      // Data read from the cache (output is adjusted for kyber_k)
    output logic [15:0]                    sum_out,
    output logic                           cache_full    // Flag that indicates when the cache is full (write pointer reached end)
);

  //--------------------------------------------------------------------------
  // Memory Array: Each entry holds one row (i.e. 4 columns)
  //--------------------------------------------------------------------------
  logic [NUM_COLS*DATA_WIDTH-1:0] cache [0:NUM_ROWS-1];
  logic [15:0] sums [0:NUM_ROWS-1];
  //--------------------------------------------------------------------------
  // Write Pointer and Write Process
  //--------------------------------------------------------------------------
  logic [$clog2(NUM_ROWS)-1:0] wr_ptr;

  // Write mode: mode 0 or mode 3.
  wire write_enable = (mode == 2'd0) || (mode == 2'd3);

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      wr_ptr     <= '0;
      cache_full <= 1'b0;
    end else if (write_enable) begin
      // During write mode, store the input row.
      // If kyber_k is 3, only the lower 3 columns are relevant;
      // however, we store the full 4-column bus. The consumer may use only the valid part.
      cache[wr_ptr] <= row_in;
      sums[wr_ptr] <= sum_in;

      wr_ptr        <= wr_ptr + 1;
      // Set cache_full when we have written the last row.
      if (wr_ptr == NUM_ROWS - 1)
        cache_full <= 1'b1;
      else
        cache_full <= 1'b0;
    end
  end

  //--------------------------------------------------------------------------
  // Read Pointer and Read Process
  //--------------------------------------------------------------------------
  logic [$clog2(NUM_ROWS)-1:0] rd_ptr;

  // Read mode: mode 1.
  wire read_enable = (mode == 2'd1);

  // On reset, clear the read pointer and row_out.
  // In read mode (when encryption_req is true) output one row per clock cycle.
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      rd_ptr  <= '0;
      row_out <= '0;
    end else if (read_enable && encryption_req) begin
      // If kyber_k == 3, output the lower 3 columns and pad the upper DATA_WIDTH bits with zeros.
      if (kyber_k == 3) begin
        row_out <= { {DATA_WIDTH{1'b0}}, cache[rd_ptr][3*DATA_WIDTH-1:0] };
        sum_out <= sums[rd_ptr];
      end
      else begin
        row_out <= cache[rd_ptr];
        sum_out <= sums[rd_ptr];
      end
      rd_ptr <= rd_ptr + 1;
    end
  end

endmodule

