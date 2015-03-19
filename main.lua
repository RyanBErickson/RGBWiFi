function parse(tag, str)
  local _, _, c = str:find(tag .. "=(.-)&")
  c = tonumber(c) or 0 
  if (c < 0) then c = 0 end
  if (c > 1023) then c = 1023 end
  return c
end


function main()
  -- This code runs the HTTP server on the Client...
  print("Starting RGBW HTTP Server...")
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
      elseif string.find(data,"favicon.ico") == nil then
        print(data)
        data = data .. "&" -- easier to parse...
        if (data:find("form=RGBW")) then 
          local r, g, b, w = parse("r", data), parse("g", data), parse("b", data), parse("w", data)
          rgbw(r,g,b,w)
        end
        if (data:find("form=SCENE")) then 
          local scene = parse("scene", data)
          print("Scene " .. scene)
        end
        -- Send HTTP Header...
        --conn:send("" .. html)
      end
    end)
  end)
end

-- Print immediately IP if present, otherwise wait for it, print when done.
local ret, err = pcall(function() 
trycount = 20
if (wifi.sta.getip() == nil) then
  print("Waiting on AP [" .. (CONFIG.SSID or 'none') .. "]...")
  tmr.alarm(0, 250, 1, function()
     trycount = trycount - 1
     if (trycount < 1) then tmr.stop(0) print("AP Not Found.") end
     if wifi.sta.getip() ~= nil then
        print('IP: ',wifi.sta.getip())
        tmr.stop(0)
     end
  end)
else
  print('IP: ',wifi.sta.getip())
  print('Starting HTTP server in 2 seconds...')
  tmr.alarm(0, 2000, 1, function() tmr.stop(0) main() end)
end
end)

if (not ret) then print("Error: " .. err) end

