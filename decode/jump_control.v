

`ifndef JUMP_CONTROL_V
`define JUMP_CONTROL_V



module jump_control(opcode, funct, regimm, bgt, beq, blt, rt_is_zero, link_reg);
	input wire [5:0] opcode;
	input wire [5:0] funct;
	input wire [4:0] regimm;
	output wire bgt;
	output wire beq;
	output wire blt;
	output wire rt_is_zero;
	output wire link_reg;

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





