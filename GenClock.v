module GenClock(
    output reg clk = 'b 0
);
    always begin
        #50 clk = ~clk;
    end
endmodule
