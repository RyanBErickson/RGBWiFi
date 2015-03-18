-- Declare functions
function main()
  print("Main function...")
  -- Startup webserver / UDP server???
  -- Declare LCD 'fancy color scroll, etc.'
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
  print('Starting main in 5 seconds...')
  tmr.alarm(0, 5000, 1, function() tmr.stop(0) main() end)
end
end)

if (not ret) then print("Error: " .. err) end

