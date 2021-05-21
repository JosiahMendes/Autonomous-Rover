
void setup() {
  Serial1.begin(115200, SERIAL_8N1);
  Serial.begin(115200);
}

void loop() {
  
  if(Serial1.available()) {
    char data_rcvd = Serial1.read();
    Serial.println("Driving module received: %c");
    Serial.println(data_rcvd);
  }
  
}
