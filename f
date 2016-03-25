#cp squishy.freq squishy
#squish --minify-level=basic
#./luatool.py -f freq.lua.squished -t freq.lua
#./luatool.py -f freq.lua -t freq.lua
#./luatool.py -f freq2.lua -t freq2.lua
./upload.lua freq.lua freq.lua $1
./upload.lua freq2.lua freq2.lua $1
