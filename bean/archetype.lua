local ignoredFields = {
    ['init'] = true,
}

local function fromComponentSpecs(componentSpecs)
    local archetype = {}
    archetype.__mt = { __index = archetype }

    for _, componentSpec in ipairs(componentSpecs) do
        local definition = componentSpec.componentType.definition()
        for key, value in pairs(definition) do
            if not ignoredFields[key] then
                archetype[key] = value
            end
        end
    end

    return archetype
end

return {
    fromComponentSpecs = fromComponentSpecs,
}
