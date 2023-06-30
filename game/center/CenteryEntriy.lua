local moon = require("moon")

local context = ...
local scripts = context.scripts


---@class CenterEntry
local CenterEntry = {}




function CenterEntry.Init()
    context.addr_mail = moon.queryservice("mail")
    context.addr_gate = moon.queryservice("gate")
    context.addr_db_center = moon.queryservice("db_center")
end



return CenterEntry