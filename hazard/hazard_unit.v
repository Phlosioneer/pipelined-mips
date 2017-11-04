`ifndef MIPS_H
`include "mips.h"
`endif

`ifndef HAZARD_UNIT
`define HAZARD_UNIT

module hazard_unit(
	// Inputs
	RsD, RtD, BranchD, RsE, RtE, WriteRegE, MemtoRegE, RegWriteE, WriteRegM, 
	MemtoRegM, RegWriteM, WriteRegW, RegWriteW, syscallD, HasDivE,
	HasDivM, HasDivW, MfOpInD, is_trap, pc_src_d,

	// Outputs
	StallF, StallD, FlushE, FlushD, ForwardAE, ForwardBE
	);

/* Inputs */

// The first source register from the Decode stage.
input wire [4:0] RsD;

// The second source register from the Decode stage.
input wire [4:0] RtD;

// Whether a branch instruction is executing, as determined by the Decode stage.
input wire BranchD;

// The first source register from the Execute stage.
input wire [4:0] RsE;

// The second source register from the Execute stage.
input wire [4:0] RtE;

// The register that will be written to, as determined by the Execute stage.
input wire [4:0] WriteRegE;

// Whether data is being written from M->E, as determined by the Execute stage.
input wire MemtoRegE;

// Whether a register is written to, as determined by the Execute stage.
input wire RegWriteE;

// The register that will be written to, as determined by the Mem stage.
input wire [4:0] WriteRegM;

// Whether data is being written from M->E, as determined by the Mem stage.
input wire MemtoRegM;

// Whether a register is written to, as determined by the Mem stage.
input wire RegWriteM;

// The register that will be written to, as determined by the Writeback stage.
input wire [4:0] WriteRegW;

// Whether a register is written to, as determined by the Writeback stage.
input wire RegWriteW;

// Whether the decode stage is trying to do a syscall.
input wire syscallD;

// Whether the corresponding stage corresponds to a divide instruction that
// will be written back. These are important for hazard detection for mfhi and
// mflo ops.
input wire HasDivE;
input wire HasDivM;
input wire HasDivW;

// This is true whenever the decode stage is attempting to decode either mfhi
// or mflo.
input wire MfOpInD;

// This is true if the decode stage detects a trap. The trap will cause an
// unconditional jump to the IVT; the hazard unit needs to disable branch
// delay slot processing so that it appears like a single operation to the
// rest of the program.
input wire is_trap;

// Logic for clearing the Fetch->Decode pipeline reg when pc_src_d is high is
// moved out of cpu.v and into here.
// TODO: Grok this code better.
input wire pc_src_d;

/* Outputs */

// This flag is high when the Fetch stage needs to stall.
output wire StallF;

// This flag is high when the Decode stage needs to stall.
output wire StallD;

// True when forwarding a predicted branch to the Decode stage source reg Rs.
//output wire ForwardAD;

// True when forwarding a predicted branch to the Decode stage source reg Rt.
//output wire ForwardBD;

// True when the Execute stage needs to be flushed.
// TODO: Inverted?
output wire FlushE;

// True when the Fetch stage needs to be flushed.
// TODO: Inverted?
output wire FlushD;

// 1 for MEM/EX forwarding; 2 for EX/EX forwarding of Rs.
output wire [1:0] ForwardAE;

// 1 for MEM/EX forwarding; 2 for EX/EX forwarding of Rt.
output wire [1:0] ForwardBE;

// 1 if we need to stall for the syscall.
wire stallSyscall;

// Intermediate logic for stallSyscall.
wire stallSyscallV0;
wire stallSyscallA0;

// Branch stall when a branch is taken (so the next PC is still decoding)
wire branchStall;

// Additional stall while we wait for load word's WB stage
wire lwStall;

// This is true if there's a mfhi or mflo instruction in the decode stage that
// is waiting on HasDiv in the other stages.
wire stallMfOp;

wire branch_source_in_e;
wire branch_source_in_m;

// Syscall needs to stall if there are any instructions in the pipeline write
// to v0 or a0.
assign stallSyscallV0 = (WriteRegE == `v0) || (WriteRegM == `v0) || (WriteRegW == `v0);
assign stallSyscallA0 = (WriteRegE == `a0) || (WriteRegM == `a0) || (WriteRegW == `a0);
assign stallSyscall = syscallD && (stallSyscallV0 || stallSyscallA0);

// Stall if there is an mfhi or mflo instruction in decode, and we have to
// wait for any divide operation still in execute/memory/writeback.
assign stallMfOp = MfOpInD && (HasDivE || HasDivM || HasDivW);

// branch_source_in_e is true if a branch comparison reg is going to be
// written from the execute stage.
assign branch_source_in_e = (RegWriteE &&
				(WriteRegE == RsD || WriteRegE == RtD));

// branch_source_in_m is true if a branch comparison reg is going to be
// written from the memory stage.
assign branch_source_in_m = (RegWriteM &&
				(WriteRegM == RsD || WriteRegM == RtD));

// branchStall is high if we're branching and currently writing to a source reg
assign branchStall = (BranchD &&
		(branch_source_in_e || branch_source_in_m));

// lwStall is high when we're writing from memory to a reg
assign lwStall = ((RsD == RtE) || (RtD == RtE)) && MemtoRegE;
/*
initial begin
	StallF = 1;
	StallD = 1;
	ForwardAD = 0;
	ForwardBD = 0;
	FlushE = 0;
	ForwardAE = 0;
	ForwardBE = 0;
end
*/
// Execute to Decode forwarding (for branches)
//assign ForwardAD = (RsD != 0) && (RsD == WriteRegM) && RegWriteM;
//assign ForwardBD = (RtD != 0) && (RtD == WriteRegM) && RegWriteM;

// Stall when either stall signal has been set (inverted; see diagram)
assign StallF = !(branchStall || lwStall || stallSyscall || stallMfOp);
assign StallD = !(branchStall || lwStall || stallSyscall || stallMfOp);

// Flush when either stall signal has been set
assign FlushE = !(branchStall || lwStall || stallSyscall || stallMfOp);

// Flush the instruction being sent to the decode stage if a trap is detected.
// This is used to turn the instruction after a trap into a NOP, to prevent
// branch delay slot behavior.
assign FlushD = !(is_trap) || pc_src_d;

// Assign EX/EX or MEM/EX forwarding of Rs as appropriate
assign ForwardAE = ((RsE != 0) && (RsE == WriteRegM) && RegWriteM)  ? 2'b10 : // EX/EX
				   (((RsE != 0) && (RsE == WriteRegW) && RegWriteW) ? 2'b01 : // MEM/EX
				   0);

// Assign EX/EX or MEM/EX forwarding of Rt as appropriate
assign ForwardBE = ((RtE != 0) && (RtE == WriteRegM) && RegWriteM)  ? 2'b10 : // EX/EX
				   (((RtE != 0) && (RtE == WriteRegW) && RegWriteW) ? 2'b01 : // MEM/EX
				   0);

endmodule

`endif
