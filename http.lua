HTTPPORT = 80

STATUS = {}
STATUS[0] = "Idle" -- STA_IDLE,
STATUS[1] = "Connecting" -- STA_CONNECTING,
STATUS[2] = "Wrong Password" -- STA_WRONGPWD,
STATUS[3] = "AP Not Found" -- STA_APNOTFOUND,
STATUS[4] = "Failed to Connect" -- STA_FAIL,
STATUS[5] = "Connected" -- STA_GOTIP.

-- TCP (HTTP) Client...
srv=net.createServer(net.TCP) 
srv:listen(HTTPPORT,function(conn)
  conn:on("receive",function(conn,data)
    local isOpen = false
    local fileName = ''

    conn:on("sent", function(conn)
      if (fileName ~= '') then
        if not isOpen then
          isOpen = true
          file.open(fileName, 'r')
        end
-- TODO: should I pcall this, since this is the line that fails from time to time?  How can I reproduce this line failing?
        local html = file.read(256)
        if html then
          -- [W] in brackets will be filled in with current SSID / IP Info...
          if (html:find("[W]",1,true)) then
            print("[W] found.")
            local SSID = wifi.sta.getconfig() or ""
            local IP = wifi.sta.getip() or ""
            local statustxt = STATUS[wifi.sta.status()] or "NONE"
            conn:send(html:gsub("%[W%]","<p/>SSID: " .. SSID .. "<p/>IP: " .. IP .. "<p/>Status: " .. statustxt))
          else
            conn:send(html)
          end
          --html = nil
        else
          file.close()
          conn:close()
          conn = nil
        end
      else
        conn:close()
        conn = nil
      end
    end)

    if (string.sub(data, 1, 6) == 'GET / ') then
      fileName = 'index.html'
      conn:send("H")
    else
      local _, _, msg = data:find("GET /(.-) HTTP")
      msg = msg or ""

      -- Parse color params if sent...
      local _,_,green = msg:find("green=(%d+)")
      local _,_,yellow = msg:find("yellow=(%d+)")
      local _,_,red = msg:find("red=(%d+)")

      if (msg == "index.html") then 
        fileName = 'index.html'
        conn:send("H")
      elseif (msg == "on") then 
        on() 
      elseif (msg == "off") then 
        off() 
      elseif (msg == "disconnect") then 
        wifi.sta.config('','')
        return
      elseif (msg:find("config")) then 
        local _,_,ssid,pwd = msg:find("ssid=(%S+)&pwd=(%S+)")
        ssid = ssid or ''
        pwd = pwd or ''
        if (ssid == '') then return end
        wifi.sta.config(ssid,pwd)
      end

      fileName = 'nodata.html'
      conn:send("H")
    end
  end)
end)

print("Loaded HTTP[" .. HTTPPORT .. "]...")
