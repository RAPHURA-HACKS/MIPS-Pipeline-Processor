`timescale 1ns / 1ns

module burrote (
    // Entradas
    input               clk,        // Reloj
    input               rst,        // Reset 
    input               we,         // Write Enable 
    input       [4:0]   addr_r1,    // RS
    input       [4:0]   addr_r2,    // RT
    input       [4:0]   addr_w,     // AW
    input       [31:0]  data_w,     // DataW

    // Salidas
    output      [31:0]  data_r1,    // DR1
    output      [31:0]  data_r2     // DR2
);

    reg [31:0] register_file[31:0];
    
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                register_file[i] <= 32'd0;
            end
        end 
        else if (we && (addr_w != 5'd0)) begin
            register_file[addr_w] <= data_w;
        end
    end

    assign data_r1 = register_file[addr_r1];
    assign data_r2 = register_file[addr_r2];

endmodule
