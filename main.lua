local ip = wifi.sta.getip() or "none"
-- This code runs the HTTP server on the Client...
print("Starting RGBW HTTP Server on " .. ip .. "...")
srv=net.createServer(net.TCP) 
srv:listen(80,function(conn)
  conn:on("receive",function(conn,data)
    local isOpen = false

    conn:on("sent", function(conn)
      if not isOpen then
        print('open ' .. fileName)
        isOpen = true
        file.open(fileName, 'r')
      end
      local data = file.read(1024) -- 1024 max
      if data then
        print('send ' .. #data)
        conn:send(data)
      else
        print('close')
        file.close()
        conn:close()
        conn = nil
      end
    end)

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
      conn:close()
      conn = nil
    end
  end)
end)

