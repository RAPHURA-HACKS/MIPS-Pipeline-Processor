`timescale 1ns / 1ns

module ALUControl (
    input      [2:0] alu_op,
    input      [5:0] funct,
    output reg [3:0] alu_control
);
    always @(*) begin
        case (alu_op)
            3'b000: alu_control = 4'b0010; // ADD (LW/SW/ADDI)
            3'b001: alu_control = 4'b0110; // SUB (BEQ)
            3'b010: begin // Tipo R
                case (funct)
                    6'b100000: alu_control = 4'b0010; // ADD
                    6'b100010: alu_control = 4'b0110; // SUB
                    6'b100100: alu_control = 4'b0000; // AND
                    6'b100101: alu_control = 4'b0001; // OR
                    6'b101010: alu_control = 4'b0111; // SLT
                    default:   alu_control = 4'b0000;
                endcase
            end
            3'b011: alu_control = 4'b0000; // ANDI
            3'b100: alu_control = 4'b0001; // ORI
            3'b101: alu_control = 4'b0011; // XORI
            3'b110: alu_control = 4'b0111; // SLTI
            default: alu_control = 4'b0000;
        endcase
    end
endmodule
