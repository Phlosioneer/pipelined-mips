


`ifndef DECODER_V
`define DECODER_V

`include "decode/decoder/instr_splitter.v"
`include "decode/decoder/branch_adder.v"
`include "decode/decoder/jump_calculator.v"

// This module encapsulates the instruction decoding process.
// 
// Note: The names of these input and output wires differ slightly from the
// names given in the pipelined mips diagram. The names and their
// corresponding wire names are listed at the bottom of this file.
//
// Note: To avoid race conditions, do not modify writeback_value,
// writeback_id, and should_writeback on negedge of the clock. This is because
// the register values are written at negedge of the clock.
//
// Note: the reg_rs_value and reg_rt_value wires live-update as is_i_type and
// instruction wires change. Additionally, these values may change if they
// correspond with the current writeback_id during a writeback. If a value
// must be sampled from these registers, do so at posedge of the clock, to
// allow the values to stabilize.
//
// TODO: Add reg_jump_address for jr instruction.
module decoder(clock, instruction, pc_plus_four, is_r_type, sign_immediate,
		unsign_immediate, branch_address, jump_address, reg_rs_id, reg_rt_id,
		reg_rd_id, shamt, funct, opcode);
	
	// The clock.
	input wire clock;
	
	// The current instruction.
	input wire [31:0] instruction;
	
	// The address of the next instruction to be executed (pc + 4).
	input wire [31:0] pc_plus_four;
	

	// This is 1 if the current instruction is R-type, 0 otherwise.
	input wire is_r_type;
	
	// This outputs the sign-extended immediate value in the current
	// instruction. If the current instruction is not I-type, consider
	// this output junk.
	output wire [31:0] sign_immediate;

	// Outputs the raw immediate value, extended to 32 bits. If the
	// current instruction is not I-type, consider this output junk.
	output wire [31:0] unsign_immediate;

	// This outputs the target address of a branch instruction, based on
	// pc + 4 and the immediate value in the instruction. If the current
	// instruction is not a branch, consider this output junk.
	output wire [31:0] branch_address;

	// This outputs the target address of an unconditional jump, based on
	// pc + 4 and the immediate value in the instruction. If the current
	// instruction is not J, consider this output junk.
	output wire [31:0] jump_address;

	// This outputs the ID of the RS register of the current instruction.
	// If the current instruction is J-type, consider this output junk.
	output wire [4:0] reg_rs_id;

	// This outputs the ID of the RT register of the current instruction.
	// If the current instruction is not R-type, consider this output
	// junk.
	output wire [4:0] reg_rt_id;

	// This outputs the ID of the RD register of the current instruction.
	// If the current instruction is J-type, consider this output junk.
	output wire [4:0] reg_rd_id;

	// This outputs the shift amount value of the current instruction. If
	// the current instruction is not sll or sra, consider this output
	// junk.
	output wire [4:0] shamt;

	// This outputs the function value of the current instruction. If the
	// current instruction is not R-type, consider this value junk.
	output wire [5:0] funct;
	
	// Outputs the current opcode.
	output wire [5:0] opcode;

	// These are the register ID's decoded assuming the current instruction
	// is R-type.
	wire [4:0] r_type_rs;
	wire [4:0] r_type_rt;
	wire [4:0] r_type_rd;

	// These are the register ID's decoded assuming the current
	// instruction is I-type.
	wire [4:0] i_type_rs;
	wire [4:0] i_type_rd;

	// This is the unprocessed jump address immediate value in the current
	// instruction, assuming the current instruction is J-type.
	wire [25:0] raw_jump_address;

	// Decide which rs, rt, and rd ID values to output based on whether
	// the current instruction is I-type.
	assign reg_rs_id = is_r_type ? r_type_rs : i_type_rs;
	assign reg_rt_id = is_r_type ? r_type_rt : i_type_rd;
	assign reg_rd_id = is_r_type ? r_type_rd : i_type_rd;


	// This module extracts info from the current instruction, assuming it
	// is R-type.
	instr_splitter_r r_split(
		.instruction (instruction),
		.rs (r_type_rs),
		.rt (r_type_rt),
		.rd (r_type_rd),
		.shamt (shamt),
		.funct (funct)
		);

	// This module extracts info from the current instruction, assuming it
	// is I-type.
	instr_splitter_i i_split(
		.instruction (instruction),
		.rs (i_type_rs),
		.rd (i_type_rd),
		.sign_immediate (sign_immediate),
		.unsign_immediate (unsign_immediate)
		);

	// This module extracts info from the current instruction, assuming it
	// is J-type.
	instr_splitter_j j_split(instruction, raw_jump_address);

	instr_opcode opcode_split(instruction, opcode);

	// This module calculates the actual target address, assuming the
	// current instruction is a branch instruction.
	branch_adder b_calc(sign_immediate, pc_plus_four, branch_address);

	// This module calculates the actual target address, assuming the
	// current instruction is a jump instruction.
	wire [31:0] calc_jump_address;
	jump_calculator j_calc(raw_jump_address, pc_plus_four, jump_address);
	
	

endmodule


`endif





