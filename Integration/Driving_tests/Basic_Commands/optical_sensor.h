#ifndef optical_sensor_h
#define optical_sensor_h
extern int PIN_SS;
extern int PIN_MISO;
extern int PIN_MOSI;
extern int PIN_SCK;



extern int PIN_MOUSECAM_RESET;
extern int PIN_MOUSECAM_CS;

extern int ADNS3080_PIXELS_X;
extern int ADNS3080_PIXELS_Y;
extern int ADNS3080_PRODUCT_ID;
extern int ADNS3080_REVISION_ID;
extern int ADNS3080_MOTION;
extern int ADNS3080_DELTA_X;
extern int ADNS3080_DELTA_Y;
extern int ADNS3080_SQUAL;
extern int ADNS3080_PIXEL_SUM;
extern int ADNS3080_MAXIMUM_PIXEL;
extern int ADNS3080_CONFIGURATION_BITS;
extern int ADNS3080_EXTENDED_CONFIG;
extern int ADNS3080_DATA_OUT_LOWER;
extern int ADNS3080_DATA_OUT_UPPER;
extern int ADNS3080_SHUTTER_LOWER;
extern int ADNS3080_SHUTTER_UPPER;
extern int ADNS3080_FRAME_PERIOD_LOWER;
extern int ADNS3080_FRAME_PERIOD_UPPER;
extern int ADNS3080_MOTION_CLEAR;
extern int ADNS3080_FRAME_CAPTURE;
extern int ADNS3080_SROM_ENABLE;
extern int ADNS3080_FRAME_PERIOD_MAX_BOUND_LOWER;
extern int ADNS3080_FRAME_PERIOD_MAX_BOUND_UPPER;
extern int ADNS3080_FRAME_PERIOD_MIN_BOUND_LOWER;
extern int ADNS3080_FRAME_PERIOD_MIN_BOUND_UPPER;
extern int ADNS3080_SHUTTER_MAX_BOUND_LOWER;
extern int ADNS3080_SHUTTER_MAX_BOUND_UPPER;
extern int ADNS3080_SROM_ID;
extern int ADNS3080_OBSERVATION;
extern int ADNS3080_INVERSE_PRODUCT_ID;
extern int ADNS3080_PIXEL_BURST;
extern int ADNS3080_MOTION_BURST;
extern int ADNS3080_SROM_LOAD;

extern int ADNS3080_PRODUCT_ID_VAL;



extern float total_x;

extern float total_y;


extern float total_x1;

extern float total_y1;


extern int x;
extern int y;

extern int a;
extern int b;




extern int distance_x;
extern int distance_y;


  
extern volatile byte movementflag;
extern volatile int xydat[2];
extern int tdistance;
extern byte frame[];

struct MD
  {
   byte motion;
   char dx, dy;
   byte squal;
   word shutter;
   byte max_pix;
  };
  
class   opticalSensor{
  public:
  
  opticalSensor();
  void Init();
  int convTwosComp(int b);
  void mousecam_reset();
  int mousecam_init();
  void mousecam_write_reg(int reg, int val);
  int mousecam_read_reg(int reg);
  void mousecam_read_motion(struct MD *p);
  int mousecam_frame_capture(byte *pdata);
  char asciiart(int k);
  
};

extern opticalSensor optical;



#endif
