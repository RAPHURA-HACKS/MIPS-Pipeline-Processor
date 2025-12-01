`timescale 1ns / 1ns

module DataMemory (
    input             clk,
    input      [31:0] Address, WriteData,
    input             MemRead, MemWrite,
    output reg [31:0] ReadData
);
    reg [31:0] memory [0:63];
    integer i;

    initial begin
        for (i = 0; i < 64; i = i + 1)
            memory[i] = 32'd0;
        memory[5] = 32'hDEADBEEF;
    end

    always @(*) begin
        if (MemRead)
            ReadData = memory[Address[31:2]];
        else
            ReadData = 32'd0;
    end

    always @(negedge clk) begin
        if (MemWrite)
            memory[Address[31:2]] <= WriteData;
    end
endmodule
