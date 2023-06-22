local protocol = require("common.protocol_pb")
local socket = require("moon.socket")
local random = require("random")


local msghelper = {}


function msghelper.read(fd)
    assert(fd)
    local data, err = socket.read(fd, 2)
    if not data then
        return false, err
    end
    local len = string.unpack(">H", data)
    data, err = socket.read(fd, len)
    if not data then
        return false, err
    end
    -- local id = string.unpack("<H",string.sub(data,1,2))
    -- if id == MSGID.S2CErrorCode then
    --     moon.error(string.sub(data,3))
    -- end
  
    local name, t, id = protocol.decodestring(data)
    print("receive serve msg"..name.." id = "..id)
    return id, t
end

function msghelper.send(fd, data)
    if not fd then
        return false
    end
    local len = #data
    return socket.write(fd, string.pack(">H", len) .. data)
end

function msghelper.close(fd)
    socket.close(fd)
end

function msghelper.randopenid()

    return "test_"..random.rand_range(1,100000000)
end

return msghelper