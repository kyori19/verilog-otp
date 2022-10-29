/**
 * [RFC-3174] US Secure Hash Algorithm 1 (SHA1)
 * https://www.ietf.org/rfc/rfc3174.txt
 */
module SHA1(
    input  wire         clk,
    input  wire         reset,
    input  wire         feed,
    input  wire [511:0] message,
    output wire [159:0] hash,
    output wire         done
);
    reg  [31:0] word   [16];
    reg  [31:0] result [ 5];
    reg  [31:0] buffer [ 5];
    reg  [ 6:0] iter;
    wire [ 6:0] prev_iter;
    wire [ 3:0] base;
    wire [ 3:0] prev_base;

    assign hash      = { result[0], result[1], result[2], result[3], result[4] };
    assign prev_iter = 7' (iter - 1);
    assign base      = iter[3:0];
    assign prev_base = prev_iter[3:0];
    assign done      = iter == 82;

    function [31:0] CircularShift(
        input [31:0] in,
        input  [4:0] n
    );
        CircularShift = (in << n) | (in >> (32 - n));
    endfunction

    function [31:0] LogicalFunction(
        input [ 6:0] t,
        input [31:0] B,
        input [31:0] C,
        input [31:0] D
    );
        if (t <= 19) begin
            LogicalFunction = (B & C) | (~B & D);
        end else if (t <= 39) begin
            LogicalFunction = B ^ C ^ D;
        end else if (t <= 59) begin
            LogicalFunction = (B & C) | (B & D) | (C & D);
        end else begin
            LogicalFunction = B ^ C ^ D;
        end
    endfunction

    function [31:0] ConstK(
        input [6:0] t
    );
        if (t <= 19) begin
            ConstK = 'h 5a827999;
        end else if (t <= 39) begin
            ConstK = 'h 6ed9eba1;
        end else if (t <= 59) begin
            ConstK = 'h 8f1bbcdc;
        end else begin
            ConstK = 'h ca62c1d6;
        end
    endfunction

    always @(posedge clk) begin
        if (reset) begin
            iter <= 82;

            result[0] <= 'h 67452301;
            result[1] <= 'h efcdab89;
            result[2] <= 'h 98badcfe;
            result[3] <= 'h 10325476;
            result[4] <= 'h c3d2e1f0;
        end else if (done && feed) begin
            iter   <= 0;
            buffer <= result;

            for (int i = 0; i < $size(word); i++) begin
                for (int j = 0; j < 32; j++) begin
                    word[i][j] <= message[(16 - i) * 32 - (32 - j)];
                end
            end
        end else begin
            if (16 <= iter && iter <= 79) begin
                word[base] <= CircularShift(word[4' (base + 13)] ^ word[4' (base + 8)] ^ word[4' (base + 2)] ^ word[base], 1);
            end

            if (1 <= iter && iter <= 80) begin
                buffer[0] <= CircularShift(buffer[0], 5)
                           + LogicalFunction(prev_iter, buffer[1], buffer[2], buffer[3])
                           + buffer[4]
                           + word[prev_base]
                           + ConstK(prev_iter);
                buffer[1] <= buffer[0];
                buffer[2] <= CircularShift(buffer[1], 30);
                buffer[3] <= buffer[2];
                buffer[4] <= buffer[3];
            end

            if (iter == 81) begin
                for (int i = 0; i < $size(result); i++) begin
                    result[i] <= result[i] + buffer[i];
                end
            end

            if (iter < 82) begin
                iter <= 7' (iter + 1);
            end
        end
    end
endmodule
