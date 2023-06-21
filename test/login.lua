local clientsimulator = require("clientsmulator")
local moon = require("moon")
local cmdcode = require("common.CmdCode")
local msghelper = require("msghelper")
local protocol = require("common.protocol_pb")

clientsimulator.start(function(fd)
    msghelper.send(fd, protocol.encodestring(cmdcode.C2SLogin, {
        openid = msghelper.randopenid()
    }))
    local ok, data = msghelper.read(fd)
    print(ok, data.time)

    local ok, data = msghelper.read(fd)
    print_r(data)

    msghelper.close(fd)
end)
