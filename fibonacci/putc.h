


#ifndef PUTC_H
#define PUTC_H


#ifdef DEBUG

#include<stdio.h>

void putc_mips(char c) {
	printf("%c", c);
}


#else

extern void putc_mips(char c);

#endif


#endif




