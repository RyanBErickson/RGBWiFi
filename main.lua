local ip = wifi.sta.getip() or "none"

-- This code runs the HTTP server on the Client...
print("HTTP Server: " .. ip .. "...")
srv=net.createServer(net.TCP) 
srv:listen(80,function(conn)
  conn:on("receive",function(conn,data)
    local isOpen = false
    local fileName = ''

    conn:on("sent", function(conn)
      if (fileName ~= '') then
        if not isOpen then
          --print('open ' .. fileName)
          isOpen = true
          file.open(fileName, 'r')
        end
        local html = file.read(256)
        if html then
          --print('send ' .. #html)
          conn:send(html)
          html = nil
        else
          --print('close')
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
      print("index.html")
      conn:send("H")
    else
      local _, _, msg = data:find("GET /(.-) HTTP")
      if (msg:find("scene") == 1) then 
        local scene = msg:sub(6, 6)
        scene = tonumber(scene) or 0
        if (scene ~= 0) then
          do_scene(scene)
        end
        fileName = 'nodata.html'
        conn:send("H")
      else
        if (msg == "up") then 
          gIntensity = (gIntensity or 10) + 1
          if (gIntensity > 10) then gIntensity = 10 end
          rgbw(R,G,B,W)
        elseif (msg == "down") then 
          gIntensity = (gIntensity or 0) - 1
          if (gIntensity < 1) then gIntensity = 1 end
          rgbw(R,G,B,W)
        else
          tmr.stop(1) -- Stop Scene...
          if (msg:find("level")) then 
            local level = msg:sub(6) -- level 00-100
            level = tonumber(level) or 0
            rgbw(level*10, level*10, level*10, level*10)
          elseif (msg == "on") then 
            on() 
          elseif (msg == "off") then 
            off() 
          elseif (msg:sub(1, 1) == "~") then
            local _, _, r, g, b = msg:find("~(..)(..)(..)")
            r = tonumber(r, 16) or 0
            g = tonumber(g, 16) or 0
            b = tonumber(b, 16) or 0
            rgbw(r*4, g*4, b*4)
            --print("RGB: ",r, g, b)
          end
        end
        fileName = 'nodata.html'
        conn:send("H")
      end
    end
  end)
end)

-- Delay loading of freq.lua to allow heap memory to recover...
tmr.alarm(0, 1000, 0, function() dofile('freq.lua') end)
