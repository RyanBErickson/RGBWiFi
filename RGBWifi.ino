/* ====== ESP8266 Demo ======
 *   Print out analog values
 * ==========================
 *
 * Change SSID and PASS to match your WiFi settings.
 * The IP address is displayed to soft serial upon successful connection.
 *
 * Ray Wang @ Rayshobby LLC
 * http://rayshobby.net/?p=9734
 */
const int redPin = 21;
const int greenPin = 22;
const int bluePin = 23;

#define HWSERIAL Serial1
// Using USB/Serial monitor...
#define dbg Serial

enum {WIFI_ERROR_NONE=0, WIFI_ERROR_AT, WIFI_ERROR_RST, WIFI_ERROR_MODE, WIFI_ERROR_SSIDPWD, WIFI_ERROR_JOIN_WAIT, WIFI_ERROR_SERVER, WIFI_ERROR_UNKNOWN};

#define BUFFER_SIZE 64

#define SSID  "***REMOVED***"   // change this to match your WiFi SSID
#define PASS  "***REMOVED***"  // change this to match your WiFi password
#define PORT  "8080"      // using port 8080 by default

char buffer[BUFFER_SIZE];

void setup() {
  pinMode(redPin, OUTPUT);
  analogWrite(redPin, 255);   
  pinMode(greenPin, OUTPUT);
  analogWrite(greenPin, 255);   
  pinMode(bluePin, OUTPUT);
  analogWrite(bluePin, 0);   

  HWSERIAL.begin(115200);  // was 115200
  HWSERIAL.setTimeout(5000);
 
  delay(5000);  // Wait for Serial Monitor to be opened...  DEBUG code...
  analogWrite(bluePin, 255);   
  
  dbg.begin(9600);
  dbg.println("begin.");
    
  byte err = setupWiFi();
  if (err) {
    // error, print error code
    dbg.print("setup error:");
    dbg.println((int)err);

    // Blink out error number...
    for (int i = 0; i < (int)err; i++){
      analogWrite(redPin, 0);
      delay(500);
      analogWrite(redPin, 255);
      delay(500);
    }
  } else {
    // Wait for IP Address assignment, etc...  TODO: Retry getting IP Address if blank...
    delay(2000);
    // success, print IP
    dbg.print("ip addr:");
    char *ip = getIP();
    if (ip) {
      dbg.println(ip);
    }
    else {
      dbg.println("none");
    }
    maxTimeout();
  }
}

bool maxTimeout() {
  // send AT command
  HWSERIAL.println("AT+CIPSTO=0");
  if(HWSERIAL.find("OK")) {
    return true;
  } else {
    return false;
  }
}

char* getIP() {
  // send AT command
  HWSERIAL.println("AT+CIFSR");

  // the response from the module is:
  // AT+CIFSR\n\n
  // 192.168.x.x\n 
  // so read util \n three times
  // NOTE: Only 2 times on my HW Version...
  HWSERIAL.readBytesUntil('\n', buffer, BUFFER_SIZE);  
  HWSERIAL.readBytesUntil('\n', buffer, BUFFER_SIZE);  
  buffer[strlen(buffer)-1]=0;

  return buffer;
}

void loop() {
  int ch_id, packet_len;
  char *pb;  
  HWSERIAL.readBytesUntil('\n', buffer, BUFFER_SIZE);
  if(strncmp(buffer, "+IPD,", 5)==0) {
    // request: +IPD,ch,len:data
    sscanf(buffer+5, "%d,%d", &ch_id, &packet_len);
    if (packet_len > 0) {
      // read serial until packet_len character received
      // start from :
      pb = buffer+5;
      while(*pb!=':') pb++;
      pb++;
      if (strncmp(pb, "GET /", 5) == 0) {
        serve_homepage(ch_id);
      }
    }
  }
}

void serve_homepage(int ch_id) {
  String header = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nConnection: close\r\nRefresh: 5\r\n";

  String content="";
  // output the value of each analog input pin
  for (int analogChannel = 0; analogChannel < 6; analogChannel++) {
    int sensorReading = analogRead(analogChannel);
    content += "analog input ";
    content += analogChannel;
    content += " is ";
    content += sensorReading;
    content += "<br />\n";       
  }

  header += "Content-Length:";
  header += (int)(content.length());
  header += "\r\n\r\n";
  HWSERIAL.print("AT+CIPSEND=");
  HWSERIAL.print(ch_id);
  HWSERIAL.print(",");
  HWSERIAL.println(header.length()+content.length());
  if (HWSERIAL.find(">")) {
    HWSERIAL.print(header);
    HWSERIAL.print(content);
    delay(20);
  }
  /*HWSERIAL.print("AT+CIPCLOSE=");
  HWSERIAL.println(ch_id);*/
}

byte setupWiFi() {
  // Check for AT command responses.
  HWSERIAL.println("AT");
  if (!SerialFinder(HWSERIAL, "OK", 500, 500)) return WIFI_ERROR_AT;

  // reset WiFi module
  HWSERIAL.println("AT+RST");
  // Reset puts out a lot of text after the 'OK', and ends with 'ready'... long wait for that.
  if (SerialFinder(HWSERIAL, "ready", 500, 3000)) dbg.println("Reset 'ready'."); else return WIFI_ERROR_RST;
 
  // set mode 1 (client mode)
  HWSERIAL.println("AT+CWMODE=1");
  // CWMODE response can be either 'ready' or 'no change'...  Need to handle either...

  if (SerialFinder(HWSERIAL, "no change", 500, 500)) 
    dbg.println("CWMODE 'ready'.");
  else
  {
    HWSERIAL.println("AT+CWMODE=1");
    if (SerialFinder(HWSERIAL, "no change", 500, 500)) dbg.println("CWMODE 'ready'."); else return WIFI_ERROR_MODE;
  }

  // Join Wifi Network with specified SSID / PASS
  String cmd="AT+CWJAP=\"";
  cmd+=SSID;
  cmd+="\",\"";
  cmd+=PASS;
  cmd+="\"";
  HWSERIAL.println(cmd);
  if (SerialFinder(HWSERIAL, "OK", 500, 500)) dbg.println("Join Access Point 'OK'."); else return WIFI_ERROR_SSIDPWD;

  // start server
  HWSERIAL.println("AT+CIPMUX=1");
  if (SerialFinder(HWSERIAL, "OK", 1000, 1000)) dbg.println("Single Connection Mode 'OK'."); else return WIFI_ERROR_SERVER;
  
  HWSERIAL.print("AT+CIPSERVER=1,"); // turn on TCP service
  HWSERIAL.println(PORT);

  if (SerialFinder(HWSERIAL, "OK", 1000, 1000)) dbg.println("Server Mode 'OK'."); else return WIFI_ERROR_SERVER;
  
  return WIFI_ERROR_NONE;
}


// https://scargill.wordpress.com/category/1284/
boolean SerialFinder(HardwareSerial &refSer, char *str, unsigned long howlong, unsigned long timeout)
{
   boolean gotit=false;
   unsigned long mytime;
   char *strtemp;
   char incoming;
   strtemp=str; mytime=millis()+howlong;
   while ((mytime>millis()) || refSer.available()) // if timer demands or there is something there
   {
    if (refSer.available())
      {
       mytime=millis()+timeout;
       incoming=refSer.read(); 
       dbg.print(incoming); // for debug
       if (incoming==*strtemp) { strtemp++; if (*strtemp==0) {strtemp=str; gotit=true; } } else strtemp=str;
      } 
   }
  return gotit; 
}
