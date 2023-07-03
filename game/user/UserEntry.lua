local moon = require("moon")
local common = require("common")
local Database = common.Database
local ModelFactory = require("common.ModelFactory")

local GameCfg = common.GameCfg

---@type user_context
local context = ...
local scripts = context.scripts

---@class UserEntry
local Entry = {}


---模块初始化函数
---@param req any
---@return boolean,(string|UserData|nil) @模块初始化结果
function Entry.StartModule(req)

    GameCfg.Load()

    ---加载or创建玩家数据
    ---@return UserData|nil
    local function fn()
        local data = scripts.UserModel.Get()
        if data then
            return data
        end

        data = Database.loaduser(context.addr_db_user, req.uid)

        local isnew = false
        if not data then
            if #req.openid == 0 or req.pull then
                return
            end

            isnew = true

            ---create new user
            data = ModelFactory.CreateUserData()
            data.openid = req.openid
            data.uid = req.uid
            data.name = req.openid
        end

        scripts.UserModel.Create(data)


        ---调用本模块所有的init
        context.batch_invoke("Init")
        ----调用本模块所有的start
        context.batch_invoke("Start")

        if isnew then

        end
        return data
    end

    local ok, res = xpcall(fn, debug.traceback, req)
    if not ok then
        return ok, res
    end

    if not res then
        local errmsg = string.format("user init failed, can not find user %d", req.uid)
        moon.error(errmsg)
        return false, errmsg
    end
    print_r(req)
    req.openid = res.openid
    context.uid = res.uid
    return true,res
end


return Entry