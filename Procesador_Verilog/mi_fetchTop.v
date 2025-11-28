`timescale 1ns / 1ns

module quesadilla (
    input               clk,
    input               rst,
    output      [31:0]  inst_out,
    output      [31:0]  pc_p4_out
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

        // --- PROGRAMA FINAL (Con NOPs para evitar Hazards) ---
        // 1. ADDI $10, $0, 5    (Carga 5 en reg 10)
        instruction_memory[0] = 32'h200A0005; 
        
        // NOPs de espera (Bubbles)
        instruction_memory[1] = 32'h00000000; 
        instruction_memory[2] = 32'h00000000; 

        // 2. SW $10, 20($0)     (Guarda el 5 en Memoria[20])
        instruction_memory[3] = 32'hAC0A0014; 

        // NOPs de espera
        instruction_memory[4] = 32'h00000000;
        instruction_memory[5] = 32'h00000000;

        // 3. LW $11, 20($0)     (Lee el 5 de Memoria[20])
        instruction_memory[6] = 32'h8C0B0014; 

        // NOPs de espera
        instruction_memory[7] = 32'h00000000;
        instruction_memory[8] = 32'h00000000;

        // 4. ADD $12, $10, $11  (Suma 5 + 5 = 10)
        instruction_memory[9] = 32'h014B6020; 
    end

    assign inst_out = instruction_memory[pc[31:2]]; 
    assign pc_p4_out = pc + 32'd4;
endmodule

module quesadilla_decode (
    input clk,
    input rst
);
    // --- SEÑALES ---
    wire [31:0] w_inst_fetch, w_pc_p4_fetch;
    wire [31:0] w_inst_decode, w_pc_p4_decode;
    wire [31:0] w_data_r1, w_data_r2;
    wire [4:0]  w_addr_w_mux;
    wire [31:0] w_alu_src_mux;
    wire [31:0] w_imm_extendido = {{16{w_inst_decode[15]}}, w_inst_decode[15:0]};

    // Control ID
    wire w_reg_dst, w_jump, w_branch, w_mem_read, w_mem_to_reg, w_mem_write, w_alu_src, w_reg_write;
    wire [2:0] w_alu_op;

    // Etapa EX
    wire [31:0] w_pc_p4_exec, w_dr1_exec, w_dr2_mux_exec, w_imm_exec;
    wire [4:0]  w_addr_rt_exec, w_addr_rd_exec;
    
    // Control EX
    wire w_reg_dst_ex, w_alu_src_ex, w_branch_ex, w_mem_read_ex, w_mem_write_ex, w_reg_write_ex, w_mem_to_reg_ex;
    wire [2:0] w_alu_op_ex;

    // Resultados EX
    wire [3:0]  w_alu_control_sig;
    wire [31:0] w_alu_result;
    wire [4:0]  w_dest_reg_final;
    wire        w_zero;

    // Etapa MEM
    wire [31:0] w_alu_result_mem, w_write_data_mem;
    wire [4:0]  w_dest_reg_mem;
    wire [31:0] w_mem_read_data;
    
    // Control MEM
    wire w_mem_read_mem, w_mem_write_mem, w_reg_write_mem, w_mem_to_reg_mem;

    // Etapa WB
    wire [31:0] w_mem_data_wb, w_alu_result_wb;
    wire [4:0]  w_dest_reg_wb;
    wire [31:0] w_wb_data;
    
    // Control WB
    wire w_reg_write_wb, w_mem_to_reg_wb;

    // --- INSTANCIAS ---

    quesadilla U_Quesadilla (
        .clk(clk), .rst(rst),
        .inst_out(w_inst_fetch), .pc_p4_out(w_pc_p4_fetch)
    );

    buffer_CFE U_CF_DE (
        .clk(clk), .rst(rst),
        .inst_in(w_inst_fetch), .pc_p4_in(w_pc_p4_fetch),
        .inst_out(w_inst_decode), .pc_p4_out(w_pc_p4_decode)
    );

    UnidadControl U_Control (
        .opcode(w_inst_decode[31:26]), 
        .reg_dst(w_reg_dst), .jump(w_jump), .branch(w_branch),
        .mem_read(w_mem_read), .mem_to_reg(w_mem_to_reg), .alu_op(w_alu_op),
        .mem_write(w_mem_write), .alu_src(w_alu_src), .reg_write(w_reg_write)
    );

    burrote U_Burrote (
        .clk(clk), .rst(rst),
        .we(w_reg_write_wb),       
        .addr_r1(w_inst_decode[25:21]), 
        .addr_r2(w_inst_decode[20:16]), 
        .addr_w(w_dest_reg_wb),    
        .data_w(w_wb_data),        
        .data_r1(w_data_r1), .data_r2(w_data_r2)
    );

    mux_rt_rd U_Mux_AW (
        .in_rt(w_inst_decode[20:16]), .in_rd(w_inst_decode[15:11]), 
        .sel(w_reg_dst), .out_aw(w_addr_w_mux)
    );

    mux_dr2_imm U_Mux_ALUSrc (
        .in_dr2(w_data_r2), .in_imm(w_imm_extendido),
        .sel(w_alu_src), .out_alu_src(w_alu_src_mux)
    );

    buffer_DEX U_DE_EX (
        .clk(clk), .rst(rst),
        .pc_p4_in(w_pc_p4_decode), .dr1_in(w_data_r1), .dr2_mux_in(w_alu_src_mux),
        .imm_in(w_imm_extendido), .addr_rt_in(w_inst_decode[20:16]), .addr_rd_in(w_inst_decode[15:11]),
        .i_reg_dst(w_reg_dst), .i_alu_op(w_alu_op), .i_alu_src(w_alu_src), .i_branch(w_branch),
        .i_mem_read(w_mem_read), .i_mem_write(w_mem_write), .i_reg_write(w_reg_write), .i_mem_to_reg(w_mem_to_reg),
        
        .dr1_out(w_dr1_exec), .dr2_mux_out(w_dr2_mux_exec), .imm_out(w_imm_exec),
        .addr_rt_out(w_addr_rt_exec), .addr_rd_out(w_addr_rd_exec),
        .o_reg_dst(w_reg_dst_ex), .o_alu_op(w_alu_op_ex), .o_alu_src(w_alu_src_ex), .o_branch(w_branch_ex),
        .o_mem_read(w_mem_read_ex), .o_mem_write(w_mem_write_ex), .o_reg_write(w_reg_write_ex), .o_mem_to_reg(w_mem_to_reg_ex)
    );

    ALUControl U_ALU_Ctrl (
        .alu_op(w_alu_op_ex), .funct(w_imm_exec[5:0]), .alu_control(w_alu_control_sig)
    );

    ALU U_ALU (
        .A(w_dr1_exec), .B(w_dr2_mux_exec), .alu_control(w_alu_control_sig),
        .Result(w_alu_result), .Zero(w_zero)
    );

    assign w_dest_reg_final = (w_reg_dst_ex == 0) ? w_addr_rt_exec : w_addr_rd_exec;

    buffer_EM U_EM (
        .clk(clk), .rst(rst),
        .i_mem_read(w_mem_read_ex), .i_mem_write(w_mem_write_ex), 
        .i_reg_write(w_reg_write_ex), .i_mem_to_reg(w_mem_to_reg_ex),
        .i_alu_result(w_alu_result), .i_write_data(w_dr2_mux_exec), .i_addr_dest(w_dest_reg_final),
        
        .o_mem_read(w_mem_read_mem), .o_mem_write(w_mem_write_mem), 
        .o_reg_write(w_reg_write_mem), .o_mem_to_reg(w_mem_to_reg_mem),
        .o_alu_result(w_alu_result_mem), .o_write_data(w_write_data_mem), .o_addr_dest(w_dest_reg_mem)
    );

    DataMemory U_DataMem (
        .clk(clk),
        .Address(w_alu_result_mem), 
        .WriteData(w_write_data_mem),
        .MemRead(w_mem_read_mem), 
        .MemWrite(w_mem_write_mem),
        .ReadData(w_mem_read_data)
    );

    buffer_MW U_MW (
        .clk(clk), .rst(rst),
        .i_reg_write(w_reg_write_mem), .i_mem_to_reg(w_mem_to_reg_mem),
        .i_mem_data(w_mem_read_data), .i_alu_result(w_alu_result_mem), .i_addr_dest(w_dest_reg_mem),
        
        .o_reg_write(w_reg_write_wb), .o_mem_to_reg(w_mem_to_reg_wb),
        .o_mem_data(w_mem_data_wb), .o_alu_result(w_alu_result_wb), .o_addr_dest(w_dest_reg_wb)
    );

    assign w_wb_data = (w_mem_to_reg_wb == 1) ? w_mem_data_wb : w_alu_result_wb;

endmodule