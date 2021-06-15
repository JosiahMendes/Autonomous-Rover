#include "WiFi.h"
#include <SPI.h>
#define RXP1 16 //Defining UART With Vision (Pins 8 and 9 on Arduino Adaptor)
#define TXP1 17
#define RXP2 18 //Defining UART With Drive (Pins 6 and 7 on Arduino Adaptor)
#define TXP2 5
#define VSPI_MISO 15 //Defining SPI with Camera on Vision (Pins 10, 11, 12 and 13 on Arduino Adaptor)
#define VSPI_MOSI 4
#define VSPI_SCLK 2
#define VSPI_SS 14
SPIClass * vspi = NULL; //Container for VSPI connection

const char* ssid = "COSMOTE-405421"; //Wifi Name
const char* password = "94BCU8BJ9NYAP725"; //Wifi password

const uint16_t port = 1800; //port number to connect to
const char * host = "192.168.1.10"; //IP to connect to (can be private or public)

char Command[32]; //storage for the actual command
char DriveMsg[32]; //storage for drive's message
char VisionMsg[64]; //storage for vision's message

bool driveready = true; //bool which checks whether drive is ready for receiving command
bool drivemsgready = false; //bool which checks whether drive's message is ready for sending
bool visionmsgready = false; //bool which checks whether vision's message is ready for sending
bool commandready = false; //bool which checks whether command is ready for sending command
bool alreadyconnected = false; //bool which checks whether the ESP32 has already connected with the server

//Event for when the ESP32 successfully connects as a Wifi Station
void WiFiStationConnected(WiFiEvent_t event, WiFiEventInfo_t info){
  Serial.println("Connected to AP successfully!");
}

//Event for when the ESP32 successfully receives it's local IP from the router
void WiFiGotIP(WiFiEvent_t event, WiFiEventInfo_t info){
  Serial.println("WiFi connected");
  Serial.print("RRSI: ");
  Serial.println(WiFi.RSSI());
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

//Event for when the ESP32 disconnects from the Wifi (tries to reconnect)
void WiFiStationDisconnected(WiFiEvent_t event, WiFiEventInfo_t info){
  Serial.println("Disconnected from WiFi access point");
  Serial.print("WiFi lost connection. Reason: ");
  Serial.println(info.disconnected.reason);
  Serial.println("Trying to Reconnect");
  WiFi.begin(ssid, password);
  Serial.print("Reconnecting to WiFi ..");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print('.');
    delay(1000);
  }
}

//Function for initialising connection to the WIFI
void initWiFi() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi ..");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print('.');
    delay(1000);
  }
}

void setup() {
  Serial.begin(115200); //Debugging Line
  Serial2.begin(115200, SERIAL_8N1, RXP2, TXP2); //Uart with Drive
  Serial1.begin(115200, SERIAL_8N1, RXP1, TXP1); //Uart with Vision
  vspi = new SPIClass(VSPI); //Initialising VSPI connection
  vspi->begin(VSPI_SCLK, VSPI_MISO, VSPI_MOSI, VSPI_SS);
  pinMode(VSPI_SS, OUTPUT);
  vspi->setClockDivider(SPI_CLOCK_DIV8);

  WiFi.disconnect(true);
  delay(1000);
  //Initialising events so that they run when the corresponding events occur
  WiFi.onEvent(WiFiStationConnected, SYSTEM_EVENT_STA_CONNECTED);
  WiFi.onEvent(WiFiGotIP, SYSTEM_EVENT_STA_GOT_IP);
  WiFi.onEvent(WiFiStationDisconnected, SYSTEM_EVENT_STA_DISCONNECTED);

  //Running the initialisation of Wifi
  initWiFi();
}

void loop() {
  WiFiClient client; //Initialising ESP32 as a client
  while (true){
    //Attempts to connect to Server using provided Host and Port
    if(!alreadyconnected){
      if (!client.connect(host, port)) {
        Serial.println("Connection to host failed");
        delay(100);
        return;
      }
      Serial.println("Connected to server successful!");
      client.print("Hello from ESP32!");
      alreadyconnected = true;
    }    
        
        if(Serial1.available()){ 
          for(int i = 0;i<64;++i)
          {
            VisionMsg[i]= ' '; 
          }
          char Visioninit = Serial1.read();
          if(!visionmsgready){ // so that it constantly checks for terminal input when receives ready signal from driving
          VisionMsg[0] = '[';
          VisionMsg[1] = Visioninit;
          int i = 2;
          delay(10);
          while(Serial1.available()){
            
            char Visionchar = Serial1.read();
            if(Visionchar != '\n'){
             
              VisionMsg[i] = Visionchar;
              i++;
            }else{
              Serial.println("The message from Vision has been recorded");
              
              VisionMsg[i] = ']';
              break;
            }
          }
      }
        }
        
    //Checks if there is any data on the UART Drive datastream
    if(Serial2.available()) {
      // read the bytes incoming from the UART Port:
      char Driveinit = Serial2.read();
      if(Driveinit == '@' && !driveready){ // so that it constantly checks for terminal input when receives ready signal from driving
        visionmsgready = true;
        Serial.println("Drive is ready to receive a command");
        driveready = true;
        
      }else if(Driveinit == 'D' && !drivemsgready){
        int i = 0;
        while(Serial2.available()){
          char Drivechar = Serial2.read();
          if(Drivechar != '@' || Drivechar != 'Q'){
            DriveMsg[i] = Drivechar;
            i++;
          }else{
            Serial.println("The message from Drive has been recorded");
            drivemsgready = true;
            break;
          }
        }
      }else if(Driveinit == 'Q' && !drivemsgready){
        int i = 0;
        while(Serial2.available()){
          char Drivechar = Serial2.read();
          if(Drivechar != '@'){
            DriveMsg[i] = Drivechar;
            i++;
          }else{
            Serial.println("The message from Drive has been recorded");
            drivemsgready = true;
            break;
          }
        }
      }
    }

    //Checks if there is any data on the TCP datastream and if so, reads it and echoes it back to the server
    if(client.available() && !commandready){
      // read the bytes incoming from the server:
      char Commandinit = client.read();
      if(Commandinit == '['){
        Command[0] = Commandinit;
        int i = 1;
        while(client.available()){
         
          char Commandchar = client.read();
          if(Commandchar != ']'){
            Command[i] = Commandchar;
            i++;
          }else{
            Command[i] = ']';
            Serial.println("The Command has been recorded");
            commandready = true;
            break;
          }
        }
      }else if(Commandinit == 'S'){
        Command[0] = Commandinit;
        Serial.println("The Stop signal has been recorded");
        Serial.print("Sending Stop signal to drive: ");
        Serial.write(Command[0]);
        Serial2.write(Command[0]);
        Command[0] = ' ';
      }
    }

    //Checks if drive and command are ready for moving the rover
    if(driveready && commandready){
      Serial.print("Sending command to drive: ");
      for(int i = 0; i < 32; i++){
        Serial.write(Command[i]);
        Serial2.write(Command[i]);
        Command[i] = ' ';
      }
      Serial.println();
      Serial2.write('\n');
      driveready = false;
      commandready = false;
    }

    //Checks if drive has a message for command
    if(drivemsgready){
      Serial.print("Sending message to command: ");
      for(int i = 0; i < 32; i++){
        Serial.write(DriveMsg[i]);
        client.write(DriveMsg[i]);
        DriveMsg[i] = ' ';
      }
      Serial.println();
      client.write('\n');
      drivemsgready = false;
    }

    //Checks if vision has a message for command
    if(visionmsgready){
      client.write(VisionMsg);
      Serial.print("Sending message to command: ");
      for(int i = 0; i < 64; i++){
        Serial.write(VisionMsg[i]);
        
        VisionMsg[i] = ' ';
         
      }
      Serial.println();
      
      visionmsgready = false;
    }
   
  }
  
}
