UDPPORT = 8123

-- UDP Client...
usrv=net.createServer(net.UDP)
usrv:on("receive", function(s, msg) 
    local f = loadstring(msg)
    local ret, err = pcall(f)
    if (ret) then
      s:send("OK\n")
    else
      print("Error: " .. err) s:send("Err: " .. err .. "\n")
    end
  end)
usrv:listen(UDPPORT, function(c) 
--[[
    -- Redirect output doesn't work on UDP, maybe function is never called on listen init for UDP...
    function s_output(s)
      if (c ~= nil) then
        c:send(s)
      end
    end
    node.output(s_output, 0)
]]
  end)

print("Loaded UDP[" .. UDPPORT .. "]...")
