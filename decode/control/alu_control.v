


`ifndef ALU_CONTROL_V
`define ALU_CONTROL_V

`include "mips.h"

module alu_control(clock, opcode, funct, alu_op);
	// The clock is only used for error reporting / debugging.
	input wire clock;
	input wire [5:0] opcode;
	input wire [5:0] funct;
	output reg [3:0] alu_op;

	always @(negedge clock) begin
		if ((opcode == `SPECIAL) && (alu_op === 4'bxxxx) && ($time != 0)) begin
			$display($time, ": Uknown function code %b", funct);
		end
	end

	always @(*) begin
		case (opcode)
			`SPECIAL: begin 
				case (funct)
					`SYSCALL: alu_op = 0;
					`JR: alu_op = 0;
					`ADDU: alu_op = `ALU_add;
					`ADD: alu_op = `ALU_add;
					`SUBU: alu_op = `ALU_sub;
					`SRA: alu_op = `ALU_sra;
					`SLL: alu_op = `ALU_sll;
					`DIV: alu_op = `ALU_div;
					`MFHI: alu_op = `ALU_rs_pass;
					`MFLO: alu_op = `ALU_rs_pass;
					`SLT: alu_op = `ALU_slt;
					default: alu_op = `ALU_undef;
				endcase
			end
			`SW: alu_op = `ALU_add;
			`SB: alu_op = `ALU_add;
			`LW: alu_op = `ALU_add;
			`LB: alu_op = `ALU_add;
			`ADDIU: alu_op = `ALU_add;
			`ANDI: alu_op = `ALU_AND;
			`ORI: alu_op = `ALU_OR;
			`LUI: alu_op = `ALU_slli;	// We're shifting the imm value by 16
			`SLTI: alu_op = `ALU_slt;
			`SLTIU: alu_op = `ALU_slt;
			default: alu_op = `ALU_undef;
		endcase
	end
	

endmodule


`endif



