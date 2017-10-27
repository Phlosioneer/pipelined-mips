`include "memory/mem_pipeline_register.v"
`include "memory/mem.v"

`ifndef MEM_STAGE
`define MEM_STAGE

/** Combines the pipeline register feeding the Memory stage with the memory
 * stage logic.
 */
module mem_stage(input CLK, RegWriteE, MemtoRegE, MemWriteE,
  input [31:0] ALUOutE, WriteDataE,
	input [4:0] WriteRegE, input HasDivE, input [31:0] DivHiE, input [31:0] DivLoE,
	input IsLBE,
  output RegWriteM, MemtoRegM,
  output [31:0] RD, ALUOutM, output [4:0] WriteRegM, output HasDivM,
  output [31:0] DivHiM, output [31:0] DivLoM);

  // Internal wires
  wire MemWriteM;
  wire IsLBM;
  wire [31:0] WriteDataM;
  wire [31:0] raw_mem_output;
  wire [7:0] byte_mem_output;
  wire [31:0] signed_byte_mem_output;

  // Modules
  mem_pipeline_register memPipelineRegister(
    // inputs
    .clk(CLK),
    .RegWriteE(RegWriteE),
    .MemtoRegE(MemtoRegE),
    .MemWriteE(MemWriteE),
    .ALUOutE(ALUOutE),
    .WriteDataE(WriteDataE),
    .WriteRegE(WriteRegE),
    .HasDivE(HasDivE),
    .DivHiE(DivHiE),
    .DivLoE(DivLoE),
    .IsLBE(IsLBE),

    // outputs
    .RegWriteM(RegWriteM),
    .MemtoRegM(MemtoRegM),
    .MemWriteM(MemWriteM),
    .ALUOutM(ALUOutM),
    .WriteDataM(WriteDataM),
    .WriteRegM(WriteRegM),
    .HasDivM(HasDivM),
    .DivHiM(DivHiM),
    .DivLoM(DivLoM),
    .IsLBM(IsLBM));

  Memory dataMemory(
	.A(ALUOutM),
	.WD(WriteDataM),
	.WE(MemWriteM),
	.CLK(CLK),
	.MemToRegM(MemtoRegM),
	.RegWriteM(RegWriteM),
	.RD(raw_mem_output));

  assign byte_mem_output = raw_mem_output[7:0];

  assign RD = IsLBM ? signed_byte_mem_output : raw_mem_output;

  byte_sign_extend byte_extender(byte_mem_output, signed_byte_mem_output);

endmodule

module byte_sign_extend(in, out);
	input wire signed [7:0] in;
	output wire signed [31:0] out;

	assign out = in;

endmodule

`endif
