
`ifndef SYSCALL_UNIT_V
`define SYSCALL_UNIT_V


module syscall_unit(is_syscall, syscall_funct, syscall_param1);

	input wire is_syscall;

	input wire [31:0] syscall_funct;
	
	input wire [31:0] syscall_param1;


	always @(*) begin
		if (is_syscall) begin
			case (syscall_funct)
				`SYSCALL_PRINT_INT: $write("%d\n", syscall_param1);
				`SYSCALL_PUT_C: $write("%c", syscall_param1 & 16'hFF);
				`SYSCALL_EXIT: $finish;
			endcase
		end
	end


endmodule



`endif







