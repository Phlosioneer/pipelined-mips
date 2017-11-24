

`ifndef WRITE_PIPELINE_REG
`define WRITE_PIPELINE_REG

`include "register/pipeline_reg.v"

module writeback_pipeline_reg(clock, reg_write_m, mem_to_reg_m, read_value_m, alu_out_m,
	       write_reg_m, has_div_m, div_hi_m, div_lo_m, reg_write_w, mem_to_reg_w, read_value_w,
	       alu_out_w, write_reg_w, has_div_w, div_hi_w, div_lo_w);
	input wire clock;
    input wire reg_write_m; 
    input wire mem_to_reg_m; 
    input wire [31:0] read_value_m; 
    input wire [31:0] alu_out_m; 
    input wire [4:0] write_reg_m; 
    input wire has_div_m;
    input wire [31:0] div_hi_m;
    input wire [31:0] div_lo_m;
    output wire reg_write_w; 
    output wire mem_to_reg_w; 
    output wire [31:0] read_value_w; 
    output wire [31:0] alu_out_w; 
    output wire [4:0] write_reg_w;
    output wire has_div_w;
    output wire [31:0] div_hi_w;
    output wire [31:0] div_lo_w;

    wire clear;
    assign clear = 0;
	pipeline_reg_1bit reg_write(clock, clear, reg_write_m, reg_write_w);
	pipeline_reg_1bit mem_to_reg(clock, clear, mem_to_reg_m, mem_to_reg_w);
	pipeline_reg read_value(clock, clear, read_value_m, read_value_w);
	pipeline_reg alu_out(clock, clear, alu_out_m, alu_out_w);
	pipeline_reg_5bit write_reg(clock, clear, write_reg_m, write_reg_w);
	pipeline_reg_1bit has_div(clock, clear, has_div_m, has_div_w);
	pipeline_reg div_hi(clock, clear, div_hi_m, div_hi_w);
	pipeline_reg div_lo(clock, clear, div_lo_m, div_lo_w);

endmodule

`endif


