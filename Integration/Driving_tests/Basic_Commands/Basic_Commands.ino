#include "rover_navigation.h"
#include "optical_sensor.h"
#include <movingAvg.h>
movingAvg Vb_average(1000);
void setup() {
  Serial1.begin(115200, SERIAL_8N1);
  Serial.begin(115200);
  Vb_average.begin();

  rover.Init();
  optical.Init();
  rover.SetState(HIGH, LOW);
  Serial1.write('@');
}
bool test_command = true;
void loop() {
  vref = 0.5;
  rover.VoltageRegulationStep();
  bool rcvd = false;
  if (Serial1.available())
  {
    Serial.println("in1");
    char TempChar = Serial1.read();
    if (TempChar == '[') {
      Serial.println("in2");
      delay(7);
      int n = Serial1.available();
      char Command[32];
      int count = 0;
      Serial.println("in3");
      while (n > 0) {
        rover.VoltageRegulationStep();
        Serial.println("in4");
        char TermChar = Serial1.read();
        Serial.println(TermChar);
        Command[count] = TermChar;
        Command[count + 1] = '\0';
        n--;
        count++;
        rcvd = true;
      }
      if (rcvd) {
        Serial1.write("Driving Received: "); //debugging purposes
        Serial1.write(Command);
        Serial.print("Got this command: "); Serial.println(Command); //debugging purposes
        rcvd = false;
        //Process Command
        int count = 0;
        char parameter[32] = ""; //either distance or angle
        int count_param = 0;

        for (int i = 0; i < 32; ++i) {
          Serial.println(i);
          if (Command[i] != ',') {
            parameter[count_param] = Command[i];
            count_param++;
            if (i == 31) {
              if (count % 2 == 0)
              {
                Serial.print("Paramter1 is: "); Serial.println(parameter);
                vref = 2.5;
                for(int i = 0;i< 500;++i)
                  rover.VoltageRegulationStep();
                rover.move_forward(2.5,atoi(parameter));
              }
              else {
                Serial.print("Paramter2 is: "); Serial.println(parameter);
                 rover.rotate_clockwise(atoi(parameter)/10);
              }
            }
          }
          else if (Command[i] == ',') {
            if (count % 2 == 0)
            {
              Serial.print("Paramter1 is: "); Serial.println(parameter);
              vref = 2.5;
                for(int i = 0;i< 500;++i)
                  rover.VoltageRegulationStep();
              rover.move_forward(2.5,atoi(parameter));
            }
            else {
              Serial.print("Paramter2 is: "); Serial.println(parameter);
               rover.rotate_clockwise(atoi(parameter)/10);
            }
            count++;
            count_param = 0;
            strcpy(parameter, "");

          }
        }

      }

    }
  }



}
