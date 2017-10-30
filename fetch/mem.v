
`ifndef FETCH_MEM_H
`define FETCH_MEM_H

`include "mips.h"

module memory(clock, readAddress, memInstruction, start_addr);
input clock;
input [31:0] readAddress; 
output wire [31:0] memInstruction;
output [31:0] start_addr;

reg [31:0] mem [`TEXT_DAT_BOT:`TEXT_DAT_TOP];
reg [31:0] ivt [`IVT_BOT:`IVT_TOP];
reg is_init;

wire [31:0] word_read_address;
wire [31:0] textMemInstruction;
wire [31:0] ivtMemInstruction;

wire is_text_addr;
wire is_ivt_addr;

// Strings
reg [99:0] program_name;
reg [99:0] ivt_name;

// TODO: Integrate with memory/mem.v
initial begin
  if ($value$plusargs("DAT=%s", program_name)) begin
    $readmemh(program_name, mem);
  end else begin
    $readmemh("program.dat", mem);
  end

  if ($value$plusargs("IVT=%s", ivt_name)) begin
  	$readmemh(ivt_name, ivt);
  end else begin
  	$readmemh("ivt.dat", ivt);
  end

  is_init = 0;
end

always @(posedge clock) begin
	is_init <= 1;
end

// The mask removes any byte index from the start address, just in case it was
// added by accident.
assign start_addr = mem[`START_ADDR_LOC] & ~(32'h0000_0003);

assign word_read_address = readAddress >> 2;

assign textMemInstruction = mem[word_read_address];
assign ivtMemInstruction = ivt[word_read_address];

assign is_text_addr = (word_read_address >= `TEXT_DAT_BOT && word_read_address <= `TEXT_DAT_TOP);
assign is_ivt_addr = (word_read_address >= `IVT_BOT && word_read_address <= `IVT_TOP);

assign memInstruction = is_init ? (
				is_text_addr ? textMemInstruction : (
				is_ivt_addr ? ivtMemInstruction : 32'hxxxx_xxxx)) : 0;

always @(negedge clock) begin
	if (is_init && ~(is_text_addr || is_ivt_addr)) begin
		$display($time, ": Attempt to execute address outside of .text and .ivt: [%h]", readAddress);
	end else if (is_init && (readAddress & 32'h0000_0003)) begin
		$display($time, ": Attempt to execute misaligned address [%h].", readAddress);
	end
end

endmodule

`endif
