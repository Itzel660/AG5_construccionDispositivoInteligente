#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <DHT.h>

#define DHTPIN D4
#define DHTTYPE DHT11

DHT dht(DHTPIN, DHTTYPE);
ESP8266WebServer server(80);

// Pines LED RGB
#define RED D5
#define GREEN D6
#define BLUE D7

const char* ssid = "INFINITUMEC09";
const char* password = "Rp7Dz7Uq7a";

void setup() {
  Serial.begin(115200);
  dht.begin();
  
  pinMode(RED, OUTPUT);
  pinMode(GREEN, OUTPUT);
  pinMode(BLUE, OUTPUT);
  
  WiFi.begin(ssid, password);
  Serial.print("Conectando a WiFi...");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  
  Serial.println("\nConectado! IP: " + WiFi.localIP().toString());

  server.on("/datos", HTTP_GET, []() {
    float temp = dht.readTemperature();
    float hum = dht.readHumidity();
    String json = "{\"temperatura\":" + String(temp) + ",\"humedad\":" + String(hum) + "}";
    Serial.println("update_Data");
    server.send(200, "application/json", json);
  });

  server.on("/color",  cambiarColor);

  server.begin();
}


void cambiarColor() {
    int r = server.arg("r").toInt();
    int g = server.arg("g").toInt();
    int b = server.arg("b").toInt();

    analogWrite(RED, r);
    analogWrite(GREEN, g);
    analogWrite(BLUE, b);
    Serial.println("colores: ");
    Serial.println(r);
    Serial.println(g);
    Serial.println(b);
    server.send(200, "text/plain", "Color cambiado");
  
}

void loop() {
  server.handleClient();
}
