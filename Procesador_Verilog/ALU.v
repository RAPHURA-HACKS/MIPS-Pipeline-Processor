`timescale 1ns / 1ns

module ALU (
    input      [31:0] A, B,
    input      [3:0]  alu_control,
    output reg [31:0] Result,
    output            Zero
);
    always @(*) begin
        case (alu_control)
            4'b0000: Result = A & B;
            4'b0001: Result = A | B;
            4'b0010: Result = A + B;
            4'b0011: Result = A ^ B;
            4'b0110: Result = A - B;
            4'b0111: Result = (A < B) ? 32'd1 : 32'd0;
            4'b1100: Result = ~(A | B);
            default: Result = 32'd0;
        endcase
    end
    assign Zero = (Result == 32'd0) ? 1'b1 : 1'b0;
endmodule
