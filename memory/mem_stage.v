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
	input IsByteE,
  output RegWriteM, MemtoRegM,
  output [31:0] RD, ALUOutM, output [4:0] WriteRegM, output HasDivM,
  output [31:0] DivHiM, output [31:0] DivLoM);

  // Internal wires
  wire MemWriteM;
  wire IsByteM;
  wire [31:0] WriteDataM;
  wire [31:0] raw_mem_output;
  wire [7:0] byte_mem_output;
  wire [31:0] signed_byte_mem_output;
  wire [1:0] byte_index;
  wire [31:0] masked_mem_input;
  wire [31:0] raw_mem_input;

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
    .IsByteE(IsByteE),

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
    .IsByteM(IsByteM));

  Memory dataMemory(
	.A(ALUOutM),
	.WD(raw_mem_input),
	.WE(MemWriteM),
	.CLK(CLK),
	.MemToRegM(MemtoRegM),
	.RegWriteM(RegWriteM),
	.RD(raw_mem_output));

  assign byte_index = ALUOutM[1:0];

  word_indexer indexer(raw_mem_output, byte_index, byte_mem_output);
  word_masker masker(WriteDataM, raw_mem_output, byte_index, masked_mem_input);

  assign RD = IsByteM ? signed_byte_mem_output : raw_mem_output;
  assign raw_mem_input = IsByteM ? masked_mem_input : WriteDataM;

  byte_sign_extend byte_extender(byte_mem_output, signed_byte_mem_output);

endmodule

module byte_sign_extend(in, out);
	input wire signed [7:0] in;
	output wire signed [31:0] out;

	assign out = in;

endmodule

// Note: There is no separationg between orig_word and output_word.
// To avoid logic loops, supply memory between them.
// To avoid race conditions, only assign the value of output_word
// at a clock edge, with a nonblocking assign.
module word_masker(input_word, orig_word, index, output_word);
	
	input wire [31:0] input_word;
	input wire [31:0] orig_word;
	input wire [1:0] index;
	output wire [31:0] output_word;

	wire [31:0] mask;
	wire [31:0] pure_byte;
	wire [31:0] byteless_word;

	assign mask = 32'hFF << (index * 8);

	assign pure_byte = mask & input_word;

	assign byteless_word = (~mask) & orig_word;

	assign output_word = pure_byte | byteless_word;

endmodule

module word_indexer(word, index, byte);

        input wire [31:0] word;
        input wire [1:0] index;
        output wire [7:0] byte;

        wire [31:0] shifted_word;

        assign shifted_word = word >> (8 * index);

        assign byte = shifted_word[7:0];

endmodule



`endif
