local moon = require("moon")
local common = require("common")

local conf = ...

---@class mail_context:base_context
---@field scripts mail_scripts
local context ={
    conf = conf,
    addr_gate = 0,
    addr_auth = 0,
    addr_db_mail = 0,
    docmd = nil,
    ---other
    ---@type table<integer,UserData>
    mails = {}, -- 玩家的mail
}


print("setup mail")
common.setup(context)