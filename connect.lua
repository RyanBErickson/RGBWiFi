-- Code originally from https://github.com/dannyvai/esp2866_tools

-- save config.lua... 
local _c = "config.lua"
function save_config(ssid, pass)
  ssid, pass = ssid or '', pass or ''
  file.open(_c, "w")
  file.close()
  file.remove(_c)
  file.open(_c, "w+")
  file.writeline('C = {}')
  if (ssid ~= '') then file.writeline('C.SSID = "' .. ssid .. '"') end
  if (pass ~= '') then file.writeline('C.PASS = "' .. pass .. '"') end
  file.flush()
  file.close()
end

-- Start 'myhotspot' AP... 
print("Starting 'SSID:myhotspot' Server")
wifi.setmode(wifi.STATIONAP)
wifi.ap.setip({ip = "192.168.1.1", gateway = "192.168.1.1", netmask = "255.255.255.0"})
wifi.ap.config({ssid='myhotspot', pwd='myhotspot'})
print(wifi.ap.getip())

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
        save_config(ssid,pwd)
        conn:send("HTTP/1.1 200 OK\r\n")
        conn:send("Content-type: text/html\r\n")
        conn:send("Connection: close\r\n\r\n")
        conn:send([====[<html>
<H1>Configuration Saved</H1>
<p/>Saved access point configuration.  Restarting in 3 seconds.</H1>
</html>]====])
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

