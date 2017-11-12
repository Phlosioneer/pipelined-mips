`include "memory/mem_pipeline_register.v"
`include "memory/mem.v"

`ifndef MEM_STAGE
`define MEM_STAGE

/** Combines the pipeline register feeding the Memory stage with the memory
 * stage logic.
 */
module mem_stage(input clock, reg_write_e, mem_to_reg_e, mem_write_e,
  input [31:0] alu_out_e, write_data_e,
	input [4:0] write_reg_e, input has_div_e, input [31:0] div_hi_e, input [31:0] div_lo_e,
	input is_byte_e,
  output reg_write_m, mem_to_reg_m,
  output [31:0] read_value_m, alu_out_m, output [4:0] write_reg_m, output has_div_m,
  output [31:0] div_hi_m, output [31:0] div_lo_m);

  // Internal wires
  wire mem_write_m;
  wire is_byte_m;
  wire [31:0] write_data_m;
  wire [31:0] raw_mem_output;
  wire [7:0] byte_mem_output;
  wire [31:0] signed_byte_mem_output;
  wire [1:0] byte_index;
  wire [31:0] masked_mem_input;
  wire [31:0] raw_mem_input;

  // Modules
  mem_pipeline_register memPipelineRegister(
    // inputs
    .clock(clock),
    .reg_write_e(reg_write_e),
    .mem_to_reg_e(mem_to_reg_e),
    .mem_write_e(mem_write_e),
    .alu_out_e(alu_out_e),
    .write_data_e(write_data_e),
    .write_reg_e(write_reg_e),
    .has_div_e(has_div_e),
    .div_hi_e(div_hi_e),
    .div_lo_e(div_lo_e),
    .is_byte_e(is_byte_e),

    // outputs
    .reg_write_m(reg_write_m),
    .mem_to_reg_m(mem_to_reg_m),
    .mem_write_m(mem_write_m),
    .alu_out_m(alu_out_m),
    .write_data_m(write_data_m),
    .write_reg_m(write_reg_m),
    .has_div_m(has_div_m),
    .div_hi_m(div_hi_m),
    .div_lo_m(div_lo_m),
    .is_byte_m(is_byte_m));

  Memory dataMemory(
	.address(alu_out_m),
	.write_value(raw_mem_input),
	.enable_write(mem_write_m),
	.clock(clock),
	.mem_to_reg_m(mem_to_reg_m),
	.reg_write_m(reg_write_m),
	.read_value(raw_mem_output));

  assign byte_index = alu_out_m[1:0];

  word_indexer indexer(raw_mem_output, byte_index, byte_mem_output);
  word_masker masker(write_data_m, raw_mem_output, byte_index, masked_mem_input);

  assign read_value_m = is_byte_m ? signed_byte_mem_output : raw_mem_output;
  assign raw_mem_input = is_byte_m ? masked_mem_input : write_data_m;

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

	// Only the lowest byte of the input word is used for writing.
	assign pure_byte = (32'hFF & input_word) << (index * 8);

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
