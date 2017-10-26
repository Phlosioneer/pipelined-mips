`ifndef PC_V
`define PC_V

module program_counter(clock, stallf, next_count, starting_addr, cur_count);
input [31:0] next_count;
input stallf;
input clock;
input[31:0] starting_addr;
output reg [31:0] cur_count;

reg is_init;

always @(posedge clock)
begin
    if(stallf==1) begin
        cur_count <= next_count;
    end
    
    if (~is_init) begin
	// See readme for the required starting two bytes of the binary.
    	cur_count <= starting_addr;
	is_init <= 1;
    end
end

initial
begin

	is_init = 0;

end

endmodule

`endif
