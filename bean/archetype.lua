local archetypeRegistry = {}
local keys = {}

local function createKey(componentSpecs)
    for i = 1, #componentSpecs do
        keys[i] = componentSpecs[i].componentType.id
    end

    for i = #componentSpecs + 1, #keys do
        keys[i] = nil
    end

    table.sort(keys)

    return table.concat(keys, '|')
end

local function newArchetype(componentSpecs, key, prototype)
    local archetype = setmetatable({
        componentTypes = {},
    }, prototype.__mt)
    archetype.__mt = { __index = archetype }

    for _, componentSpec in ipairs(componentSpecs) do
        table.insert(archetype.componentTypes, componentSpec.componentType)

        local methods = componentSpec.componentType.methods
        for _, method in ipairs(methods) do
            archetype[method.name] = method.fn
        end
    end
    archetypeRegistry[key or createKey(componentSpecs)] = archetype

    return archetype
end

local function fromComponentSpecs(componentSpecs, prototype)
    local key = createKey(componentSpecs)

    if archetypeRegistry[key] then
        return archetypeRegistry[key]
    end

    return newArchetype(componentSpecs, key, prototype)
end

return {
    fromComponentSpecs = fromComponentSpecs,
}
