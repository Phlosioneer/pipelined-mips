`ifndef MIPS_H
`include "mips.h"
`endif

`ifndef EXECUTE_PIPELINE_REG
`define EXECUTE_PIPELINE_REG

`include "register/pipeline_reg.v"

// This module encapsulates the entire execute pipeline register.
module execute_pipeline_reg(clock, flush_e, reg_write_d, mem_to_reg_d, mem_write_d, alu_op_d,
	alu_src_d, reg_dest_d, rs_value_d, rt_value_d, RsD, RtD, RdD, SignImmD, shamtD,
	syscallD, syscall_functD, syscall_param1D, HasDivD, IsByteD,
	RegWriteE, MemtoRegE, MemWriteE, ALUControlE, ALUSrcE, RegDstE,
	RD1E, RD2E, RsE, RtE, RdE, SignImmE, shamtE, syscallE, syscall_functE, syscall_param1E,
	HasDivE, IsByteE);

	// The clock.
	input wire clock;

	// The flag from the Hazard Unit raised when this pipeline stage should be
	// flushed.
	input wire flush_e;

	/*** The following inputs are fed from the Decode pipeline stage ***/

	// The control signal denoting whether a register is written to.
	input wire reg_write_d;

	// The control signal denoting whether data is being written from
	// memory to a register.
	input wire mem_to_reg_d;

	// The control signal denoting whether main memory is being written to.
	input wire mem_write_d;

	// The four-bit ALU op denoting which operation the ALU should perform.
	input wire [3:0] alu_op_d;

	// The control signal denoting whether the ALU input is an immediate value.
	input wire alu_src_d;

	// The control signal denoting whether the write reg is rd (R-type instr).
	input wire reg_dest_d;

	// The data read from the first source register (rs).
	input wire [31:0] rs_value_d;

	// The data read from the second source register (rt).
	input wire [31:0] rt_value_d;

	// The first source register.
	input wire [4:0] RsD;

	// The second source register.
	input wire [4:0] RtD;

	// The destination register.
	input wire [4:0] RdD;

	// The sign-extended immediate value.
	input wire [31:0] SignImmD;

	// The shift immediate value
	input wire [4:0] shamtD;

	// Logic for the syscall unit.
	input wire syscallD;
	input wire [31:0] syscall_functD;
	input wire [31:0] syscall_param1D;

	// 1 if the outputs of a divide are being written to register,
	// 0 otherwise.
	input wire HasDivD;

	input wire IsByteD;

	/*** The following outputs are generated by the Execute pipeline stage ***/

	// The control signal denoting whether a register is written to.
	output wire RegWriteE;

	// The control signal denoting whether data is being written from
	// memory to a register.
	output wire MemtoRegE;

	// The control signal denoting whether main memory is being written to.
	output wire MemWriteE;

	// The four-bit ALU op denoting which operation the ALU should perform.
	output wire [3:0] ALUControlE;

	// The control signal denoting whether the ALU input is an immediate value.
	output wire ALUSrcE;

	// The control signal denoting whether the write reg is rd (R-type instr).
	output wire RegDstE;

	// The data read from the first source register (rs).
	output wire [31:0] RD1E;

	// The data read from the second source register (rt).
	output wire [31:0] RD2E;

	// The first source register.
	output wire [4:0] RsE;

	// The second source register.
	output wire [4:0] RtE;

	// The destination register.
	output wire [4:0] RdE;

	// The sign-extended immediate value.
	output wire [31:0] SignImmE;

	// Logic for the syscall unit.
	output wire syscallE;
	output wire [31:0] syscall_functE;
	output wire [31:0] syscall_param1E;

	// The sign extend
	output wire [4:0] shamtE;

    output wire HasDivE;

	output wire IsByteE;

 	// 1-bit values to propagate
 	pipeline_reg_1bit reg_write(clock, !flush_e, reg_write_d, RegWriteE);
 	pipeline_reg_1bit mem_to_reg(clock, !flush_e, mem_to_reg_d, MemtoRegE);
 	pipeline_reg_1bit mem_write(clock, !flush_e, mem_write_d, MemWriteE);
 	pipeline_reg_1bit alu_src(clock, !flush_e, alu_src_d, ALUSrcE);
 	pipeline_reg_1bit reg_dst(clock, !flush_e, reg_dest_d, RegDstE);
	pipeline_reg_1bit syscall(clock, !flush_e, syscallD, syscallE);
	pipeline_reg_1bit HasDiv(clock, !flush_e, HasDivD, HasDivE);
	pipeline_reg_1bit IsByte(clock, !flush_e, IsByteD, IsByteE);
 
 	// 5-bit values to propagate
 	pipeline_reg_5bit rs(clock, !flush_e, RsD, RsE);
 	pipeline_reg_5bit rt(clock, !flush_e, RtD, RtE);
 	pipeline_reg_5bit rd(clock, !flush_e, RdD, RdE);
	pipeline_reg_5bit shamt(clock, !flush_e, shamtD, shamtE);

 	// 32-bit values to propagate
 	pipeline_reg rd1(clock, !flush_e, rs_value_d, RD1E);
 	pipeline_reg rd2(clock, !flush_e, rt_value_d, RD2E);
 	pipeline_reg sign_imm(clock, !flush_e, SignImmD, SignImmE);
	pipeline_reg syscall_funct(clock, !flush_e, syscall_functD, syscall_functE);
	pipeline_reg syscall_param1(clock, !flush_e, syscall_param1D, syscall_param1E);

 	pipeline_reg_4bit alu_control(clock, !flush_e, alu_op_d, ALUControlE);
	

endmodule
`endif
