

`ifndef JUMP_UNIT
`define JUMP_UNIT

`include "mips.h"

// Takes in all the jump-related info from the control_unit and decoder
// modules, and decides whether to jump and where to jump.
module jump_unit(pc_plus_four, maybe_jump_address, maybe_branch_address,
		reg_rs, reg_rt, blt, beq, bgt, link_reg, rt_is_zero, is_r_type, is_i_type, is_j_type,
		is_trap,
		jump_address, pc_src, branch, ra_write, ra_write_value);
	
	// The current PC, used for jump and link.
	input wire [31:0] pc_plus_four;

	// All the possible sources of the final jump address.
	input wire [31:0] maybe_jump_address;
	input wire [31:0] maybe_branch_address;
	
	// The current register values.
	input wire [31:0] reg_rs;
	input wire [31:0] reg_rt;

	// If true, branch if $s < $t
	input wire blt;

	// If true, branch if $s == $t
	input wire beq;

	// If true, branch if $s > $t
	input wire bgt;

	// If true, save the next PC into $ra
	input wire link_reg;

	// If true, treat reg_rt as if it were 0.
	input wire rt_is_zero;

	// Used by the jump unit to figure out how to calculate the jump
	// destination.
	// - R type means it's a JR, and the source is $ra.
	// - I type means it's relative, and the source is the immediate.
	// - J type means it's absolute and the source is the immediate.
	input wire is_r_type;
	input wire is_i_type;
	input wire is_j_type;

	// If this is a trap, the linked address needs to be 4 bytes less
	// than usual, to the instruction that would normally be considered
	// a branch display slot.
	input wire is_trap;
	
	// The actual jump address.
	output wire [31:0] jump_address;

	// Whether the PC should jump address. 1 = should jump.
	output wire pc_src;

	// Whether the current instruction is a branch/jump instruction.
	// 1 = branch/jump instruction, 0 = normal instruction.
	output wire branch;

	// This is 1 if ra_write_value should be stored to the ra register.
	output wire ra_write;

	// This is the value to write to the ra register, if needed.
	output wire [31:0] ra_write_value;
	
	// This is the register containing the value to jump to if the
	// instruction is JUMP_REG.
	wire [31:0] jump_reg_address;
	
	wire [31:0] correct_rt;

	assign correct_rt = rt_is_zero ? 0 : reg_rt;

	assign jump_reg_address = reg_rs;

	// True if the current instruction is a branch, i.e. it depends on
	// register values.
	assign branch = (blt || beq || bgt) && is_i_type;
	
	assign ra_write = pc_src && link_reg;

	assign ra_write_value = is_trap ? pc_plus_four - 1 : pc_plus_four;
    
    // Determine pc_src.
	assign pc_src =
		(blt && (reg_rs < correct_rt)) |
		(beq && (reg_rs == correct_rt)) |
		(bgt && (reg_rs > correct_rt));
	
	// Determine the end jump address.
	assign jump_address =
		is_trap ? `IVT_BOT : (
		is_r_type ? jump_reg_address : (
		is_i_type ? maybe_branch_address : (
		is_j_type ? maybe_jump_address : 32'hxxxx_xxxx)));
	

endmodule


`endif




