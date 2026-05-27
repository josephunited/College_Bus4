#include <TinyGPS++.h>
#include <HardwareSerial.h>

TinyGPSPlus gps;

// UARTs
HardwareSerial gpsSerial(2);
HardwareSerial sim800(1);

// Server (UPDATE TO PUBLIC URL, e.g., https://carat-lustily-unrobed.ngrok-free.dev/location)
String serverURL = "https://carat-lustily-unrobed.ngrok-free.dev/location";

// Function declarations
void sendAT(String cmd);
void initGPRS();
void sendToServer(float lat, float lon);
String waitForResponse(String keyword, int timeout);

void setup() {
  Serial.begin(115200);

  gpsSerial.begin(9600, SERIAL_8N1, 4, -1);   // GPS RX only
  sim800.begin(9600, SERIAL_8N1, 16, 17);

  Serial.println("System Starting...");
  delay(5000);

  initGPRS();
}

void loop() {
  while (gpsSerial.available()) {
    gps.encode(gpsSerial.read());
  }

  if (gps.location.isValid()) {
    float lat = gps.location.lat();
    float lon = gps.location.lng();

    Serial.println("\n--- GPS FIXED ---");
    Serial.println(lat, 6);
    Serial.println(lon, 6);

    sendToServer(lat, lon);

    delay(20000);
  }
}

/////////////////////////////////////////////////////
// 🔥 GPRS INIT (STABLE)
/////////////////////////////////////////////////////
void initGPRS() {
  sendAT("AT");
  sendAT("AT+CPIN?");
  sendAT("AT+CSQ");
  sendAT("AT+CREG?");

  sendAT("AT+CFUN=1");   // 🔥 radio reset
  delay(2000);

  sendAT("AT+SAPBR=0,1");
  delay(2000);

  sendAT("AT+SAPBR=3,1,\"Contype\",\"GPRS\"");
  sendAT("AT+SAPBR=3,1,\"APN\",\"airtelgprs.com\""); // Change to your SIM's APN
  delay(2000);

  sendAT("AT+SAPBR=1,1");
  delay(5000);

  sendAT("AT+SAPBR=2,1");
}

/////////////////////////////////////////////////////
// 🔥 SEND DATA
/////////////////////////////////////////////////////
void sendToServer(float lat, float lon) {
  // Ensure GPRS alive
  sendAT("AT+SAPBR=2,1");

  String json = "{\"bus_id\":6097,\"lat\":";
  json += String(lat, 6);
  json += ",\"lng\":";
  json += String(lon, 6);
  json += ",\"speed\":0}";

  Serial.println("Sending:");
  Serial.println(json);

  /////////////////////////////////////////////////////
  // 🔥 CLEAN HTTP STATE
  /////////////////////////////////////////////////////
  sendAT("AT+HTTPTERM");
  delay(1000);

  sendAT("AT+HTTPINIT");
  delay(2000);

  sendAT("AT+HTTPSSL=1");  // Enable SSL for HTTPS
  delay(1000);

  sendAT("AT+HTTPPARA=\"CID\",1");
  sendAT("AT+HTTPPARA=\"REDIR\",1");
  sendAT("AT+HTTPPARA=\"UA\",\"ESP32_SIM800\"");
  sendAT("AT+HTTPPARA=\"CONTENT\",\"application/json\"");
  sendAT(("AT+HTTPPARA=\"URL\",\"" + serverURL + "\"").c_str());

  /////////////////////////////////////////////////////
  // SEND DATA
  /////////////////////////////////////////////////////
  sim800.print("AT+HTTPDATA=");
  sim800.print(json.length());
  sim800.println(",10000");

  if (waitForResponse("DOWNLOAD", 8000) == "") {
    Serial.println("DOWNLOAD failed ❌");
    return;
  }

  sim800.print(json);
  delay(3000);

  if (waitForResponse("OK", 10000) == "") {
    Serial.println("HTTPDATA failed ❌");
    return;
  }

  /////////////////////////////////////////////////////
  // 🔥 HTTP ACTION
  /////////////////////////////////////////////////////
  sendAT("AT+HTTPACTION=1");

  String actionResponse = waitForResponse("+HTTPACTION: 1,", 15000);
  if (actionResponse == "") {
    Serial.println("HTTPACTION failed ❌");
    return;
  }

  // Parse status code
  int start = actionResponse.indexOf("+HTTPACTION: 1,");
  if (start != -1) {
    int comma1 = actionResponse.indexOf(",", start);
    int comma2 = actionResponse.indexOf(",", comma1 + 1);
    if (comma1 != -1 && comma2 != -1) {
      String statusStr = actionResponse.substring(comma1 + 1, comma2);
      int status = statusStr.toInt();
      if (status == 200) {
        Serial.println("HTTP SUCCESS ✅");
      } else {
        Serial.println("HTTP ERROR: " + String(status));
        return;
      }
    }
  }

  sendAT("AT+HTTPREAD");
  sendAT("AT+HTTPTERM");
}

/////////////////////////////////////////////////////
// 🔧 AT COMMAND HELPER
/////////////////////////////////////////////////////
void sendAT(String cmd) {
  while (sim800.available()) sim800.read();

  sim800.println(cmd);
  Serial.println(">> " + cmd);

  delay(2000);

  while (sim800.available()) {
    Serial.write(sim800.read());
  }
}

/////////////////////////////////////////////////////
// 🔧 WAIT FUNCTION (UPDATED)
/////////////////////////////////////////////////////
String waitForResponse(String keyword, int timeout) {
  long int time = millis();
  String response = "";

  while ((time + timeout) > millis()) {
    while (sim800.available()) {
      char c = sim800.read();
      response += c;
    }

    if (response.indexOf(keyword) != -1) {
      Serial.println(response);
      return response;
    }
  }

  Serial.println(response);
  return "";
}