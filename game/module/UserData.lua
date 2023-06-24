
local UserData = {}

---创建默认userdata
---@return UserData
function UserData.Create()
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
        bag = {
            itemMap = {},
            equipedIdList = {},
            weaponMap = {},
            maxCanEquipCount = 1,
        },
        gacha = {
            itemMap = {}
        }
    }
end

function UserData.CreateGachaItem()
    return {
        id = 0,
        count = 0
    }
end


return UserData
