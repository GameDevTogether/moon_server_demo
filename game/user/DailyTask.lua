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
---@class DailyTask
local DailyTask = {}
function DailyTask.Init()
    ---没有还是自己初始化吧，工厂只是备着
    local data = scripts.UserModel.Get()
    if not data.dailyTask then
        data.dailyTask = {
            awards = {}, --是不是有阶段性领奖
        }
    end
end

function DailyTask.Start()

end

return DailyTask
