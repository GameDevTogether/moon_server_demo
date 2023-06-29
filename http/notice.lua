
local json = require("json")

local http_server = require("moon.http.server")

http_server.error = function(fd, err)
    print("http server fd",fd," disconnected:",  err)
end

http_server.on("/notice",function(request, response)
    print_r(request:parse_query())
    response:write_header("Content-Type","text/plain")
    response:write("GET:Hello World")
end)

http_server.listen("127.0.0.1", 9991)
print("http_server start", "127.0.0.1", 9991)




