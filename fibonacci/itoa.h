
#ifndef ITOA_H
#define ITOA_H


#include "consts.h"

// Returns 0 on success; returns an error code otherwise.
// If an error occured, the contents of buffer are undefined.
int itoa(int val, char* buffer, size_t size, int base);

// The buffer pointer is null.
#define ITOA_ERR_NULL 1

// The buffer isn't big enough.
#define ITOA_ERR_SIZE 2

// The base is less than 2 or greater than 16.
#define ITOA_ERR_BASE 3

// An unknown error occured.
#define ITOA_ERR_UNKNOWN 4

#endif





