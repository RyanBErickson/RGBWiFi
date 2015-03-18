-- Code originally from https://github.com/dannyvai/esp2866_tools

-- Start AP... 
wifi.setmode(wifi.STATIONAP)
cfg={ssid='myhotspot',pwd='myhotspot'}
wifi.ap.setip({ip = "192.168.1.1", gateway = "192.168.1.1", netmask = "255.255.255.0"})
wifi.ap.config(cfg)

-- This code runs the HTTP server on the AP...
print("Starting 'myhotspot' SSID HTTP Server")
print(wifi.ap.getip())
srv=net.createServer(net.TCP) srv:listen(80,function(conn)
  conn:on("receive",function(conn,payload)
    print(payload)
    if string.find(payload,"favicon.ico") == nil then
    local _, _, ssid, pwd = payload:find("ssid=(.-)&pwd=(.*)")
    print(ssid)
    print(pwd)
      wifi.setmode(wifi.STATION)
      wifi.sta.config(ssid,pwd)
      print("Connecting to " .. ssid)
      save_config(ssid,pwd)
      node.restart()
  end

  html='<html><form method="POST" name="config_wifi"><p>ssid:<input name="ssid" value="" /></p>'
  html = html .. '<p>pwd:<input name="pwd" value="" /></p>'
  html = html .. '<p><input type="submit" value="config" /></p>'
  conn:send( "".. html .." ssid was :" .. ssid .. " pwd was : " .. pwd)
  end)
conn:on("sent",function(conn) conn:close() end)
end)

