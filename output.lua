#!/usr/bin/env lua

-- Show 'output' from node (printed values)...
-- To work, we'd have to redirect the output of print, as well as UDP broadcast or send to one host...
-- This would have to be a listener on that port, not a UDP client...

ESP_PORT = 18123

socket = require("socket")

udp = socket.udp()
udp:settimeout(10)
udp:setsockname("*", ESP_PORT)

while true do
  local data = udp:receive()
  if (data ~= nil) then
    print(data)
  end
end

