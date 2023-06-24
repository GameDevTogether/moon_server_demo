local clientsimulator = require("clientsmulator")
local moon = require("moon")
local cmdcode = require("common.CmdCode")
local msghelper = require("msghelper")
local protocol = require("common.protocol_pb")

clientsimulator.start(function(fd)
    msghelper.send(fd, protocol.encodestring(cmdcode.C2SLogin, {
        openid = msghelper.randopenid()
    }))
    --读取服务器返回登录信息
    local ok, data = msghelper.read(fd)
    print(ok, data.time)

    --读取用户数据
    local ok, data = msghelper.read(fd)
    print("-----------userdata-----------")
    print_r(data)

    moon.sleep(1000)

    --请求背包数据
    msghelper.send(fd, protocol.encodestring(cmdcode.C2SBag))

    local ok, data = msghelper.read(fd)
    print("-----------bag data-----------")
    print_r(data)


    --购买金币包
    msghelper.send(fd, protocol.encodestring(cmdcode.C2SPurchasePack, { packId = 1 }))

    local ok, data = msghelper.read(fd)
    print("-----------shop purchase gold -----------")
    print_r(data)
    --购买宝石包

    msghelper.send(fd, protocol.encodestring(cmdcode.C2SPurchasePack, { packId = 11 }))

    local ok, data = msghelper.read(fd)
    print("-----------shop purchase gem-----------")
    print_r(data)


    moon.sleep(1000)
    --抽奖1号宝箱1次
    msghelper.send(fd, protocol.encodestring(cmdcode.C2SGacha, { chestId = 1, count = 1 }))

    local ok, data = msghelper.read(fd)
    print("-----------shop gacha 1 1-----------")
    print_r(data)

    local ok, data = msghelper.read(fd)
    print("-----------bag data-----------")
    print_r(data)

    --抽奖1号宝箱10次
    msghelper.send(fd, protocol.encodestring(cmdcode.C2SGacha, { chestId = 1, count = 10 }))

    local ok, data = msghelper.read(fd)
    print("-----------shop gacha 1 10-----------")
    print_r(data)

    local ok, data = msghelper.read(fd)
    print("-----------bag data-----------")
    print_r(data)

    --抽奖2号宝箱1次
    msghelper.send(fd, protocol.encodestring(cmdcode.C2SGacha, { chestId = 2, count = 1 }))

    local ok, data = msghelper.read(fd)
    print("-----------shop gacha 2 1-----------")
    print_r(data)

    local ok, data = msghelper.read(fd)
    print("-----------bag data-----------")
    print_r(data)

    --抽奖2号宝箱10次
    msghelper.send(fd, protocol.encodestring(cmdcode.C2SGacha, { chestId = 2, count = 10 }))

    local ok, data = msghelper.read(fd)
    print("-----------shop gacha 2 10-----------")
    print_r(data)

    local ok, data = msghelper.read(fd)
    print("-----------bag data-----------")
    print_r(data)


    msghelper.close(fd)

    moon.quit()
end)
