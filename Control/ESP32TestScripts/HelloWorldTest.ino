
int ledPin = 2;

void setup() {
  // put your setup code here, to run once:
  pinMode(ledPin, OUTPUT);

  Serial.begin(115200);
}

void loop() {
  // put your main code here, to run repeatedly:
  Serial.print("Hello");
  digitalWrite(ledPin, HIGH);

  delay(500);
  
  Serial.print(" world! \n");
  digitalWrite(ledPin, LOW);

  delay(500);
}
