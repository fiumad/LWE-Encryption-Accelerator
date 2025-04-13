`timescale 1ns/1ps

module tb_public_key_cache;

  // Parameters for simulation (adjust as needed)
  localparam DATA_WIDTH = 16;
  localparam NUM_ROWS   = 8; // For simulation; actual design may use 768 or 1024
  localparam NUM_COLS   = 4;

  // Inputs to DUT
  logic                           clk;
  logic                           rst;
  logic           [1:0]           mode;         // 0,1,3 etc.
  logic           [2:0]           kyber_k;      // Must be 3 or 4
  logic                           encryption_req;
  logic [NUM_COLS*DATA_WIDTH-1:0] row_in;
  logic [15:0]                    sum_in;

  // Outputs from DUT
  logic [NUM_COLS*DATA_WIDTH-1:0] row_out;
  logic [15:0]                    sum_out;
  logic                           cache_full;

  // Instantiate the DUT (public key cache)
  public_key_cache #(
      .DATA_WIDTH(DATA_WIDTH),
      .NUM_ROWS(NUM_ROWS),
      .NUM_COLS(NUM_COLS)
  ) dut (
      .clk(clk),
      .rst(rst),
      .mode(mode),
      .kyber_k(kyber_k),
      .encryption_req(encryption_req),
      .row_in(row_in),
      .sum_in(sum_in),
      .row_out(row_out),
      .sum_out(sum_out),
      .cache_full(cache_full)
  );

  // Clock generation: 10ns period (toggle every 5ns)
  initial clk = 0;
  always #5 clk = ~clk;

  // Testbench procedure.
  initial begin
      integer i, j;
      // Dump waveform for debugging.
      $dumpfile("public_key_cache.vcd");
      $dumpvars(0, tb_public_key_cache);

      // Initialize signals.
      rst = 1;
      mode = 2'b00;
      kyber_k = 3;        // Start with 3 columns mode.
      encryption_req = 0;
      row_in = '0;
      
      // Hold reset for 20ns.
      #20;
      rst = 0;

      // -------------------------------------------------------
      // Write Phase: mode = 0 writes one row per clock cycle.
      // -------------------------------------------------------
      $display("---------- Write Phase (mode=0) ----------");
      mode = 2'b00;   // Write mode.
      // Write NUM_ROWS rows.
      for (i = 0; i < NUM_ROWS; i = i + 1) begin
          // Construct a test pattern for each row:
          // For example: row_in = {col3, col2, col1, col0}
          // Each column gets an 8-bit value based on the loop variable.
          row_in = { 8'(i+3), 8'(i+2), 8'(i+1), 8'(i) };
          row_in = row_in + 64'hffffeeee00000000;
          sum_in = 16'(i);
          @(posedge clk);
          $display("Writing row %0d: row_in = %h", i, row_in);
          $display("Writing sum %0d: sum_in = %h", i, sum_in);
      end
      
      // Allow one extra cycle.
      @(posedge clk);
      $display("Write Phase Complete. cache_full = %b", cache_full);

      // -------------------------------------------------------
      // Read Phase with kyber_k = 3: read one row per clock cycle.
      // -------------------------------------------------------
      $display("---------- Read Phase (mode=1, kyber_k = 3) ----------");
      mode = 2'b01;  // Read mode.
      kyber_k = 3;
      encryption_req = 1;
      // Reset read pointer is assumed to be handled internally via reset.
      // For testing, you might reassert reset if required (depending on your design).
      for (j = 0; j < NUM_ROWS; j = j + 1) begin
          @(posedge clk);
          $display("Read row %0d: row_out = %h", j, row_out);
          $display("Read sum %0d: sum = %h", j, sum_out);
      end

      // -------------------------------------------------------
      // Read Phase with kyber_k = 4: full 4-column output.
      // -------------------------------------------------------
      $display("---------- Read Phase (mode=1, kyber_k = 4) ----------");
      // Reinitialize the DUT so that the read pointer starts at 0.
      rst = 1;
      @(posedge clk);
      rst = 0;
      // Write new test rows to the cache.
      mode = 2'b00; // Write mode.
      for (i = 0; i < NUM_ROWS; i = i + 1) begin
          row_in = { 8'(i+3), 8'(i+2), 8'(i+1), 8'(i) };
          row_in = row_in + 64'hffffeeee00000000;
          sum_in = 16'(i);
          @(posedge clk);
          $display("Writing row %0d: row_in = %h", i, row_in);
          $display("Writing sum %0d: sum_in = %h", i, sum_in);
      end
      @(posedge clk);
      $display("Write Phase Complete (for kyber_k = 4). cache_full = %b", cache_full);

      // Switch to read mode.
      mode = 2'b01;  // Read mode.
      kyber_k = 4;   // Use all four columns.
      encryption_req = 1;
      for (j = 0; j < NUM_ROWS; j = j + 1) begin
          @(posedge clk);
          $display("Read row %0d: row_out = %h", j, row_out);
          $display("Read sum %0d: sum = %h", j, sum_out);
      end

      $finish;
  end

endmodule
