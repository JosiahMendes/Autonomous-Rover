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
bool c = true;
void loop() {
 
  rover.VoltageRegulationStep();
 
  bool rcvd = false;
  if (Serial1.available())
  {
    char TempChar = Serial1.read();
    if (TempChar == '[') { // check for valid initial character of command 
      delay(7); // small delay to allow data to arrive to the Serial buffer
      int n = Serial1.available(); // number of characters available to be read in the Serial
      char Command[32]; // Command buffer
      int count = 0;
      while (n > 0) { 
        rover.VoltageRegulationStep();
        char TermChar = Serial1.read(); // read character of command
        Command[count] = TermChar;
        Command[count + 1] = '\0';//String end
        n--; // decrease available characters
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
          if(command == 'M')// this character is for the move_forward and move_backward command
          {
            sp = Command[i+1]; // this character denotes the required speed of the rover (ranges from A-E)
            i++;
          }
          continue;
         }
          
          if (Command[i] == ',' || i == 31) { // comma seperates commands and i = 31 when we read the last character of the Command buffer
            if (command == 'M')
            {
              
              Serial.print("Distance is: "); Serial.println(parameter); //example 
              float ret_speed = choose_speed(sp);
              if(atoi(parameter) > 0)
                rover.move_forward(ret_speed,atoi(parameter));// if the value is positive then move forward
              else 
                rover.move_backward(ret_speed,abs(atoi(parameter)));// if it is negative then backward
            }
            else {
              Serial.print("Angle is: "); Serial.println(parameter);
               if(atoi(parameter) > 0)//if angle is positive rotate clockwise else anticlockwise
                rover.rotate_clockwise(atoi(parameter));
               else
                rover.rotate_anticlockwise(abs(atoi(parameter)));
            }
            count++;
            count_param = 0;
            strcpy(parameter, "");
            command = i!= 31 ? Command[i+1] : ' ';//read next command
            i = i+1;
            if(command == 'M')
            {
              sp = Command[i+1]; // read speed
              i++;
            }

          }
         else if (Command[i] != ',') {// if the current character is not a comma then add it to the parameter
            parameter[count_param] = Command[i];
            count_param++;
            
          }
        }
        Serial1.write('@');// send to Control when a command is finished

      }

    }
  }



}
