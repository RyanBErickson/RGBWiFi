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
const int redPin = 23;
const int greenPin = 22;
const int bluePin = 21;

int cur_r = 0;
int cur_g = 0;
int cur_b = 0;

#define HWSERIAL Serial1
// Using USB/Serial monitor...
#define dbg Serial

enum {WIFI_ERROR_NONE=0, WIFI_ERROR_AT, WIFI_ERROR_RST, WIFI_ERROR_MODE, WIFI_ERROR_SSIDPWD, WIFI_ERROR_ECHOOFF, WIFI_ERROR_JOIN_WAIT, WIFI_ERROR_SERVER, WIFI_ERROR_UNKNOWN};

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
    
  // TODO: If we get an WIFI_ERROR_AT, we need to cycle power on the module, and start over...
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
    if (maxTimeout()) dbg.println("Max Timeout Set OK"); else dbg.println("Could not set Max Timeout.");
  }
}

bool maxTimeout() {
  // send AT command
  HWSERIAL.setTimeout(30000); // 30 seconds on serial port timeout...
  HWSERIAL.println("AT+CIPSTO=30");	// This doesn't seem as long as 30 seconds, more like 25...
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
  // NOTE: Only 2 times on my HW/Firmware Version...
  HWSERIAL.readBytesUntil('\n', buffer, BUFFER_SIZE);  
  HWSERIAL.readBytesUntil('\n', buffer, BUFFER_SIZE);  
  buffer[strlen(buffer)-1]=0;

  return buffer;
}

void loop() {
  int ch_id, packet_len;
  char *pb;  
  HWSERIAL.readBytesUntil('\n', buffer, BUFFER_SIZE);

  String mybuf="[";
  mybuf+=buffer;
  mybuf+="]";
  dbg.println(mybuf);

  if(strncmp(buffer, "+IPD,", 5)==0) {
    // request: +IPD,ch,len:data
    sscanf(buffer+5, "%d,%d", &ch_id, &packet_len);
    if (packet_len > 0) {
      // read serial until packet_len character received
      // start from :
      pb = buffer+5;
      while(*pb!=':') pb++;
      pb++;

      // --------- Command Set --------- 
      // All commands end with Newline...
      // !RGB=255,255,255 (RGB Set)
      // !R=128 
      // !G=128
      // !B=128
      // !BRI -- Raises proportionally (right now, not... just adds 5 or 10)
      // !DIM   -- Lowers proprtionally  (right now, not... just adds 5 or 10)
      // !BRI=10 -- Raises by 10
      // !DIM=10   -- Lowers by 10
      // !CFAST -- Cycle Fast (colors) -- Find modes from IR device... (maybe colors)
      // !CSLOW -- Cycle Slow (colors)
      // !COLOR=RED/BLUE/GREEN/YELLOW/BLACK
      // !RAMP=128,128,128 -- RAMP to RGB over time...
      // ------------------------------- 

      // TODO: Move parsing into a function...
      // TODO: How to do ramps, plus check HWSERIAL.available() to get new commands?
      // TODO: Can I have multiple ramps going at once???  That sounds *HARD*... :)

      // DEBUG: Diagnostic mode, where commands prefixed by ~ get sent to the modem...  Then I can do some API testing...
      if (strncmp(pb, "~", 1) == 0) {
        String cmd = pb+1;
        dbg.print("Sending: [");
        dbg.print(cmd);
        dbg.println("] to ESP8266...");
        HWSERIAL.println(cmd);
      }


      -- TODO: Should probably match by smallest to largest string comparisons...

      if ((strncmp(pb, "!BRI", 4) == 0) || (strncmp(pb, "!bri", 4) == 0)) {
	SetRGB(cur_r+10, cur_g+10, cur_b+10);

        -- TODO: These should all return current RGB values, not just 'OK'...
	-- TODO: But probably not during fades...
	SendReply(ch_id, "OK");
      }
      if ((strncmp(pb, "!DIM", 4) == 0) || (strncmp(pb, "!dim", 4) == 0)) {
	SetRGB(cur_r-10, cur_g-10, cur_b-10);
	SendReply(ch_id, "OK");
      }
      if ((strncmp(pb, "!RGB=", 5) == 0) || (strncmp(pb, "!rgb=", 5) == 0)) {
        int r, g, b;
        sscanf(pb+5, "%d,%d,%d", &r, &g, &b);
	SetRGB(r, g, b);
	SendReply(ch_id, "OK");
      }
      if ((strncmp(pb, "!R=", 3) == 0) || (strncmp(pb, "!r=", 3) == 0)) {
        int r;
        sscanf(pb+3, "%d", &r);
	SetRGB(r, cur_g, cur_b);
        cur_r = r;
	SendReply(ch_id, "OK");
      }
      if ((strncmp(pb, "!G=", 3) == 0) || (strncmp(pb, "!g=", 3) == 0)) {
        int g;
        sscanf(pb+3, "%d", &g);
	SetRGB(cur_r, g, cur_b);
        cur_g = g;
	SendReply(ch_id, "OK");
      }
      if ((strncmp(pb, "!B=", 3) == 0) || (strncmp(pb, "!b=", 3) == 0)) {
        int b;
        sscanf(pb+3, "%d", &b);
	SetRGB(cur_r, cur_g, b);
        cur_b = b;
	SendReply(ch_id, "OK");
      }
    }
  }
}


boolean SetRGB(int r, int g, int b)
{
  // Validate
  if (r > 255) r = 255;
  if (r < 0) r = 0;
  if (g > 255) g = 255;
  if (g < 0) g = 0;
  if (b > 255) b = 255;
  if (b < 0) b = 0;

  // Save Current
  cur_r = r;
  cur_g = g;
  cur_b = b;

  // Set Outputs
  analogWrite(redPin, 255-r);
  analogWrite(greenPin, 255-g);
  analogWrite(bluePin, 255-b);
}


boolean SendReply(int ch_id, String msg)
{
  HWSERIAL.print("AT+CIPSEND=");
  HWSERIAL.print(ch_id);
  HWSERIAL.print(",");
  msg += "\n";
  HWSERIAL.println(msg.length());
  if (HWSERIAL.find(">")) {
    HWSERIAL.print(msg);
  }
}


byte setupWiFi() {
  // Check for AT command responses.
  HWSERIAL.println("AT");
  if (!SerialFinder(HWSERIAL, "OK", 500, 500)) return WIFI_ERROR_AT;

  // reset WiFi module
  HWSERIAL.println("AT+RST");
  // Reset puts out a lot of text after the 'OK', and ends with 'ready'... long wait for that.
  if (SerialFinder(HWSERIAL, "ready", 500, 3000)) dbg.println("Reset 'ready'."); else return WIFI_ERROR_RST;
 
  // set mode 1 (client mode) or 3 (both?)
  HWSERIAL.println("AT+CWMODE=3");
  // CWMODE response can be either 'ready' or 'no change'...  Need to handle either...

  if (SerialFinder(HWSERIAL, "no change", 500, 500)) 
    dbg.println("CWMODE 'ready'.");
  else
  {
    HWSERIAL.println("AT+CWMODE=3");
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

  // Echo Off -- Requires updated firmware... TODO:
  //HWSERIAL.println("ATE0");
  //if (SerialFinder(HWSERIAL, "OK", 1000, 1000)) dbg.println("Echo Off 'OK'."); else return WIFI_ERROR_ECHOOFF;

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
