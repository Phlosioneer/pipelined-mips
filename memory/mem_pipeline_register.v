`ifndef MIPS_H
`include "mips.h"
`endif

`include "register/pipeline_reg.v"

`ifndef MEM_PIPELINE_REGISTER
`define MEM_PIPELINE_REGISTER

// This module encapsulates the entire memory pipeline register.
module mem_pipeline_register(clock, reg_write_e, mem_to_reg_e, mem_write_e, alu_out_e, write_data_e,
	write_reg_e, has_div_e, div_hi_e, div_lo_e, is_byte_e, reg_write_m, mem_to_reg_m, mem_write_m, alu_out_m,
	write_data_m, write_reg_m, has_div_m, div_hi_m, div_lo_m, is_byte_m);

	// The clock.
	input wire clock;

	/*** The following inputs are fed from the Execute pipeline stage ***/

	// The control signal denoting whether a register is written to.
	input wire reg_write_e;

	// The control signal denoting whether data is being written from
	// memory to a register.
	input wire mem_to_reg_e;

	// The control signal denoting whether main memory is being written to.
	input wire mem_write_e;

	// The 32-bit output computed by the ALU.
	input wire [31:0] alu_out_e;

	// The 32-bit value to write to memory.
	input wire [31:0] write_data_e;

	// The 5-bit register code that will be written to.
	input wire [4:0] write_reg_e;

	input wire has_div_e;
	input wire [31:0] div_hi_e;
	input wire [31:0] div_lo_e;

	input wire is_byte_e;

	/*** The following outputs are generated by the Memory pipeline stage ***/

	// The control signal denoting whether a register is written to.
	output reg_write_m;

	// The control signal denoting whether data is being written from
	// memory to a register.
	output mem_to_reg_m;

	// The control signal denoting whether main memory is being written to.
	output mem_write_m;

	// The 32-bit output computed by the ALU.
	output [31:0] alu_out_m;

	// The 32-bit value to write to memory.
	output [31:0] write_data_m;

	// The 5-bit register code that will be written to.
	output [4:0] write_reg_m;

	output wire has_div_m;
	output wire [31:0] div_hi_m;
	output wire [31:0] div_lo_m;

	output wire is_byte_m;

	// Values in the mem stage will always pass through
	// TODO: What is the purpose of this??
	wire signal;
	assign signal = 0;

	// Propagate values
	pipeline_reg_1bit reg_write(clock, signal, reg_write_e, reg_write_m);
	pipeline_reg_1bit mem_to_reg(clock, signal, mem_to_reg_e, mem_to_reg_m);
	pipeline_reg_1bit mem_write(clock, signal, mem_write_e, mem_write_m);
	pipeline_reg_1bit HasDiv(clock, signal, has_div_e, has_div_m);
	pipeline_reg_1bit IsByte(clock, signal, is_byte_e, is_byte_m);
	pipeline_reg DivHi(clock, signal, div_hi_e, div_hi_m);
	pipeline_reg DivLo(clock, signal, div_lo_e, div_lo_m);
	pipeline_reg alu_out(clock, signal, alu_out_e, alu_out_m);
	pipeline_reg write_data(clock, signal, write_data_e, write_data_m);
	pipeline_reg_5bit write_reg(clock, signal, write_reg_e, write_reg_m);

endmodule
`endif
