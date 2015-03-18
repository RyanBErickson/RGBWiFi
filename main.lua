-- Print immediately IP if present, otherwise wait for it, print when done.
if (wifi.sta.getip() == nil) then
  tmr.alarm(0, 1000, 1, function()
     if wifi.sta.getip() == nil then
        print("Connecting to AP...")
     else
        print('IP: ',wifi.sta.getip())
        tmr.stop(0)
     end
  end)
else
  print('IP: ',wifi.sta.getip())
  main()
end

-- Declare functions
function main()
  -- Startup webserver / UDP server???
  -- Declare LCD 'fancy color scroll, etc.'
end


