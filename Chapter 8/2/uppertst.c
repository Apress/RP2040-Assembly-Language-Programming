//
// C program to call our Assembly Language
// toupper routine.
//

#include <stdio.h>
#include "pico/stdlib.h"

extern int mytoupper( char *, char * );

#define MAX_BUFFSIZE 255
void main()
{
	char *str = "This is a test.";
	char outBuf[MAX_BUFFSIZE];
	int len;
	
	stdio_init_all();

	while( 1 )
	{
		len = mytoupper( str, outBuf );
		printf("Before str: %s\n", str);
		printf("After str: %s\n", outBuf);
		printf("Str len = %d\n", len);
	}	
}
