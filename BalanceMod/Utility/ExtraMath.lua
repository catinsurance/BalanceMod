local ExtraMath = {}

function ExtraMath:Clamp(value, min, max)
    if value < min then
        return min
    elseif value > max then
        return max
    end
    return value
end

function ExtraMath:Round(num) -- stack overflow says this deals with floating point errors or something like that
    local ofs = 2^52
    if math.abs(num) > ofs then
      return num
    end
    return num < 0 and num - ofs + ofs or num + ofs - ofs
end

return ExtraMath