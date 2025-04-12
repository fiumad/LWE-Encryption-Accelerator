module aes_encrypt (
    input  logic              clk,
    input  logic              rst,
    input  logic              load_key,    // Loads key into internal registers
    input  logic [127:0]      key,         // AES key input (change width for AES-256)
    input  logic [127:0]      plaintext,   // 128-bit plaintext input
    output logic [127:0]      ciphertext   // 128-bit ciphertext output
);
    
    logic [127:0] stored_key;

    // For simulation purposes only, we pass the plaintext directly.
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            ciphertext <= 128'd0;
            stored_key <= 128'd0;
        end else if (load_key) begin
            stored_key <= key;
        end else begin
            // A dummy encryption behavior (NOT SECURE) for simulation.
            ciphertext <= plaintext ^ stored_key; 
            stored_key <= stored_key + stored_key;
        end
    end

endmodule

