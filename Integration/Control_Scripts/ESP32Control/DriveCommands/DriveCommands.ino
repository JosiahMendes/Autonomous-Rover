#define RXP2 16
#define TXP2 17

void setup() {
  Serial.begin(115200);
  Serial2.begin(115200, SERIAL_8N1, RXP2, TXP2);
  Serial2.print("Hey2");
  Serial.print("Hey1");
}

bool drv_ready = true;
void loop() {



 

  while (true) {
     char Command[32];
    if (Serial2.available()) {
      // read the bytes incoming from the UART Port:
      char DriveReady = Serial2.read();
      while (DriveReady == '@') { // so that it constantly checks for terminal input when receives ready signal from driving
        
        if(drv_ready){
          Serial.println("Command is ready");
          drv_ready = false;
        }
          
        int n = Serial.available();
        if (n > 0)
        {
          char TermReady = Serial.read();
          
          delay(2);//give time for data to get to serial. Otherwise it would give k = 0
          int k = Serial.available();
          if (TermReady == '!') {
            

           
            int count = 0;
            while (k > 0) {
              
              char TermChar = Serial.read();
              Command[count] = TermChar;
              Command[count + 1] = '\0';
              k--;
              count++;
            }
            Serial2.write(Command);
            Serial.println(Command);
            
            
          }
          DriveReady = 'L';// break from while

        }
      }
      drv_ready = true;
      if(DriveReady == 'D'){
        Serial.println("Driving sent smth");
        delay(3);
        int k = Serial2.available();
        char Drive_message[32];
        int count = 0;
        while (k > 0) {
              Serial.println("In3");
              char TermChar = Serial2.read();
              Drive_message[count] = TermChar;
              Drive_message[count + 1] = '\0';
              k--;
              count++;
            }
        Serial.print("D");Serial.println(Drive_message);
        
      }

    }



  }



}
