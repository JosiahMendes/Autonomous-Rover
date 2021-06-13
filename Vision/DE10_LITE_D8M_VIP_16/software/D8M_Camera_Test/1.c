#include  "system.h"
#include <stdio.h>
#include <unistd.h>


int main1 (){
	int count = 0;
	while(1){
		fprintf(stderr, "Sending to UART\n");
		fprintf(stdout, "Test %d\n", count);
		count++;
	    usleep(1000000);


	}
}
