`timescale 1ns / 1ns

module mux_rt_rd (
    input       [4:0]   in_rt, in_rd,
    input               sel,
    output      [4:0]   out_aw
);
    assign out_aw = (sel == 1'b0) ? in_rt : in_rd;
endmodule

module mux_dr2_imm  (
    input       [31:0]  in_dr2, in_imm,
    input               sel,
    output      [31:0]  out_alu_src 
);
    assign out_alu_src = (sel == 1'b0) ? in_dr2 : in_imm;
endmodule
