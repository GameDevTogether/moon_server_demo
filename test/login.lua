local seri = require("seri")
local moon = require("moon")
local socket = require("moon.socket")
local cmdcode = require("common.cmdcode")

---加载协议
local pb = require "pb"

local function load_protocol(file)
    local fobj, err = io.open(file, "rb")
    assert(fobj, err)
    local content = fobj:read("*a")
    fobj:close()
    assert(pb.load(content))
end

---load proto file first, then multhread share read only pb state
load_protocol("../proto/proto.pb")
pb.share_state()

local concats = seri.concats

local pencode = pb.encode
local pdecode = pb.decode

local type = type

-- used for find message name by id
local id_name = {}
-- used for id bytes cache
local id_bytes = {}

for k,v in pairs(cmdcode) do
    local c = string.pack(">H",v)

    assert(not id_name[c],"")
    id_name[c] = k

    assert(not id_bytes[v],"")
    id_bytes[v] = c
end

local function _encode(id,t)
    if type(id)=='string' then
        id = cmdcode[id]
    end
    local data = id_bytes[id]
    if t then
        local name =  id_name[data]
        return concats(data, pencode(name, t))
    else
        return data
    end
end

local function _decode(data)
    local name =  id_name[data:sub(1,2)]
    return name, pdecode(name, data:sub(3))
end

local LEN_SIZE = 2
local MSGID_SIZE = 2

local function session_read(fd)
    if not fd then
        return false
    end
    local data,err = socket.read(fd, LEN_SIZE)
    if not data then
        print(fd,"fd read LEN error",err)
        return false
    end
    local len = string.unpack(">H",data)
    --data: MSGID+INDEX+message data
    data,err = socket.read(fd,len)
    if not data then
        print(fd,"fd read Data error",err)
        return false
    end

    return _decode(data)
end

local function session_send(fd, msgid, t)
    local data = _encode(msgid, t)
    data = string.pack(">H", #data)..data
    socket.write(fd,data)
end

local function print_msg(cmd, data)
    print("RECV", cmd)
    print_r(data)
    return cmd, data
end

local expect_cmd = {}
local yield_co = {}

local function expect(fd, cmd, fn)
    assert(fd)
    assert(cmd)
    expect_cmd[fd] = {cmd = cmd,fn = fn}
    yield_co[fd] = coroutine.running()
    return coroutine.yield()
end

local function auto_read_msg(fd)
    moon.async(function ()
        while true do
            local cmd,data = session_read(fd)
            if not cmd then
                print("socket error", data)
                return
            end
            local isfind = false
            local res
            if expect_cmd[fd] and cmd == expect_cmd[fd].cmd  then
                local fn = expect_cmd[fd].fn
                isfind = true
                if fn then
                    isfind, res = fn(data)
                    if res then
                        data = res
                    end
                end
            end

            if isfind then
                expect_cmd[fd] = nil
                local ok, err = coroutine.resume(yield_co[fd], data)
                if not ok then
                    error(err)
                end
            else
                print_msg(cmd,data)
            end
        end
    end)
end

moon.shutdown(function()
    moon.quit()
end)

local Behavior ={}

local conf = {}
-- conf.host = "62.234.143.208"
-- conf.port = 7777
conf.host = "127.0.0.1"
conf.port = 12345

moon.async(function()
    local count = 1
    for i=1,count do
        moon.sleep(30)
        moon.async(function()
            local fd,err = socket.connect(conf.host, conf.port, moon.PTYPE_SOCKET_TCP)
            if not fd then
                print("connect server failed", err)
                return
            end
            print("connect server success:")

            auto_read_msg(fd)

            Behavior.Auth(fd)

            -- Behavior.Cost(fd)

            -- Behavior.Fight(fd)
            -- Behavior.Fight(fd)
            -- Behavior.Fight(fd)
            -- Behavior.Fight(fd)
            -- Behavior.Fight(fd)
            --Behavior.Equip(fd)

            -- Behavior.Guaji(fd)
            -- Behavior.Draw(fd)
            -- Behavior.DrawTen(fd)
            -- Behavior.QueryShopItems(fd)
            -- Behavior.BuyItem(fd)
            Behavior.QueryAdId(fd)
        end)
    end
end)

function Behavior.Auth(fd)
    session_send(fd, cmdcode.C2SLogin,{openid = "wang1"})
    ---@type S2CLogin
    local S2CLogin =  expect(fd, "S2CLogin")
    print_r(S2CLogin)

    session_send(fd, cmdcode.C2SUserData)
    ---@type S2CUserData
    local S2CUserData =  expect(fd, "S2CUserData")
    print_r(S2CUserData)

    session_send(fd, cmdcode.C2SItemList)
    ---@type S2CUserData
    local S2CUserData =  expect(fd, "S2CItemList")
    print_r(S2CUserData)

end

function Behavior.Cost(fd)
    session_send(fd, cmdcode.C2SUseItem, {id=40001,count=1000})
end

function Behavior.Fight(fd)
    session_send(fd, cmdcode.C2SFightStart)
    ---@type S2CFightStart
    local S2CFightStart =  expect(fd, "S2CFightStart")
    print_r(S2CFightStart)
    session_send(fd, cmdcode.C2SFightEnd)
    ---@type S2CFightEnd
    local S2CFightEnd =  expect(fd, "S2CFightEnd")
    print_r(S2CFightEnd)
end

function Behavior.Equip(fd)
    session_send(fd, cmdcode.C2SEquipList)
    ---@type S2CEquipList
    local S2CEquipList =  expect(fd, "S2CEquipList")
    print_r(S2CEquipList)

    for k,v in pairs(S2CEquipList.list) do
        session_send(fd, cmdcode.C2SEquip,{uniqueid = v.uniqueid})
        ---@type S2CEquipSlots
        local S2CEquipSlots =  expect(fd, "S2CUpdateEquipSlot")
        print_r(S2CEquipSlots)
        session_send(fd, cmdcode.C2SEquipReinforce,{slot = 1})
        session_send(fd, cmdcode.C2SEquipLock,{uniqueid = v.uniqueid, locked=true})
    end
end

function Behavior.Treasure(fd)
    session_send(fd, cmdcode.C2STreasureList)
    ---@type S2CTreasureList
    local S2CTreasureList =  expect(fd, "S2CTreasureList")
    print_r(S2CTreasureList)
end

function Behavior.Guaji(fd)
    moon.sleep(5*1000)
    session_send(fd, cmdcode.C2SGuajiReward)
    ---@type S2CGuajiReward
    local S2CGuajiReward =  expect(fd, "S2CGuajiReward")
    print_r(S2CGuajiReward)
end

function Behavior.Draw(fd)
    moon.sleep(5*1000)
    session_send(fd, cmdcode.C2SDrawOnce)

    local data =  expect(fd, "S2CDrawOnce")
    print_r(data)
end

function Behavior.DrawTen(fd)
    moon.sleep(5*1000)
    session_send(fd, cmdcode.C2SDrawTen)

    local data =  expect(fd, "S2CDrawTen")
    print_r(data)
end

function Behavior.QueryShopItems(fd)
    moon.sleep(5*1000)
    session_send(fd, cmdcode.C2SQueryShopItems)

    local S2CGuajiReward =  expect(fd, "S2CQueryShopItems")
    print_r(S2CGuajiReward)
end

function Behavior.BuyItem(fd)
    moon.sleep(5*1000)
    session_send(fd, cmdcode.C2SBuyItem,{id = 1})

    local data =  expect(fd, "S2CBuyItem")
    print_r(data)
end


function Behavior.QueryAdId(fd)
    moon.sleep(5*1000)
    session_send(fd, cmdcode.C2SQueryAdId)

    local data =  expect(fd, "S2CQueryAdId")
    print_r(data)
end