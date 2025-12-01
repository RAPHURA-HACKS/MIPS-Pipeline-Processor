vlog -work work -refresh *.v
vsim -voptargs=+acc work.tb_quesadilla_decode

add wave -divider "1. FETCH"
add wave -radix hex sim:/tb_quesadilla_decode/DUT/w_pc_p4_fetch
add wave -radix hex sim:/tb_quesadilla_decode/DUT/w_inst_fetch

add wave -divider "2. DECODE"
add wave -radix hex sim:/tb_quesadilla_decode/DUT/w_inst_decode
add wave -color Gold sim:/tb_quesadilla_decode/DUT/w_alu_src
add wave -color Gold sim:/tb_quesadilla_decode/DUT/w_mem_write
add wave -color Gold sim:/tb_quesadilla_decode/DUT/w_mem_to_reg

add wave -divider "3. EXECUTE"
add wave -radix hex sim:/tb_quesadilla_decode/DUT/w_dr1_exec
add wave -radix hex sim:/tb_quesadilla_decode/DUT/w_dr2_raw_exec
add wave -radix hex -color Magenta sim:/tb_quesadilla_decode/DUT/w_alu_result

add wave -divider "4. MEMORY"
add wave -radix hex sim:/tb_quesadilla_decode/DUT/w_alu_result_mem
add wave -radix hex sim:/tb_quesadilla_decode/DUT/w_mem_read_data
add wave -color Red sim:/tb_quesadilla_decode/DUT/w_mem_write_mem

add wave -divider "5. WRITE BACK"
add wave -radix decimal -color Lime sim:/tb_quesadilla_decode/DUT/w_wb_data
add wave -radix unsigned sim:/tb_quesadilla_decode/DUT/w_dest_reg_wb
add wave -color Lime sim:/tb_quesadilla_decode/DUT/w_reg_write_wb

run 200ns