
`ifndef CPU_V
`define CPU_V

`include "execute/execute_stage.v"
`include "decode/decode_stage.v"
`include "fetch/fetch.v"
`include "memory/mem_stage.v"

module cpu(clock);

    input wire clock;
    
    // Inputs from control and decode
    wire [31:0] pc_branch_d;
    wire pc_src_d;

    // Input from hazard unit
    wire stallf;

    // Outputs to decode
    wire [31:0] pc_plus_4f;
    wire [31:0] instructionf;
    
    wire FlushE;
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
    wire [1:0] ForwardAE;
    wire [1:0] ForwardBE;

    wire RegWriteE;
    wire MemtoRegE;
    wire MemWriteE;
    wire RegDstE;
    wire [3:0] ALUControlE;
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
    
    // TODO: Duplicate ResultW
    wire [31:0] ResultW;

    fetch fetch(
        .clk(clock),
        
        // Inputs from decode and control.
        .pc_branch_d(pc_branch_d),
        .pcsrc_d(pc_src_d),
        
        // Inputs from the hazard unit.
        .stallf(stallf),

        // Outputs to the decode stage.
        .pc_plus_4f(pc_plus_4f),
        .instructionf(instructionf)
        );

    decode_stage decode(
        .clock(clock),
            
        // Inputs from fetch.
        .instruction(instructionf),
        .pc_plus_four(pc_plus_4f), 
    
        // Inputs from writeback.
        .writeback_value(Writeback_RD), 
        .writeback_id(WriteRegM), 
        .reg_write_W(RegWriteM),
    
        // Decode to EX.
        .reg_rs_value(RD1D),
        .reg_rt_value(RD2D),
        .immediate(SignImmD),
        .reg_rs_id(RsD),
        .reg_rt_id(RtD),
        .reg_rd_id(RdD),
        .shamt(shamtD),

        // Control to EX
        .reg_write_D(RegWriteD),
        .mem_to_reg(MemtoRegD),
        .mem_write(MemWriteD),
        .alu_op(ALUControlD),
        .alu_src(ALUSrcD),
        .reg_dest(RegDstD),

        // Outputs back to fetch.
        .jump(pc_src_d),
        .jump_address(pc_branch_d)
        );

    execute_stage EX_stage(
        .clk(clock),
    
        // Input from the hazard control unit.
        .FlushE(FlushE),
    
        // Input from the decode stage.
        .RegWriteD(RegWriteD),
        .MemtoRegD(MemtoRegD),
        .MemWriteD(MemWriteD),
        .ALUControlD(ALUControlD),
        .ALUSrcD(ALUSrcD),
        .RegDstD(RegDstD),
        .RD1D(RD1D),
        .RD2D(RD2D),
        .RsD(RsD),
        .RtD(RtD),
        .RdD(RdD),
        .SignImmD(SignImmD),
        .shamtD(shamtD),

        // Output to the mem stage.
        .RegWriteE(RegWriteE),
        .MemtoRegE(MemtoRegE),
        .MemWriteE(MemWriteE),
        .RegDstE(RegDstE),
        .ALUControlE(ALUControlE),
        .RD1E(RD1E),
        .RD2E(RD2E),
        .RsE(RsE),
        .RtE(RtE),
        .RdE(RdE),
        .SignImmE(SignImmE),
        .ResultW(ResultW),
        .ALUOutM(ALUOutM),

        // Input from the hazard unit.
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),

        // Wires from the control unit forwarded to the mem stage.
        .WriteRegE(WriteRegE),
        .WriteDataE(WriteDataE),
        .ALUOutE(ALUOutE)
        );

    mem_stage myMemStage(
        .CLK(clock),
        .RegWriteE(RegWriteE),
        .MemtoRegE(MemtoRegE),
        .MemWriteE(MemWriteE),
        .ALUOutE(ALUOutE),
        .WriteDataE(WriteDataE),
        .WriteRegE(WriteRegE),
        .RegWriteM(RegWriteM),
        .MemtoRegM(MemtoRegM),
        .RD(Writeback_RD),
        .ALUOutM(ALUOutM),
        .WriteRegM(WriteRegM)
        );

endmodule

`endif