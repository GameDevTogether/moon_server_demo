local moon = require("moon")
local common = require("common")
local CmdCode = common.CmdCode
local ErrorCode = common.Enums.ErrorCode

---@type user_context
local context = ...
local scripts = context.scripts


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
        return ErrorCode.ParamInvalid
    end
    local UserModel = scripts.UserModel
    local item = scripts.UserModel.Get().bag.itemMap[id]
    if not item or item.count < count then
        return ErrorCode.ItemNotEnough
    end
    return 0
end

---新增道具
---@param id integer @道具id
---@param count integer @数量
---@param send_list table
---@return integer @错误码
function Bag.AddItem(id, count, immediately)
    local item = scripts.UserModel.Get().bag.itemMap[id]
    if not item then
        ---@type ItemData
        item = { count = 0, uid = id }
        scripts.UserModel.MutGet().bag.itemMap[id] = item
    end
    item.id = id
    item.count = item.count + count

    Bag.SyncPlayer(item, immediately)
end

---@private
--同步数据给玩家
---@param item ItemData
---@param immediately boolean
function Bag.SyncPlayer(item, immediately)
    if immediately then
        context.S2C(CmdCode.S2CBag, { data = scripts.UserModel.Get().bag })
    end
end

function Bag.Cost(id, count, source, send_list)
    if count <= 0 then
        return ErrorCode.ParamInvalid
    end
    local item = scripts.UserModel.Get().bag.itemMap[id]
    if not item or item.count < count then
        return ErrorCode.ItemNotEnough
    end
    item.count = item.count - count

    Bag.SyncPlayer(item, send_list)
end

function Bag.Costlist(list, source)
    local userData = scripts.UserModel.Get()
    for _, v in ipairs(list) do
        local item = userData.bag.itemMap[v[1]]
        if not item or item.count < v[2] then
            return ErrorCode.ItemNotEnough
        end
    end

    local send_list = {}
    for _, v in ipairs(list) do
        Bag.Cost(v[1], v[2], source, send_list)
    end

    Bag.SyncPlayer(_, true)
end

function Bag.AddItemList(list)
    local send_list = {}
    for _, v in ipairs(list) do
        Bag.AddItem(v.id, v.count, false)
    end

    Bag.SyncPlayer(_, true)
end

---增加武器到背包
---@param list WeaponData[]
function Bag.AddWeaponList(list)
    local weaponMap = scripts.UserModel.MutGet().bag.weaponMap
    for _, value in pairs(list) do
        weaponMap[value.uid] = value
    end

    context.S2C(CmdCode.C2SBag, { data = userData.bag })
end

---获得武器
---@param uid integer @道具id
---@return WeaponData
function Bag.GetWeapon(uid)
    return scripts.UserModel.Get().bag.weaponMap[uid]
end

---获得道具
---@param uid integer @道具id
---@return ItemData
function Bag.GetItem(uid)
    return scripts.UserModel.Get().bag.itemMap[uid]
end

---武器是否已装备
---@param uid integer @道具id
---@return boolean
function Bag.Equiped(uid)
    return table.contains(scripts.UserModel.Get().bag.equipedIdList, uid)
end

---装备武器
---@param uid integer @道具id
---@return integer @错误吗|nil
function Bag.EquipWeapon(uid)
    ---检查背包有没有这个装备
    local weapon = Bag.GetWeapon(uid)

    if weapon == nil then
        return ErrorCode.WithoutWeapon
    end


    --检查是否装备过了
    if Bag.Equiped(uid) then
        return ErrorCode.AlreadyEquipped
    end

    local UserModel = scripts.UserModel
    local userData = UserModel.Get()
    local num = table.count(userData.bag.equipedIdList)
    --检查装备数量是否到达上限
    
    if num >= userData.bag.maxCanEquipCount then
        return ErrorCode.MaxEquipWeaponCount
    end

    table.insert(UserModel.MutGet().bag.equipedIdList, uid)
end

---卸载武器
---@param uid integer @道具id
---@return integer|nil
function Bag.UnEquipWeapon(uid)
    ---检查背包有没有这个装备
    local weapon = Bag.GetWeapon(uid)

    if weapon == nil then
        return ErrorCode.WithoutWeapon
    end


    --检查是否装备过了
    if not Bag.Equiped(uid) then
        return ErrorCode.AlreadyUnEquipped
    end

    ---检查已装备数量
    local num = table.count(scripts.UserModel.Get().bag.equipedIdList)
    if num <= 1 then
        return ErrorCode.NeedOneWeapnEquipped
    end

    local list = scripts.UserModel.MutGet().bag.equipedIdList
    table.remove(list, table.indexof(list, uid))
end

function Bag.SetWeaponLevel(uid, level)
    local weapon = scripts.UserModel.MutGet().bag.weaponMap[uid]
    weapon.level = level
end

---客户端请求背包数据处理函数
function Bag.C2SBag()
    Bag.SyncPlayer(_, true)
end

return Bag
