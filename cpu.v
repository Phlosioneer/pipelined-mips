
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
    wire StallF;
    wire StallD;

    wire FlushE;
     
    wire [1:0] forward_rs_e;
    wire [1:0] forward_rt_e;
    
    // Outputs to decode
    wire [31:0] pc_plus_4f;
    wire [31:0] pc_plus_4d;
    wire [31:0] instructionf;
    wire [31:0] instructiond;

    wire RegWriteD;
    wire MemtoRegD;
    wire MemWriteD;
    wire [3:0] ALUControlD;
    wire ALUSrcD;
    wire RegDstD;
    wire [31:0] RD1D;
    wire [31:0] RD2D;
    wire [4:0] RsD;
    wire [4:0] RtD;
    wire [4:0] RdD;
    wire [31:0] SignImmD;
    wire syscallD;
    wire [31:0] syscall_functD;
    wire [31:0] syscall_param1D;

    wire RegWriteE;
    wire MemtoRegE;
    wire MemWriteE;
    wire RegDstE;
    wire [3:0] ALUControlE;
    // ALU outputs (ignored)
    wire [31:0] RD1E;   // ALU outputs.
    wire [31:0] RD2E;
    wire [4:0] RsE;
    wire [4:0] RtE;
    wire [4:0] RdE;
    wire [31:0] SignImmE;
    wire [4:0] shamtE;
    wire [4:0] WriteRegE;
    wire [31:0] WriteDataE;
    wire [31:0] ALUOutE;

    // Inputs from the Fetch stage.
    wire [31:0] instruction;
    wire [31:0] pc_plus_four;

    // Outputs to EX
    wire [4:0] shamtD;

    // Outputs of the memory stage.
    wire RegWriteM;
    wire MemtoRegM;
    wire [31:0] Writeback_RD; 
    wire [31:0] ALUOutM;
    wire [4:0] WriteRegM;
    
    // Outputs of Writeback pipe
    wire RegWriteW;
    wire MemtoRegW;
    wire [31:0] ReadDataW;
    wire [31:0] ALUOutW;
    wire [4:0] WriteRegW;
    
    // This control signal is true if the decode stage has decoded a MFHI or
    // MFLO opcode. It's used by the hazard unit.
    wire MfOpInD;

    // Divide stuff.
    wire HasDivD;
    wire HasDivE;
    wire HasDivM;
    wire HasDivW;
    wire [31:0] DivHiE;
    wire [31:0] DivHiM;
    wire [31:0] DivHiW;
    wire [31:0] DivLoE;
    wire [31:0] DivLoM;
    wire [31:0] DivLoW;

    wire IsByteD;
    wire IsByteE;

    //this wire is a mux for ResultW
    wire [31:0] ResultW;
    assign ResultW = MemtoRegW ? ReadDataW : ALUOutW;

    // This is true if the current instruction is a jump / branch instruction.
    // This is distinct from pc_branch_d, which stores the pc to jump to.
    // This is distinct from pc_src_d, which decides whether the processor
    // actually jumps.
    wire BranchD;

    fetch fetch(
        .clock(clock),
        
        // Inputs from decode and control.
        .pc_branch_d(pc_branch_d),
        .pc_src_d(pc_src_d),
        
        // Inputs from the hazard unit.
        .stall_f(StallF),

        // Outputs to the decode stage.
        .pc_plus_4_f(pc_plus_4f),
        .instruction_f(instructionf)
        );
     fetch_pipeline_reg fpipe(
       .clock(clock)
     , .clear(pc_src_d)
     , .StallD(StallD)
     , .pc_plus_four_F(pc_plus_4f)
     , .instruction_F(instructionf)
     , .pc_plus_four_D(pc_plus_4d)
     , .instruction_D(instructiond));

    decode_stage decode(
        .clock(clock),
            
        // Inputs from fetch.
        .instruction(instructiond),
        .pc_plus_four(pc_plus_4d), 
    
        // Inputs from writeback.
        .writeback_value(ResultW), 
        .writeback_id(WriteRegW), 
        .reg_write_w(RegWriteW),
		.has_div_w(HasDivW),
		.div_hi_w(DivHiW),
		.div_lo_w(DivLoW),

        // Decode to EX.
        .reg_rs_value(RD1D),
        .reg_rt_value(RD2D),
        .immediate(SignImmD),
        .reg_rs_id(RsD),
        .reg_rt_id(RtD),
        .reg_rd_id(RdD),
        .shamt_d(shamtD),

        // Control to EX
        .reg_write_d(RegWriteD),
        .mem_to_reg(MemtoRegD),
        .mem_write(MemWriteD),
        .alu_op(ALUControlD),
        .alu_src(ALUSrcD),
        .reg_dest(RegDstD),
		.has_div_d(HasDivD),
		.is_byte_d(IsByteD),

		// Control to Hazard
		.mf_op_in_d(MfOpInD),
		.branch_d(BranchD),

		// Outputs back to fetch.
		.pc_src (pc_src_d),
	    .jump_address(pc_branch_d),

		// Syscall logic
		.syscall(syscallD),
		.syscall_funct(syscall_functD),
		.syscall_param_1(syscall_param1D)
        );

    execute_stage EX_stage(
        .clock(clock),
    
        // Input from the hazard control unit.
        .flush_e(FlushE),
    
        // Input from the decode stage.
        .reg_write_d(RegWriteD),
        .mem_to_reg_d(MemtoRegD),
        .mem_write_d(MemWriteD),
        .alu_op_d(ALUControlD),
        .alu_src_d(ALUSrcD),
        .reg_dest_d(RegDstD),
        .rs_value_d(RD1D),
        .rt_value_d(RD2D),
        .rs_id_d(RsD),
        .rt_id_d(RtD),
        .rd_id_d(RdD),
        .sign_imm_d(SignImmD),
        .shamt_d(shamtD),
		.is_syscall_d(syscallD),
		.syscall_funct_d(syscall_functD),
		.syscall_param_1_d(syscall_param1D),
		.has_div_d(HasDivD),
		.is_byte_d(IsByteD),
		.ex_to_ex_value(ALUOutM),
        .mem_to_ex_value(ResultW),

        // Output to the mem stage.
        .reg_write_e(RegWriteE),
        .mem_to_reg_e(MemtoRegE),
        .mem_write_e(MemWriteE),
        .reg_dest_e(RegDstE),
        .rs_id_e(RsE),
        .rt_id_e(RtE),
        .rd_id_e(RdE),
		.has_div_e(HasDivE),
		.div_hi_e(DivHiE),
		.div_lo_e(DivLoE),
		.is_byte_e(IsByteE),

        // Input from the hazard unit.
        .forward_rs_e(forward_rs_e),
        .forward_rt_e(forward_rt_e),

        // Wires from the control unit forwarded to the mem stage.
        .write_reg_e(WriteRegE),
        .write_data_e(WriteDataE),
        .alu_out_e(ALUOutE)
        );

    mem_stage myMemStage(
        .clock(clock),

        // Input from the Execute stage.
		.reg_write_e(RegWriteE),
        .mem_to_reg_e(MemtoRegE),
        .mem_write_e(MemWriteE),
        .alu_out_e(ALUOutE),
        .write_data_e(WriteDataE),
        .write_reg_e(WriteRegE),
		.has_div_e(HasDivE),
		.div_hi_e(DivHiE),
		.div_lo_e(DivLoE),
		.is_byte_e(IsByteE),

		// Output to the WB stage.
        .reg_write_m(RegWriteM),
        .mem_to_reg_m(MemtoRegM),
        .read_value_m(Writeback_RD),
        .write_reg_m(WriteRegM),
		.has_div_m(HasDivM),
		.div_hi_m(DivHiM),
		.div_lo_m(DivLoM),

		// This output is used for ex->ex forwarding.
        .alu_out_m(ALUOutM)
        );
    
    writeback_pipeline_reg wpipe(
    .clock(clock), 
    .reg_write_m(RegWriteM),
    .mem_to_reg_m(MemtoRegM), 
    .read_value_m(Writeback_RD), 
    .alu_out_m(ALUOutM), 
    .write_reg_m(WriteRegM),
    .has_div_m(HasDivM),
    .div_hi_m(DivHiM),
    .div_lo_m(DivLoM), 
    .reg_write_w(RegWriteW), 
    .mem_to_reg_w(MemtoRegW), 
    .read_value_w(ReadDataW), 
    .alu_out_w(ALUOutW), 
    .write_reg_w(WriteRegW),
    .has_div_w(HasDivW),
    .div_hi_w(DivHiW),
    .div_lo_w(DivLoW)
    );
    
    hazard_unit hazard(
	// Inputs
	.rs_id_d(RsD),
	.rt_id_d(RtD),
	.branch_d(BranchD),
	.rs_id_e(RsE),
	.rt_id_e(RtE),
	.write_reg_e(WriteRegE),
	.mem_to_reg_e(MemtoRegE),
	.reg_write_e(RegWriteE),
	.rd_id_m(WriteRegM),
	.mem_to_reg_m(MemtoRegM),
	.reg_write_m(RegWriteM),
	.rd_id_w(WriteRegW),
	.reg_write_w(RegWriteW),
	.syscall_d(syscallD),
	.mf_op_in_d(MfOpInD),
	.has_div_e(HasDivE),
	.has_div_m(HasDivM),
	.has_div_w(HasDivW),

	// Outputs
	.stall_f(StallF),
	.stall_d(StallD),
	.flush_e(FlushE),
	.forward_rs_e(forward_rs_e),
	.forward_rt_e(forward_rt_e)
	);



endmodule

`endif
