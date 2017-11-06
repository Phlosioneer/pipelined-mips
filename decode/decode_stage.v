


`ifndef DECODE_STAGE_V
`define DECODE_STAGE_V

`include "decode/decoder/decoder.v"
`include "decode/control/control_unit.v"
`include "decode/jump_unit.v"
`include "hazard/hazard_unit.v"
`include "decode/mf_unit.v"

module decode_stage(clock, instruction, pc_plus_four, writeback_value, writeback_id, reg_write_w,
		has_div_w, div_hi_w, div_lo_w,

		reg_rs_value, reg_rt_value, immediate, jump_address, reg_rs_id,
		reg_rt_id, reg_rd_id, shamt_d,

		reg_write_d, mem_to_reg, mem_write, alu_op, alu_src, reg_dest, pc_src,
		
		syscall, syscall_funct, syscall_param_1, mf_op_in_d, has_div_d, is_byte_d, branch_d);

	input wire clock;

	// Inputs from the Fetch stage.
	input wire [31:0] instruction;
	input wire [31:0] pc_plus_four;

	// Inputs from the Writeback stage.
	input wire [31:0] writeback_value;
	input wire [4:0] writeback_id;
	input wire reg_write_w;
	input wire has_div_w;
	input wire [31:0] div_hi_w;
	input wire [31:0] div_lo_w;

	// Outputs from the decode stage.
	output wire [31:0] reg_rs_value;
	output wire [31:0] reg_rt_value;
	output wire [31:0] immediate;
	output wire [31:0] jump_address;
	output wire [4:0] reg_rs_id;
	output wire [4:0] reg_rt_id;
	output wire [4:0] reg_rd_id;
	output wire [4:0] shamt_d;

	// Outputs from the control unit.
	output wire reg_write_d;
	output wire mem_to_reg;
	output wire mem_write;
	output wire [3:0] alu_op;
	output wire alu_src;
	output wire reg_dest;
	output wire pc_src;
	
	output wire syscall;
	output wire [31:0] syscall_funct;
	output wire [31:0] syscall_param_1;

	output wire has_div_d;

	// This output is used by the hazard unit. It is 1 if the current
	// instruction is MFHI or MFLO.
	output wire mf_op_in_d;

	// This output is used by the hazard unit. It is 1 if the current
	// instruction is a branch.
	output wire branch_d;

	// This output is used by the memory stage.
	output wire is_byte_d;
	
	// Internal wires.
	wire is_r_type;
	wire is_i_type;
	wire is_j_type;

	wire blt;
	wire beq;
	wire bgt;
	wire link_reg;
	wire rt_is_zero;

	wire [5:0] funct;
	wire [5:0] opcode;

	wire [31:0] maybe_jump_address;
	wire [31:0] maybe_branch_address;

	wire [2:0] branch_variant;

	wire imm_is_unsigned;
	wire [31:0] sign_immediate;
	wire [31:0] unsign_immediate;

	wire is_mf_hi;
	wire is_mf_lo;
	
	// The values of the special hi and lo registers, used during divides
	// and multiplies.
	wire [31:0] reg_hi_d;
	wire [31:0] reg_lo_d;

	// True if ra_write_value needs to be written to the ra register.
	wire ra_write;
	wire [31:0] ra_write_value;

	// This wire holds the shamt value specified by the instruction. The
	// actual shamt value may be modified by the control unit for some
	// instructions.
	wire [4:0] instr_shamt;
	
	// This wire holds the rs value specified by the rs register id. The
	// actual rs value may be modified by the mf unit to be the
	// special hi or lo registers.
	wire [31:0] instr_rs_value;
	
	assign immediate = imm_is_unsigned ? unsign_immediate : sign_immediate;

	assign mf_op_in_d = is_mf_hi | is_mf_lo;

	// This module contains the register file. Writeback happens
	// at negedge of the clock.
	reg_file bank(
		// Inputs
		.clock (clock),
		.reg_rs_id (reg_rs_id),
		.reg_rt_id (reg_rt_id),
		.control_reg_write (reg_write_w),
		.control_write_id (writeback_id),
		.reg_write_value(writeback_value),
		.ra_write(ra_write),
		.ra_write_value(ra_write_value),
		.reg_hi_w(div_hi_w),
		.reg_lo_w(div_lo_w),
		.has_div_w(has_div_w),
		
		// Outputs
		.reg_rs_value(instr_rs_value),
		.reg_rt_value(reg_rt_value),
		.syscall_funct(syscall_funct),
		.syscall_param_1(syscall_param_1),
		.reg_hi_d(reg_hi_d),
		.reg_lo_d(reg_lo_d)
		);

	// The decoder
	decoder decoder(
		.clock (clock),
		.instruction (instruction),
		.pc_plus_four (pc_plus_four),
		.is_r_type (is_r_type),
		.sign_immediate (sign_immediate),
		.unsign_immediate (unsign_immediate),
		.branch_address (maybe_branch_address),
		.jump_address (maybe_jump_address),
		.reg_rs_id (reg_rs_id),
		.reg_rt_id (reg_rt_id),
		.reg_rd_id (reg_rd_id),
		.shamt (instr_shamt),
		.funct (funct),
		.opcode (opcode)
		);

	// The control unit.
	control_unit control(
		.clock (clock),
		.opcode (opcode),
		.funct (funct),
		.instr_shamt (instr_shamt),
		.reg_rt_id (reg_rt_id),
		.is_r_type (is_r_type),
		.is_i_type (is_i_type),
		.is_j_type (is_j_type),
		.reg_write (reg_write_d),
		.mem_to_reg (mem_to_reg),
		.mem_write (mem_write),
		.alu_op (alu_op),
		.alu_src (alu_src),
		.reg_dest (reg_dest),
		.blt(blt),
		.beq(beq),
		.bgt(bgt),
		.link_reg(link_reg),
		.rt_is_zero(rt_is_zero),
		.syscall (syscall),
		.imm_is_unsigned (imm_is_unsigned),
		.shamtD (shamt_d),
		.is_mf_hi (is_mf_hi),
		.is_mf_lo (is_mf_lo),
		.HasDivD (has_div_d),
		.IsByteD(is_byte_d)
		);
	
	// The jump decider.
	jump_unit jump_decider(
		.pc_plus_four(pc_plus_four),
		.maybe_jump_address (maybe_jump_address),
		.maybe_branch_address (maybe_branch_address),
		.reg_rs (reg_rs_value),
		.reg_rt (reg_rt_value),
		.blt(blt),
		.beq(beq),
		.bgt(bgt),
		.link_reg(link_reg),
		.is_r_type(is_r_type),
		.is_i_type(is_i_type),
		.is_j_type(is_j_type),
		.rt_is_zero(rt_is_zero),
		.jump_address (jump_address),
		.pc_src (pc_src),
		.branch (branch_d),
		.ra_write_value (ra_write_value),
		.ra_write (ra_write)
		);

	mf_unit mf_decider(
		.reg_hi (reg_hi_d),
		.reg_lo (reg_lo_d),
		.instr_rs_value (instr_rs_value),
		.is_mf_hi (is_mf_hi),
		.is_mf_lo (is_mf_lo),
		.actual_rs_value (reg_rs_value)
		
		);	

endmodule


`endif




