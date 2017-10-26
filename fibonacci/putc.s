
.text
.global putc_mips

# puts uses syscall 4, $a0 is the address of a 
# null terminated string.
# the cpu simulator will have to trap this and
# generate a $display call

putc_mips:
    li $v0, 4
    syscall
    jr $ra
