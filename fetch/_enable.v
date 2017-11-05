



module enable(prev, curr, flag, clock);
	input [31:0] prev;
	input flag;
	input clock;
	output [31:0] curr;

	always@(posedge clock)
	begin
		if(flag) begin
			curr = prev;
		end
	end

endmodule
