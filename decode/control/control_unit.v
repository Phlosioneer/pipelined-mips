

`ifndef CONTROL_UNIT_V
`define CONTROL_UNIT_V

`include "mips.h"
`include "decode/control/jump_control.v"
`include "decode/control/classify.v"
`include "decode/control/alu_control.v"

module control_unit(clock, opcode, funct, instr_shamt, reg_rt_id, is_r_type,
		is_i_type, is_j_type, reg_write,
		mem_to_reg, mem_write, alu_op, alu_src, reg_dest,
		syscall, imm_is_unsigned, shamt_d, is_mf_hi, is_mf_lo,
		has_div_d, is_byte_d, bgt, beq, blt, rt_is_zero, link_reg);

	// The clock is only used for error reporting / debugging.
	input wire clock;
	input wire [5:0] opcode;
	input wire [5:0] funct;
	input wire [4:0] instr_shamt;
	
	// This register ID is used like a funct for opcode 1 (called REGIMM)
	input wire [4:0] reg_rt_id;
	wire [4:0] regimm;

	// Used by the decoder and jump_unit.
	output wire is_r_type;
	output wire is_i_type;
	output wire is_j_type;

	output wire reg_write;
	output wire mem_to_reg;
	output wire mem_write;

	output wire [3:0] alu_op;
	
	output wire alu_src;
	output wire reg_dest;

	// Outputs 1 if the current instruction is a syscall, 0 otherwise.
	output wire syscall;

	// Outputs 0 if the current instruction uses an unsigned immediate
	// value; 1 otherwise.
	output wire imm_is_unsigned;
	
	output wire [4:0] shamt_d;

	// 1 if the current instruction is MFHI, 0 otherwise.
	output wire is_mf_hi;

	// 1 if the current instruction is MFLO, 0 otherwise.
	output wire is_mf_lo;

	// 1 if the current instruction is divide.
	output wire has_div_d;

	// 1 if the current instruction is LB or SB.
	output wire is_byte_d;

	// Branch_control to jump_unit:
	output wire bgt;	// True if $s > $t causes jump
	output wire beq;	// True if $s == $t causes jump
	output wire blt;	// True if $s < $t causes jump
	output wire link_reg;	// If true, set $ra = $pc
	
	// Branch_control to decode stage:
	output wire rt_is_zero;	// If true, reg_rt_value is set to $zero.

	wire is_shift_op;

	// True if the special opcode requires reg_write. Junk if the current
	// instruction isn't special.
	wire reg_write_special;

	assign regimm = reg_rt_id;

	alu_control alu(clock, opcode, funct, alu_op);
	classify classifier(clock, opcode, is_r_type, is_i_type, is_j_type);

	assign is_mf_hi = (opcode == `SPECIAL) && (funct == `MFHI);
	assign is_mf_lo = (opcode == `SPECIAL) && (funct == `MFLO);

	assign has_div_d = (opcode == `SPECIAL) && (funct == `DIV);

	assign is_byte_d = (opcode == `LB || opcode == `SB);

	assign mem_write =
		(opcode == `SW) |
		(opcode == `SB);
	
	assign reg_write =
		((opcode == `SPECIAL) && reg_write_special) |
		(opcode == `ADDIU) |
		(opcode == `ANDI) |
		(opcode == `ORI) |
		(opcode == `SLTI) |
		(opcode == `SLTIU) |
		(opcode == `LUI) |
		(opcode == `LW) |
		(opcode == `LB);

	assign reg_write_special = !((funct == `JR) || (funct == `SYSCALL));
	
	assign imm_is_unsigned =
		(opcode == `ORI) |
		(opcode == `ANDI) |
		(opcode == `SLTIU);

	assign mem_to_reg =
		(opcode == `LW) |
		(opcode == `LB);
	
	assign is_shift_op =
		(opcode == `SPECIAL) & (
		(funct == `SRA) |
		(funct == `SLL));
	
	// For LUI, the shamt needs to be set to 16.
	assign shamt_d = (opcode == `LUI) ? 16 : instr_shamt;

	// This is 1 if and only if the instruction is an r-type instruction.
	assign reg_dest = is_r_type; 
	
	assign syscall = (opcode == `SPECIAL) & (funct == `SYSCALL);

	assign alu_src = is_i_type | is_shift_op;

	jump_control jump_control(opcode, funct, regimm, bgt, beq, blt, rt_is_zero, link_reg);	

endmodule


`endif




