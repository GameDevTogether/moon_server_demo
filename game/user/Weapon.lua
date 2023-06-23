
local moon = require("moon")
local common = require("common")
local CmdCode = common.CmdCode
local GameCfg = common.GameCfg
local errcode = common.ErrorCode

---@type user_context
local context = ...
local scripts = context.scripts
local UserModel = scripts.UserModel


---@class Weapon
local Weapon = {}

function Weapon.Init()

end

function Weapon.Start()

end


---客户端请求装备武器
---@param req C2SEquip
function Weapon.C2SEquip(req)

end

---客户端请求升级武器
---@param req C2SUpgradeWeapon
function Weapon.C2SUpgradeWeapon(req)
    
end





return Weapon
