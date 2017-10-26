WARNS = -Wimplicit -Wportbind
VERSION = -g2005

all: testbench

execute_test:
	iverilog ex_test.v -o ex_test.out -I../ $(WARNS) $(VERSION)

cpu_compile:
	echo Note: This only compiles for syntax checking.
	iverilog cpu.v -o cpu.out $(WARNS) $(VERSION)

testbench:
	iverilog testbench.v -o testbench.out $(WARNS) $(VERSION)
	

clean:
	rm *.out *.dump
