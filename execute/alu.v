
`ifndef ALU_V
`define ALU_V

`include "mips.h"

module alu(l_value, r_value, alu_op, shamt, result, div_hi, div_lo);

input [31:0] l_value;
input [31:0] r_value;
input [3:0] alu_op;
input [4:0] shamt;
output reg [31:0] result;
output reg [31:0] div_lo;
output reg [31:0] div_hi;

always @(*)
begin
    div_lo = 0;
    div_hi = 0;

    case (alu_op)
        `ALU_add: result = l_value + r_value; // l_value + r_value;
        `ALU_sub: result = l_value - r_value; // l_value - r_value;
        `ALU_OR:  result = l_value | r_value; // l_value | r_value;
        `ALU_AND: result = l_value & r_value; // l_value & r_value;
        `ALU_slt: result = l_value < r_value; // l_value < r_value;
        `ALU_sll: result = l_value << shamt;
        `ALU_sra: result = l_value >>> shamt;
		`ALU_rs_pass: result = l_value;		// Pass along the RS register value.
		`ALU_slli: result = r_value << shamt;	// SLL on an immediate value
		`ALU_div: begin
			div_lo = l_value / r_value;
			div_hi = l_value % r_value;
		end
		`ALU_slt: result = (l_value < r_value);	// 1 if l_value < r_value; 0 otherwise.
        `ALU_undef: result = `dc32;
    endcase
end

endmodule
`endif
