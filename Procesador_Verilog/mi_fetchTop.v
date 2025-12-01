`timescale 1ns / 1ns

module quesadilla (
    input               clk, rst,
    output      [31:0]  inst_out, pc_p4_out
);
    reg [31:0] pc;
    always @(posedge clk or posedge rst) begin
        if (rst) pc <= 32'd0;
        else     pc <= pc + 32'd4;
    end

    reg [31:0] instruction_memory [0:31];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1) instruction_memory[i] = 32'h00000000;

        // PROGRAMA FINAL (ADDI, SW, LW, ADD)
        instruction_memory[0] = 32'h200A0005; // ADDI $10, $0, 5
        instruction_memory[1] = 32'h00000000; // NOP
        instruction_memory[2] = 32'h00000000; // NOP
        instruction_memory[3] = 32'h00000000;
        instruction_memory[4] = 32'hAC0A0014; // SW $10, 20($0)
        instruction_memory[5] = 32'h00000000; // NOP
        instruction_memory[6] = 32'h00000000; // NOP
        instruction_memory[7] = 32'h8C0B0014; // LW $11, 20($0)
        instruction_memory[8] = 32'h00000000; // NOP
        instruction_memory[9] = 32'h00000000; // NOP
        instruction_memory[10] = 32'h00000000; // NOP
        instruction_memory[11] = 32'h014B6020; // ADD $12, $10, $11
    end

    assign inst_out = instruction_memory[pc[31:2]]; 
    assign pc_p4_out = pc + 32'd4;
endmodule

module quesadilla_decode (
    input clk, rst
);

    // FETCH
    wire [31:0] w_inst_fetch, w_pc_p4_fetch;
    wire [31:0] w_inst_decode, w_pc_p4_decode;

    // DECODE
    wire [31:0] w_data_r1, w_data_r2;
    wire [31:0] w_imm_extendido = {{16{w_inst_decode[15]}}, w_inst_decode[15:0]};

    // Control ID
    wire w_reg_dst, w_jump, w_branch, w_mem_read, w_mem_to_reg, w_mem_write, w_alu_src, w_reg_write;
    wire [2:0] w_alu_op;

    // EX
    wire [31:0] w_pc_p4_exec, w_dr1_exec, w_dr2_raw_exec, w_imm_exec;
    wire [4:0]  w_addr_rt_exec, w_addr_rd_exec;
    wire [5:0]  w_funct_exec;             
    wire [31:0] w_alu_operand_b;

    wire w_reg_dst_ex, w_alu_src_ex, w_branch_ex, w_mem_read_ex, w_mem_write_ex, w_reg_write_ex, w_mem_to_reg_ex;
    wire [2:0] w_alu_op_ex;

    wire [3:0]  w_alu_control_sig;
    wire [31:0] w_alu_result;
    wire w_zero;

    // DESTINO
    wire [4:0] w_dest_reg_final;

    // MEM
    wire [31:0] w_alu_result_mem, w_write_data_mem;
    wire [4:0]  w_dest_reg_mem;
    wire w_mem_read_mem, w_mem_write_mem, w_reg_write_mem, w_mem_to_reg_mem;
    wire [31:0] w_mem_read_data;

    // WB
    wire [31:0] w_mem_data_wb, w_alu_result_wb, w_wb_data;
    wire [4:0]  w_dest_reg_wb;
    wire w_reg_write_wb, w_mem_to_reg_wb;

    // INSTANCIAS
    quesadilla U_Q (
        .clk(clk), .rst(rst),
        .inst_out(w_inst_fetch), .pc_p4_out(w_pc_p4_fetch)
    );

    buffer_CFE U_IF_ID (
        .clk(clk), .rst(rst),
        .inst_in(w_inst_fetch), .pc_p4_in(w_pc_p4_fetch),
        .inst_out(w_inst_decode), .pc_p4_out(w_pc_p4_decode)
    );

    UnidadControl U_CTRL (
        .opcode(w_inst_decode[31:26]),
        .reg_dst(w_reg_dst), .jump(w_jump), .branch(w_branch),
        .mem_read(w_mem_read), .mem_to_reg(w_mem_to_reg), .alu_op(w_alu_op),
        .mem_write(w_mem_write), .alu_src(w_alu_src), .reg_write(w_reg_write)
    );

    burrote U_RF (
        .clk(clk), .rst(rst),
        .we(w_reg_write_wb),
        .addr_r1(w_inst_decode[25:21]),
        .addr_r2(w_inst_decode[20:16]),
        .addr_w(w_dest_reg_wb),
        .data_w(w_wb_data),
        .data_r1(w_data_r1), .data_r2(w_data_r2)
    );

    buffer_DEX U_ID_EX (
        .clk(clk), .rst(rst),
        .pc_p4_in(w_pc_p4_decode),
        .dr1_in(w_data_r1),
        .dr2_mux_in(w_data_r2),
        .imm_in(w_imm_extendido),
        .addr_rt_in(w_inst_decode[20:16]),
        .addr_rd_in(w_inst_decode[15:11]),
        .funct_in(w_inst_decode[5:0]),        

        .i_reg_dst(w_reg_dst), .i_alu_op(w_alu_op), .i_alu_src(w_alu_src),
        .i_branch(w_branch), .i_mem_read(w_mem_read), .i_mem_write(w_mem_write),
        .i_reg_write(w_reg_write), .i_mem_to_reg(w_mem_to_reg),

        .pc_p4_out(w_pc_p4_exec),
        .dr1_out(w_dr1_exec),
        .dr2_mux_out(w_dr2_raw_exec),
        .imm_out(w_imm_exec),
        .addr_rt_out(w_addr_rt_exec),
        .addr_rd_out(w_addr_rd_exec),
        .funct_out(w_funct_exec),             

        .o_reg_dst(w_reg_dst_ex), .o_alu_op(w_alu_op_ex),
        .o_alu_src(w_alu_src_ex), .o_branch(w_branch_ex),
        .o_mem_read(w_mem_read_ex), .o_mem_write(w_mem_write_ex),
        .o_reg_write(w_reg_write_ex), .o_mem_to_reg(w_mem_to_reg_ex)
    );

    mux_dr2_imm U_MUX_ALUSRC (
        .in_dr2(w_dr2_raw_exec),
        .in_imm(w_imm_exec),
        .sel(w_alu_src_ex),
        .out_alu_src(w_alu_operand_b)
    );

    ALUControl U_ALUCTRL (
        .alu_op(w_alu_op_ex),
        .funct(w_funct_exec),        
        .alu_control(w_alu_control_sig)
    );

    ALU U_ALU (
        .A(w_dr1_exec),
        .B(w_alu_operand_b),
        .alu_control(w_alu_control_sig),
        .Result(w_alu_result),
        .Zero(w_zero)
    );

    assign w_dest_reg_final = (w_reg_dst_ex == 0) ? w_addr_rt_exec : w_addr_rd_exec;

    buffer_EM U_EX_MEM (
        .clk(clk), .rst(rst),
        .i_mem_read(w_mem_read_ex), .i_mem_write(w_mem_write_ex),
        .i_reg_write(w_reg_write_ex), .i_mem_to_reg(w_mem_to_reg_ex),
        .i_alu_result(w_alu_result),
        .i_write_data(w_dr2_raw_exec),
        .i_addr_dest(w_dest_reg_final),

        .o_mem_read(w_mem_read_mem), .o_mem_write(w_mem_write_mem),
        .o_reg_write(w_reg_write_mem), .o_mem_to_reg(w_mem_to_reg_mem),
        .o_alu_result(w_alu_result_mem),
        .o_write_data(w_write_data_mem),
        .o_addr_dest(w_dest_reg_mem)
    );

    DataMemory U_DM (
        .clk(clk),
        .Address(w_alu_result_mem),
        .WriteData(w_write_data_mem),
        .MemRead(w_mem_read_mem),
        .MemWrite(w_mem_write_mem),
        .ReadData(w_mem_read_data)
    );

    buffer_MW U_MEM_WB (
        .clk(clk), .rst(rst),
        .i_reg_write(w_reg_write_mem),
        .i_mem_to_reg(w_mem_to_reg_mem),
        .i_mem_data(w_mem_read_data),
        .i_alu_result(w_alu_result_mem),
        .i_addr_dest(w_dest_reg_mem),

        .o_reg_write(w_reg_write_wb),
        .o_mem_to_reg(w_mem_to_reg_wb),
        .o_mem_data(w_mem_data_wb),
        .o_alu_result(w_alu_result_wb),
        .o_addr_dest(w_dest_reg_wb)
    );

    assign w_wb_data = (w_mem_to_reg_wb == 1) ? w_mem_data_wb : w_alu_result_wb;

endmodule
