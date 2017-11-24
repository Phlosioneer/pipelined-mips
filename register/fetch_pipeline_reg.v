

`ifndef FETCH_PIPELINE_REG
`define FETCH_PIPELINE_REG

`include "register/pipeline_reg.v"

module fetch_pipeline_reg(clock, clear, stall_d, pc_plus_four_f, instruction_f, pc_plus_four_d, instruction_d);
	input wire clock;
	input wire clear;
	input wire [31:0] pc_plus_four_f;
	input wire [31:0] instruction_f;
    input wire stall_d;
	output wire [31:0] pc_plus_four_d;
	output wire [31:0] instruction_d;
    	
	// This is to fix the fact that pc_src_d is stalled and won't change
	// in the middle of a stall.
	wire corrected_clear;

	assign corrected_clear = clear & !stall_d;

	pipeline_reg_stall pc_plus_four(clock, corrected_clear, stall_d, pc_plus_four_f, pc_plus_four_d);
	pipeline_reg_stall instruction(clock, corrected_clear, stall_d, instruction_f, instruction_d);

endmodule

`endif


