-- Code from https://github.com/dannyvai/esp2866_tools

-- Start 'myhotspot' AP... 
print("Starting 'SSID:RGBWifi' Server")
wifi.setmode(wifi.STATIONAP)
wifi.ap.setip({ip = "192.168.1.1", gateway = "192.168.1.1", netmask = "255.255.255.0"})
wifi.ap.config({ssid='RGBWifi', pwd='password'})
wifi.ap.dhcp.start()
print("DHCP Range: ["..wifi.ap.dhcp.config({start="192.168.1.100"}).."]")
print("IP Info: [" .. wifi.ap.getip() .. "]")

-- Start slow 'yellow' blink...
blinkstop()
blink(20, 20, 0, 1500, 1000)

function SendContent(conn, content)
  local out, tins = {}, table.insert
  tins(out,"HTTP/1.1 200 OK\r\n")
  tins(out,"Content-type: text/html\r\n")
  tins(out,"Content-length: " .. #content .. "\r\n")
  tins(out,"Connection: close\r\n\r\n")
  tins(out,content)
  print("SENDING: [" .. table.concat(out, "") .. "]")
  conn:send(table.concat(out, ""))
end

-- Start webserver...
srv=net.createServer(net.TCP, 30)
srv:listen(80,function(conn)
  conn:on("receive",function(conn,payload)
    if string.find(payload,"favicon.ico") == nil then
      print("recv: " .. payload)
      payload = payload .. "&" -- easier to parse...
      local _, _, ssid = payload:find("ssid=(.-)&")
      local _, _, pwd = payload:find("pwd=(.-)&")
      if (ssid ~= nil) and (pwd ~= nil) then

        -- Test the new config with wifi.station mode...
        wifi.sta.eventMonReg(wifi.STA_WRONGPWD, function() 
             SendContent(conn,"<html><h2>Wrong Password... Refresh to try again.</h2>")
             rgbw(30,0)
          end)
        wifi.sta.eventMonReg(wifi.STA_GOTIP, function() 
             config(ssid,pwd)
             SendContent(conn,"<html><h2>Success!!!<h2><p/>IP Address: " .. (wifi.sta.getip()) .. 
                              "<p/>Saving Config and restarting...")
             blinkstop()
             blink(0, 50, 0, 1000, 3, function() node.restart() end)
          end)
	wifi.sta.eventMonStart()
        wifi.sta.config(ssid,pwd)
      else
        local content = [====[<html>
  <form method="POST" name="config_wifi">
    <p>ssid:<input type="text" name="ssid" value="" /></p>
    <p>pwd:<input type="text" name="pwd" value="" /></p>
    <p><input type="submit" value="Config" /></p>
  </form>
</html>]====]
        SendContent(conn,content)
      end
    else
      -- no favicon...
      conn:close()
    end
  end)
  conn:on("sent",function(conn) conn:close() end)
end)

print("Loaded connect...")

