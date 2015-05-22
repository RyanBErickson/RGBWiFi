#cp squishy.init squishy
#squish --minify-level=basic
#./luatool.py -f init.lua -t init.lua
#./luatool.py -f init.lua.squished -t init.lua
./upload.lua init.lua init.lua $1
