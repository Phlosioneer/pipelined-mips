`ifndef MIPS_H
`include "mips.h"
`endif

`ifndef HAZARD_UNIT
`define HAZARD_UNIT

module hazard_unit(
	// Inputs
	rs_id_d, rt_id_d, branch_d, rs_id_e, rt_id_e, write_reg_e, mem_to_reg_e, reg_write_e, rd_id_m, 
	mem_to_reg_m, reg_write_m, rd_id_w, reg_write_w, syscall_d, has_div_e,
	has_div_m, has_div_w, mf_op_in_d,

	// Outputs
	stall_f, stall_d, flush_e, forward_rs_e, forward_rt_e
	);

/* Inputs */

// The first source register from the Decode stage.
input wire [4:0] rs_id_d;

// The second source register from the Decode stage.
input wire [4:0] rt_id_d;

// Whether a branch instruction is executing, as determined by the Decode stage.
input wire branch_d;

// The first source register from the Execute stage.
input wire [4:0] rs_id_e;

// The second source register from the Execute stage.
input wire [4:0] rt_id_e;

// The register that will be written to, as determined by the Execute stage.
input wire [4:0] write_reg_e;

// Whether data is being written from M->E, as determined by the Execute stage.
input wire mem_to_reg_e;

// Whether a register is written to, as determined by the Execute stage.
input wire reg_write_e;

// The register that will be written to, as determined by the Mem stage.
input wire [4:0] rd_id_m;

// Whether data is being written from M->E, as determined by the Mem stage.
input wire mem_to_reg_m;

// Whether a register is written to, as determined by the Mem stage.
input wire reg_write_m;

// The register that will be written to, as determined by the Writeback stage.
input wire [4:0] rd_id_w;

// Whether a register is written to, as determined by the Writeback stage.
input wire reg_write_w;

// Whether the decode stage is trying to do a syscall.
input wire syscall_d;

// Whether the corresponding stage corresponds to a divide instruction that
// will be written back. These are important for hazard detection for mfhi and
// mflo ops.
input wire has_div_e;
input wire has_div_m;
input wire has_div_w;

// This is true whenever the decode stage is attempting to decode either mfhi
// or mflo.
input wire mf_op_in_d;

/* Outputs */

// This flag is high when the Fetch stage needs to stall.
output wire stall_f;

// This flag is high when the Decode stage needs to stall.
output wire stall_d;

// True when forwarding a predicted branch to the Decode stage source reg Rs.
//output wire ForwardAD;

// True when forwarding a predicted branch to the Decode stage source reg Rt.
//output wire ForwardBD;

// True when the Execute stage needs to be flushed.
output wire flush_e;

// 1 for MEM/EX forwarding; 2 for EX/EX forwarding of Rs.
output wire [1:0] forward_rs_e;

// 1 for MEM/EX forwarding; 2 for EX/EX forwarding of Rt.
output wire [1:0] forward_rt_e;

// 1 if we need to stall for the syscall.
wire stall_syscall;

// Intermediate logic for stall_syscall.
wire stall_syscallV0;
wire stall_syscallA0;

// Branch stall when a branch is taken (so the next PC is still decoding)
wire branch_stall;

// Additional stall while we wait for load word's WB stage
wire lw_stall;

// This is true if there's a mfhi or mflo instruction in the decode stage that
// is waiting on HasDiv in the other stages.
wire stall_mf_op;

wire branch_source_in_e;
wire branch_source_in_m;

// Syscall needs to stall if there are any instructions in the pipeline write
// to v0 or a0.
assign stall_syscallV0 = (write_reg_e == `v0) || (rd_id_m == `v0) || (rd_id_w == `v0);
assign stall_syscallA0 = (write_reg_e == `a0) || (rd_id_m == `a0) || (rd_id_w == `a0);
assign stall_syscall = syscall_d && (stall_syscallV0 || stall_syscallA0);

// Stall if there is an mfhi or mflo instruction in decode, and we have to
// wait for any divide operation still in execute/memory/writeback.
assign stall_mf_op = mf_op_in_d && (has_div_e || has_div_m || has_div_w);

// branch_source_in_e is true if a branch comparison reg is going to be
// written from the execute stage.
assign branch_source_in_e = (reg_write_e &&
				(write_reg_e == rs_id_d || write_reg_e == rt_id_d));

// branch_source_in_m is true if a branch comparison reg is going to be
// written from the memory stage.
assign branch_source_in_m = (reg_write_m &&
				(rd_id_m == rs_id_d || rd_id_m == rt_id_d));

// branch_stall is high if we're branching and currently writing to a source reg
assign branch_stall = (branch_d &&
		(branch_source_in_e || branch_source_in_m));

// lw_stall is high when we're writing from memory to a reg
assign lw_stall = ((rs_id_d == rt_id_e) || (rt_id_d == rt_id_e)) && mem_to_reg_e;
/*
initial begin
	stall_f = 1;
	stall_d = 1;
	ForwardAD = 0;
	ForwardBD = 0;
	flush_e = 0;
	forward_rs_e = 0;
	forward_rt_e = 0;
end
*/
// Execute to Decode forwarding (for branches)
//assign ForwardAD = (rs_id_d != 0) && (rs_id_d == rd_id_m) && reg_write_m;
//assign ForwardBD = (rt_id_d != 0) && (rt_id_d == rd_id_m) && reg_write_m;

// Stall when either stall signal has been set (inverted; see diagram)
assign stall_f = !(branch_stall || lw_stall || stall_syscall || stall_mf_op);
assign stall_d = !(branch_stall || lw_stall || stall_syscall || stall_mf_op);

// Flush when either stall signal has been set
assign flush_e = !(branch_stall || lw_stall || stall_syscall || stall_mf_op);

// Assign EX/EX or MEM/EX forwarding of Rs as appropriate
assign forward_rs_e = ((rs_id_e != 0) && (rs_id_e == rd_id_m) && reg_write_m)  ? 2'b10 : // EX/EX
				   (((rs_id_e != 0) && (rs_id_e == rd_id_w) && reg_write_w) ? 2'b01 : // MEM/EX
				   0);

// Assign EX/EX or MEM/EX forwarding of Rt as appropriate
assign forward_rt_e = ((rt_id_e != 0) && (rt_id_e == rd_id_m) && reg_write_m)  ? 2'b10 : // EX/EX
				   (((rt_id_e != 0) && (rt_id_e == rd_id_w) && reg_write_w) ? 2'b01 : // MEM/EX
				   0);

endmodule

`endif
