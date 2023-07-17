local moon = require("moon")
local uuid = require("uuid")
local common = require("common")
local Database = common.Database
local GameCfg = common.GameCfg
local ErrorCode = common.Enums.ErrorCode
local CmdCode = common.CmdCode


---@type center_context
local context = ...

local scripts = context.scripts



---@class CodeGift
local CodeGift = {}


---请求兑换礼包码
---@param uid integer
---@param req C2SExchangeGift
function CodeGift.C2SExchangeGift(uid, req)
    local code = req.code
    local config = GameCfg.codegifts[code]
    if not config then
        return ErrorCode.CodeInvalid
    end

    local count = Database.loadcodegift(context.addr_db_center, code)
    if not count then
        count = config.count
    end

    if count == 0 then
        return ErrorCode.CodeFullyRedeemed
    end

    count = count - 1
    Database.savecodegift(context.addr_db_center, code, count)

    --TODO 发送邮件
    local mailData = {
        msgid = uuid.next(),
        id = "test id",
        itemlist = {
            {
                id = 1,
                count = math.random(1, 5),
            }, {
            id = 2,
            count = math.random(1, 30),
        }, },
        state = 1,
        jsonparams = "test",
    }

    --给客户端发送邮件
    moon.send("lua", context.addr_mail, "Mail.S2CUpdateMail", uid, { mail = mailData })

    --通知客户端兑换成功
    context.S2C(uid,CmdCode.S2CExchangeGift)



end

return CodeGift
