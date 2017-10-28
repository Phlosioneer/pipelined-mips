

`ifndef CONTROL_UNIT
`define CONTROL_UNIT

`ifndef MIPS_H
`include "mips.h"
`endif

`include "decode/classify.v"
`include "decode/alu_control.v"

module control_unit(opcode, funct, instr_shamt, reg_rt_id, is_r_type,
		is_i_type, is_j_type, reg_write,
		mem_to_reg, mem_write, alu_op, alu_src, reg_dest,
		syscall, imm_is_unsigned, shamtD, is_mf_hi, is_mf_lo,
		HasDivD, IsByteD, bgt, beq, blt, rt_is_zero, link_reg);

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
	
	output wire [4:0] shamtD;

	// 1 if the current instruction is MFHI, 0 otherwise.
	output wire is_mf_hi;

	// 1 if the current instruction is MFLO, 0 otherwise.
	output wire is_mf_lo;

	// 1 if the current instruction is divide.
	output wire HasDivD;

	// 1 if the current instruction is LB or SB.
	output wire IsByteD;

	// Branch_control to jump_unit:
	output wire bgt;	// True if $s > $t causes jump
	output wire beq;	// True if $s == $t causes jump
	output wire blt;	// True if $s < $t causes jump
	output wire link_reg;	// If true, set $ra = $pc
	output wire [1:0] j_src;	// A code for where to get the jump address
	
	// Branch_control to decode stage:
	output wire rt_is_zero;	// If true, reg_rt_value is set to $zero.

	wire is_shift_op;

	// True if the special opcode requires reg_write. Junk if the current
	// instruction isn't special.
	wire reg_write_special;

	assign regimm = reg_rt_id;

	alu_control alu(opcode, funct, alu_op);
	classify classifier(opcode, is_r_type, is_i_type, is_j_type);

	assign is_mf_hi = (opcode == `SPECIAL) && (funct == `MFHI);
	assign is_mf_lo = (opcode == `SPECIAL) && (funct == `MFLO);

	assign HasDivD = (opcode == `SPECIAL) && (funct == `DIV);

	assign IsByteD = (opcode == `LB || opcode == `SB);

	assign mem_write =
		(opcode == `SW) |
		(opcode == `SB);
	
	assign reg_write =
		((opcode == `SPECIAL) && reg_write_special) |
		(opcode == `ADDIU) |
		(opcode == `ORI) |
		(opcode == `SLTI) |
		(opcode == `SLTIU) |
		(opcode == `LUI) |
		(opcode == `LW) |
		(opcode == `LB);

	assign reg_write_special = !((funct == `JR) || (funct == `SYSCALL));
	
	assign imm_is_unsigned =
		(opcode == `ORI) |
		(opcode == `SLTIU);

	assign mem_to_reg =
		(opcode == `LW) |
		(opcode == `LB);
	
	assign is_shift_op =
		(opcode == `SPECIAL) & (
		(funct == `SRA) |
		(funct == `SLL));
	
	// For LUI, the shamt needs to be set to 16.
	assign shamtD = (opcode == `LUI) ? 16 : instr_shamt;

	// This is 1 if and only if the instruction is an r-type instruction.
	assign reg_dest = is_r_type; 
	
	assign syscall = (opcode == `SPECIAL) & (funct == `SYSCALL);

	assign alu_src = is_i_type | is_shift_op;

	
	// TODO: Refactor this into a separate branch_control module.

	assign bgt =
		(opcode == `J) |
		(opcode == `JAL) |
		((opcode == `REGIMM) && (regimm == `BGEZ)) |
		((opcode == `REGIMM) && (regimm == `BGEZAL)) |
		(opcode == `BGTZ) |
		((opcode == `SPECIAL) && (funct == `JR)) |
		(opcode == `BNE);
	
	assign beq =
		(opcode == `J) |
		(opcode == `JAL) |
		((opcode == `SPECIAL) && (funct == `JR)) |
		(opcode == `BEQ) |
		(opcode == `BGTZ) |
		(opcode == `BLEZ) |
		((opcode == `REGIMM) && (regimm == `BGEZAL));
	
	assign blt =
		(opcode == `J) |
		(opcode == `JAL) |
		((opcode == `SPECIAL) && (funct == `JR)) |
		(opcode == `BNE) |
		(opcode == `BLEZ) |
		((opcode == `REGIMM) && (regimm == `BLTZ)) |
		((opcode == `REGIMM) && (regimm == `BLTZAL));

	assign rt_is_zero =
		((opcode == `REGIMM) && (regimm == `BGEZ)) |
		((opcode == `REGIMM) && (regimm == `BGEZAL)) |
		((opcode == `REGIMM) && (regimm == `BLTZ)) |
		(opcode == `BGTZ) |
		(opcode == `BLEZ);

	assign link_reg =
		((opcode == `REGIMM) && (regimm == `BLTZAL)) |
		((opcode == `REGIMM) && (regimm == `BGEZAL)) |
		(opcode == `JAL);

endmodule


`endif




