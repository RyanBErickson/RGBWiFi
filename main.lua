local ip = wifi.sta.getip() or "-"

-- This code runs the HTTP server on the Client...
print("IP: " .. ip .. "...")

-- TODO: If there is no ip address (i.e. no client found) for X times booting (persist the data), automatically reset to AP mode.
-- TODO: Have a Light indicator for if it's in AP mode... (low blinking red, for example)

local delay = 500
--local norepeat = 0

--tmr.alarm(0, delay, 0, function() require('http') end)
--delay = delay + 500

-- Delay loading of udp.lua and tcp.lua to allow heap memory to recover...
tmr.alarm(1, delay, 0, function() require('udp') require('tcp') end)
--tmr.alarm(1, delay, 0, function() require('udp') end)
delay = delay + 500

-- Delay loading of freq.lua to allow heap memory to recover...
tmr.alarm(2, delay + 1000, 0, function() require('freq') end)
delay = delay + 500

