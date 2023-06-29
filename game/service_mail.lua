local moon = require("moon")
local common = require("common")

local conf = ...

---@class mail_context:base_context
---@field scripts mail_scripts
local context ={
    conf = conf,
    addr_gate = 0,
    addr_auth = 0,
    addr_db_user = 0,
    docmd = nil,
    ---other
}


print("setup mail")
common.setup(context)