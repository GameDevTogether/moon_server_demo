local moon = require("moon")
local common = require("common")
local CmdCode = common.CmdCode
local GameCfg = common.GameCfg
local ErrorCode = common.Enums.ErrorCode
local CurrencyType = common.Enums.CurrencyType

---@type user_context
local context = ...
local scripts = context.scripts


---@class Weapon
local Weapon = {}

function Weapon.Init()

end

function Weapon.Start()

end

---客户端请求装备武器
---@param req C2SEquip
function Weapon.C2SEquip(req)
    local errorCode = scripts.Bag.EquipWeapon(req.uid)

    if errorCode then
        return errorCode
    end

    context.S2C(CmdCode.S2CEquip, { uid = req.uid, ok = errorCode == ErrorCode.None })
end

---客户端请求卸载武器
---@param req C2SUnEquip
function Weapon.C2SUnEquip(req)
    local errorCode = scripts.Bag.UnEquipWeapon(req.uid)

    if errorCode then
        return errorCode
    end

    context.S2C(CmdCode.S2CUnEquip, { uid = req.uid, ok = errorCode == ErrorCode.None })
end

---客户端请求升级武器
---@param req C2SUpgradeWeapon
function Weapon.C2SUpgradeWeapon(req)
    local weapon = scripts.Bag.GetWeapon(req.uid)
    if not weapon then
        return ErrorCode.WithoutWeapon
    end

    local weaponConfigId = Weapon.GetWeaponConfigId(weapon.weaponId, weapon.quailty, weapon.star)
    local config = GameCfg.weaponconfigs[weaponConfigId]
    if not config then
        return ErrorCode.ConfigError
    end

    --检查等级是否满级
    if weapon.level >= config.maxlevel then
        return ErrorCode.WeaponMaxLevel
    end

    local nextLevel = weapon.level + 1
    --检查金钱是否足够
    --TODO 后面需要修改公式
    local needGold = nextLevel * 10 + 100

    local errorCode = scripts.UserModel.AddCurrency(CurrencyType.Gold, -needGold)

    if errorCode then
        return errorCode
    end

    ---保存结果
    scripts.Bag.SetWeaponLevel(req.uid, nextLevel)


    context.S2C(CmdCode.S2CUpgradeWeapon, { uid = req.uid, level = nextLevel })
end

---获得武器配置id
---@param weaponId integer
---@param quality integer
---@param star integer
---@return integer @武器配置id
function Weapon.GetWeaponConfigId(weaponId, quality, star)
    return weaponId * 100 + quality * 10 + star
end

---根据配置id获得武器id 品质，星级
---@param weaponConfigId any
---@return integer,integer,integer @武器id,品质,星级
function Weapon.SplitConfigId(weaponConfigId)
    local weaponId = weaponConfigId // 100
    local quailty = (weaponConfigId - weaponId * 100) // 10
    local star = weaponConfigId - weaponId * 100 - quailty * 10
    return weaponId, quailty, star
end

return Weapon
