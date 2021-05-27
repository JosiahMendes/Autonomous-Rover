#include "rover_navigation.h"
#include "optical_sensor.h"
#include <movingAvg.h>

movingAvg Vb_average(1000);
void setup() {
  Serial.begin(115200);
   
  rover.Init();
  optical.Init();
  Vb_average.begin();
  rover.SetState(HIGH,LOW);
  
}
bool c = true;

void loop() {
    
    rover.VoltageRegulationStep();
    if(c)
    {
      rover.rotate_clockwise(90);
      rover.move_forward(2.5,200);
    }
    
    c=false;
   
}
