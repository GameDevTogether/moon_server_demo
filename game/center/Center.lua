local moon = require("moon")

local context = ...
local scripts = context.scripts


---@class Center
local Center = {}


function Center.Init()
    context.addr_mail = moon.queryservice("mail")
    context.addr_gate = moon.queryservice("gate")
    context.addr_db_center = moon.queryservice("db_center")
end

function Center.Shutdown()
    moon.quit()
    return true

end



return Center