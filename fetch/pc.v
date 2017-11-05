`ifndef PC_V
`define PC_V

module program_counter(clock, stall_f, next_count, starting_addr, curr_count);
	input [31:0] next_count;
	input stall_f;
	input clock;
	input[31:0] starting_addr;
	output reg [31:0] curr_count;

	reg is_init;

	always @(posedge clock)
		begin
		if(stall_f == 1) begin
			curr_count <= next_count;
		end
    
		if (~is_init) begin
			// See readme for the required starting two bytes of the binary.
			//cur_count <= starting_addr;
			curr_count <= 32'h0040_0000;
			is_init <= 1;
		end
	end

	initial
	begin
		is_init = 0;
	end

endmodule

`endif
