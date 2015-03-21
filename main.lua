local ip = wifi.sta.getip() or "none"
local mac = wifi.sta.getmac() or "00:00:00:00:00:00"

-- This code runs the HTTP server on the Client...
--print("Starting RGBW HTTP Server on " .. ip .. " (" .. mac .. ")...")
print("Starting RGBW HTTP Server on " .. ip .. "...")
srv=net.createServer(net.TCP) 
srv:listen(80,function(conn)
  conn:on("receive",function(conn,data)
    local isOpen = false
    local fileName = ''

    conn:on("sent", function(conn)
      if (fileName ~= '') then
        if not isOpen then
          print('open ' .. fileName)
          isOpen = true
          file.open(fileName, 'r')
        end
        local html = file.read(1024) -- 1024 max
        if html then
          print('send ' .. #html)
          conn:send(html)
        else
          print('close')
          file.close()
          conn:close()
          conn = nil
        end
      else
        conn:close()
        conn = nil
      end
    end)

    --print(data)
    if (string.sub(data, 1, 6) == 'GET / ') then
      fileName = 'index.html'
      conn:send("HTTP/1.1 200 OK\r\n")
      conn:send("Content-type: text/html\r\n")
      conn:send("Connection: close\r\n\r\n")
    else
      --print(data)
      local _, _, msg = data:find("GET /(.-) HTTP")
      if (msg == "on") then 
        on() 
      elseif (msg == "off") then 
        off() 
      elseif (msg:find("scene")) then 
        local scene = msg:sub(6, 6)
        scene = tonumber(scene) or 0
        if (scene ~= 0) then
          print("Scene: " .. scene)
        end
      elseif (msg:sub(1, 1) == "~") then
        local _, _, r, g, b = msg:find("~(..)(..)(..)")
        r = tonumber(r, 16) or 0
        g = tonumber(g, 16) or 0
        b = tonumber(b, 16) or 0
        print("RGB: ",r, g, b)
        rgbw(r*4, g*4, b*4)
      end
      conn:send("HTTP/1.1 200 OK\r\nContent-Length: 0\r\nContent-type: text/html\r\nConnection: close\r\n\r\n")
      --conn:close()
      --conn = nil
    end
  end)
end)

