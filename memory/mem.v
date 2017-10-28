`ifndef MIPS_H
`include "mips.h"
`endif

`ifndef MEMORY
`define MEMORY

`define STACK_TOP 32'h7FFF_FFFC
`define STACK_BOT 32'h7FFF_FBFC

`define TEXT_DAT_TOP 32'h0010_1000
`define TEXT_DAT_BOT 32'h0010_0000

//`define MEM_VERBOSE


module Memory(input [31:0] A, WD, input WE, CLK, MemToRegM, RegWriteM, output reg [31:0] RD);
	// Old: h'7fff_fffC
  reg [31:0] stack[`STACK_BOT:`STACK_TOP]; // 1k Stack from 7fff_fffc down
  reg [31:0] text_dat[`TEXT_DAT_BOT:`TEXT_DAT_TOP]; // 2k text... I think?

  // String
  reg [99:0] program_name;

  reg mem_verbose;

  // TODO: Integrate with fetch/mem.v
  initial begin
    if ($value$plusargs("DAT=%s", program_name)) begin
    	$readmemh(program_name, text_dat);
    end else begin
    	$readmemh("program.dat", text_dat);
    end

	if (~$value$plusargs("MEM_VERBOSE=%d", mem_verbose)) begin
		// If no value is given, assume false.
		mem_verbose = 0;
	end
  end

  wire [31:0] text_A;
  
  assign text_A = A >> 2;

  always @(negedge CLK) begin
    if (A <= `STACK_TOP && A >= `STACK_BOT) begin
      RD <= stack[A];

       if (MemToRegM && mem_verbose) begin
          $display($time, ": Reading from .stack address [%h]: %h", A, stack[A]);
       end
    end else if (text_A <= `TEXT_DAT_TOP && text_A >= `TEXT_DAT_BOT) begin
      // TODO: LB can do un-aligned memory access. That means accessing
      // a particular byte within a word!
      
        if (MemToRegM && mem_verbose) begin
      	  $display($time, ": Reading from .text address [%h]: %h", text_A, text_dat[text_A]);
        end
      RD <= text_dat[text_A];
    end else begin
      if (MemToRegM && RegWriteM) begin
        $display($time, ": Attempt to read from undefined address %h.", A);
      end
      RD <= `undefined;
    end
  end

  always @(negedge CLK) begin
    if (WE) begin // MemWrite signal
      if (A <= 32'h7FFF_FFFC && A >= 32'h7FFF_FBFC) begin
	  	if (mem_verbose) begin
			$display($time, ": Writing to .stack address [%h]: %h replacing %h",
				  A, WD, stack[A]);
		end
        stack[A] <= WD;
      end else if (text_A <= `TEXT_DAT_TOP && text_A >= `TEXT_DAT_BOT) begin
	  	if (mem_verbose) begin
        	$display($time, ": Writing to .text (read-only) address [%h]: %h replacing %h",
				 text_A, WD, text_dat[text_A]);
		end
		text_dat[text_A] <= WD;
      end else begin
        $display($time, ": Tried to write to unallocated address %h", A);
      end
    end // MemWrite signal if block
  end // always block
endmodule


`endif
// // Module representing everything between the register banks surrounding the Memory state
// module Memory(input RegWriteM, MemtoRegM, MemWriteM, input [31:0] ALUOutM, WriteDataM, input [4:0] WriteRegM,
//               output reg [31:0] RD, output reg MemtoRegM, RegWriteM);
//
// endmodule
