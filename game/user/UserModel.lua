local moon = require("moon")
local common = require("common")
local Database = common.Database
local CurrencyType = common.Constant.CurrencyType

----DB Model 标准定义格式

---@type user_context
local context = ...

---定时存储标记
local dirty = false

---@type UserData
local DBData

---@class UserModel
local UserModel = {}



function UserModel.Create(data)

    if DBData then
        return DBData
    end

    DBData = data

    ---定义自动存储
    moon.async(function()
        while true do
            moon.sleep(5000)
            if dirty then
                local ok, err = xpcall(UserModel.Save, debug.traceback, true)
                if not ok then
                    moon.error(err)
                end
            end
        end
    end)

    return data
end

---需要立刻保存重要数据时,使用这个函数,参数使用默认值即可
---@param checkDirty? boolean
function UserModel.Save(checkDirty)
    if checkDirty and not dirty then
        return
    end
    Database.saveuser(context.addr_db_user, DBData.uid, DBData)
    dirty = false
end

---只读,使用这个函数
---@return UserData
function UserModel.Get()
    return DBData
end

---需要修改数据时,使用这个函数
---@return UserData
function UserModel.MutGet()
    dirty = true
    return DBData
end

---检查游戏货币是否足够
---@param currencyType CurrencyType
---@param value integer
---@return boolean @货币是否足够
function UserModel.CheckCurrencyEnyouch(currencyType,value)
    assert(currencyType ~= CurrencyType.Money,"param currencyType must be gold/gem")

    local data = UserModel.Get()

    local userCurrencyValue = data.gold
    if currencyType == CurrencyType.Gem then
        userCurrencyValue = data.gem
    end

    return userCurrencyValue>= value
end

---检查游戏货币是否足够
---@param currencyType CurrencyType
---@param value integer
---@param integer @错误码
function UserModel.AddCurrency(currencyType,value)
    if UserModel.CheckCurrencyEnyouch(currencyType,value) then

    end


    assert(currencyType ~= CurrencyType.Money,"param currencyType must be gold/gem")

    local data = UserModel.MutGet()

    if currencyType == CurrencyType.Gem then
        data.gem = data.gem+ value

        
    else if currencyType == CurrencyType.Gold then

    end

    return userCurrencyValue>= value
end

return UserModel