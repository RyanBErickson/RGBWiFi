cp squishy.freq squishy
squish --minify-level=basic
#./luatool.py -f freq.lua -t freq.lua
./luatool.py -f freq.lua.squished -t freq.lua
