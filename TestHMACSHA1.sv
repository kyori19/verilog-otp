module TestHMACSHA1;
    wire         clk;
    reg          reset;
    reg  [511:0] message;
    reg  [511:0] key;
    wire [159:0] hash;
    wire         done;

    function [159:0] GetExpected(
        input string string_message,
        input string string_key
    );
        int         fd;
        bit [159:0] out;

        $system($sformatf("echo -n \"%s\" | openssl sha1 -hmac \"%s\" -binary -out /tmp/hash", string_message, string_key));
        fd = $fopen("/tmp/hash", "r");
        $fgets(out, fd);
        $fclose(fd);

        GetExpected = out;
    endfunction

    task GetActual(
        input string string_message,
        input string string_key
    );
        int bits;

        begin
            bits = string_message.len() * 8;
            message = string_message;
            message = message << 512 - bits;
            message[512 - bits - 1] = 1'b 1;
            message[63:0] = 512 + bits;
            key = string_key;
            key = key << 512 - string_key.len() * 8;

            reset = 1;

            forever begin
                #50;
                if (!done) begin
                    break;
                end
            end

            reset = 0;

            forever begin
                #50;
                if (done) begin
                    break;
                end
            end
        end
    endtask

    task TestHash(
        input string string_message,
        input string string_key
    );
        bit [159:0] expected;

        begin
            $display("TestHash: %s (key: %s)", string_message, string_key);

            expected = GetExpected(string_message, string_key);
            GetActual(string_message, string_key);

            $display("expected: %x, actual: %x", expected, hash);
            if (expected != hash) begin
                $display("!!! Assertion Failed !!!");
            end
        end
    endtask

    GenClock gen_clock (clk);
    HMACSHA1 hmac_sha1 (clk, reset, message, key, hash, done);

    initial begin
        TestHash("a", "b");
        TestHash("example1", "12345");
        TestHash("Hello, world!", "SystemVerilog");
        $finish;
    end
endmodule
