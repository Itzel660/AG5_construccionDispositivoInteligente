#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <DHT_U.h>
#include <WiFi.h>
#include <WebServer.h>

#define DHTPIN 15     
#define DHTTYPE DHT22 

const char* ssid = "INFINITUM116C_2.4";
const char* password = "29UxeTQuaX";    

DHT_Unified dht(DHTPIN, DHTTYPE);
WebServer server(80);


#define LED_R 25 
#define LED_G 26  
#define LED_B 27

void setColor(int r, int g, int b) {
  ledcWrite(LED_R, 255 - r); 
  ledcWrite(LED_G, 255 - g);
  ledcWrite(LED_B, 255 - b);
}

void handleSensorData() {
  sensors_event_t event;
  dht.temperature().getEvent(&event);
  float temperatura = isnan(event.temperature) ? -1 : event.temperature;
  dht.humidity().getEvent(&event);
  float humedad = isnan(event.relative_humidity) ? -1 : event.relative_humidity;

  String json = "{\"temperatura\": " + String(temperatura) + ", \"humedad\": " + String(humedad) + "}";
  server.send(200, "application/json", json);
}

void handleSetColor() {
  if (server.hasArg("r") && server.hasArg("g") && server.hasArg("b")) {
    int r = server.arg("r").toInt();
    int g = server.arg("g").toInt();
    int b = server.arg("b").toInt();
    setColor(r, g, b);
    server.send(200, "text/plain", "Color set successfully");
  } else {
    server.send(400, "text/plain", "Missing color parameters");
  }
}

void setup() {
  Serial.begin(9600);
  dht.begin();
  WiFi.begin(ssid, password);

  Serial.print("Conectando a Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
  }
  Serial.println("\nConectado a Wi-Fi!");
  Serial.print("Dirección IP: ");
  Serial.println(WiFi.localIP());


  ledcAttach(25, 5000, 8); 
  ledcAttach(26, 5000, 8); 
  ledcAttach(27, 5000, 8); 
  setColor(255, 255, 255); 

 
  server.on("/sensor", handleSensorData);
  server.on("/setColor", handleSetColor);
  server.begin();
}

void loop() {
  server.handleClient();
}
