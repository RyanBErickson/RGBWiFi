TCPPORT = 8124

-- TCP Server...
tsrv=net.createServer(net.TCP, 600)

-- if data received, print data to console,
tsrv:listen(TCPPORT,function(c)
  c:on("receive", function(c, msg) 
    local f = loadstring(msg)
    local ret, err = pcall(f)
    if (ret) then
      c:send("OK\n")
    else
      print("Error: " .. err) c:send("Err: " .. err .. "\n")
    end
    
  end)
  -- How do I send out-of-band to open TCP socket???
  --c:send("hello world")
end)

print("Loaded TCP[" .. TCPPORT .. "]...")

