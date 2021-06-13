#define RXP2 3
#define TXP2 1

void setup() {
  Serial.begin(115200);
  Serial2.begin(115200, SERIAL_8N1, RXP2, TXP2);
}

void loop() {
  char* Command;
  while(true){
    if(Serial2.available()){
    // read the bytes incoming from the UART Port:
    char DriveReady = Serial2.read();
      if(DriveReady == '@'){
        if(Serial.available()){
          char TermReady = Serial.read();
          if(TermReady == '!'){
            Command = "";
            while(Serial.available()){
              char TermChar = Serial.read();
              Command + TermChar;
            }
          }
        }
      Serial2.write(Command);
      }
    }
  }
}