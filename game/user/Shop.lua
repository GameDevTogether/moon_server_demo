
local moon = require("moon")
local common = require("common")
local CmdCode = common.CmdCode
local GameCfg = common.GameCfg
local errcode = common.ErrorCode
local Constant = common.Constant
---@type user_context
local context = ...
local scripts = context.scripts
local UserModel = scripts.UserModel


---@class Shop
local Shop = {}

function Shop.Init()

end

function Shop.Start()

end


---客户端请求抽奖
---@param req C2SEquip
function Shop.C2SGacha(req)

end

---客户端请求购买金币/宝石包
---@param req C2SPurchasePack
function Shop.C2SPurchasePack(req)
    local config = GameCfg.shopitemconfigs[req.packId]

    if config.CurrencyType == Constant.CurrencyType.Gem then
        --购买金币包

        


    else if config.CurrencyType == Constant.CurrencyType.Money then
        Shop.Recharge(config)
    end
end

---充值处理
---@param config table
function Shop.Recharge(config)


end




return Shop
