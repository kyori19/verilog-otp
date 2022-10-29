module TestSHA1;
    wire         clk;
    reg          reset;
    reg          feed;
    reg  [511:0] message;
    wire [159:0] hash;
    wire         done;

    function [511:0] PadString(
        input string string_message
    );
        int         bits;
        bit [511:0] out;

        bits = string_message.len() * 8;
        out = string_message;
        out = out << 512 - bits;
        for (int i = 0; i < 512 - bits - 1; i++) begin
            out[i] = 1'b 0;
        end
        out[512 - bits - 1] = 1'b 1;

        PadString = out;
    endfunction

    function [159:0] GetExpected(
        input string string_message
    );
        int         fd;
        bit [159:0] out;

        $system($sformatf("echo -n \"%s\" | openssl sha1 -binary -out /tmp/hash", string_message));
        fd = $fopen("/tmp/hash", "r");
        $fgets(out, fd);
        $fclose(fd);

        GetExpected = out;
    endfunction

    task GetActual(
        input string string_message
    );
        int i;
        int len;

        begin
            len = string_message.len();
            reset = 1;
            feed  = 0;
            #200;
            reset = 0;

            for (i = 0; i - 8 <= len; i += 64) begin
                if (len - i >= 64) begin
                    message = string_message.substr(i, i + 63);
                end else begin
                    message = PadString(string_message.substr(i, len - 1));

                    if (len - i < 56) begin
                        message[63:0] = len * 8;
                    end
                end

                feed = 1;
                #200;
                feed = 0;

                forever begin
                    #50;
                    if (done) begin
                        break;
                    end
                end
            end
        end
    endtask

    task TestHash(
        input string string_message
    );
        bit [159:0] expected;

        begin
            $display("TestHash: %s", string_message);

            expected = GetExpected(string_message);
            GetActual(string_message);

            $display("expected: %x, actual: %x", expected, hash);
            if (expected != hash) begin
                $display("!!! Assertion Failed !!!");
            end
        end
    endtask

    GenClock gen_clock (clk);
    SHA1     sha1      (clk, reset, feed, message, hash, done);

    initial begin
        TestHash("abc");
        TestHash("openssl");
        TestHash("Hello, world!");
        TestHash("01234567012345670123456701234567");
        TestHash("0123456701234567012345670123456701234567012345670123456701234567");
        TestHash("0123456701234567012345670123456701234567012345670123456701234567abc");
        TestHash("01234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567");
        $finish;
    end
endmodule
