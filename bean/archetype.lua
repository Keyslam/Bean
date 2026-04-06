local archetypeRegistry = {}
local keys = {}

local function fromComponentSpecs(componentSpecs)
    for i = 1, #componentSpecs do
        keys[i] = componentSpecs[i].componentType.id
    end

    for i = #componentSpecs + 1, #keys do
        keys[i] = nil
    end

    table.sort(keys)
    local cacheKey = table.concat(keys, '|')

    if archetypeRegistry[cacheKey] then
        return archetypeRegistry[cacheKey]
    end

    local archetype = {}
    archetype.__mt = { __index = archetype }

    for _, componentSpec in ipairs(componentSpecs) do
        for name, fn in pairs(componentSpec.componentType.methods) do
            archetype[name] = fn
        end
    end
    archetypeRegistry[cacheKey] = archetype

    return archetype
end

return {
    fromComponentSpecs = fromComponentSpecs,
}
