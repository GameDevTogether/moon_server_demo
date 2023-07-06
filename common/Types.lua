
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
     ---@field public CodeInvalid integer
     ---@field public CodeFullyRedeemed integer
     ---@field public AdOverCountLimit integer
     ---@field public AdInCDTime integer
     ---@field public TaskOptError integer
     ---@field public TaskError integer
    ['ErrorCode'] = {   None=0,  ParamInvalid=1,  ConfigError=2,  GoldNotEnough=3,  GemNotEnough=4,  RechargeFailed=5,  AlreadyEquipped=6,  AlreadyUnEquipped=7,  WeaponMaxLevel=8,  MaxEquipWeaponCount=9,  NeedOneWeapnEquipped=10,  WithoutWeapon=11,  MailStateFit=12,  MailNoID=13,  MailNoRewards=14,  MailHadRewards=15,  MailNoDelete=16,  CodeInvalid=17,  CodeFullyRedeemed=18,  AdOverCountLimit=19,  AdInCDTime=20,  TaskOptError=21,  TaskError=22,  };
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
    ---@class TaskState
     ---@field public CanNotAccept integer
     ---@field public CanAccept integer
     ---@field public Accept integer
     ---@field public CanCommit integer
     ---@field public Commit integer
    ['TaskState'] = {   CanNotAccept=1,  CanAccept=2,  Accept=3,  CanCommit=4,  Commit=5,  };
    ---@class TaskUpdateState
     ---@field public State integer
     ---@field public Mark integer
     ---@field public Add integer
     ---@field public Delete integer
     ---@field public Submit integer
    ['TaskUpdateState'] = {   State=1,  Mark=2,  Add=3,  Delete=4,  Submit=5,  };
    ---@class TaskOpt
     ---@field public Accept integer
     ---@field public Commit integer
    ['TaskOpt'] = {   Accept=1,  Commit=2,  };
    ---@class TaskType
     ---@field public DailyTask integer
     ---@field public WeekTask integer
     ---@field public PassTask integer
    ['TaskType'] = {   DailyTask=1,  WeekTask=2,  PassTask=3,  };
    ---@class TaskEvent
     ---@field public UseItem integer
     ---@field public GetItem integer
     ---@field public BuyByShop integer
     ---@field public WatchAd integer
     ---@field public LoginGame integer
    ['TaskEvent'] = {   UseItem=1,  GetItem=2,  BuyByShop=3,  WatchAd=4,  LoginGame=5,  };
}

local tables =
{
    { name='WeaponConfigs', file='weaponconfigs', mode='map', index='id', value_type='WeaponConfig' },

    { name='GameItemConfigs', file='gameitemconfigs', mode='map', index='id', value_type='GameItemConfig' },

    { name='ShopCurrencyPackConfigs', file='shopcurrencypackconfigs', mode='map', index='id', value_type='ShopCurrencyPackConfig' },

    { name='GachaConfigs', file='gachaconfigs', mode='map', index='id', value_type='GachaConfig' },

    { name='CodeGifts', file='codegifts', mode='map', index='code', value_type='CodeGift' },

    { name='TaskConfigs', file='taskconfigs', mode='map', index='id', value_type='TaskConfig' },

}

return { enums = enums, tables = tables }
