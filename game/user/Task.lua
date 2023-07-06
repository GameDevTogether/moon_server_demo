local moon = require("moon")
---@type random
local random = require("random")
local common = require("common")
local CmdCode = common.CmdCode
local ErrorCode = common.Enums.ErrorCode
local TaskState = common.Enums.TaskState
local TaskUpdateState = common.Enums.TaskUpdateState
local TaskOpt = common.Enums.TaskOpt
local taskConfig = common.GameCfg.taskconfigs
local TaskEvent = common.Enums.TaskEvent
---@type user_context
local context = ...
local scripts = context.scripts

--------------------------------

---@class Task
local Task = {}
Task.tricks = {}
function Task.Init()
    ---没有还是自己初始化吧，工厂只是备着
    local data = scripts.UserModel.Get()
    if not data.task then
        data.task = {
            tasks = {},
            finishs = {}
        }
    end
    for _, v in pairs(TaskEvent) do
        Task.tricks[v] = {}
    end
end

function Task.Start()

end

---获取任务数据
---@param taskid integer
---@return TaskData
function Task.Get(taskid)
    local data = scripts.UserModel.Get().task.tasks
    local task = data[taskid]
    return task
end

function Task.CreateTasks(list)

end

function Task.Check(type, value, count)
    local tricks = Task.tricks[type]
    if tricks == nil then
        print("没有这个类型：", type)
        return
    end
    local tasks = scripts.UserModel.Get().task.tasks
    local updates = {}
    for key, _ in pairs(tricks) do
        local task = tasks[key]
        if not task then
            tricks[task.taskid] = nil --不再进遍历
        else
            local config = taskConfig[task.taskid]
            if config.trickKey == value then
                task.condcount = tasks[key].condcount + count
                table.insert(updates,
                    { taskid = task.taskid, condcount = task.condcount, updatetype = TaskUpdateState.Mark })
                if task.condcount >= config.trickCount then
                    tricks[task.taskid] = nil --不再进遍历
                end
            end
        end
    end
    if #updates > 0 then
        scripts.UserModel.SetDirty()
        Task.UpdateTask(updates)
    end
end

---comment
---@param list table<integer,TaskData>
---@return Task
function Task.PushToTrick(list)
    local tricks = Task.tricks
    for _, v in pairs(list) do
        local config = taskConfig[v.taskid]
        if config then
            if not tricks[config.trickId] then
                print("需要更新配置", config.trickId)
                tricks[config.trickId] = {}
            end
            tricks[config.trickId][v.taskid] = 1
        else
            --配置表取消了该任务，直接清空
            print("配置表取消了该任务：", v.taskid)
        end
    end
end

function Task.PopTask(id)
    local data = scripts.UserModel.Get().task.tasks
    data[id] = nil
end

---请求任务数据
function Task.C2STaskList()
    local list = {}
    local tasklist = {}
    for _, value in pairs(list) do
        table.insert(tasklist, value)
    end
    context.S2C(CmdCode.S2CTaskList, { tasklist = tasklist })
end

---任务更新
---@param list TaskUpdateData[]
function Task.UpdateTask(list)
    context.S2C(CmdCode.S2CTaskUpdate, { updateinfos = list })
end

---请求任务操作
---@param req C2STaskOpt
function Task.C2STaskOpt(req)
    local task = Task.Get(req.taskid)
    if not task then return ErrorCode.TaskError end
    if (task.state == TaskState.CanAccept and req.opt == TaskOpt.Accept) then
        task.state = TaskState.Accept
        scripts.UserModel.SetDirty()
        Task.UpdateTask({ { taskid = task.taskid, state = task.state, updatetype = TaskUpdateState.State } })
    elseif task.state == TaskState.CanCommit and req.opt == TaskOpt.Commit then
        task.state = TaskState.Commit
        scripts.UserModel.SetDirty()
        Task.UpdateTask({ { taskid = task.taskid, state = task.state, updatetype = TaskUpdateState.State } })
    end
    return ErrorCode.TaskOptError
end

return Task
