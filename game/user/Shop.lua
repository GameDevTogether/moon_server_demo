local moon = require("moon")
local ModelFactory = require("common.ModelFactory")

local random = require("random")
local uuid = require("uuid")
local common = require("common")
local CmdCode = common.CmdCode
local GameCfg = common.GameCfg
local ErrorCode = common.Enums.ErrorCode
local CurrencyType = common.Enums.CurrencyType

---@type user_context
local context = ...
local scripts = context.scripts



--------------------------------------------------------------------------------

---@class Shop
local Shop = {}

function Shop.Init()
    local data = scripts.UserModel.Get()
    if not data.gacha then
        data.gacha = {
            itemMap = {}
        }
    end
end

function Shop.Start()

end

---@private
---获得抽奖道具，在各种前置检查后调用，获得武器数据
---@param quailties integer[] @品质数组
---@param probabilities integer[] @每个品质概率，和上面数组一一对应
---@param itemIds table<integer,integer[]> @存放每个品质要抽的id数组
---@return WeaponData @武器数据
function Shop.GacheOnce(quailties, probabilities, itemIds)
    ---@type WeaponData
    local weaponData = { uid = 0, weaponId = 0, level = 1, star = 1, quailty = 0 }
    --先随机出品质
    local quailty = random.rand_weight(quailties, probabilities)
    weaponData.quailty = quailty

    local ids = itemIds[quailty]

    local id = ids[random.rand_range(1, #ids)]


    weaponData.weaponId = id

    weaponData.uid = uuid.next()

    return weaponData
end

---抽奖，暂时就抽武器类型
---@param id integer @宝箱id
---@param count integer @就支持1,10两种数量,10个送一次抽奖次数
---@return integer|nil,WeaponData[]|nil @错误码|nil,WeaponData数组
function Shop.Gacha(id, count)
    local config = GameCfg.gachaconfigs[id]
    if not config then
        return ErrorCode.ConfigError, nil
    end

    if count ~= 1 and count ~= 10 then
        return ErrorCode.ParamInvalid, nil
    end

    if count == 10 then
        count = 11
    end

    local UserModel = scripts.UserModel

    ---扣除金钱
    local currency = config.currencyNum * count
    local errorCode = UserModel.AddCurrency(config.CurrencyType, -currency)
    if errorCode then
        return errorCode, nil
    end

    --正常抽奖流程
    --TODO 暂时纯随机
    local quailties = {}
    local probabilities = {}
    for _, value in pairs(config.gachaItem) do
        table.insert(quailties, value.quality)
        table.insert(probabilities, value.probability)
    end


    local userDataRW = UserModel.MutGet()
    local weaponList = {}
    for i = 1, count do
        local weaponData = Shop.GacheOnce(quailties, probabilities, config.awardItem)

        --增加抽奖计数
        local itemMap = userDataRW.gacha.itemMap
        if not itemMap[id] then
            itemMap[id] = ModelFactory.CreateGachaItem()
            itemMap[id].id = id
        end
        itemMap[id].count = itemMap[id].count + 1

        table.insert(weaponList, weaponData)
    end

    --增加到背包
    scripts.Bag.AddWeaponList(weaponList)

    context.S2C(CmdCode.S2CGacha, { weaponlist = weaponList })
end

---客户端请求抽奖
---@param req C2SGacha
function Shop.C2SGacha(req)
    ---TODO 以后修改抽奖

    local errorCode = Shop.Gacha(req.chestId, req.count)

    if errorCode then
        return errorCode
    end
end

---客户端请求购买金币/宝石包
---@param req C2SPurchasePack
function Shop.C2SPurchasePack(req)
    local config = GameCfg.shopcurrencypackconfigs[req.packId]

   

    if config.CurrencyType == CurrencyType.Gem then

        local errorCode = scripts.UserModel.CheckCurrencyEnough(config.CurrencyType, config.currencyNum)

        if errorCode then
            return errorCode
        end
        --购买金币包
        --扣除宝石
        scripts.UserModel.AddCurrency(config.CurrencyType, -config.currencyNum)
        --增加金币
        scripts.UserModel.AddCurrency(config.TargetCurrencyType, config.TargetCurrencyNum)
        --同步给玩家
        scripts.User.S2CUserData()
    elseif config.CurrencyType == CurrencyType.Money then
        Shop.Recharge(config)
    end
end

---充值处理
---@param config table
function Shop.Recharge(config)
    ---直接成功

    -- scripts.UserModel.AddCurrency(config.CurrencyType, -config.currencyNum)
    --增加宝石
    scripts.UserModel.AddCurrency(config.TargetCurrencyType, config.TargetCurrencyNum)
    --同步给玩家
    scripts.User.S2CUserData()
end

return Shop
