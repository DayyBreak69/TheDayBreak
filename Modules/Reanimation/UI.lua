--==================================================
-- DayBreak
-- Reanimation UI
--
-- UI/data layer only. The actual engine is intentionally
-- kept separate.
--==================================================

local AnimationFormat = require("Data.AnimationFormat")

local ReanimationUI = {
    Name = "Reanimation",

    Tabs = {
        "All",
        "Favs",
        "Binds",
        "Custom",
        "States",
        "Size",
    },

    State = {
        Search = "",
        ActiveTab = "All",
        Favorites = {},
        CustomAnimations = {},
        States = {
            Idle = nil,
            Walk = nil,
            Jump = nil,
        },
    },

    BuiltInAnimations = {
        "15 MINUTES",
        "2 arm stroke",
        "360",
        "7 Rings Dance",
        "8-Bit Shuffle",
        "9mm Go Bang!",
        "A Bar Song",
        "Chief Keef",
        "Moonwalk",
        "Wave",
    },
}

function ReanimationUI:Initialize(ui)
    self.UI = ui
end

function ReanimationUI:SetTab(tabName)
    for _, tab in ipairs(self.Tabs) do
        if tab == tabName then
            self.State.ActiveTab = tabName
            if self.UI then
                self.UI:Emit("ReanimationTabChanged", tabName)
            end
            return true
        end
    end

    return false
end

function ReanimationUI:SetSearch(text)
    self.State.Search = text or ""
end

function ReanimationUI:GetAnimations()
    local result = {}

    for _, name in ipairs(self.BuiltInAnimations) do
        result[#result + 1] = name
    end

    for _, animation in ipairs(self.State.CustomAnimations) do
        result[#result + 1] = animation.name
    end

    return result
end

function ReanimationUI:Search()
    local query = string.lower(self.State.Search)
    local result = {}

    for _, name in ipairs(self:GetAnimations()) do
        if query == "" or string.find(string.lower(name), query, 1, true) then
            result[#result + 1] = name
        end
    end

    return result
end

function ReanimationUI:SetFavorite(name, enabled)
    if enabled then
        self.State.Favorites[name] = true
    else
        self.State.Favorites[name] = nil
    end
end

function ReanimationUI:IsFavorite(name)
    return self.State.Favorites[name] == true
end

function ReanimationUI:AddCustomAnimation(name, keyframes, options)
    assert(type(name) == "string" and name ~= "", "Animation name is required")

    local animation = AnimationFormat.Create(name, keyframes, options)
    local valid, reason = AnimationFormat.Validate(animation)

    if not valid then
        return false, reason
    end

    for _, existing in ipairs(self:GetAnimations()) do
        if string.lower(existing) == string.lower(name) then
            return false, "Animation name already exists"
        end
    end

    self.State.CustomAnimations[#self.State.CustomAnimations + 1] = animation
    return true, animation
end

function ReanimationUI:RemoveCustomAnimation(name)
    for index, animation in ipairs(self.State.CustomAnimations) do
        if animation.name == name then
            table.remove(self.State.CustomAnimations, index)
            self.State.Favorites[name] = nil

            for stateName, assigned in pairs(self.State.States) do
                if assigned == name then
                    self.State.States[stateName] = nil
                end
            end

            return true
        end
    end

    return false
end

function ReanimationUI:SetState(stateName, animationName)
    if self.State.States[stateName] == nil
       and stateName ~= "Idle"
       and stateName ~= "Walk"
       and stateName ~= "Jump" then
        return false, "Unknown state"
    end

    if animationName ~= nil then
        local found = false

        for _, name in ipairs(self:GetAnimations()) do
            if name == animationName then
                found = true
                break
            end
        end

        if not found then
            return false, "Animation not found"
        end
    end

    self.State.States[stateName] = animationName
    return true
end

return ReanimationUI
