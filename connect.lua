-- Code from https://github.com/dannyvai/esp2866_tools

-- Start 'myhotspot' AP... 
print("Starting 'SSID:myhotspot' Server")
wifi.setmode(wifi.STATIONAP)
wifi.ap.setip({ip = "192.168.1.1", gateway = "192.168.1.1", netmask = "255.255.255.0"})
wifi.ap.config({ssid='myhotspot', pwd='myhotspot'})
print(wifi.ap.getip())

-- slow blink red LED for 'configuration mode'... once every 3 seconds
--tmr.alarm(0, 1500, 1, function() led() end)
blinkstop()
blink(20, 20, 0, 1000)

-- Start webserver...
srv=net.createServer(net.TCP) 
srv:listen(80,function(conn)
  conn:on("receive",function(conn,payload)
    if string.find(payload,"favicon.ico") == nil then
      payload = payload .. "&" -- easier to parse...
      print(payload)
      local _, _, ssid = payload:find("ssid=(.-)&")
      local _, _, pwd = payload:find("pwd=(.-)&")
      if (ssid ~= nil) and (pwd ~= nil) then
        print("Saving SSID data and restarting...")
        config(ssid,pwd)
        conn:send("HTTP/1.1 200 OK\r\n")
        conn:send("Content-type: text/html\r\n")
        conn:send("Connection: close\r\n\r\n")
        conn:send([====[<html>
<H1>Configuration Saved</H1>
<p/>Saved access point configuration.  Restarting in 3 seconds.</H1>
</html>]====])
        kill()
        rgbw(0,30)
        tmr.alarm(1, 3000, 0, function() conn:close() srv:close() node.restart() end)
      else
        conn:send("HTTP/1.1 200 OK\r\n")
        conn:send("Content-type: text/html\r\n")
        conn:send("Connection: close\r\n\r\n")
        conn:send([====[<html>
  <form method="POST" name="config_wifi">
    <p>ssid:<input type="text" name="ssid" value="" /></p>
    <p>pwd:<input type="text" name="pwd" value="" /></p>
    <p><input type="submit" value="Config" /></p>
  </form>
</html>]====])
      end
    end
  end)
  conn:on("sent",function(conn) conn:close() end)
end)

print("Loaded connect...")
