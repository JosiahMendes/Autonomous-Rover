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
float choose_speed(char sp)
{
  float ret_speed;
  switch(sp){
    case 'A':
      ret_speed = 4.05;
      break;
    case 'B':
      ret_speed = 3.4;
      break;
    case 'C':
      ret_speed = 2.75;
      break;
    case 'D':
      ret_speed = 2.1;
      break;
    case 'E':
      ret_speed = 1.46;
      break;
    default :
      ret_speed = 2.75;
      
  }
  return ret_speed;
  
}
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
        //Serial1.write("Driving Received: "); //debugging purposes //interfered with stop signal
       // Serial1.write(Command);
        Serial.print("Got this command: "); Serial.println(Command); //debugging purposes
        rcvd = false;
        //Process Command
        int count = 0;
        char parameter[32] = ""; //either distance or angle
        int count_param = 0;
        char command;
        char sp;
        for (int i = 0; i < 32; ++i) {
         if(i==0)
         {
          command = Command[i];
          if(command == 'M')
          {
            sp = Command[i+1];
            i++;
          }
          continue;
         }
          
          if (Command[i] == ',' || i == 31) {
            if (command == 'M')
            {
              
              Serial.print("Paramter1 is: "); Serial.println(parameter);
              
              float ret_speed = choose_speed(sp);
              vref = ret_speed;
                for(int i = 0;i< 500;++i)
                  rover.VoltageRegulationStep();
              if(atoi(parameter) > 0)
                rover.move_forward(ret_speed,atoi(parameter));
              else 
                rover.move_backward(ret_speed,abs(atoi(parameter)));
            }
            else {
              Serial.print("Paramter2 is: "); Serial.println(parameter);
              vref=1.6;
               for(int i = 0;i< 500;++i)
                  rover.VoltageRegulationStep();
               if(atoi(parameter) > 0)
                rover.rotate_clockwise(atoi(parameter));
               else
                rover.rotate_anticlockwise(abs(atoi(parameter)));
            }
            count++;
            count_param = 0;
            strcpy(parameter, "");
            command = i!= 31 ? Command[i+1] : ' ';
            i = i+1;
            if(command == 'M')
            {
              sp = Command[i+1];
              i++;
            }

          }
         else if (Command[i] != ',') {
            parameter[count_param] = Command[i];
            count_param++;
            
          }
        }
        Serial1.write('@');

      }

    }
  }



}
