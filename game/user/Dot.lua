local moon = require("moon")
---@type random
local random = require("random")
local common = require("common")
local CmdCode = common.CmdCode
local ErrorCode = common.Enums.ErrorCode
---@type user_context
local context = ...
local scripts = context.scripts

--------------------------------
---@class Dot
local Dot = {}
function Dot.Init()
    ---没有还是自己初始化吧，工厂只是备着
    local data = scripts.UserModel.Get()
    if not data.dots then
        data.dots = {}
    end
end

function Dot.Start()

end

return Dot
