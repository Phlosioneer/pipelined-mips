
`ifndef CPU_V
`define CPU_V

`include "execute/execute_stage.v"
`include "decode/decode_stage.v"
`include "fetch/fetch.v"
`include "memory/mem_stage.v"
`include "register/fetch_pipeline_reg.v"
`include "register/writeback_pipeline_reg.v"
`include "hazard/hazard_unit.v"
module cpu(clock);

	input wire clock;
	
	// Inputs from control and decode
	wire [31:0] pc_branch_d;
	wire pc_src_d;

	// Input from hazard unit
	wire stall_f;
	wire stall_d;

	wire flush_e;
	 
	wire [1:0] forward_rs_e;
	wire [1:0] forward_rt_e;
	
	// Outputs to decode
	wire [31:0] pc_plus_4_f;
	wire [31:0] pc_plus_4_d;
	wire [31:0] instruction_f;
	wire [31:0] instruction_d;

	wire reg_write_d;
	wire mem_to_reg_d;
	wire mem_write_d;
	wire [3:0] alu_op;
	wire alu_src_d;
	wire reg_dest_d;
	wire [31:0] rs_value_d;
	wire [31:0] rt_value_d;
	wire [4:0] rs_id_d;
	wire [4:0] rt_id_d;
	wire [4:0] rd_id_d;
	wire [31:0] sign_imm_d;
	wire syscall_d;
	wire [31:0] syscall_funct_d;
	wire [31:0] syscall_param_1_d;

	wire reg_write_e;
	wire mem_to_reg_e;
	wire mem_write_e;
	wire reg_dest_e;
	// ALU outputs
	wire [4:0] rs_id_e;
	wire [4:0] rt_id_e;
	wire [4:0] rd_id_e;
	wire [31:0] write_data_e;
	wire [31:0] alu_out_e;


	// Outputs to EX
	wire [4:0] shamt_d;

	// Outputs of the memory stage.
	wire reg_write_m;
	wire mem_to_reg_m;
	wire [31:0] read_value_m; 
	wire [31:0] ex_to_ex_m;
	wire [4:0] rd_id_m;
	
	// Outputs of Writeback pipe
	wire reg_write_w;
	wire mem_to_reg_w;
	wire [31:0] read_value_w;
	wire [31:0] alu_out_w;
	wire [4:0] rd_id_w;
	
	// This control signal is true if the decode stage has decoded a MFHI or
	// MFLO opcode. It's used by the hazard unit.
	wire mf_op_in_d;

	// Divide stuff.
	wire has_div_d;
	wire has_div_e;
	wire has_div_m;
	wire has_div_w;
	wire [31:0] div_hi_e;
	wire [31:0] div_hi_m;
	wire [31:0] div_hi_w;
	wire [31:0] div_lo_e;
	wire [31:0] div_lo_m;
	wire [31:0] div_lo_w;

	wire is_byte_d;
	wire is_byte_e;

	//this wire is a mux for writeback_value_w
	//TODO: Move this to the memory stage?
	wire [31:0] writeback_value_w;
	assign writeback_value_w = mem_to_reg_w ? read_value_w : alu_out_w;

	// This is true if the current instruction is a jump / branch instruction.
	// This is distinct from pc_branch_d, which stores the pc to jump to.
	// This is distinct from pc_src_d, which decides whether the processor
	// actually jumps.
	wire branch_d;

	fetch fetch(
		.clock(clock),
		
		// Inputs from decode and control.
		.pc_branch_d(pc_branch_d),
		.pc_src_d(pc_src_d),
		
		// Inputs from the hazard unit.
		.stall_f(stall_f),

		// Outputs to the decode stage.
		.pc_plus_4_f(pc_plus_4_f),
		.instruction_f(instruction_f)
		);
	fetch_pipeline_reg fpipe(
		.clock(clock),
		.clear(pc_src_d),
		.stall_d(stall_d),
		.pc_plus_four_f(pc_plus_4_f),
		.instruction_f(instruction_f),
		.pc_plus_four_d(pc_plus_4_d),
		.instruction_d(instruction_d)
		);

	decode_stage decode(
		.clock(clock),
			
		// Inputs from fetch.
		.instruction(instruction_d),
		.pc_plus_four(pc_plus_4_d), 
	
		// Inputs from writeback.
		.writeback_value(writeback_value_w), 
		.writeback_id(rd_id_w), 
		.reg_write_w(reg_write_w),
		.has_div_w(has_div_w),
		.div_hi_w(div_hi_w),
		.div_lo_w(div_lo_w),

		// Decode to EX.
		.reg_rs_value(rs_value_d),
		.reg_rt_value(rt_value_d),
		.immediate(sign_imm_d),
		.reg_rs_id(rs_id_d),
		.reg_rt_id(rt_id_d),
		.reg_rd_id(rd_id_d),
		.shamt_d(shamt_d),

		// Control to EX
		.reg_write_d(reg_write_d),
		.mem_to_reg(mem_to_reg_d),
		.mem_write(mem_write_d),
		.alu_op(alu_op),
		.alu_src(alu_src_d),
		.reg_dest(reg_dest_d),
		.has_div_d(has_div_d),
		.is_byte_d(is_byte_d),

		// Control to Hazard
		.mf_op_in_d(mf_op_in_d),
		.branch_d(branch_d),

		// Outputs back to fetch.
		.pc_src (pc_src_d),
		.jump_address(pc_branch_d),

		// Syscall logic
		.syscall(syscall_d),
		.syscall_funct(syscall_funct_d),
		.syscall_param_1(syscall_param_1_d)
		);

	execute_stage EX_stage(
		.clock(clock),
	
		// Input from the hazard control unit.
		.flush_e(flush_e),
	
		// Input from the decode stage.
		.reg_write_d(reg_write_d),
		.mem_to_reg_d(mem_to_reg_d),
		.mem_write_d(mem_write_d),
		.alu_op_d(alu_op),
		.alu_src_d(alu_src_d),
		.reg_dest_d(reg_dest_d),
		.rs_value_d(rs_value_d),
		.rt_value_d(rt_value_d),
		.rs_id_d(rs_id_d),
		.rt_id_d(rt_id_d),
		.rd_id_d(rd_id_d),
		.sign_imm_d(sign_imm_d),
		.shamt_d(shamt_d),
		.is_syscall_d(syscall_d),
		.syscall_funct_d(syscall_funct_d),
		.syscall_param_1_d(syscall_param_1_d),
		.has_div_d(has_div_d),
		.is_byte_d(is_byte_d),
		.ex_to_ex_value(ex_to_ex_m),
		.mem_to_ex_value(writeback_value_w),

		// Output to the mem stage.
		.reg_write_e(reg_write_e),
		.mem_to_reg_e(mem_to_reg_e),
		.mem_write_e(mem_write_e),
		.reg_dest_e(reg_dest_e),
		.rs_id_e(rs_id_e),
		.rt_id_e(rt_id_e),
		.has_div_e(has_div_e),
		.div_hi_e(div_hi_e),
		.div_lo_e(div_lo_e),
		.is_byte_e(is_byte_e),

		// Input from the hazard unit.
		.forward_rs_e(forward_rs_e),
		.forward_rt_e(forward_rt_e),

		// Wires from the control unit forwarded to the mem stage.
		.write_reg_e(rd_id_e),
		.write_data_e(write_data_e),
		.alu_out_e(alu_out_e)
		);

	mem_stage myMemStage(
		.clock(clock),

		// Input from the Execute stage.
		.reg_write_e(reg_write_e),
		.mem_to_reg_e(mem_to_reg_e),
		.mem_write_e(mem_write_e),
		.alu_out_e(alu_out_e),
		.write_data_e(write_data_e),
		.write_reg_e(rd_id_e),			// TODO: Rename this in the memory stage.
		.has_div_e(has_div_e),
		.div_hi_e(div_hi_e),
		.div_lo_e(div_lo_e),
		.is_byte_e(is_byte_e),

		// Output to the WB stage.
		.reg_write_m(reg_write_m),
		.mem_to_reg_m(mem_to_reg_m),
		.read_value_m(read_value_m),
		.write_reg_m(rd_id_m),			// TODO: Rename this in the memory stage.
		.has_div_m(has_div_m),
		.div_hi_m(div_hi_m),
		.div_lo_m(div_lo_m),

		// This output is used for ex->ex forwarding.
		.alu_out_m(ex_to_ex_m)
		);
	
	writeback_pipeline_reg wpipe(
		.clock(clock), 
		.reg_write_m(reg_write_m),
		.mem_to_reg_m(mem_to_reg_m), 
		.read_value_m(read_value_m), 
		.alu_out_m(ex_to_ex_m), 
		.write_reg_m(rd_id_m),
		.has_div_m(has_div_m),
		.div_hi_m(div_hi_m),
		.div_lo_m(div_lo_m), 
		.reg_write_w(reg_write_w), 
		.mem_to_reg_w(mem_to_reg_w), 
		.read_value_w(read_value_w), 
		.alu_out_w(alu_out_w), 
		.write_reg_w(rd_id_w),
		.has_div_w(has_div_w),
		.div_hi_w(div_hi_w),
		.div_lo_w(div_lo_w)
		);
	
	hazard_unit hazard(
		// Inputs
		.rs_id_d(rs_id_d),
		.rt_id_d(rt_id_d),
		.branch_d(branch_d),
		.rs_id_e(rs_id_e),
		.rt_id_e(rt_id_e),
		.write_reg_e(rd_id_e),
		.mem_to_reg_e(mem_to_reg_e),
		.reg_write_e(reg_write_e),
		.rd_id_m(rd_id_m),
		.mem_to_reg_m(mem_to_reg_m),
		.reg_write_m(reg_write_m),
		.rd_id_w(rd_id_w),
		.reg_write_w(reg_write_w),
		.syscall_d(syscall_d),
		.mf_op_in_d(mf_op_in_d),
		.has_div_e(has_div_e),
		.has_div_m(has_div_m),
		.has_div_w(has_div_w),

		// Outputs
		.stall_f(stall_f),
		.stall_d(stall_d),
		.flush_e(flush_e),
		.forward_rs_e(forward_rs_e),
		.forward_rt_e(forward_rt_e)
		);



endmodule

`endif
