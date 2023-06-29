local moon = require("moon")
local common = require("common")
local Database = common.Database
local GameCfg = common.GameCfg
local ErrorCode = common.Enums.ErrorCode

---@type user_context
local context = ...
local scripts = context.scripts



---@class CodeGift
local CodeGift = {}

---检查礼包码是否可用
---@param code string
---@return integer|nil @错误码|空
function CodeGift.CheckGiftCodeAvailable(code)
   

end

---请求兑换礼包码
---@param req C2SExchangeGift
function CodeGift.C2SExchangeGift(req)
    local code = req.code
    local config = GameCfg.codegifts[code]
    if not config then
        return ErrorCode.CodeInvalid
    end

    local count = Database.loadcodegift(context.addr_center,code)
    if not count then
        count = config.count
    end

    if count == 0 then
        return ErrorCode.CodeFullyRedeemed
    end

    count = count - 1
    Database.savecodegift(context.addr_center,code,count)

    --TODO 发送邮件

    
end
return CodeGift