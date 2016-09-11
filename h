#cp squishy.main squishy
#squish --minify-level=basic
#./luatool.py -f http.lua -t http.lua
./upload.lua http.lua http.lua $1
./upload.lua index.html index.html $1
./upload.lua nodata.html nodata.html $1
