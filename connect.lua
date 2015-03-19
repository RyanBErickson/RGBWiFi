-- Code originally from https://github.com/dannyvai/esp2866_tools

-- Start AP... 
wifi.setmode(wifi.STATIONAP)
cfg={ssid='myhotspot',pwd='myhotspot'}
wifi.ap.setip({ip = "192.168.1.1", gateway = "192.168.1.1", netmask = "255.255.255.0"})
wifi.ap.config(cfg)

-- This code runs the HTTP server on the AP...
print("Starting 'myhotspot' SSID HTTP Server")
print(wifi.ap.getip())
srv=net.createServer(net.TCP) 
srv:listen(80,function(conn)
  conn:on("receive",function(conn,payload)
    if string.find(payload,"favicon.ico") == nil then
      --print(payload)
      payload = payload .. "&" -- easier to parse...
      local _, _, ssid = payload:find("ssid=(.-)&")
      local _, _, pwd = payload:find("pwd=(.-)&")
      if (ssid ~= nil) and (pwd ~= nil) then
        wifi.setmode(wifi.STATION)
        wifi.sta.config(ssid,pwd)
        print("Connecting to " .. ssid)
        save_config(ssid,pwd)
        conn:close()
        srv:close()
        node.restart()
      end

      html = [====[
<html>
  <form method="POST" name="config_wifi">
    <p>ssid:<input type="text" name="ssid" value="" /></p>
    <p>pwd:<input type="text" name="pwd" value="" /></p>
    <p><input type="submit" value="Config" /></p>
  </form>
</html>
]====]
      conn:send("" .. html)
    end
  end)
  conn:on("sent",function(conn) conn:close() end)
  end)

