

#include "itoa.h"


int itoa(int val, char* buffer, size_t size, int base) {

	if (base < 2 || base > 16) {
		return ITOA_ERR_BASE;
	}

	if (size == 0) {
		return ITOA_ERR_SIZE;
	}

	if (buffer == NULL) {
		return ITOA_ERR_NULL;
	}

	// Start at the end of the string.
	int i = size - 1;

	// Put a zero byte at the start of the string.
	buffer[0] = '\0';

	if (val < 0) {
		val *= -1;
		buffer[i] = '-';
		i--;
		if (size == 1) {
			return ITOA_ERR_SIZE;
		}
	}

	// Work from the least significant digit upwards.
	for (; val != 0 && i > 0; i--) {
		buffer[i] = "0123456789abcdef"[val % base];
		val /= base;
	}
	
	if (i <= 0 && val != 0) {
		// Loop terminated because we ran out of space.
		return ITOA_ERR_SIZE;
	}


	int num_size = size - i - 1;
	for (i = 0; i < num_size; i++) {
		int from = size - 1 - i;
		int to = num_size - 1 - i;
		
		buffer[to] = buffer[from];
	}
	buffer[num_size] = '\0';

	return 0;
}



