`timescale 1ns / 1ns

module tb_quesadilla_decode;
    reg clk;
    reg rst;

    quesadilla_decode DUT (
        .clk(clk),
        .rst(rst)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        #15;
        rst = 0;
        #200;
        $stop;
    end
endmodule
