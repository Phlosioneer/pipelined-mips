# Makefile to generate bare metal code to run on a simulated (Verilog) processor
# Bucknell University
# Alan Marchiori 2014

MIPSEL_ROOT=/usr/remote/mipsel
MIPSEL=$(MIPSEL_ROOT)/bin/mipsel-linux-

COMMON_CFLAGS=-Wall -Wextra --std=c99
COMMON_LDFLAGS=


AS=$(MIPSEL)as


SREC=srec_cat

ASMSOURCE=$(wildcard *.s)
CSOURCE=$(wildcard *.c)

ASMOBJ=$(ASMSOURCE:.s=.o)
COBJ=$(CSOURCE:.c=.o)

GCC=$(MIPSEL)gcc
LD=$(MIPSEL)ld
OBJDUMP=$(MIPSEL)objdump

# these are the flags we need for bare metal code generation
CFLAGS=-fpic -mno-abicalls -nostdlib -static $(COMMON_CFLAGS)
LDFLAGS=-L/usr/remote/mipsel/lib/gcc/mipsel-buildroot-linux-uclibc/4.6.3 -lgcc_eh --oformat=srec

OBJECTS=$(ASMOBJ:.o=_mips.o) $(COBJ:.o=_mips.o)
	
D_GCC=gcc
D_LD=gcc
D_OBJDUMP=objdump

D_CFLAGS=$(COMMON_CFLAGS) -D DEBUG
D_LDFLAGS=$(COMMON_LDFLAGS)

# Separate the normal .o files from the debug ones.
D_OBJECTS=$(COBJ:.o=_debug.o)

BIN_OUTPUT=fib
D_BIN_OUTPUT=fib_debug
GCC_OUTPUT=fib.srec
VERILOG_OUTPUT=fib.dat
OUTPUT=$(BIN_OUTPUT) $(GCC_OUTPUT) $(VERILOG_OUTPUT) $(D_BIN_OUTPUT)

.PHONY: all, debug


all: $(OUTPUT)

debug: $(D_BIN_OUTPUT)

$(D_BIN_OUTPUT): $(D_OBJECTS)
	$(D_LD) $(D_LDFLAGS) $(D_OBJECTS) -o $(D_BIN_OUTPUT)

$(BIN_OUTPUT): $(OBJECTS)
	$(LD) $(LDFLAGS) $(OBJECTS) -o $(BIN_OUTPUT)

$(GCC_OUTPUT): $(OBJECTS)
	# Link to an SRecord
	$(LD) $(LDFLAGS) $(OBJECTS) -o $(GCC_OUTPUT)

$(VERILOG_OUTPUT): $(GCC_OUTPUT)
	# Convert the gcc output SRecord into a Motorola SRecord for mips
	./vmem_injector.sh $(GCC_OUTPUT) $(VERILOG_OUTPUT)

%_mips.o: %.c
	# compile C to object files as usual
	$(GCC) -c $(CFLAGS) $< -o $@

%_mips.o: %.s
	# assemble to a motorola srecord file
	$(AS) $< -o $@

%_debug.o: %.c
	$(D_GCC) -c $(D_CFLAGS) $< -o $@

clean:
	rm -f $(OUTPUT) $(OBJECTS) a.out *.dump $(D_OBJECTS)
