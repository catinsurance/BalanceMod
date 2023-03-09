---@diagnostic disable

BalanceMod = {}

include = require

---@param callback ModCallbacks
---@param func function
---@param ... any
function BalanceMod:AddCallback(callback, func, ...) end

---@param callback ModCallbacks
---@param priority CallbackPriority
---@param func function
function BalanceMod:AddPriorityCallback(callback, priority, func) end

---@return boolean
function BalanceMod:HasData() end

---@return string
function BalanceMod:LoadData() end

---@param callback ModCallbacks
---@param func function
function BalanceMod:RemoveCallback(callback, func) end

---Generally, don't do this.
function BalanceMod:RemoveData() end

---@param data string
function BalanceMod:SaveData(data) end

---@type string
BalanceMod.Name = ""

EID = {}