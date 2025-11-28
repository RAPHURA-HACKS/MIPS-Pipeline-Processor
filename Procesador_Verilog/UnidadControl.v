`timescale 1ns / 1ns

module UnidadControl (
    input  [5:0] opcode,
    output reg   reg_dst, jump, branch, mem_read, mem_to_reg, 
                 mem_write, alu_src, reg_write,
    output reg [2:0] alu_op
);
    always @(*) begin
        // Defaults
        reg_dst = 0; jump = 0; branch = 0; mem_read = 0; mem_to_reg = 0;
        alu_op = 3'b000; mem_write = 0; alu_src = 0; reg_write = 0;

        case (opcode)
            // TIPO R
            6'b000000: begin
                reg_dst = 1; reg_write = 1; alu_op = 3'b010;
            end
            // LW
            6'b100011: begin 
                alu_src = 1; mem_read = 1; mem_to_reg = 1; reg_write = 1;
            end
            // SW
            6'b101011: begin 
                alu_src = 1; mem_write = 1;
            end
            // BEQ
            6'b000100: begin 
                branch = 1; alu_op = 3'b001;
            end
            // ADDI
            6'b001000: begin 
                alu_src = 1; reg_write = 1;
            end
            // ANDI
            6'b001100: begin 
                alu_src = 1; reg_write = 1; alu_op = 3'b011;
            end
            // ORI
            6'b001101: begin 
                alu_src = 1; reg_write = 1; alu_op = 3'b100;
            end
            // XORI
            6'b001110: begin 
                alu_src = 1; reg_write = 1; alu_op = 3'b101;
            end
            // SLTI
            6'b001010: begin 
                alu_src = 1; reg_write = 1; alu_op = 3'b110;
            end
            // J
            6'b000010: begin 
                jump = 1;
            end
            default: begin end
        endcase
    end
endmodule