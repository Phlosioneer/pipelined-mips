module memory(readAddress, memInstruction);
input [31:0] readAddress; 
output [31:0] memInstruction;
reg [31:0] mem [32'h100000:32'h101000];
initial begin
  $readmemh("../mips_processor/mips_code/add_test.v"
  /*"jump.in"*/, mem);
end
assign memInstruction = mem[readAddress >> 2];
/*always @(readAddress)
begin
  wordAddress = readAddress >> 2;
  memInstruction = mem[wordAddress];
  //$display("readAddress: %x", readAddress);
end*/
endmodule