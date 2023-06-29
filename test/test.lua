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

    ---先注释，停下来了
    -- --购买金币包
    -- msghelper.send(fd, protocol.encodestring(cmdcode.C2SPurchasePack, { packId = 1 }))

    -- local ok, data = msghelper.read(fd)
    -- print("-----------shop purchase gold -----------")
    -- print_r(data)
    -- --购买宝石包

    -- msghelper.send(fd, protocol.encodestring(cmdcode.C2SPurchasePack, { packId = 11 }))

    -- local ok, data = msghelper.read(fd)
    -- print("-----------shop purchase gem-----------")
    -- print_r(data)


    -- moon.sleep(1000)
    -- --抽奖1号宝箱1次
    -- msghelper.send(fd, protocol.encodestring(cmdcode.C2SGacha, { chestId = 1, count = 1 }))

    -- local ok, data = msghelper.read(fd)
    -- print("-----------shop gacha 1 1-----------")
    -- print_r(data)

    -- local ok, data = msghelper.read(fd)
    -- print("-----------bag data-----------")
    -- print_r(data)

    -- --抽奖1号宝箱10次
    -- msghelper.send(fd, protocol.encodestring(cmdcode.C2SGacha, { chestId = 1, count = 10 }))

    -- local ok, data = msghelper.read(fd)
    -- print("-----------shop gacha 1 10-----------")
    -- print_r(data)

    -- local ok, data = msghelper.read(fd)
    -- print("-----------bag data-----------")
    -- print_r(data)

    -- --抽奖2号宝箱1次
    -- msghelper.send(fd, protocol.encodestring(cmdcode.C2SGacha, { chestId = 2, count = 1 }))

    -- local ok, data = msghelper.read(fd)
    -- print("-----------shop gacha 2 1-----------")
    -- print_r(data)

    -- local ok, data = msghelper.read(fd)
    -- print("-----------bag data-----------")
    -- print_r(data)

    -- --抽奖2号宝箱10次
    -- msghelper.send(fd, protocol.encodestring(cmdcode.C2SGacha, { chestId = 2, count = 10 }))

    -- local ok, data = msghelper.read(fd)
    -- print("-----------shop gacha 2 10-----------")
    -- print_r(data)

    -- local ok, data = msghelper.read(fd)
    -- print("-----------bag data-----------")
    -- print_r(data)


    print("------------------mail data-----------------------")
    msghelper.send(fd,protocol.encodestring(cmdcode.C2SMailList,{}))
    local ok,listdata = msghelper.read(fd)
    print_r(listdata)
    if #listdata.maillist == 0 then
        msghelper.send(fd, protocol.encodestring(cmdcode.C2SGM, { id = 1, jsonParams = "" }))
        local ok,data = msghelper.read(fd)
        print_r(data)
    
        msghelper.send(fd, protocol.encodestring(cmdcode.C2SGM, { id = 1, jsonParams = "" }))
        local ok,data = msghelper.read(fd)
        print_r(data)
    
        msghelper.send(fd, protocol.encodestring(cmdcode.C2SGM, { id = 1, jsonParams = "" }))
        local ok,data = msghelper.read(fd)
        print_r(data)
    
        msghelper.send(fd, protocol.encodestring(cmdcode.C2SGM, { id = 1, jsonParams = "" }))
        local ok,data = msghelper.read(fd)
        print_r(data)
    
        msghelper.send(fd, protocol.encodestring(cmdcode.C2SGM, { id = 1, jsonParams = "" }))
        local ok,data = msghelper.read(fd)
        print_r(data)
    
        msghelper.send(fd,protocol.encodestring(cmdcode.C2SMailList,{}))
        ok,listdata = msghelper.read(fd)
        print_r(listdata)
    end

    print(fd,"Please input('quit' for exit):")
    local isEnd = true
    while isEnd do
        local input = io.read()
        moon.sleep(100)
        if input then
            if input == "exit" or input == "quit" then
                msghelper.close(fd)
                moon.quit()
                break
            end
            if input == "delete" then
                local id = 0
                local len = 0
                for i,v in pairs(listdata.maillist) do
                    if v.state == 3 then
                        len = i
                        id = v.msgid
                        break
                    end
                end
                if id~= 0 then
                    table.remove(listdata.maillist,len)
                    msghelper.send(fd,protocol.encodestring(cmdcode.C2SMailDelete,{msgid = id}))
                    local ok,data = msghelper.read(fd)
                    print_r(data)
                else
                    print("no delete")
                end
            elseif input == "get" then
                msghelper.send(fd,protocol.encodestring(cmdcode.C2SMailList,{}))
                ok,listdata = msghelper.read(fd)
                print_r(listdata)
            elseif input == "deletes"  then
                msghelper.send(fd,protocol.encodestring(cmdcode.C2SMailDeletes,{}))
                local ok,data = msghelper.read(fd)
                print_r(data)
            elseif input == "reward"  then
                local id = 0
                for _,v in pairs(listdata.maillist) do
                    if v.state == 2 then
                        v.state = 3
                        id = v.msgid
                        break
                    end
                end
                if id~= 0 then
                    msghelper.send(fd,protocol.encodestring(cmdcode.C2SMailRecive,{msgid = id}))
                    local ok,data = msghelper.read(fd)
                    print_r(data)
                else
                    print("no reward")
                end
              
            elseif input == "rewards"  then
                msghelper.send(fd,protocol.encodestring(cmdcode.C2SMailRecives,{}))
                local ok,data = msghelper.read(fd)
                print_r(data)
            elseif input == "read"  then
                local id = 0
                for _,v in pairs(listdata.maillist) do
                    if v then
                        print_r(v)
                        if v.state == 1 then
                            v.state = 2
                            id = v.msgid
                            break
                        end
                    end
                end
                if id~= 0 then
                    msghelper.send(fd,protocol.encodestring(cmdcode.C2SMailState,{msgid = id}))
                    -- local ok,data = msghelper.read(fd)
                    print_r(listdata)
                else
                    print("no can read")
                    -- print_r(listdata)
                end
            end
        end
    end
end)
