local moon = require("moon")
local common = require("common")
local CmdCode = common.CmdCode
local GameCfg = common.GameCfg
local Database = common.Database
local UserDataFn = require("game.module.UserData")



---@type user_context
local context = ...
local scripts = context.scripts

local state = { ---内存中的状态
    online = false,
    data_changed = false
}

---@class User
local User = {}


function User.Login(req)
    if req.pull then --服务器主动拉起玩家
        return scripts.UserModel.Get().openid
    end
    if state.online then
        context.batch_invoke("Offline")
    end
    context.batch_invoke("Online")
    return scripts.UserModel.Get().openid
end

---登录成功,触发该函数
---@param req any
function User.LoginSuccess(req)
    print(req.uid,"login success")
    --同步玩家数据给服务器
    User.C2SUserData()
end

function User.Logout()
    context.batch_invoke("Offline")
end

function User.Init()
    GameCfg.Load()
end

function User.Start()

end

function User.Online()
    state.online = true
    scripts.UserModel.MutGet().logintime = moon.time()
end

function User.Offline()
    if not state.online then
        return
    end

    print(context.uid, "offline")
    state.online = false
end

function User.OnHour()
    -- body
end

function User.OnDay()
    -- body
end

function User.Exit()
    local ok, err = xpcall(scripts.UserModel.Save, debug.traceback)
    if not ok then
        moon.error("user exit save db error", err)
    end
    moon.quit()
    return true
end

function User.C2SUserData()
    context.S2C(CmdCode.S2CUserData, scripts.UserModel.Get())
end

function User.C2SPing(req)
    req.stime = moon.time()
    context.S2C(CmdCode.S2CPong, req)
end



return User
