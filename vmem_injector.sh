#!/bin/bash

# Usage: vmem_injector <srec_file> <vmem_output_file>

# First, generate a VMem file.
srec_cat $1 -byte-swap 4 -o $2 -VMem

# Then, extract the execution address from srec_info
exec_addr=$(srec_info $1 | awk '/Execution/{print $NF}')

# Now, figure out what address to put it in memory.
store_addr="@00100000"

# Append this new entry to the end of the vmem file. It'll overwrite
# whatever junk srec_cat decided to put into the first 8 words. 
echo "$store_addr $exec_addr" >> $2


