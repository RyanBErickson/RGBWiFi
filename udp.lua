-- UDP Client...

-- Note: can use socat to do a 'telnet-like' connection to UDP server...
-- socat - UDP-DATAGRAM:ipaddr:8123
UDPPORT = 8123
TCPPORT = 8124

function StartUDP()

  -- UDP Server...
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
    end)

end

--[[
function StartTCP()
  -- TCP Server...
  tsrv=net.createServer(net.TCP, 600)

  -- if data received, print data to console,
  tsrv:listen(TCPPORT,function(c)

    -- Hook output from print() to tcp server...
    function s_output(str) if (c ~= nil) then c:send(str) end end

    node.output(s_output, 0)

    c:on("receive", function(c, msg) 
      node.input(msg)
    end)

    c:on("disconnection", function(c) node.output(nil) end)
  end)
end

-- Verify our IP Address before starting UDP+TCP...
tmr.alarm(0, 500, 1, function()
  ip, nm, gw=wifi.sta.getip()
  if ip ~= nil then
    tmr.stop(0)
    StartUDP()
    StartUDP = nil -- clear it out when not necessary anymore...
    StartTCP()
    StartTCP = nil -- clear it out when not necessary anymore...
    print("Started UDP / TCP [" .. ip .. ":" .. UDPPORT .. "/" .. TCPPORT .. "]...")
  end
end)
]]
print("Loaded UDP...")



