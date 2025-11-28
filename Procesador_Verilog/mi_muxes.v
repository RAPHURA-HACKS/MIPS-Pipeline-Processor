`timescale 1ns / 1ns

//--- MUX 1: Decide la dirección de escritura (rt o rd) ---
module mux_rt_rd (
    // Entradas
    input       [4:0]   in_rt,      // Entrada de AR2
    input       [4:0]   in_rd,      // Entrada de AR3
    input               sel,        // Señal de selección

    // Salida
    output      [4:0]   out_aw      // Corregí la declaración a una sola línea
);

    // Lógica del multiplexor
    assign out_aw = (sel == 1'b0) ? in_rt : in_rd;

endmodule


//--- MUX 2: Decide la 2da fuente de la ALU (dr2 o imm) ---
module mux_dr2_imm  (
    // Entradas
    input       [31:0]  in_dr2,     // Dato del registro rt
    input       [31:0]  in_imm,     // Dato inmediato extendido
    input               sel,        // Señal de selección

    // Salida
    output      [31:0]  out_alu_src // hacia DEX
);

    // Lógica del multiplexor
    assign out_alu_src = (sel == 1'b0) ? in_dr2 : in_imm;

endmodule