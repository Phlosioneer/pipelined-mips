
`ifndef FETCH_V
`define FETCH_V

`include "fetch/pc.v"
`include "util.v"
`include "fetch/instr_mem.v"

module fetch(pc_branch_d, pc_src_d, stall_f, clock, pc_plus_4_f, instruction_f);
	input [31:0] pc_branch_d;
	input pc_src_d;
	input stall_f;
	input clock;
	output [31:0] pc_plus_4_f;
	output [31:0] instruction_f;

	wire [31:0] next_count;
	wire [31:0] cur_count;
	wire [31:0] start_addr;
	program_counter pc(clock, stall_f, next_count, start_addr, cur_count);
	adder pc_adder(cur_count, 4, pc_plus_4_f);
	mux32_2 pc_or_branch(pc_branch_d, pc_plus_4_f, pc_src_d, next_count);

	instr_memory instr_mem(clock, cur_count, instruction_f, start_addr);

endmodule
`endif


