#cp squishy.freq squishy
#squish --minify-level=basic
#./luatool.py -f freq.lua.squished -t freq.lua
#./luatool.py -f freq.lua -t freq.lua
./upload.lua freq.lua freq.lua $1
