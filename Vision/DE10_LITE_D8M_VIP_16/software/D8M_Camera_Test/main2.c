#include "alt_types.h"
#include "sys/alt_stdio.h"
#include "io.h"
#include <stdio.h>
#include "system.h"
#include "sys/alt_irq.h"


int mai1n()
{
	perror("Entered Main\n");

	while(1){
		perror("Entered While\n");
		printf("test");
		usleep(1000000);
	}
 }
