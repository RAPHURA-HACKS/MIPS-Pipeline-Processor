`timescale 1ns / 1ns

//  BUFFER IF/ID (buffer_CFE)
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


//  BUFFER ID/EX (buffer_DEX)
//  Esta versión usa los nombres que aparece en tu instancia:
//  pc_p4_in, dr1_in, dr2_mux_in, imm_in, addr_rt_in, addr_rd_in, funct_in
//  y señales de control i_*  -> o_*
module buffer_DEX (
    input               clk, rst,

    // Datos In
    input       [31:0]  pc_p4_in,
    input       [31:0]  dr1_in,
    input       [31:0]  dr2_mux_in,
    input       [31:0]  imm_in,
    input       [4:0]   addr_rt_in,
    input       [4:0]   addr_rd_in,
    input       [5:0]   funct_in,

    // Control In (prefijo i_)
    input               i_reg_dst,
    input       [2:0]   i_alu_op,
    input               i_alu_src,
    input               i_branch,
    input               i_mem_read,
    input               i_mem_write,
    input               i_reg_write,
    input               i_mem_to_reg,

    // Datos Out
    output  reg [31:0]  pc_p4_out,
    output  reg [31:0]  dr1_out,
    output  reg [31:0]  dr2_mux_out,
    output  reg [31:0]  imm_out,
    output  reg [4:0]   addr_rt_out,
    output  reg [4:0]   addr_rd_out,
    output  reg [5:0]   funct_out,

    // Control Out (prefijo o_)
    output  reg         o_reg_dst,
    output  reg [2:0]   o_alu_op,
    output  reg         o_alu_src,
    output  reg         o_branch,
    output  reg         o_mem_read,
    output  reg         o_mem_write,
    output  reg         o_reg_write,
    output  reg         o_mem_to_reg
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_p4_out    <= 32'd0;
            dr1_out      <= 32'd0;
            dr2_mux_out  <= 32'd0;
            imm_out      <= 32'd0;
            addr_rt_out  <= 5'd0;
            addr_rd_out  <= 5'd0;
            funct_out    <= 6'd0;

            o_reg_dst    <= 1'b0;
            o_alu_op     <= 3'b000;
            o_alu_src    <= 1'b0;
            o_branch     <= 1'b0;
            o_mem_read   <= 1'b0;
            o_mem_write  <= 1'b0;
            o_reg_write  <= 1'b0;
            o_mem_to_reg <= 1'b0;
        end else begin
            pc_p4_out    <= pc_p4_in;
            dr1_out      <= dr1_in;
            dr2_mux_out  <= dr2_mux_in;
            imm_out      <= imm_in;
            addr_rt_out  <= addr_rt_in;
            addr_rd_out  <= addr_rd_in;
            funct_out    <= funct_in;

            o_reg_dst    <= i_reg_dst;
            o_alu_op     <= i_alu_op;
            o_alu_src    <= i_alu_src;
            o_branch     <= i_branch;
            o_mem_read   <= i_mem_read;
            o_mem_write  <= i_mem_write;
            o_reg_write  <= i_reg_write;
            o_mem_to_reg <= i_mem_to_reg;
        end
    end
endmodule


//  BUFFER EX/MEM (buffer_EM)
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
            o_mem_read   <= 1'b0;
            o_mem_write  <= 1'b0;
            o_reg_write  <= 1'b0;
            o_mem_to_reg <= 1'b0;
            o_alu_result <= 32'd0;
            o_write_data <= 32'd0;
            o_addr_dest  <= 5'd0;
        end else begin
            o_mem_read   <= i_mem_read;
            o_mem_write  <= i_mem_write;
            o_reg_write  <= i_reg_write;
            o_mem_to_reg <= i_mem_to_reg;
            o_alu_result <= i_alu_result;
            o_write_data <= i_write_data;
            o_addr_dest  <= i_addr_dest;
        end
    end
endmodule


//  BUFFER MEM/WB (buffer_MW)
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
            o_reg_write  <= 1'b0;
            o_mem_to_reg <= 1'b0;
            o_mem_data   <= 32'd0;
            o_alu_result <= 32'd0;
            o_addr_dest  <= 5'd0;
        end else begin
            o_reg_write  <= i_reg_write;
            o_mem_to_reg <= i_mem_to_reg;
            o_mem_data   <= i_mem_data;
            o_alu_result <= i_alu_result;
            o_addr_dest  <= i_addr_dest;
        end
    end
endmodule
