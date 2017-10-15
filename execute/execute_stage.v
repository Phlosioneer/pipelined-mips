`ifndef MIPS_H
`include "../mips.h"
`endif

`ifndef EXECUTE_TEST
`define EXECUTE_TEST

// This module encapsulates the entire execute stage.
module execute_test(clk, FlushE, RegWriteD, MemtoRegD, MemWriteD, ALUControlD,
	ALUSrcD, RegDstD, RD1, RD2, RsD, RtD, RdD, SignImmD,
	RegWriteE, MemtoRegE, MemWriteE, ALUControlE, ALUSrcE, RegDstE,
	RD1E, RD2E, RsE, RtE, RdE, SignImmE,
	ResultW, ALUOutM, ForwardAE, ForwardBE, 
	WriteRegE, WriteDataE, ALUOutE);

	// The clock.
	input wire clk;

	// The flag from the Hazard Unit raised when this pipeline stage should be
	// flushed.
	input wire FlushE;

	/*** The following inputs are fed from the Decode pipeline stage ***/

	// The control signal denoting whether a register is written to.
	input wire RegWriteD;

	// The control signal denoting whether data is being written from
	// memory to a register.
	input wire MemtoRegD;

	// The control signal denoting whether main memory is being written to.
	input wire MemWriteD;

	// The four-bit ALU op denoting which operation the ALU should perform.
	input wire [3:0] ALUControlD;

	// The control signal denoting whether the ALU input is an immediate value.
	input wire ALUSrcD;

	// The control signal denoting whether the write reg is rd (R-type instr).
	input wire RegDstD;

	// The data read from the first source register (rs).
	input wire [31:0] RD1;

	// The data read from the second source register (rt).
	input wire [31:0] RD2;

	// The first source register.
	input wire [4:0] RsD;

	// The second source register.
	input wire [4:0] RtD;

	// The destination register.
	input wire [4:0] RdD;

	// The sign-extended immediate value.
	input wire [31:0] SignImmD;

	/*** The following inputs are fed from elsewhere ***/

	// The chosen value to write (may be ALU output or from data memory).
	input wire [31:0] ResultW;

	// The output of the ALU after it has passed through the Memory pipeline reg.
	input wire [31:0] ALUOutM;

	// The input to the mux (from Hazard Unit) that determines SrcAE.
	input wire [1:0] ForwardAE;

	// The input to the mux (from Hazard Unit) that determines SrcBE.
	input wire [1:0] ForwardBE;


	/*** The following outputs are generated by the Execute pipeline stage ***/

	// The control signal denoting whether a register is written to.
	output reg RegWriteE;

	// The control signal denoting whether data is being written from
	// memory to a register.
	output reg MemtoRegE;

	// The control signal denoting whether main memory is being written to.
	output reg MemWriteE;

	// The four-bit ALU op denoting which operation the ALU should perform.
	output reg [3:0] ALUControlE;

	// The control signal denoting whether the ALU input is an immediate value.
	output reg ALUSrcE;

	// The control signal denoting whether the write reg is rd (R-type instr).
	output reg RegDstE;

	// The data read from the first source register (rs).
	output reg [31:0] RD1E;

	// The data read from the second source register (rt).
	output reg [31:0] RD2E;

	// The first source register.
	output reg [4:0] RsE;

	// The second source register.
	output reg [4:0] RtE;

	// The destination register.
	output reg [4:0] RdE;

	// The sign-extended immediate value.
	output reg [31:0] SignImmE;

	/*** The following outputs are generated internal to the execute stage ***/

	// The 5-bit register code that will be written to.
	output reg [4:0] WriteRegE;

	// The 32-bit data to write to memory.
	output reg [31:0] WriteDataE;

	// The 32-bit LHS of the ALU operation to perform.
	reg [31:0] SrcAE; // Note: Not a top-level output from the EX stage

	// The 32-bit RHS of the ALU operation to perform.
	reg [31:0] SrcBE; // Note: Not a top-level output from the EX stage

	// The 32-bit output from the ALU.
	output reg [31:0] ALUOutE;

	// Instantiate all muxes, the ALU, and the EX pipeline register

	mux5_2 write_reg_mux(RtE, RdE, RegDstE, WriteRegE);
	mux32_3 write_data_mux(RD2E, ResultW, ALUOutM, ForwardBE, WriteDataE);
	mux32_3 srcA_mux(RD1E, ResultW, ALUOutM, ForwardAE, SrcAE);
	mux32_2 srcB_mux(WriteDataE, SignImmE, ALUSrcE, SrcBE);

	alu myALU(SrcAE, SrcBE, ALUControlE, ALUOutE);

	execute_stage EX_pipeline_reg(clk, FlushE, RegWriteD, MemtoRegD, MemWriteD, 
		ALUControlD, ALUSrcD, RegDstD, RD1, RD2, RsD, RtD, RdD, SignImmD,
		RegWriteE, MemtoRegE, MemWriteE, ALUControlE, ALUSrcE, RegDstE,
		RD1E, RD2E, RsE, RtE, RdE, SignImmE);

endmodule
`endif
