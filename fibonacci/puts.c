
#include "puts.h"
#include "consts.h"

#ifdef DEBUG

#include <stdio.h>

void putc_mips(char c) {
	printf("%c", c);
}

#else

extern void putc_mips(char c);

#endif

int puts(const char* str) {
	if (str == NULL) {
		return PUTS_ERR_NULL;
	}

	size_t i = 0;
	while (str[i] != 0) {
		putc_mips(str[i]);
		i++;
	}
	return i;
}




