#include <stdio.h>
#include "I2C_core.h"
#include "terasic_includes.h"

//MIPI Protocol Helpers
#include "mipi_camera_config.h"
#include "mipi_bridge_config.h"
#include "mipi_helpers.h"

#include "auto_focus.h"

//System address defines
#include "system.h"

//SPI Comms for Bounding Boxes
#include "altera_avalon_spi.h"
#include "altera_avalon_spi_regs.h"

#include <fcntl.h>
#include <unistd.h>
#include <string.h>

//EEE_IMGPROC defines
#define EEE_IMGPROC_MSG_START ('R'<<16 | 'B'<<8 | 'B')
#define EEE_IMGPROC_PIXEL_START ('P'<<16 | 'I' << 8 | 'X')


//offsets
#define EEE_IMGPROC_STATUS 0
#define EEE_IMGPROC_MSG 1
#define EEE_IMGPROC_ID 2
#define EEE_IMGPROC_BBCOL 3

//Default Camera Settings
#define EXPOSURE_INIT 0x001300
#define EXPOSURE_STEP 0x100
#define GAIN_INIT 0x180
#define GAIN_STEP 0x020
#define DEFAULT_LEVEL 3

#define MWB_INIT 0x400
#define MWB_STEP 0x50

const int color = 5;
const int coords = 4;

void calcLoc (int arr[color][coords]){
	fprintf(stderr, "\nNew Calculation\n");
	for (int i = 0; i< color; i++){
		fprintf(stderr, "Colour %d " , i);
		fprintf(stderr,"X = %d , Y  = %d ",arr[i][0],arr[i][1]);
		fprintf(stderr,"X = %d , Y  = %d \n",arr[i][2],arr[i][3]);
		float x, y;
		int xlength, ylength;
		xlength = - arr[i][0] +  arr[i][2];
		ylength =   - arr[i][1] +  arr[i][3];
		fprintf(stderr, "X = %d , Y  = %d", xlength,  ylength);

		if(xlength > 100 || xlength < 10 || ylength > 100 || ylength < 10){
			fprintf(stdout, "0.0,0.0;");
			fprintf(stderr, "\tValue too big/small, ignoring and writing 0.0,0.0; \n");
		} else if (xlength/ylength > 3 || ylength/xlength > 3){
			fprintf(stdout, "0.0,0.0;");
			fprintf(stderr, "\tRatio is weird, ignoring and writing 0.0,0.0; \n");
		} else {
			int xcenter = (xlength>>1)+ arr[i][0] - 320;
			int ycenter = arr[i][3];

			fprintf(stderr,"%d, %d\n", xcenter, ycenter);
			x = -0.0000267750706078921 * xcenter *xcenter
			 + 0.000362236977958633 * ycenter * ycenter
			 + -0.000514969732228439 * xcenter * ycenter
			 + 0.281851572976718 * xcenter
			 + -0.279845971987078 * ycenter
			 + 53.1811991001082;

			 y = 0.0000419454036771478 * xcenter *xcenter
			 + 0.0012174042450394* ycenter * ycenter
			 + 0.0000314129772376016 * xcenter * ycenter
			 + -0.00883583925972652 * xcenter
			 + -1.31880570162837 * ycenter
			 + 381.614766741501;

			//fprintf(stderr,"y value = %f \n", y);


				fprintf(stdout, "%.2f,%.2f;",x, y);
				fprintf(stderr, "\t Calculated Values for x is %.2f and y is %.2f;\n",x, y);

		}


	}
	       fprintf(stdout, "\n");
	       fprintf(stderr, "\n==================================================\n");
}

int main()
{

	fcntl(STDIN_FILENO, F_SETFL, O_NONBLOCK);

    fprintf(stderr,"DE10-LITE D8M VGA Demo\n");
    fprintf(stderr,"Imperial College EEE2 Project version\n");
    IOWR(MIPI_PWDN_N_BASE, 0x00, 0x00);
    IOWR(MIPI_RESET_N_BASE, 0x00, 0x00);

    usleep(2000);
    IOWR(MIPI_PWDN_N_BASE, 0x00, 0xFF);
    usleep(2000);
    IOWR(MIPI_RESET_N_BASE, 0x00, 0xFF);

    fprintf(stderr,"Image Processor ID: %x\n",IORD(EEE_IMGPROC_0_BASE,EEE_IMGPROC_ID));
    usleep(2000);


    // MIPI Init
    if (!MIPI_Init()){
        fprintf(stderr,"MIPI_Init Init failed!\r\n");
    }else{
	    fprintf(stderr,"MIPI_Init Init successfully!\r\n");
    }

//   while(1){
 	    mipi_clear_error();
	 	usleep(50*1000);
 	    mipi_clear_error();
	 	usleep(1000*1000);
	    mipi_show_error_info();
//	    mipi_show_error_info_more();
	    fprintf(stderr,"\n");
//   }



    //////////////////////////////////////////////////////////
    int bb [5][4];
    alt_u16 bin_level = DEFAULT_LEVEL;
    alt_u8  manual_focus_step = 10;
    alt_u16  current_focus = 300;
    int boundingBoxColour = 0;
    alt_u32 exposureTime = EXPOSURE_INIT;
    alt_u16 gain = GAIN_INIT;
    alt_u16 MWBr = MWB_INIT;
    alt_u16 MWBg = MWB_INIT;
    alt_u16 MWBb = MWB_INIT;

    OV8865SetExposure(exposureTime);
    OV8865SetGain(gain);
    Focus_Init();


    while(1){
    	// fprintf(stderr,"In While Loop\n");
        // touch KEY0 to trigger Auto focus
        if((IORD(KEY_BASE,0)&0x03) == 0x02){
        	fprintf(stderr,"Doing auto focus\n");
            current_focus = Focus_Window(320,240);
        }
        // touch KEY1 to ZOOM
		if((IORD(KEY_BASE,0)&0x03) == 0x01){
			fprintf(stderr,"Zooming\n");
			if(bin_level == 3 )bin_level = 1;
			else bin_level ++;
				fprintf(stderr,"set bin level to %d\n",bin_level);
				MIPI_BIN_LEVEL(bin_level);
				usleep(500000);
		}


       alt_u8 idx = 0;
       alt_u8 colour = 0;
       alt_u16 x, y;
       bool calcVal = 0;
       //Read messages from the image processor and print them on the terminal
       while ((IORD(EEE_IMGPROC_0_BASE,EEE_IMGPROC_STATUS)>>8) & 0xff) { 	//Find out if there are words to read
           int word = IORD(EEE_IMGPROC_0_BASE,EEE_IMGPROC_MSG); 			//Get next word from message buffer
    	   if (word == EEE_IMGPROC_MSG_START){ 					//Newline on message identifier
    		   fprintf(stderr,"\n");
    	   }
    	   if (idx == 0){
    		   fprintf(stderr,"RBB MSG ID: \n");
			   //fprintf(stderr,"%08x",word);
    	   } else {
    		   //fprintf(stderr,"%08x\n",word);
    		   x =(word & 0xffff0000)>> 16;
    		   y = (word & 0x0000ffff);
    		   if (idx == 1){
    			   fprintf(stderr,"x0: %u , \t\ty1: %u  \t\t",x ,y);
    			   bb[colour][0] = x;
    			   bb[colour][1] = y;
    		   } else if (idx == 2){
    			   fprintf(stderr,"x2: %u , \t\ty3: %u\n",x ,y);
    			   bb[colour][2] = x;
    			   bb[colour][3] = y;
    			   idx = 0;
    			   colour++;
    		   }
    	   }
    	   idx++;
    	   calcVal = 1;

       }
       if(calcVal){
    	   calcLoc(bb);
    	   calcVal = 0;
       }

       //Update the bounding box colour
       boundingBoxColour = ((boundingBoxColour + 1) & 0xff);
       IOWR(EEE_IMGPROC_0_BASE, EEE_IMGPROC_BBCOL, (boundingBoxColour << 8) | (0xff - boundingBoxColour));

       //Process input commands
       int in = getchar();
       switch (in) {
       	   case 'e': {
       		   exposureTime += EXPOSURE_STEP;
       		   OV8865SetExposure(exposureTime);
       		   fprintf(stderr,"\nExposure = %x ", exposureTime);
       	   	   break;}
       	   case 'd': {
       		   exposureTime -= EXPOSURE_STEP;
       		   OV8865SetExposure(exposureTime);
       		   fprintf(stderr,"\nExposure = %x ", exposureTime);
       	   	   break;}
       	   case 't': {
       		   gain += GAIN_STEP;
       		   OV8865SetGain(gain);
       		   fprintf(stderr,"\nGain = %x ", gain);
       	   	   break;}
       	   case 'g': {
       		   gain -= GAIN_STEP;
       		   OV8865SetGain(gain);
       		   fprintf(stderr,"\nGain = %x ", gain);
       	   	   break;}
       	   case 'r': {
        	   current_focus += manual_focus_step;
        	   if(current_focus >1023) current_focus = 1023;
        	   OV8865_FOCUS_Move_to(current_focus);
        	   fprintf(stderr,"\nFocus = %x ",current_focus);
       	   	   break;}
       	   case 'f': {
        	   if(current_focus > manual_focus_step) current_focus -= manual_focus_step;
        	   OV8865_FOCUS_Move_to(current_focus);
        	   fprintf(stderr,"\nFocus = %x ",current_focus);
       	   	   break;}

       	   case 'i':{
               MWBr += MWB_STEP;
               OV8865SetRedMWBGain(MWBr);
               fprintf(stderr, "\n red MWB = %x", MWBr);
               break;}
           case 'j':{
               MWBr -= MWB_STEP;
               OV8865SetRedMWBGain(MWBr);
               fprintf(stderr, "\n red MWB = %x", MWBr);
               break;}
           case 'o':{
               MWBg += MWB_STEP;
               OV8865SetGreenMWBGain(MWBg);
               fprintf(stderr, "\n green MWB = %x", MWBg);
               break;}
           case 'k':{
               MWBg -= MWB_STEP;
               OV8865SetGreenMWBGain(MWBg);
               fprintf(stderr, "\n green MWB = %x", MWBg);
               break;}
           case 'p':{
               MWBb += MWB_STEP;
               OV8865SetBlueMWBGain(MWBb);
               fprintf(stderr, "\n blue MWB = %x", MWBb);
               break;}
           case 'l':{
               MWBb -= MWB_STEP;
               OV8865SetBlueMWBGain(MWBb);
               fprintf(stderr, "\n blue MWB = %x", MWBb);
               break;}
       }
       // fprintf(stderr,"After Getting Char\n");


	   //Main loop delay
	   usleep(10000);

   };
  return 0;
}
