`timescale 1ns / 1ns

module burrote (
    input               clk, rst, we,         
    input       [4:0]   addr_r1, addr_r2, addr_w,
    input       [31:0]  data_w,

    output      [31:0]  data_r1, data_r2
);
    reg [31:0] register_file[31:0];
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) register_file[i] <= 32'd0;
        end 
        else if (we && (addr_w != 5'd0)) begin
            register_file[addr_w] <= data_w;
        end
    end

    assign data_r1 = register_file[addr_r1];
    assign data_r2 = register_file[addr_r2];
endmodule
