module tb_crypto_prng;

    logic clk = 0;
    logic rst = 0;
    logic load_key = 0;
    logic [127:0] key = 128'h0123456789abcdef0123456789abcdef;
    logic [255:0] random_word;

    // Instantiate the crypto PRNG
    crypto_prng uut (
        .clk         (clk),
        .rst         (rst),
        .load_key    (load_key),
        .key         (key),
        .random_word (random_word)
    );

    // Clock generation: 10ns period (100MHz clock)
    always #5 clk = ~clk;

    initial begin
        $display("Starting Crypto PRNG Testbench...");
        // Reset the design
        rst = 1;
        #10;
        rst = 0;
        // Load the key
        load_key = 1;
        #10;
        load_key = 0;

        // Run for several cycles to display random words
        repeat (10) begin
            @(posedge clk);
            $display("Random word: %h", random_word);
        end

        $finish;
    end

endmodule
