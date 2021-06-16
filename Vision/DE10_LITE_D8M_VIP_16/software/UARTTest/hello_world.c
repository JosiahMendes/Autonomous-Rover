/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include  "system.h"
#include <stdio.h>
#include <unistd.h>


int main (){
	int count = 0;
	while(1){
		fprintf(stderr, "Sending to UART\n");
		fprintf(stdout, "Test blah balkfn lj ljadsflj kdsjflj ldjskjfldaksjf ljadsjfldkj  %d\n", count);
		count++;
	    usleep(10000);
	}
	return 0;
}
