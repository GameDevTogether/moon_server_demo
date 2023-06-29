
local setmetatable = setmetatable
local pairs = pairs
local ipairs = ipairs
local tinsert = table.insert

local function SimpleClass()
    local class = {}
    class.__index = class
    class.New = function(...)
        local ctor = class.ctor
        local o = ctor and ctor(...) or {}
        setmetatable(o, class)
        return o
    end
    return class
end


local function get_map_size(m)
    local n = 0
    for _ in pairs(m) do
        n = n + 1
    end
    return n
end
local enums =
{
    ---@class ItemQuality
     ---@field public White integer
     ---@field public Green integer
     ---@field public Blue integer
     ---@field public Purple integer
     ---@field public Gold integer
    ['ItemQuality'] = {   White=1,  Green=2,  Blue=3,  Purple=4,  Gold=5,  };
    ---@class ItemType
     ---@field public Weapon integer
     ---@field public Currency integer
    ['ItemType'] = {   Weapon=1,  Currency=2,  };
    ---@class CurrencyType
     ---@field public Gold integer
     ---@field public Gem integer
     ---@field public Cash integer
    ['CurrencyType'] = {   Gold=1,  Gem=2,  Cash=3,  };
    ---@class ErrorCode
     ---@field public None integer
     ---@field public ParamInvalid integer
     ---@field public ConfigError integer
     ---@field public GoldNotEnough integer
     ---@field public GemNotEnough integer
     ---@field public RechargeFailed integer
     ---@field public AlreadyEquipped integer
     ---@field public AlreadyUnEquipped integer
     ---@field public WeaponMaxLevel integer
     ---@field public MaxEquipWeaponCount integer
     ---@field public NeedOneWeapnEquipped integer
     ---@field public WithoutWeapon integer
     ---@field public MailStateFit integer
     ---@field public MailNoID integer
     ---@field public MailNoRewards integer
     ---@field public MailHadRewards integer
     ---@field public MailNoDelete integer
    ['ErrorCode'] = {   None=0,  ParamInvalid=1,  ConfigError=2,  GoldNotEnough=3,  GemNotEnough=4,  RechargeFailed=5,  AlreadyEquipped=6,  AlreadyUnEquipped=7,  WeaponMaxLevel=8,  MaxEquipWeaponCount=9,  NeedOneWeapnEquipped=10,  WithoutWeapon=11,  MailStateFit=12,  MailNoID=13,  MailNoRewards=14,  MailHadRewards=15,  MailNoDelete=16,  };
}

local tables =
{
    { name='WeaponConfigs', file='weaponconfigs', mode='map', index='id', value_type='WeaponConfig' },

    { name='GameItemConfigs', file='gameitemconfigs', mode='map', index='id', value_type='GameItemConfig' },

    { name='ShopCurrencyPackConfigs', file='shopcurrencypackconfigs', mode='map', index='id', value_type='ShopCurrencyPackConfig' },

    { name='GachaConfigs', file='gachaconfigs', mode='map', index='id', value_type='GachaConfig' },

}

return { enums = enums, tables = tables }
