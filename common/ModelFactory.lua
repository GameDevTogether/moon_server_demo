---@class ModelFactory 数据结构工厂
local ModelFactory = {}

---创建默认user基础数据
---@return UserData
function ModelFactory.CreateUserData()
    return {
        openid = "",
        uid = 0,
        name = "",
        level = 1,
        exp = 0,
        logintime = 0,
        gem = 100,
        gold = 1000,
        levelId = 0,
    
    }
end

---创建默认抽奖数据
---@return GachaItem
function ModelFactory.CreateGachaItem()
    return {
        id = 0,
        count = 0
    }
end


return ModelFactory
