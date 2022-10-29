/**
 * Implementation of HMAC-SHA1
 *
 * [RFC-2104] Keyed-Hashing for Message Authentication
 * https://www.ietf.org/rfc/rfc2104.txt
 */
module HMACSHA1(
    input  wire         clk,
    input  wire         reset,
    input  wire [511:0] input_message,
    input  wire [511:0] key,
    output wire [159:0] hash,
    output wire         done
);
    reg [  2:0] stage;
    reg [511:0] message;

    wire          in_feed;
    wire         out_feed;
    wire [511:0]  in_message;
    wire [511:0] out_message;
    wire [159:0]  in_hash;
    wire          in_done;
    wire         out_done;

    assign done        = stage == 6;

    assign in_feed     = stage == 0 || stage == 2;
    assign out_feed    = stage == 0 || stage == 4;
    assign in_message  = stage == 0 ? key ^ {64{8'h 36}} : message;
    assign out_message = stage == 0 ? key ^ {64{8'h 5c}} : {in_hash, 1'b 1, 287'd 0, 64' (512 + 160)};

    SHA1 sha1_in  (clk, reset,  in_feed,  in_message, in_hash,  in_done);
    SHA1 sha1_out (clk, reset, out_feed, out_message,    hash, out_done);

    always @(posedge clk) begin
        if (reset) begin
            stage   <= 0;
            message <= input_message;
        end else begin
            case (stage)
                0: if (in_done == 0 && out_done == 0) begin
                    stage <= 1;
                end

                1: if (in_done == 1) begin
                    stage <= 2;
                end

                2: if (in_done == 0) begin
                    stage <= 3;
                end

                3: if (in_done == 1 && out_done == 1) begin
                    stage <= 4;
                end

                4: if (out_done == 0) begin
                    stage <= 5;
                end

                5: if (out_done == 1) begin
                    stage <= 6;
                end
            endcase
        end
    end
endmodule
