
#include "puts.h"
#include "itoa.h"

// This contains memset() used by GCC.
#include <string.h>

#define BUFFER_SIZE 128

// basic non-optimized recusive fibonacci generator
int fibonacci(int n)
{
   if ( n == 0 )
      return 0;
   else if ( n == 1 )
      return 1;
   else
      return ( fibonacci(n-1) + fibonacci(n-2) );
} 

int main(void)
{
	char s[BUFFER_SIZE]= {0};
	int f = fibonacci(6);
	puts("Result is: ");
	itoa(f, s, BUFFER_SIZE, 10);
	puts(s);
	puts("\n");
	return 0;
}
