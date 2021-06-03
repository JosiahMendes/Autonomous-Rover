#include "alt_types.h"
#include "sys/alt_stdio.h"
#include "io.h"
#include "system.h"
#include "altera_avalon_spi.h"
#include "altera_avalon_spi_regs.h"

#define SPI_MASTER_BASE SPI_0_BASE

int main1()
{
	printf("Entered Main\n");
	alt_u8 send_M;
	alt_u8 rcvd_M;
	alt_u8 count;
	alt_u32 test = 35;
	count = 0;

	while(1){
		send_M = count;
		// Load Slave TX buffer THEN load Master TX buffer
		// loading master TX causes transmission to start
		//
		IOWR_ALTERA_AVALON_SPI_TXDATA(SPI_0_BASE, test);
		usleep(50000);
		//IOWR_ALTERA_AVALON_SPI_TXDATA(SPI_0_BASE, '\n');
		// Wait for transfer to complete //
		usleep(75);

		// Read Master and Slave RX buffers
		rcvd_M = IORD_ALTERA_AVALON_SPI_RXDATA(SPI_0_BASE);

		// Print results
		printf("master sent = %i\tmaster recv'd = %i\n", send_M, rcvd_M);		     // Setup for next loop
		count ++;
		usleep(1000000); // end while
	}
	return 0;
 }
