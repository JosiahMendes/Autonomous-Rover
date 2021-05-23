#include "rover_navigation.h"

void setup() {
  Serial.begin(115200);
   
  rover.Init();
  
}

void loop() {
  rover.VoltageRegulationStep();
  rover.move_forward(1,10);
  
}
