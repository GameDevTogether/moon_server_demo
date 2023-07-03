local moon = require("moon")
local json = require("json")
local random = require("random")
local uuid = require("uuid")
local common = require("common")
local Database = common.Database
local UserData = require("game.module.UserData")
local CmdCode = common.CmdCode
local GameCfg = common.GameCfg
local ErrorCode = common.Enums.ErrorCode
local jdecode = json.decode

---@type mail_context
local context = ...
local scripts = context.scripts

--------------------------------------------------------------------------------

---@class Mail
local Mail = {}

function Mail.Init()
    context.addr_gate = moon.queryservice("gate")
    context.addr_auth = moon.queryservice("auth")
    context.addr_db_user = moon.queryservice("db_user")
    return true
end

function Mail.Start()

end

function Mail.LoadUserMail(uid)
    if type(context.mails[uid] )=="table" then return context.mails[uid]  end
    ---@type UserData
    local data = Database.loadusermails(context.addr_db_user, uid)
    data = jdecode(data)
    context.mails[uid] = data
    return data or {}
end

function Mail.SaveUserMails(uid,data)
    if data then context.mails[uid] = data end
    Database.saveusermails(context.addr_db_user,uid, context.mails[uid])
end

function Mail.FindMail(uid,msgid)
    local list = Mail.LoadUserMail(uid)
    for k, value in ipairs(list) do
        if msgid == value.msgid then
            return k
        end
    end
    return nil
end

function Mail.TestMail(uid)
    ---@type MailData
    local mail  = {}
    mail.msgid = uuid.next()
    mail.id = "test id"
    mail.itemlist = {
        {
            id = 1,
            count = math.random(1,5),
        }, {
            id = 2,
            count =  math.random(1,30),
        },}
    mail.state = 1
    mail.jsonparams = "test"
    Mail.S2CUpdateMail(uid,{mail = mail})
end


---同步 邮件数据
---@param data S2CUpdateMail 邮件内容
function Mail.S2CUpdateMail(uid,data)
    local list = Mail.LoadUserMail(uid)
    table.insert(list,data.mail)
    Mail.SaveUserMails(uid,list)
    context.S2C(uid,CmdCode.S2CUpdateMail,data)
end

---请求 邮件数据
function Mail.C2SMailList(uid)
    local list = Mail.LoadUserMail(uid)
    context.S2C(uid,CmdCode.S2CMailList,{maillist = list})
end

---请求变更邮件状态
---@param req C2SMailState
function Mail.C2SMailState(uid,req)
    local key = Mail.FindMail(uid,req.msgid)
    if not key then return ErrorCode.MailNoID end
    local list = Mail.LoadUserMail(uid)
    local data = list[key]
    if data.state ~= 1 then
        return ErrorCode.MailStateFit
    end
    data.state = #data.itemlist == 0 and 3 or 2
    -- context.call_user(uid,"UserModel.SetDirty")
    Mail.SaveUserMails(uid)
end

---请求 领取邮件附件
---@param req C2SMailRecive
function Mail.C2SMailRecive(uid,req)
    local key = Mail.FindMail(uid,req.msgid)
    if not key then return ErrorCode.MailNoID end
    local list = Mail.LoadUserMail(uid)
    local data = list[key]
    if #data.itemlist == 0 then return ErrorCode.MailNoRewards end
    ---todo 发送道具奖励 
    data.state = 3
    -- context.call_user(uid,"UserModel.SetDirty")
    Mail.SaveUserMails(uid)
    context.S2C(uid,CmdCode.S2CMailRecive,{msgid = req.msgid})
end

---请求 删除邮件
---@param req C2SMailDelete
function Mail.C2SMailDelete(uid,req)
    local key = Mail.FindMail(uid,req.msgid)
    if not key then return ErrorCode.MailNoID end
    local list = Mail.LoadUserMail(uid)
    local data = list[key]
    if #data.itemlist>0 and data.state~= 3 then --有附件未领取不允许删除
        return ErrorCode.MailHadRewards
    end
    table.remove(list,key)
    -- context.call_user(uid,"UserModel.SetDirty")
    Mail.SaveUserMails(uid)
    context.S2C(uid,CmdCode.C2SMailDelete,{msgid = req.msgid})
end

---请求 一键领取邮件附件
function Mail.C2SMailRecives(uid)
    local list = Mail.LoadUserMail(uid)
    local len = #list
    if len == 0 then return ErrorCode.MailNoRewards end
    local ids = {}
    for i = len,0,-1 do
        local data = list[i]
        if data.state ~=3 and #data.itemlist>0 then
            data.state = 3
            table.insert(ids,data.msgid)
        end
    end
    if #ids==0 then
        return ErrorCode.MailNoRewards
    end
    -- context.call_user(uid,"UserModel.SetDirty")
    Mail.SaveUserMails(uid)
    context.S2C(uid,CmdCode.C2SMailRecives,{msgids = ids})
end

---请求 一键删除邮件
function Mail.C2SMailDeletes(uid)
    local list = Mail.LoadUserMail(uid)
    local len = #list
    if len == 0 then return ErrorCode.MailNoDelete end
    local ids = {}
    for i = len,0,-1 do
        local data = list[i]
        if data.state == 3 then
            table.remove(list,i)
            table.insert(ids,data.msgid)
        end
    end
    if #ids==0 then
        return ErrorCode.MailNoDelete
    end
    -- context.call_user(uid,"UserModel.SetDirty")
    Mail.SaveUserMails(uid)
    context.S2C(uid,CmdCode.C2SMailDeletes,{msgids = ids})
end

function Mail.Shutdown()
    moon.quit()
    return true
end

return Mail