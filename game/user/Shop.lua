local moon = require("moon")
local uuid = require("uuid")
local shop = require "static.shop"


---@type random
local random = require("random")
local cfgmgr = require("common.cfgmgr")
local cmdcode = require("common.cmdcode")
local errcode = require("common.errcode")
local dropdrace = require("common.droptrace")


local tbinsert = table.insert
---@type user_context
local context = ...

local scripts = context.scripts

local state = context.state

local Treasures = {}

---@class BuyItem
---@field id integer 商品id
---@field count integer 购买次数
---@field time integer 购买时间


---@class Shop
local Shop = {}

local DrawTraits = {}

-- local TreasureTotalCount = {}

function Shop.init()

    local treasures_cfg = cfgmgr.treasures
    for _,treasure in pairs(treasures_cfg) do
        if not Treasures[treasure.quality] then 
            Treasures[treasure.quality] = {}
        end
        tbinsert(Treasures[treasure.quality],treasure)
    end

    if not context.model.buyItems then 
        context.model.buyItems = {}
    end 
    if not context.model.draws then 
        context.model.draws = {
            drawCount = 0,  --抽奖次数.前几次抽奖走固定配置
            goldNumbers = {}, ---100抽内包含哪些是金卡的次数
        }
    end 

    -- local function GetTreasureTotalCount(id)
    --     print(id)
    --     local config = cfgmgr.treasures[id]
    --     local totalCount = TreasureTotalCount[config.max_level]
    --     if not totalCount then 
    --         totalCount = 0
    --         for i = 1,config.max_level do 
    --             totalCount = totalCount + cfgmgr.constant.GemLevelNeedSelf[i]
    --         end 
    --         if totalCount == 0 then 
    --             totalCount = 1
    --         end 
    --         TreasureTotalCount[config.max_level] = totalCount
    --     end 
    --     return totalCount
    -- end 
    -- local function GetCanDrawIds(playerTreasures,ids)
    --     local newids = {}
    --     for _,id in ipairs(ids) do 
    --         local treasuredata =  playerTreasures[id]
    --         local treasureTotalCount = 0
    --         if  treasuredata then 
    --             treasureTotalCount = treasuredata.totalcount
    --         end 
    --         -- local totalcount = GetTreasureTotalCount(id) 
    --         -- if totalcount > treasureTotalCount then 
    --             newids[#newids+1] = id 
    --         -- end
    --     end 
    --     return newids
    -- end 

    local function GetId(playerTreasures,config)
        local keys = table.keys(config)
        -- keys = GetCanDrawIds(playerTreasures,keys)
        if #keys == 0 then 
            return 0
        end 
        local index=  random.rand_range(1,#keys)
        return keys[index]
    end 

    DrawTraits[1] = function(playerTreasures)
        local config = cfgmgr.gacha_gold
      
        return GetId(playerTreasures,config)
    end 
    DrawTraits[2] = function(playerTreasures)
        local config = cfgmgr.gacha_purple
        return GetId(playerTreasures,config)
    end 
    DrawTraits[3] = function(playerTreasures)
        local config = cfgmgr.gacha_blue
        return GetId(playerTreasures,config)
    end 
    DrawTraits[4] = function()
      
        return 10001
    end 
end

function Shop.start()
    -- body
end


function Shop.BuyItem(id)
    local config = cfgmgr.shop[id]
    if not config then
        moon.error("shop config do not exist", id)
        return errcode.ShopItemNotExist
    end

    ---@type BuyItem
    local data = context.model.buyItems[id]

    local err = scripts.Item.cost(config.price_type,config.price_num)
    if err then 
        return err
    end 


    if data then 
        if config.limited >0  then
            if data.count >= config.limited then 
                return errcode.ShopItemSoldOut
            end
        end

        data.count = data.count + 1 
        data.time =  moon.time()
    else
        data = {id = id,count = 1,time = moon.time()}
        context.model.buyItems[id] = data
    end

    context.send(cmdcode.S2CBuyItem,{data = data})
    scripts.Item.AddItem(config.item_id,config.amount,dropdrace.Shop)
    scripts.User.save()
end

function Shop.RefreshItems()
    ---@param data BuyItem
    for id,data in pairs(context.model.buyItems) do
        local config = cfgmgr.shop[id]
        if not config then 
            moon.warn("shop config do not exist ",id) 
            context.model.buyItems[id] = nil 
        end 
        if config.limited >0  then 
            local now = moon.time()
            local nowTimeT = os.date("*t",now)
            local buyTimeT = os.date("*t",data.time)
            if config.fresh_type == cfgmgr.constant.ShopItemRefreshType.Day then 
                if nowTimeT.yday ~= buyTimeT.yday then 
                    context.model.buyItems[id] = nil 
                end
            elseif config.fresh_type == cfgmgr.constant.ShopItemRefreshType.Monday then
                if nowTimeT.wday ~= buyTimeT.wday and nowTimeT.wday == 1 then 
                    context.model.buyItems[id] = nil 
                end
            end
        end
    end
    print_r(context.model.buyItems)
    scripts.User.save()
end



local MoneyId = {
    Copper = 10001,
    Gold = 10002
}




function Shop.Draw()
    local itemdata =  {id = 0,count = 1}
    local id = 4
    local drawsData = context.model.draws
    drawsData.drawCount = drawsData.drawCount + 1

    local FirstDrawItems = cfgmgr.constant.FirstDrawItems

    local firstDrawCount = #FirstDrawItems


    if drawsData.drawCount <= firstDrawCount then 
        --走固定配置
        itemdata = FirstDrawItems[drawsData.drawCount]

    else 
        --正常抽奖流程
        local count =  (drawsData.drawCount -firstDrawCount)  % 100
        if #drawsData.goldNumbers == 0 then 
            drawsData.goldNumbers = random.rand_range_some(0,99,cfgmgr.constant.GachaGold)
        end 
        
        local isGold = false 
        for _,number in ipairs(drawsData.goldNumbers) do 
            if number == count then 
                isGold = true 
                break
            end 
        end 

        if not isGold then 
            id = random.rand_weight({2,3,4},{
                                        math.floor(cfgmgr.constant.GachaPurple*100),
                                        math.floor(cfgmgr.constant.GachaBlue*100),
                                        math.floor(cfgmgr.constant.GachaOther*100)})
           
        else 
            id = 1
        end 
        itemdata.id = DrawTraits[id](context.model.treasurelist)
    end 

    print("抽奖道具",itemdata.id,itemdata.count)
    if id < 4 then 
        scripts.Treasure.add(itemdata.id,itemdata.count)
    else 
        scripts.Item.AddItem(itemdata.id,itemdata.count,dropdrace.Draw)
    end 
   
    return itemdata
end

function Shop.C2SDrawOnce()
    local cost = cfgmgr.constant.GachaOneGold
    local err = scripts.Item.cost(MoneyId.Gold,cost)
    if err then
        return err
    end
    -- local err = scripts.Item.check(MoneyId.Gold,cost)
    -- if err then 
    --     return err
    -- end 

    local data = Shop.Draw()
    -- if data.id == 0 then 
    --     --抽奖失败 
    --     return errcode.DrawFailed
    -- else 
        context.send(cmdcode.S2CDrawOnce, {data = data})
        scripts.User.save()
    -- end 
   
end

function Shop.C2SDrawTen()
    local cost = cfgmgr.constant.GachaTenGold
    local err = scripts.Item.cost(MoneyId.Gold,cost)
    if err then
        return err
    end

    local items = {}
    for i = 1,10 do 
        local item = Shop.Draw()
        table.insert(items,item)
    end 
    context.send(cmdcode.S2CDrawTen, {list = items})
    scripts.User.save()
end

function Shop.C2SQueryShopItems()

    local ret = {}
    ---@param data BuyItem
    for id,data in pairs(context.model.buyItems) do
        ret[#ret+1] = {id = data.id,count = data.count}
    end
    print_r(ret)
    context.send(cmdcode.S2CQueryShopItems, {list = ret})
end

function Shop.C2SBuyItem(req)
    print_r(req)
    if not req or req.id == 0 then
        return errcode.ParamInvalid
    end
    local err = Shop.BuyItem(req.id)
    if err then 
        return err
    end 
    scripts.User.save()
end

function Shop.C2SRecharge(req)
    if not req or req.id == 0 then
        return errcode.ParamInvalid
    end

    local config = cfgmgr.recharge[req.id]
    if not config then 
        moon.error("recharge config do not exist ",req.id) 
        return 
    end 
    print(context.model.exchangecount ,config.ad_count)
    if context.model.exchangecount < config.ad_count then 
        return errcode.ExchangeNotEnough
    end 

    context.model.exchangecount  = context.model.exchangecount - config.ad_count
    context.send(cmdcode.S2CRecharge,{id = req.id,exchangecount =  context.model.exchangecount})
    scripts.Item.AddItem(config.item_id,config.count,dropdrace.AdExchange)
    scripts.User.save()
end 

return Shop