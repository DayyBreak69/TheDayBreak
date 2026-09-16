--==================================================
-- DayBreak
-- Module Manager
--==================================================

local ModuleManager = {}
ModuleManager.__index = ModuleManager

function ModuleManager.new()
    return setmetatable({
        Modules = {},
    }, ModuleManager)
end

function ModuleManager:Register(name, module)
    assert(type(name) == "string", "Module name must be a string")
    assert(type(module) == "table", "Module must be a table")

    self.Modules[name] = module
    return module
end

function ModuleManager:Get(name)
    return self.Modules[name]
end

function ModuleManager:Has(name)
    return self.Modules[name] ~= nil
end

function ModuleManager:GetNames()
    local names = {}

    for name in pairs(self.Modules) do
        names[#names + 1] = name
    end

    table.sort(names)
    return names
end

return ModuleManager
