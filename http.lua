HTTPPORT = 80

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
        local html = file.read(256)
        if html then
          conn:send(html)
          html = nil
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
      print(fileName)
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
          level(INTENSITY + 5)
        elseif (msg == "down") then 
          level(INTENSITY - 5)
        elseif (msg:find("level")) then 
          local level = msg:sub(6) -- level 01-99 ??
          level(level)
        else
          tmr.stop(1) -- Stop Scene...
          if (msg == "on") then 
            on() 
          elseif (msg == "off") then 
            off() 
          elseif (msg == "ln") then 
            lightning() 
          elseif (msg:sub(1, 1) == "~") then
            local _, _, r, g, b = msg:find("~(..)(..)(..)")
            r = tonumber(r, 16) or 0
            g = tonumber(g, 16) or 0
            b = tonumber(b, 16) or 0
            rgbw(r*4, g*4, b*4)
          end
        end
        fileName = 'nodata.html'
        conn:send("H")
      end
    end
  end)
end)

print("Loaded HTTP[" .. HTTPPORT .. "]...")
