TCPPORT = 8124

-- TCP Server...
tsrv=net.createServer(net.TCP, 600)


-- if data received, print data to console,
tsrv:listen(TCPPORT,function(c)
  -- Hook output from print() to tcp server...
  function s_output(str) if (c ~= nil) then c:send(str) end end
  node.output(s_output, 0)

  c:on("receive", function(c, msg) 
    --local f = loadstring(msg)
    --local ret, err = pcall(f)
    --if (ret) then
      --c:send("OK\n")
    --else
      --print("Error: " .. tostring(err)) c:send("Err: " .. tostring(err) .. "\n")
    --end
    node.input(msg)
    
  end)
  c:on("disconnection", function(c) node.output(nil) end)
end)

print("Loaded TCP[" .. TCPPORT .. "]...")

