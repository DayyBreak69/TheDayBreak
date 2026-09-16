--==================================================
-- DayBreak
-- Reanimation UI Module
--
-- This module manages the Reanimation interface and
-- animation library data.
--
-- IMPORTANT:
-- This file does NOT execute the Reanimation engine.
--==================================================

local AnimationFormat = require("Data.AnimationFormat")

local ReanimationUI = {}
ReanimationUI.__index = ReanimationUI

--==================================================
-- MODULE INFORMATION
--==================================================

ReanimationUI.Name = "Reanimation"

ReanimationUI.Tabs = {
    "All",
    "Favs",
    "Binds",
    "Custom",
    "States",
    "Size",
}

--==================================================
-- BUILT-IN ANIMATIONS
--
-- Temporary list for the UI.
-- This can be replaced with the real animation
-- library later.
--==================================================

ReanimationUI.BuiltInAnimations = {
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
}

--==================================================
-- CREATE
--==================================================

function ReanimationUI.new()
    local self = setmetatable({}, ReanimationUI)

    self.State = {
        ActiveTab = "All",

        SearchText = "",

        Favorites = {},

        Binds = {},

        CustomAnimations = {},

        States = {
            Idle = nil,
            Walk = nil,
            Jump = nil,
        },

        Size = {
            Scale = 1,
        },
    }

    self.UI = nil

    return self
end

--==================================================
-- INITIALIZE
--==================================================

function ReanimationUI:Initialize(ui)
    self.UI = ui

    if self.UI then
        self.UI:RegisterModule(
            self.Name,
            self
        )
    end

    return self
end

--==================================================
-- TAB MANAGEMENT
--==================================================

function ReanimationUI:SetTab(tabName)
    for _, tab in ipairs(self.Tabs) do
        if tab == tabName then
            self.State.ActiveTab = tabName

            if self.UI then
                self.UI:Emit(
                    "ReanimationTabChanged",
                    tabName
                )
            end

            return true
        end
    end

    return false, "Unknown Reanimation tab"
end

function ReanimationUI:GetTab()
    return self.State.ActiveTab
end

function ReanimationUI:GetTabs()
    return self.Tabs
end

--==================================================
-- SEARCH
--==================================================

function ReanimationUI:SetSearch(text)
    self.State.SearchText = tostring(text or "")

    if self.UI then
        self.UI:Emit(
            "ReanimationSearchChanged",
            self.State.SearchText
        )
    end
end

function ReanimationUI:GetSearch()
    return self.State.SearchText
end

--==================================================
-- GET ALL ANIMATIONS
--==================================================

function ReanimationUI:GetAnimations()
    local animations = {}

    -- Built-in animations
    for _, name in ipairs(self.BuiltInAnimations) do
        animations[#animations + 1] = {
            Name = name,
            Type = "BuiltIn",
        }
    end

    -- Custom animations
    for _, animation in ipairs(self.State.CustomAnimations) do
        animations[#animations + 1] = {
            Name = animation.name,
            Type = "Custom",
            Data = animation,
        }
    end

    return animations
end

--==================================================
-- GET ANIMATION NAMES
--==================================================

function ReanimationUI:GetAnimationNames()
    local names = {}

    for _, animation in ipairs(self:GetAnimations()) do
        names[#names + 1] = animation.Name
    end

    return names
end

--==================================================
-- FIND ANIMATION
--==================================================

function ReanimationUI:FindAnimation(name)
    if type(name) ~= "string" then
        return nil
    end

    for _, animation in ipairs(self:GetAnimations()) do
        if animation.Name == name then
            return animation
        end
    end

    return nil
end

--==================================================
-- SEARCH ANIMATIONS
--==================================================

function ReanimationUI:SearchAnimations(text)
    text = tostring(text or "")

    local query = string.lower(text)
    local results = {}

    for _, animation in ipairs(self:GetAnimations()) do
        local name = string.lower(animation.Name)

        if query == ""
            or string.find(
                name,
                query,
                1,
                true
            ) then

            results[#results + 1] = animation
        end
    end

    return results
end

--==================================================
-- GET CURRENT TAB CONTENT
--==================================================

function ReanimationUI:GetVisibleAnimations()
    local tab = self.State.ActiveTab

    --==============================================
    -- ALL
    --==============================================

    if tab == "All" then
        return self:SearchAnimations(
            self.State.SearchText
        )
    end

    --==============================================
    -- FAVORITES
    --==============================================

    if tab == "Favs" then
        local results = {}
        local search = string.lower(
            self.State.SearchText
        )

        for _, animation in ipairs(self:GetAnimations()) do
            if self:IsFavorite(animation.Name) then
                local name = string.lower(
                    animation.Name
                )

                if search == ""
                    or string.find(
                        name,
                        search,
                        1,
                        true
                    ) then

                    results[#results + 1] = animation
                end
            end
        end

        return results
    end

    --==============================================
    -- CUSTOM
    --==============================================

    if tab == "Custom" then
        local results = {}
        local search = string.lower(
            self.State.SearchText
        )

        for _, animation in ipairs(
            self.State.CustomAnimations
        ) do
            local name = string.lower(
                animation.name
            )

            if search == ""
                or string.find(
                    name,
                    search,
                    1,
                    true
                ) then

                results[#results + 1] = {
                    Name = animation.name,
                    Type = "Custom",
                    Data = animation,
                }
            end
        end

        return results
    end

    return {}
end

--==================================================
-- FAVORITES
--==================================================

function ReanimationUI:SetFavorite(
    animationName,
    enabled
)
    if not self:FindAnimation(animationName) then
        return false, "Animation not found"
    end

    if enabled then
        self.State.Favorites[animationName] = true
    else
        self.State.Favorites[animationName] = nil
    end

    if self.UI then
        self.UI:Emit(
            "ReanimationFavoriteChanged",
            animationName,
            enabled
        )
    end

    return true
end

function ReanimationUI:ToggleFavorite(animationName)
    return self:SetFavorite(
        animationName,
        not self:IsFavorite(animationName)
    )
end

function ReanimationUI:IsFavorite(animationName)
    return self.State.Favorites[animationName] == true
end

function ReanimationUI:GetFavorites()
    local results = {}

    for name in pairs(self.State.Favorites) do
        results[#results + 1] = name
    end

    table.sort(results)

    return results
end

--==================================================
-- CUSTOM ANIMATIONS
--==================================================

function ReanimationUI:AddCustomAnimation(
    name,
    keyframes,
    options
)
    if type(name) ~= "string"
        or name == "" then

        return false, "Animation name is required"
    end

    if self:FindAnimation(name) then
        return false, "Animation name already exists"
    end

    local animation =
        AnimationFormat.Create(
            name,
            keyframes,
            options
        )

    local valid, reason =
        AnimationFormat.Validate(animation)

    if not valid then
        return false, reason
    end

    self.State.CustomAnimations[#self.State.CustomAnimations + 1] =
        animation

    if self.UI then
        self.UI:Emit(
            "CustomAnimationAdded",
            animation
        )
    end

    return true, animation
end

function ReanimationUI:GetCustomAnimations()
    return self.State.CustomAnimations
end

function ReanimationUI:GetCustomAnimation(name)
    for _, animation in ipairs(
        self.State.CustomAnimations
    ) do
        if animation.name == name then
            return animation
        end
    end

    return nil
end

function ReanimationUI:RemoveCustomAnimation(name)
    for index, animation in ipairs(
        self.State.CustomAnimations
    ) do

        if animation.name == name then
            table.remove(
                self.State.CustomAnimations,
                index
            )

            -- Remove its favorite status
            self.State.Favorites[name] = nil

            -- Remove it from any states
            for stateName, assignedName in pairs(
                self.State.States
            ) do

                if assignedName == name then
                    self.State.States[stateName] = nil
                end
            end

            -- Remove any bind
            self.State.Binds[name] = nil

            if self.UI then
                self.UI:Emit(
                    "CustomAnimationRemoved",
                    name
                )
            end

            return true
        end
    end

    return false, "Custom animation not found"
end

--==================================================
-- STATES
--==================================================

function ReanimationUI:SetState(
    stateName,
    animationName
)
    local validStates = {
        Idle = true,
        Walk = true,
        Jump = true,
    }

    if not validStates[stateName] then
        return false, "Unknown animation state"
    end

    if animationName ~= nil then
        if not self:FindAnimation(animationName) then
            return false, "Animation not found"
        end
    end

    self.State.States[stateName] =
        animationName

    if self.UI then
        self.UI:Emit(
            "ReanimationStateChanged",
            stateName,
            animationName
        )
    end

    return true
end

function ReanimationUI:GetState(stateName)
    return self.State.States[stateName]
end

function ReanimationUI:GetStates()
    return {
        Idle = self.State.States.Idle,
        Walk = self.State.States.Walk,
        Jump = self.State.States.Jump,
    }
end

--==================================================
-- BINDS
--==================================================

function ReanimationUI:SetBind(
    animationName,
    key
)
    if not self:FindAnimation(animationName) then
        return false, "Animation not found"
    end

    if type(key) ~= "string"
        or key == "" then

        return false, "Key is required"
    end

    self.State.Binds[animationName] =
        key

    if self.UI then
        self.UI:Emit(
            "ReanimationBindChanged",
            animationName,
            key
        )
    end

    return true
end

function ReanimationUI:RemoveBind(animationName)
    self.State.Binds[animationName] = nil

    if self.UI then
        self.UI:Emit(
            "ReanimationBindChanged",
            animationName,
            nil
        )
    end
end

function ReanimationUI:GetBind(animationName)
    return self.State.Binds[animationName]
end

function ReanimationUI:GetBinds()
    return self.State.Binds
end

--==================================================
-- SIZE
--==================================================

function ReanimationUI:SetSize(scale)
    scale = tonumber(scale)

    if not scale then
        return false, "Size must be a number"
    end

    if scale < 0.5 then
        scale = 0.5
    end

    if scale > 2 then
        scale = 2
    end

    self.State.Size.Scale = scale

    if self.UI then
        self.UI:Emit(
            "ReanimationSizeChanged",
            scale
        )
    end

    return true
end

function ReanimationUI:GetSize()
    return self.State.Size.Scale
end

--==================================================
-- RESET
--==================================================

function ReanimationUI:Reset()
    self.State.ActiveTab = "All"
    self.State.SearchText = ""

    self.State.Favorites = {}
    self.State.Binds = {}

    self.State.CustomAnimations = {}

    self.State.States = {
        Idle = nil,
        Walk = nil,
        Jump = nil,
    }

    self.State.Size = {
        Scale = 1,
    }

    if self.UI then
        self.UI:Emit(
            "ReanimationReset"
        )
    end
end

--==================================================
-- DEBUG / STATE
--==================================================

function ReanimationUI:GetState()
    return self.State
end

return ReanimationUI
