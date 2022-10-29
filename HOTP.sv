/**
 * [RFC-4226] HOTP: An HMAC-Based One-Time Password Algorithm
 * https://www.ietf.org/rfc/rfc4226.txt
 */
module HOTP(
    input  wire         clk,
    input  wire         reset,
    input  wire [511:0] key,
    input  wire [ 63:0] counter,
    output wire [ 19:0] code,
    output wire         done
);
    wire [511:0] message;
    wire [159:0] hash;
    wire [  3:0] offset;
    wire [ 30:0] number;

    assign message = {counter, 1'b 1, 383'd 0, 64' (512 + 64)};
    assign offset  = hash[3:0];
    assign code    = 20' (number % 1000000);

    genvar i;
    generate
        for (i = 0; i < $size(number); i++) begin: AssignNumber
            assign number[i] = hash[(20 - offset - 4) * 8 + i];
        end
    endgenerate

    HMACSHA1 hmac_sha1 (clk, reset, message, key, hash, done);
endmodule
