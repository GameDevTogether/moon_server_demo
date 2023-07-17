local moon = require("moon")
---@type random
local random = require("random")
local common = require("common")
local CmdCode = common.CmdCode
local ErrorCode = common.Enums.ErrorCode

---@type user_context
local context = ...
local scripts = context.scripts


local AdCd = 30
local MaxAdCount = 30
---@class Ad
local Ad = {}

---初始化函数
function Ad.Init()
    local userdata = context.scripts.UserModel.Get()
    if not userdata.ad then
        userdata.ad = {
            count = 0,
            totalcount = 0,
            lastadtime = 0
        }
    end
end


---在线检查一下有没有跨天
function Ad.Online()
    Ad.ClearAdCountOnNextDay()
end

---第二天清空广告次数
function Ad.ClearAdCountOnNextDay()
    local nowTimeT = os.date("*t",moon.time())

    local userdata = context.scripts.UserModel.Get()

    local lastAdTimeT = os.date("*t",userdata.ad.lastadtime)

    if nowTimeT.yday >= lastAdTimeT.yday then
        userdata = context.scripts.UserModel.MutGet()
        userdata.ad.adcount = 0
        userdata.ad.lastadtime = 0
    end
end

local Ids = {
    1234596,
    5678990,
    3465466
}

function Ad.C2SAdAppId()
    context.S2C(CmdCode.S2CAdAppId,{id =5194234})
end

function Ad.C2SQueryAdId()
    local userdata = context.scripts.UserModel.MutGet()
    if  userdata.ad.adcount > MaxAdCount then
        return ErrorCode.AdOverCountLimit
    end

    local time = moon.time()
    if time - userdata.ad.lastadtime < AdCd then
        return ErrorCode.AdInCDTime
    end

    userdata.ad.lastadtime = time
    userdata.ad.adcount = userdata.ad.adcount + 1
    local index = random.rand_range(1,#Ids)
    context.S2C(CmdCode.S2CAdId,{id = Ids[index]})
end



return Ad