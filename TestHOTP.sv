module TestHOTP;
    wire         clk;
    reg          reset;
    reg  [511:0] key;
    reg  [ 63:0] counter;
    wire [ 19:0] code;
    wire         done;

    task GetActual(
        input string string_key,
        input [63:0] counter_val
    );
        begin
            counter = counter_val;
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

    task TestCode(
        input string string_key,
        input [63:0] counter_val,
        input [19:0] expected
    );
        begin
            $display("TestCode: key %s, counter: %d", string_key, counter_val);

            GetActual(string_key, counter_val);

            $display("expected: %d, actual: %d", expected, code);
            if (expected != code) begin
                $display("!!! Assertion Failed !!!");
            end
        end
    endtask

    GenClock gen_clock (clk);
    HOTP     hotp      (clk, reset, key, counter, code, done);

    initial begin
        TestCode("Hello, world!", 0, 557396);
        TestCode("Leia", 1234, 35954);
        $finish;
    end
endmodule
