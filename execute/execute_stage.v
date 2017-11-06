
`ifndef EXECUTE_STAGE
`define EXECUTE_STAGE

`include "mips.h"
`include "execute/alu.v"
`include "execute/execute_pipeline_reg.v"
`include "execute/syscall_unit.v"
`include "util.v"

// This module encapsulates the entire execute stage.
module execute_stage(clock, flush_e, reg_write_d, mem_to_reg_d, mem_write_d, alu_op_d,
	alu_src_d, reg_dest_d, rs_value_d, rt_value_d, rs_id_d, rt_id_d, rd_id_d, sign_imm_d, shamt_d,
	is_syscall_d, syscall_funct_d, syscall_param_1_d, has_div_d, is_byte_d,
	reg_write_e, mem_to_reg_e, mem_write_e, reg_dest_e,
	rs_id_e, rt_id_e, rd_id_e,
	mem_to_ex_value, ex_to_ex_value, ForwardAE, ForwardBE,
	WriteRegE, WriteDataE, ALUOutE, DivHiE, DivLoE, has_div_e, is_byte_e);

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
	input wire [4:0] rs_id_d;

	// The second source register.
	input wire [4:0] rt_id_d;

	// The destination register.
	input wire [4:0] rd_id_d;

	// The sign-extended immediate value.
	input wire [31:0] sign_imm_d;

	// The shift amount value
	input wire [4:0] shamt_d;

	/*** The following inputs are fed from elsewhere ***/

	// The chosen value to write (may be ALU output or from data memory).
	input wire [31:0] mem_to_ex_value;

	// The output of the ALU after it has passed through the Memory pipeline reg.
	input wire [31:0] ex_to_ex_value;

	// The input to the mux (from Hazard Unit) that determines SrcAE.
	input wire [1:0] ForwardAE;

	// The input to the mux (from Hazard Unit) that determines SrcBE.
	input wire [1:0] ForwardBE;

	// Logic for the syscall unit.
	input wire is_syscall_d;
	input wire [31:0] syscall_funct_d;
	input wire [31:0] syscall_param_1_d;

	// 1 if the outputs of a divide operation are being written to
	// registers; 0 otherwise.
	input wire has_div_d;

	input wire is_byte_d;

	/*** The following outputs are generated by the Execute pipeline stage ***/

	// The control signal denoting whether a register is written to.
	output wire reg_write_e;

	// The control signal denoting whether data is being written from
	// memory to a register.
	output wire mem_to_reg_e;

	// The control signal denoting whether main memory is being written to.
	output wire mem_write_e;

	// The four-bit ALU op denoting which operation the ALU should perform.
	wire [3:0] alu_op_e;

	// The control signal denoting whether the ALU input is an immediate value.
	wire alu_src_e;

	// The control signal denoting whether the write reg is rd (R-type instr).
	output wire reg_dest_e;

	// The data read from the first source register (rs).
	wire [31:0] rs_value_e;

	// The data read from the second source register (rt).
	wire [31:0] rt_value_e;

	// The first source register.
	output wire [4:0] rs_id_e;

	// The second source register.
	output wire [4:0] rt_id_e;

	// The destination register.
	output wire [4:0] rd_id_e;

	// The sign-extended immediate value.
	wire [31:0] sign_imm_e;

	/*** The following outputs are generated internal to the execute stage ***/

	// The 5-bit register code that will be written to.
	output wire [4:0] WriteRegE;

	// The 32-bit data to write to memory.
	output wire [31:0] WriteDataE;

	// The outputs of a divide instruction; 0 otherwise.
	output wire [31:0] DivHiE;
	output wire [31:0] DivLoE;

	// This is 1 if the outputs of a divide instruction are being written
	// to the registers; 0 otherwise.
	output wire has_div_e;

	output wire is_byte_e;

	// The 32-bit output from the ALU.
	output wire [31:0] ALUOutE;

	// The 32-bit LHS of the ALU operation to perform.
	wire [31:0] SrcAE; // Note: Not a top-level output from the EX stage

	// The 32-bit RHS of the ALU operation to perform.
	wire [31:0] SrcBE; // Note: Not a top-level output from the EX stage

	// The execute stage's shift immediate value
	wire [4:0] shamt_e;

	// Logic for the syscall unit.
	wire syscall_e;
	wire [31:0] syscall_funct_e;
	wire [31:0] syscall_param_1_e;

	// Instantiate all muxes, the ALU, and the EX pipeline register

	execute_pipeline_reg EX_pipeline_reg(
		.clock(clock), 
		.flush_e(flush_e), 
		.reg_write_d(reg_write_d),
		.mem_to_reg_d(mem_to_reg_d),
		.mem_write_d(mem_write_d),
		.alu_op_d(alu_op_d),
		.alu_src_d(alu_src_d),
		.reg_dest_d(reg_dest_d),
		.rs_value_d(rs_value_d),
		.rt_value_d(rt_value_d),
		.rs_id_d(rs_id_d),
		.rt_id_d(rt_id_d),
		.rd_id_d(rd_id_d),
		.sign_imm_d(sign_imm_d),
		.shamt_d(shamt_d),
		.is_syscall_d(is_syscall_d),
		.syscall_funct_d(syscall_funct_d),
		.syscall_param_1_d(syscall_param_1_d),
		.has_div_d(has_div_d),
		.is_byte_d(is_byte_d),
		
		.reg_write_e(reg_write_e),
		.mem_to_reg_e(mem_to_reg_e),
		.mem_write_e(mem_write_e),
		.alu_op_e(alu_op_e),
		.alu_src_e(alu_src_e),
		.reg_dest_e(reg_dest_e),
		.rs_value_e(rs_value_e),
		.rt_value_e(rt_value_e),
		.rs_id_e(rs_id_e),
		.rt_id_e(rt_id_e),
		.rd_id_e(rd_id_e),
		.sign_imm_e(sign_imm_e),
		.shamt_e(shamt_e),
		.syscall_e(syscall_e),
		.syscall_funct_e(syscall_funct_e),
		.syscall_param_1_e(syscall_param_1_e),
		.has_div_e(has_div_e),
		.is_byte_e(is_byte_e));

	mux5_2 write_reg_mux(rd_id_e, rt_id_e, reg_dest_e, WriteRegE);
	mux32_3 write_data_mux(rt_value_e, mem_to_ex_value, ex_to_ex_value, ForwardBE, WriteDataE);
	mux32_3 srcA_mux(rs_value_e, mem_to_ex_value, ex_to_ex_value, ForwardAE, SrcAE);
	mux32_2 srcB_mux(sign_imm_e, WriteDataE, alu_src_e, SrcBE);

	alu myALU(
		.l_value(SrcAE),
		.r_value(SrcBE),
		.alu_op(alu_op_e),
		.shamt(shamt_e),
		.result(ALUOutE),
		.div_hi(DivHiE),
		.div_lo(DivLoE)
		);
	
	syscall_unit syscall_unit(syscall_e, syscall_funct_e, syscall_param_1_e);

endmodule
`endif
