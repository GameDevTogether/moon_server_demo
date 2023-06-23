
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
    ---@class WeaponQuality
     ---@field public White integer
     ---@field public Green integer
     ---@field public Blue integer
     ---@field public Purple integer
     ---@field public Gold integer
    ['WeaponQuality'] = {   White=1,  Green=2,  Blue=3,  Purple=4,  Gold=5,  };
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
     ---@field public Money integer
    ['CurrencyType'] = {   Gold=1,  Gem=2,  Money=3,  };
}

local tables =
{
    { name='MonsterConfigs', file='monsterconfigs', mode='map', index='id', value_type='MonsterConfig' },

    { name='LevelConfigs', file='levelconfigs', mode='map', index='id', value_type='LevelConfig' },

    { name='WeaponConfigs', file='weaponconfigs', mode='map', index='id', value_type='WeaponConfig' },

    { name='BattleLeveUpAwardConfigs', file='battleleveupawardconfigs', mode='map', index='id', value_type='BattleLeveUpAward' },

    { name='GameItemConfigs', file='gameitemconfigs', mode='map', index='id', value_type='GameItemConfig' },

    { name='ItemQualityConfigs', file='itemqualityconfigs', mode='map', index='id', value_type='ItemQualityConfig' },

    { name='ShopItemConfigs', file='shopitemconfigs', mode='map', index='id', value_type='ShopItemConfig' },

}

return { enums = enums, tables = tables }
