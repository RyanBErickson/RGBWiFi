#cp squishy.main squishy
#squish --minify-level=basic
#./luatool.py -f main.lua.squished -t main.lua
#./luatool.py -f main.lua -t main.lua
./upload.lua main.lua main.lua
