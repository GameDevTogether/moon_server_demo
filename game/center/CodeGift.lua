local moon = require("moon")
local common = require("common")
local CmdCode = common.CmdCode
local GameCfg = common.GameCfg


---@type user_context
local context = ...
local scripts = context.scripts



---@class CodeGift
local CodeGift = {}

---检查礼包码是否可用
---@param code string
---@return integer 错误码
function CodeGift.CheckGiftCodeAvailable(code)
    local config = GameCfg.codegifts[code]
    if not config then
        return 
    end
end

return CodeGift