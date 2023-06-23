local moon = require("moon")
local common = require("common")
local CmdCode = common.CmdCode
local GameCfg = common.GameCfg
local Database = common.Database
local errcode = common.ErrorCode

---@type user_context
local context = ...
local scripts = context.scripts
local UserModel = scripts.UserModel

local ItemTraits = {}

---@class Bag
local Bag = {}

function Bag.Init()

end

function Bag.Start()

end

---检查物品数量是否足够
---@param id integer @道具id
---@param count integer @数量
---@return integer @错误码
function Bag.CheckItemEnough(id, count)
    if count <= 0 then
        return errcode.ParamInvalid
    end
    local item = UserModel.Get().bag.itemMap[id]
    if not item or item.count < count then
        return errcode.ItemNotEnough
    end
    return 0
end

---新增道具
---@param id integer @道具id
---@param count integer @数量
---@param source any
---@param send_list table
---@return integer @错误码
function Bag.AddItem(id, count, source, send_list)
    local item = UserModel.Get().bag.itemMap[id]
    if not item then
        ---@type ItemData
        item = { count = 0, uid = id }
        UserModel.MutGet().bag.itemMap[id] = item
    end
    item.id = id
    item.count = item.count + count

    Bag.SyncPlayer(item, send_list)

    return errcode.None
end

---@private
--同步数据给玩家
---@param item ItemData
---@param immediately boolean
function Bag.SyncPlayer(item, immediately)
    if not immediately then
        context.S2C(CmdCode.Bag, { data = UserModel.Get().bag })
    end
end

function Bag.Cost(id, count, source, send_list)
    if count <= 0 then
        return errcode.ParamInvalid
    end
    local item = UserModel.Get().bag.itemMap[id]
    if not item or item.count < count then
        return errcode.ItemNotEnough
    end
    item.count = item.count - count

    Bag.SyncPlayer(item, send_list)
end

function Bag.Costlist(list, source)
    for _, v in ipairs(list) do
        local item = UserModel.Get().bag.itemMap[v[1]]
        if not item or item.count < v[2] then
            return errcode.ItemNotEnough
        end
    end

    local send_list = {}
    for _, v in ipairs(list) do
        Bag.Cost(v[1], v[2], source, send_list)
    end

    Bag.SyncPlayer(_, true)
end

function Bag.AddItemList(list, source)
    local send_list = {}
    for _, v in ipairs(list) do
        Bag.AddItem(v.id, v.count, source, send_list)
    end
    if #send_list > 0 then
        Bag.SyncPlayer(_, true)
    end
end


---客户端请求背包数据处理函数
function Bag.C2SBag()
    Bag.SyncPlayer(_, true)
end

return Bag
