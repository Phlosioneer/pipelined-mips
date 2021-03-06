



`ifndef CLASSIFY_V
`define CLASSIFY_V

`include "mips.h"

module classify(clock, opcode, is_r_type, is_i_type, is_j_type);
	// The clock is only used for error reporting / debugging.
	input wire clock;
	input wire [5:0] opcode;
	output wire is_r_type;
	output wire is_i_type;
	output wire is_j_type;
	
	// R-type: addu, div, mfhi, mflo, sll, sra, subu, jr, syscall, break
	// Instructions under "SPECIAL" opcode: addu, div, mfhi, mflo, sra,
	// sll, subu
	// pseudo-instructions: move a, b = addu a, $zero, b
	assign is_r_type = 
		(opcode == `SPECIAL);

	// I-type: addiu, lui, lw, sw, sb, b, bltz, bne, bnez
	// pseudo-instructions: 
	// 	li a, imm = 
	// 		lui a, upper_16(imm)
	// 		ori a, a, lower_16(imm)
	//	b label = beq $zero, $zero, label
	//	bnez $r, label = bne $zero, $r, label
	assign is_i_type = 
		(opcode == `ADDIU) |
		(opcode == `LUI) |
		(opcode == `LW) |
		(opcode == `LB) |
		(opcode == `SW) |
		(opcode == `SB) |
		(opcode == `REGIMM) |
		(opcode == `BNE) |
		(opcode == `BEQ) |
		(opcode == `BGTZ) |
		(opcode == `BLEZ) |
		(opcode == `ORI) |
		(opcode == `ANDI) |
		(opcode == `SLTI) |
		(opcode == `SLTIU);

	// J-type: j, jal
	assign is_j_type = 
		(opcode == `J) |
		(opcode == `JAL);

	always @(negedge clock) begin
		if (~(is_r_type | is_i_type | is_j_type)) begin
			$display($time, ": Unclassified opcode found: %b", opcode);
		end
	end

endmodule


`endif


