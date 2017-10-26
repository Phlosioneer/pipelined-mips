

#ifndef PUTS_H
#define PUTS_H

// Prints the string. Returns either PUTS_ERR_NULL, or the number
// of characters printed to the screen.
int puts(const char* str);

// Returned if the string is a null pointer.
#define PUTS_ERR_NULL -1;

#endif

