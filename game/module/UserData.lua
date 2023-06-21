---创建默认userdata
---@return UserData
local function NewUserData()
    return {
        openid = "",
        uid = 0,
        name = "",
        level = 1,
        exp = 0,
        logintime = 0,
        gem = 0,
        gold = 0,
        levelId = 0,
        itemlist = {}
    }
end


return NewUserData
