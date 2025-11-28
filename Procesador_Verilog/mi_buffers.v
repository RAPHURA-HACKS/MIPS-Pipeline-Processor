`timescale 1ns / 1ns

module buffer_CFE (
    input               clk, rst,        
    input       [31:0]  inst_in, pc_p4_in,  
    output  reg [31:0]  inst_out, pc_p4_out 
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            inst_out  <= 32'd0;
            pc_p4_out <= 32'd0;
        end else begin
            inst_out  <= inst_in;
            pc_p4_out <= pc_p4_in;
        end
    end
endmodule

module buffer_DEX (
    input               clk, rst,               
    
    // Datos In
    input       [31:0]  pc_p4_in, dr1_in, dr2_mux_in, imm_in,
    input       [4:0]   addr_rt_in, addr_rd_in,    

    // Control In
    input               i_reg_dst, i_alu_src, i_branch, i_mem_read,
                        i_mem_write, i_reg_write, i_mem_to_reg,
    input       [2:0]   i_alu_op,
   
    // Datos Out
    output  reg [31:0]  pc_p4_out, dr1_out, dr2_mux_out, imm_out,
    output  reg [4:0]   addr_rt_out, addr_rd_out,

    // Control Out
    output  reg         o_reg_dst, o_alu_src, o_branch, o_mem_read,
                        o_mem_write, o_reg_write, o_mem_to_reg,
    output  reg [2:0]   o_alu_op
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_p4_out    <= 0; dr1_out      <= 0; dr2_mux_out  <= 0;
            imm_out      <= 0; addr_rt_out  <= 0; addr_rd_out  <= 0;
            o_reg_dst    <= 0; o_alu_op     <= 0; o_alu_src    <= 0;
            o_branch     <= 0; o_mem_read   <= 0; o_mem_write  <= 0;
            o_reg_write  <= 0; o_mem_to_reg <= 0;
        end else begin
            pc_p4_out    <= pc_p4_in; dr1_out      <= dr1_in; dr2_mux_out  <= dr2_mux_in;
            imm_out      <= imm_in; addr_rt_out  <= addr_rt_in; addr_rd_out  <= addr_rd_in;
            o_reg_dst    <= i_reg_dst; o_alu_op     <= i_alu_op; o_alu_src    <= i_alu_src;
            o_branch     <= i_branch; o_mem_read   <= i_mem_read; o_mem_write  <= i_mem_write;
            o_reg_write  <= i_reg_write; o_mem_to_reg <= i_mem_to_reg;
        end
    end
endmodule

module buffer_EM (
    input               clk, rst,
    input               i_mem_read, i_mem_write, i_reg_write, i_mem_to_reg,
    input       [31:0]  i_alu_result, i_write_data,
    input       [4:0]   i_addr_dest,

    output reg          o_mem_read, o_mem_write, o_reg_write, o_mem_to_reg,
    output reg  [31:0]  o_alu_result, o_write_data,
    output reg  [4:0]   o_addr_dest
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            o_mem_read   <= 0; o_mem_write  <= 0; o_reg_write  <= 0; 
            o_mem_to_reg <= 0; o_alu_result <= 0; o_write_data <= 0; o_addr_dest  <= 0;
        end else begin
            o_mem_read   <= i_mem_read; o_mem_write  <= i_mem_write;
            o_reg_write  <= i_reg_write; o_mem_to_reg <= i_mem_to_reg;
            o_alu_result <= i_alu_result; o_write_data <= i_write_data;
            o_addr_dest  <= i_addr_dest;
        end
    end
endmodule

module buffer_MW (
    input               clk, rst,
    input               i_reg_write, i_mem_to_reg,
    input       [31:0]  i_mem_data, i_alu_result,
    input       [4:0]   i_addr_dest,

    output reg          o_reg_write, o_mem_to_reg,
    output reg  [31:0]  o_mem_data, o_alu_result,
    output reg  [4:0]   o_addr_dest
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            o_reg_write  <= 0; o_mem_to_reg <= 0;
            o_mem_data   <= 0; o_alu_result <= 0; o_addr_dest  <= 0;
        end else begin
            o_reg_write  <= i_reg_write; o_mem_to_reg <= i_mem_to_reg;
            o_mem_data   <= i_mem_data; o_alu_result <= i_alu_result;
            o_addr_dest  <= i_addr_dest;
        end
    end
endmodule