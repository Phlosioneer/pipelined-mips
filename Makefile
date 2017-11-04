# Makefile to generate bare metal code to run on a simulated (Verilog) processor
# Bucknell University
# Alan Marchiori 2014

MIPSEL_ROOT=/usr/remote/mipsel
MIPSEL=$(MIPSEL_ROOT)/bin/mipsel-linux-

COMMON_CFLAGS=-Wall -Wextra --std=c99
COMMON_LDFLAGS=

SRC_DIR=fibonacci
BUILD_DIR=build

AS=$(MIPSEL)as


SREC=srec_cat

ASMSOURCE:=$(wildcard $(SRC_DIR)/*.s)
CSOURCE:=$(wildcard $(SRC_DIR)/*.c)
SCRIPT_FILE=$(SRC_DIR)/sections.ld

ASMOBJ:=$(ASMSOURCE:.s=.o)
COBJ:=$(CSOURCE:.c=.o)

ASMOBJ:=$(subst $(SRC_DIR),$(BUILD_DIR),$(ASMOBJ))
COBJ:=$(subst $(SRC_DIR),$(BUILD_DIR),$(COBJ))

$(info asmobj is [$(ASMOBJ)])
$(info cobj is [$(COBJ)])

GCC=$(MIPSEL)gcc
LD=$(MIPSEL)ld
OBJDUMP=$(MIPSEL)objdump

# these are the flags we need for bare metal code generation
LDSCRIPT=--script=$(SCRIPT_FILE)
CFLAGS=-fpic -mno-abicalls -nostdlib -static $(COMMON_CFLAGS)
LDFLAGS=-L/usr/remote/mipsel/lib/gcc/mipsel-buildroot-linux-uclibc/4.6.3 -lgcc_eh --oformat=srec $(LDSCRIPT)
OBJDUMP_FLAGS=-m mips --endian=little
SREC_FLAGS=-byte-swap 4 -VMem

OBJECTS=$(ASMOBJ:.o=_mips.o) $(COBJ:.o=_mips.o)
	
D_GCC=gcc
D_LD=gcc
D_OBJDUMP=objdump

D_CFLAGS=$(COMMON_CFLAGS) -D DEBUG
D_LDFLAGS=$(COMMON_LDFLAGS)

# Separate the normal .o files from the debug ones.
D_OBJECTS=$(COBJ:.o=_debug.o)

BIN_OUTPUT=$(BUILD_DIR)/fib
D_BIN_OUTPUT=$(BUILD_DIR)/fib_debug
GCC_OUTPUT=$(BUILD_DIR)/fib.srec
VERILOG_OUTPUT=$(BUILD_DIR)/fib.dat
OBJDUMP_OUTPUT=$(BUILD_DIR)/fib.dis
TESTBENCH_OUTPUT_NAME=testbench.out
TESTBENCH_OUTPUT=$(BUILD_DIR)/$(TESTBENCH_OUTPUT_NAME)
PROGRAM_DAT_NAME=program.dat
PROGRAM_DAT=$(BUILD_DIR)/$(PROGRAM_DAT_NAME)
OUTPUT=$(BIN_OUTPUT) $(GCC_OUTPUT) $(VERILOG_OUTPUT) $(D_BIN_OUTPUT) $(OBJDUMP_OUTPUT) $(TESTBENCH_OUTPUT) $(PROGRAM_DAT)

.PHONY: all, debug, run, build_dir

VERILOG_WARNS=-Wimplicit -Wportbind
VERILOG_VERSION=-g2005

all: $(OUTPUT)

debug: $(D_BIN_OUTPUT)
	./$(D_BIN_OUTPUT)

build_dir:
	mkdir -p $(BUILD_DIR)

run: $(TESTBENCH_OUTPUT) $(PROGRAM_DAT)
	cd $(BUILD_DIR) ; ./$(TESTBENCH_OUTPUT_NAME) +DAT=$(PROGRAM_DAT_NAME)

$(PROGRAM_DAT): $(VERILOG_OUTPUT) build_dir
	cp $(VERILOG_OUTPUT) $(PROGRAM_DAT)

$(TESTBENCH_OUTPUT): build_dir
	iverilog testbench.v -o $@ $(VERILOG_WARNS) $(VERILOG_VERSION)

$(D_BIN_OUTPUT): $(D_OBJECTS) build_dir
	$(D_LD) $(D_LDFLAGS) $(D_OBJECTS) -o $(D_BIN_OUTPUT)

$(BIN_OUTPUT): $(OBJECTS) build_dir
	$(LD) $(LDFLAGS) $(OBJECTS) -o $(BIN_OUTPUT)

$(GCC_OUTPUT): $(OBJECTS) build_dir
	# Link to an SRecord
	$(LD) $(LDFLAGS) $(OBJECTS) -o $(GCC_OUTPUT)

$(VERILOG_OUTPUT): $(GCC_OUTPUT) build_dir
	# Convert the gcc output SRecord into a Motorola SRecord for mips
	$(SREC) $(GCC_OUTPUT) -byte-swap 4 -o $(VERILOG_OUTPUT) -VMem

$(OBJDUMP_OUTPUT): $(GCC_OUTPUT) build_dir
	$(OBJDUMP) $(OBJDUMP_FLAGS) -D $< > $@

$(BUILD_DIR)/%_mips.o: $(SRC_DIR)/%.c build_dir
	# compile C to object files as usual
	$(GCC) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/%_mips.o: $(SRC_DIR)/%.s build_dir
	# assemble to a motorola srecord file
	$(AS) $< -o $@

$(BUILD_DIR)/%_debug.o: $(SRC_DIR)/%.c build_dir
	$(D_GCC) -c $(D_CFLAGS) $< -o $@

clean:
	rm -rf $(BUILD_DIR)
