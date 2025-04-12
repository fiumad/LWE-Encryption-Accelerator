module crypto_prng #(
    parameter KEY_WIDTH = 128  // Change to 256 if using an AES-256 core
) (
    input  logic              clk,
    input  logic              rst,
    input  logic              load_key,    // Signal to load the encryption key
    input  logic [KEY_WIDTH-1:0] key,       // Cryptographic key/seed
    output logic [255:0]      random_word  // 256-bit secure pseudorandom output
);

    // Internal counter (128-bit for AES block)
    logic [127:0] counter;

    // Outputs from AES encryption cores
    logic [127:0] aes_out1;
    logic [127:0] aes_out2;

    // Counter update: On reset, initialize to 0; otherwise, increment by 2 each cycle.
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 128'd0;
        end else begin
            counter <= counter + 128'd2;
        end
    end

    // Instance AES encryption core for lower 128 bits.
    // It encrypts the current counter value.
    aes_encrypt aes_inst1 (
        .clk        (clk),
        .rst        (rst),
        .load_key   (load_key),
        .key        (key),
        .plaintext  (counter),
        .ciphertext (aes_out1)
    );

    // Instance AES encryption core for upper 128 bits.
    // It encrypts the counter value plus 1.
    aes_encrypt aes_inst2 (
        .clk        (clk),
        .rst        (rst),
        .load_key   (load_key),
        .key        (key),
        .plaintext  (counter + 128'd1),
        .ciphertext (aes_out2)
    );

    // Concatenate the two AES outputs to form a 256-bit pseudorandom word
    assign random_word = {aes_out1, aes_out2};

endmodule
