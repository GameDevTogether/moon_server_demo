local moon = require("moon")
local common = require("common")
local Database = common.Database
local CurrencyType = common.Enums.CurrencyType
local ErrorCode = common.Enums.ErrorCode

----DB Model 标准定义格式

---@type user_context
local context = ...
local scripts = context.scripts


---定时存储标记
local dirty = false

---所有玩家数据 包括其他数据 手动写
---@class UserAllData
---@field public userdata UserData 用户数据
---@field public mails MailData[] @邮件数据

---@type UserAllData
local DBUserData = {}

---@type UserData
local DBData

---@class UserModel
local UserModel = {}



function UserModel.Create(data)
    if DBData then
        return DBData
    end

    DBData = data
    DBUserData.userdata = data

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
    Database.saveuser(context.addr_db_user, DBData.uid, DBUserData)
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

function UserModel.SetDirty()
    dirty = true
end

function UserModel.PushData(key,data)
    dirty = true
    DBUserData[key] = data
    return true
end

function UserModel.GetData(key)
    return DBUserData[key]
end

function UserModel.MutGetData(key)
    dirty = true
    return DBUserData[key]
end

---检查游戏货币是否足够
---@param currencyType integer
---@param value integer
---@return integer|nil @错误吗|nil
function UserModel.CheckCurrencyEnough(currencyType, value)
    assert(currencyType ~= CurrencyType.Money, "param currencyType must be gold/gem")

    local data = UserModel.Get()

    if currencyType == CurrencyType.Gold then
        if data.gold < value then
            return ErrorCode.GoldNotEnough
        end
    elseif currencyType == CurrencyType.Gem then
        if data.gem < value then
            return ErrorCode.GemNotEnough
        end
    end
end

---检查游戏货币是否足够
---@param currencyType integer
---@param value integer
---@return integer|nil @错误码|nil
function UserModel.AddCurrency(currencyType, value)
    if value < 0 then
        local errorCode = UserModel.CheckCurrencyEnough(currencyType, value)
        if errorCode ~= ErrorCode.None then
            return errorCode
        end
    end

    assert(currencyType ~= CurrencyType.Money, "param currencyType must be gold/gem")

    local data = UserModel.MutGet()

    if currencyType == CurrencyType.Gem then
        data.gem = data.gem + value
    elseif currencyType == CurrencyType.Gold then
        data.gold = data.gold + value
    end
end

return UserModel
