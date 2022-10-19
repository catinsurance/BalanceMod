local m = {}
local callbacks = {}
local shaders = {}

function m.AddShaderCondition(name, id, condition)
    table.insert(shaders, {
        Name = name,
        Conditional = condition,
        Id = id,
    })
end

function m.RemoveShaderCondition(name)
    for i, shader in ipairs(shaders) do
        if shader.Name == name then
            table.remove(shaders, i)
            break
        end
    end
end

function callbacks:Run(shaderName)
    if Game():IsPaused() then
        return {
            Enabled = 0.0,
        }
    end

    for _, shader in ipairs(shaders) do
        if shaderName == shader.Name then
            local dataToReturn = shader.Conditional(shader.Name)
            if dataToReturn ~= nil then
                dataToReturn.Enabled = shader.Id
                return dataToReturn
            end
        end
    end

    return {
        Enabled = 0.0,
    }
end

function m.Init(mod)
    shaders = {}
    mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, callbacks.Run)
end

return m