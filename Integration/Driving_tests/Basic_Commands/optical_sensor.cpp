#include "SPI.h"
#include "optical_sensor.h"

// these pins may be different on different boards
// this is for the uno
int PIN_SS = 10;
int PIN_MISO = 12;
int PIN_MOSI = 11;
int PIN_SCK =  13;



int PIN_MOUSECAM_RESET = 8;
int PIN_MOUSECAM_CS = 7;

int ADNS3080_PIXELS_X = 30;
int ADNS3080_PIXELS_Y = 30;

int ADNS3080_PRODUCT_ID = 0x00;
int ADNS3080_REVISION_ID = 0x01;
int ADNS3080_MOTION = 0x02;
int ADNS3080_DELTA_X =  0x03;
int ADNS3080_DELTA_Y = 0x04;
int ADNS3080_SQUAL  = 0x05;
int ADNS3080_PIXEL_SUM = 0x06;
int ADNS3080_MAXIMUM_PIXEL =  0x07;
int ADNS3080_CONFIGURATION_BITS = 0x0a;
int ADNS3080_EXTENDED_CONFIG = 0x0b;
int ADNS3080_DATA_OUT_LOWER = 0x0c;
int ADNS3080_DATA_OUT_UPPER = 0x0d;
int ADNS3080_SHUTTER_LOWER = 0x0e;
int ADNS3080_SHUTTER_UPPER = 0x0f;
int ADNS3080_FRAME_PERIOD_LOWER  =  0x10;
int ADNS3080_FRAME_PERIOD_UPPER  =  0x11;
int ADNS3080_MOTION_CLEAR   = 0x12;
int ADNS3080_FRAME_CAPTURE  = 0x13;
int ADNS3080_SROM_ENABLE  = 0x14;
int ADNS3080_FRAME_PERIOD_MAX_BOUND_LOWER   =   0x19;
int ADNS3080_FRAME_PERIOD_MAX_BOUND_UPPER  =    0x1a;
int ADNS3080_FRAME_PERIOD_MIN_BOUND_LOWER   =   0x1b;
int ADNS3080_FRAME_PERIOD_MIN_BOUND_UPPER   =   0x1c;
int ADNS3080_SHUTTER_MAX_BOUND_LOWER     =      0x1e;
int ADNS3080_SHUTTER_MAX_BOUND_UPPER    =       0x1e;
int ADNS3080_SROM_ID      =         0x1f;
int ADNS3080_OBSERVATION      =     0x3d;
int ADNS3080_INVERSE_PRODUCT_ID  =  0x3f;
int ADNS3080_PIXEL_BURST    =       0x40;
int ADNS3080_MOTION_BURST   =       0x50;
int ADNS3080_SROM_LOAD      =       0x60;

int ADNS3080_PRODUCT_ID_VAL  =      0x17;

double total_x = 0;

double total_y = 0;


double total_x1 = 0;

double total_y1 = 0;


int x=0;
int y=0;

int a=0;
int b=0;




int distance_x=0;
int distance_y=0;


  
volatile byte movementflag=0;
volatile int xydat[2];
int tdistance = 0;


opticalSensor:: opticalSensor(){
  
}


int opticalSensor:: convTwosComp(int b){
  //Convert from 2's complement
  if(b & 0x80){
    b = -1 * ((b ^ 0xff) + 1);
    }
  return b;
}


void opticalSensor:: mousecam_reset()
{
  digitalWrite(PIN_MOUSECAM_RESET,HIGH);
  delay(1); // reset pulse >10us
  digitalWrite(PIN_MOUSECAM_RESET,LOW);
  delay(35); // 35ms from reset to functional
}


int opticalSensor:: mousecam_init()
{
  pinMode(PIN_MOUSECAM_RESET,OUTPUT);
  pinMode(PIN_MOUSECAM_CS,OUTPUT);
  
  digitalWrite(PIN_MOUSECAM_CS,HIGH);
  
  this->mousecam_reset();
  
  int pid = this->mousecam_read_reg(ADNS3080_PRODUCT_ID);
  if(pid != ADNS3080_PRODUCT_ID_VAL)
    return -1;

  // turn on sensitive mode
  this->mousecam_write_reg(ADNS3080_CONFIGURATION_BITS, 0x19);

  return 0;
}

void opticalSensor:: mousecam_write_reg(int reg, int val)
{
  digitalWrite(PIN_MOUSECAM_CS, LOW);
  SPI.transfer(reg | 0x80);
  SPI.transfer(val);
  digitalWrite(PIN_MOUSECAM_CS,HIGH);
  delayMicroseconds(50);
}

int opticalSensor:: mousecam_read_reg(int reg)
{
  digitalWrite(PIN_MOUSECAM_CS, LOW);
  SPI.transfer(reg);
  delayMicroseconds(75);
  int ret = SPI.transfer(0xff);
  digitalWrite(PIN_MOUSECAM_CS,HIGH); 
  delayMicroseconds(1);
  return ret;
}

void opticalSensor:: mousecam_read_motion(struct MD *p)
{
  digitalWrite(PIN_MOUSECAM_CS, LOW);
  SPI.transfer(ADNS3080_MOTION_BURST);
  delayMicroseconds(75);
  p->motion =  SPI.transfer(0xff);
  p->dx =  SPI.transfer(0xff);
  p->dy =  SPI.transfer(0xff);
  p->squal =  SPI.transfer(0xff);
  p->shutter =  SPI.transfer(0xff)<<8;
  p->shutter |=  SPI.transfer(0xff);
  p->max_pix =  SPI.transfer(0xff);
  digitalWrite(PIN_MOUSECAM_CS,HIGH); 
  delayMicroseconds(5);
}

// pdata must point to an array of size ADNS3080_PIXELS_X x ADNS3080_PIXELS_Y
// you must call mousecam_reset() after this if you want to go back to normal operation
int opticalSensor:: mousecam_frame_capture(byte *pdata)
{
  mousecam_write_reg(ADNS3080_FRAME_CAPTURE,0x83);
  
  digitalWrite(PIN_MOUSECAM_CS, LOW);
  
  SPI.transfer(ADNS3080_PIXEL_BURST);
  delayMicroseconds(50);
  
  int pix;
  byte started = 0;
  int count;
  int timeout = 0;
  int ret = 0;
  for(count = 0; count < ADNS3080_PIXELS_X * ADNS3080_PIXELS_Y; )
  {
    pix = SPI.transfer(0xff);
    delayMicroseconds(10);
    if(started==0)
    {
      if(pix&0x40)
        started = 1;
      else
      {
        timeout++;
        if(timeout==100)
        {
          ret = -1;
          break;
        }
      }
    }
    if(started==1)
    {
      pdata[count++] = (pix & 0x3f)<<2; // scale to normal grayscale byte range
    }
  }

  digitalWrite(PIN_MOUSECAM_CS,HIGH); 
  delayMicroseconds(14);
  
  return ret;
}
void opticalSensor:: Init(){
  pinMode(PIN_SS,OUTPUT);
  pinMode(PIN_MISO,INPUT);
  pinMode(PIN_MOSI,OUTPUT);
  pinMode(PIN_SCK,OUTPUT);
  
  SPI.begin();
  SPI.setClockDivider(SPI_CLOCK_DIV32);
  SPI.setDataMode(SPI_MODE3);
  SPI.setBitOrder(MSBFIRST);
  if(this->mousecam_init()==-1)
  {
    Serial.println("Mouse cam failed to init");
    while(1);
  }  
}

char opticalSensor:: asciiart(int k)
{
  static char foo[] = "WX86*3I>!;~:,`. ";
  return foo[k>>4];
}
byte frame[30* 30];

opticalSensor optical = opticalSensor();
