
`ifndef FETCH_MEM_H
`define FETCH_MEM_H

module instr_memory(clock, read_address, mem_instruction, start_addr);
	input clock;
	input [31:0] read_address; 
	output [31:0] mem_instruction;
	output [31:0] start_addr;

	reg [31:0] mem [32'h0010_0000:32'h0010_1000];
	reg is_init;

	// String
	reg [99:0] program;

	// TODO: Integrate with memory/mem.v
	initial begin
		if ($value$plusargs("DAT=%s", program)) begin
			$readmemh(program, mem);
		end else begin
			$readmemh("program.dat", mem);
		end
	is_init = 0;
	end

	always @(posedge clock) begin
		is_init <= 1;
	end

	// -4 to account for the 1 cycle stall at the start of the simulation.
	assign start_addr = mem[32'h0010_0000];
	assign mem_instruction = is_init ? mem[read_address >> 2] : 0;
endmodule

`endif
