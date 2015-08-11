local ip = wifi.sta.getip() or "-"

-- This code runs the HTTP server on the Client...
print("IP: " .. ip .. "...")

local delay = 500
--local norepeat = 0

--tmr.alarm(0, delay, 0, function() require('http') end)
--delay = delay + 500

-- Delay loading of udp.lua and tcp.lua to allow heap memory to recover...
tmr.alarm(1, delay, 0, function() require('udp') require('tcp') end)
delay = delay + 500

-- Delay loading of freq.lua to allow heap memory to recover...
tmr.alarm(2, delay, 0, function() require('freq') end)
delay = delay + 500

