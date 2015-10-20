UDPPORT = 8123
TCPPORT = 8124
PRINT_HOST = "192.168.29.18" -- desktop
PRINT_PORT = 18123

-- Note: can use socat to do a 'telnet-style' connection to UDP server...
-- socat - UDP-DATAGRAM:192.168.29.186:8123

-- UDP Client...
-- Used to send print, etc...  Still fails sometimes, not sure if client or server.
client = net.createConnection(net.UDP, false)

client:connect(PRINT_PORT, PRINT_HOST)

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

--[[
-- Redirect print output to go to both print (USB/Serial and UDP)
origprint = print
-- TODO: Why does this require client:connect before the client:send???
print = function(s) 
  client:connect(PRINT_PORT, PRINT_HOST) 
  client:send(tostring(s) .. '\n')
  origprint(s)
end

print("Redirected print to UDP output...")
]]
print("Loaded UDP[" .. UDPPORT .. "]...")

