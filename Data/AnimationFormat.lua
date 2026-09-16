--==================================================
-- DayBreak Animation Format
--==================================================

local AnimationFormat = {}

AnimationFormat.Format = "DayBreakAnimation"
AnimationFormat.Version = 1

function AnimationFormat.Create(name, keyframes, options)
    options = options or {}

    return {
        format = AnimationFormat.Format,
        version = AnimationFormat.Version,
        name = name,
        looped = options.looped == true,
        speed = options.speed or 1,
        keyframes = keyframes or {},
    }
end

function AnimationFormat.Validate(animation)
    if type(animation) ~= "table" then
        return false, "Animation must be a table"
    end

    if animation.format ~= AnimationFormat.Format then
        return false, "Unsupported animation format"
    end

    if animation.version ~= AnimationFormat.Version then
        return false, "Unsupported animation version"
    end

    if type(animation.name) ~= "string" or animation.name == "" then
        return false, "Animation name is required"
    end

    if type(animation.keyframes) ~= "table" then
        return false, "Keyframes must be a table"
    end

    return true
end

return AnimationFormat
