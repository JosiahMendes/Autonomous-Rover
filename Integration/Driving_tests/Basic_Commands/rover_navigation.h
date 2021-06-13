#ifndef rover_navigation_h
#define rover_navigation_h
#include <Vector.h>
#include <INA219_WE.h>
#include <movingAvg.h>

extern INA219_WE ina219;
//************************** SMPS Constants **************************//
extern float open_loop, closed_loop; // Duty Cycles
extern float vpd,vb,vref,iL,dutyref,current_mA; // Measurement Variables
extern unsigned int sensorValue0,sensorValue1,sensorValue2,sensorValue3;  // ADC sample values declaration
extern float ev,cv,ei,oc; //internal signals
extern float Ts; //1.25 kHz control frequency. It's better to design the control period as integral multiple of switching period.
extern float kpv,kiv,kdv; // voltage pid.
extern float u0v,u1v,delta_uv,e0v,e1v,e2v; // u->output; e->error; 0->this time; 1->last time; 2->last last time
extern float kpi,kii,kdi; // current pid.
extern float u0i,u1i,delta_ui,e0i,e1i,e2i; // Internal values for the current controller
extern float uv_max, uv_min; //anti-windup limitation
extern float ui_max, ui_min; //anti-windup limitation
extern float current_limit ;
extern boolean Boost_mode ;
extern boolean CL_mode;
extern movingAvg Vb_average;


extern unsigned int loopTrigger;
extern unsigned int com_count;   // a variables to count the interrupts. Used for program debugging.

//************************** Motor Constants **************************//

extern int DIRRstate;              //initializing direction states
extern int DIRLstate;

extern int DIRL;                    //defining left direction pin
extern int DIRR;                    //defining right direction pin

extern int pwmr;                     //pin to control right wheel speed using pwm
extern int pwml;                     //pin to control left wheel speed using pwm
//*******************************************************************//
extern float pre_ev;




class Rover{
  public:
  Rover();
  void Init();
  //SMPS METHODS
  void PWM_output();
  void sampling();
  float saturation(float sat_input, float uplim, float lowlim);
  void pwm_modulate(float pid_input);
  void VoltageRegulationStep();
  void VoltageRegulation();
  //CLOSED-LOOP BUCK
  float pidv(float pid_input);
  float pidi(float pid_input);
  void ControlLoopInterrupt();
  void SetSMPSPins();
  //Motor Methods
  void SetMotorPins();
  void SetState(int Rstate, int Lstate);
  //Navigation Methods
  void move_forward(float rover_speed, long int distance);
  void move_backward(float rover_speed, long int distance);
  void rotate_clockwise(int deg);
  void rotate_anticlockwise(int deg);
  void Stop();
  
  //MAPPING
  void path_follower(Vector<float> distance , Vector<int> deg);
  
  };

extern Rover rover;
#endif
