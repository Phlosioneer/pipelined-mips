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


module memory(input [31:0] address, write_value, input enable_write, clock, mem_to_reg_m, reg_write_m, output reg [31:0] read_value);
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

  wire [31:0] text_address;
  
  assign text_address = address >> 2;

  always @(negedge clock) begin
    if (address <= `STACK_TOP && address >= `STACK_BOT) begin
      read_value <= stack[address];

       if (mem_to_reg_m && mem_verbose) begin
          $display($time, ": Reading from .stack address [%h]: %h", address, stack[address]);
       end
    end else if (text_address <= `TEXT_DAT_TOP && text_address >= `TEXT_DAT_BOT) begin
      // TODO: LB can do un-aligned memory access. That means accessing
      // a particular byte within a word!
      
        if (mem_to_reg_m && mem_verbose) begin
      	  $display($time, ": Reading from .text address [%h]: %h", text_address, text_dat[text_address]);
        end
      read_value <= text_dat[text_address];
    end else begin
      if (mem_to_reg_m && reg_write_m) begin
        $display($time, ": Attempt to read from undefined address %h.", address);
      end
      read_value <= `undefined;
    end
  end

  always @(negedge clock) begin
    if (enable_write) begin // MemWrite signal
      if (address <= 32'h7FFF_FFFC && address >= 32'h7FFF_FBFC) begin
	  	if (mem_verbose) begin
			$display($time, ": Writing to .stack address [%h]: %h replacing %h",
				  address, write_value, stack[address]);
		end
        stack[address] <= write_value;
      end else if (text_address <= `TEXT_DAT_TOP && text_address >= `TEXT_DAT_BOT) begin
	  	if (mem_verbose) begin
        	$display($time, ": Writing to .text (read-only) address [%h]: %h replacing %h",
				 text_address, write_value, text_dat[text_address]);
		end
		text_dat[text_address] <= write_value;
      end else begin
        $display($time, ": Tried to write to unallocated address %h", address);
      end
    end // MemWrite signal if block
  end // always block
endmodule


`endif
