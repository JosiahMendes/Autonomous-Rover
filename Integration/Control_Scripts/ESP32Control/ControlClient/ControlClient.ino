#include "WiFi.h"
#define RXp2 3
#define TXp2 1//need to install the ESP32 software serial library through Arduino manager

const char* ssid = "COSMOTE-405421"; //Wifi Name
const char* password = "94BCU8BJ9NYAP725"; //Wifi password

const uint16_t port = 1800; //port number to connect to
const char * host = "192.168.1.4"; //IP to connect to (can be private or public)

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
  Serial.begin(115200);
  Serial2.begin(115200, SERIAL_8N1, RXp2, TXp2);
  WiFi.disconnect(true);
  delay(1000);
   //Begin UART Port
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
    //Checks if there is any data on the TCP datastream and if so, reads it and echoes it back to the server
    if(client.available()){
      // read the bytes incoming from the server:
      char thisChar = client.read();
      // echo the bytes back to the server:
      client.write(thisChar);
      // write the bytes to all serial devices as well:
      Serial.write(thisChar);
      Serial2.write(thisChar);
    }
  }
}
