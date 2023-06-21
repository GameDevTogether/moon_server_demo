local path = table.concat({
    "./?.lua",
    ".././?.lua",
    ".././?/init.lua",
    "../moon/lualib/?.lua",
    "../moon/service/?.lua",
    -- Append your lua module search path
}, ";")

package.path = path .. ";"

local moon = require("moon")
local socket = require("moon.socket")


local conf = {
    host = "127.0.0.1",
    port = 12345
}


local clientsimulator = {}

local pb = require "pb"

local function load_protocol(file)
    local fobj, err = io.open(file, "rb")
    assert(fobj, err)
    local content = fobj:read("*a")
    fobj:close()
    assert(pb.load(content))
end

---load proto file first, then multhread share read only pb state
load_protocol("../protocol/proto.pb")


---启动客户端模拟
---@param client_handler fun(fd: string):void 模拟函数
function clientsimulator.start(client_handler)
    moon.async(function()
        moon.sleep(10)

        local fd, err = socket.connect(conf.host, conf.port, moon.PTYPE_SOCKET_TCP)
        if not fd then
            print("connect game server failed", err)
            return
        end

        moon.async(function()
            print(xpcall(client_handler, debug.traceback, fd))
            moon.sleep(2000)
            print("----------simulate success-----------")
        end)
    end)
end

return clientsimulator
