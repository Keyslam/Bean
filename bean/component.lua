local ComponentTypePrototype = {}
ComponentTypePrototype.__mt = {
    __index = ComponentTypePrototype,
    __call = function(self, ...)
        return self:spec(...)
    end,
}

local nextComponentId = 1

local function getNextComponentId()
    local id = nextComponentId
    nextComponentId = nextComponentId + 1

    return id
end

local ignoredMethods = {
    ['init'] = true,
}

local function extractMethods(definition)
    local methods = {}

    for key, value in pairs(definition) do
        if type(value) ~= 'function' then
            goto continue
        end

        if ignoredMethods[key] then
            goto continue
        end

        table.insert(methods, {
            name = key,
            fn = value,
        })

        ::continue::
    end

    return methods
end

local function newComponentType(definition)
    local componentType = setmetatable({
        id = getNextComponentId(),
        methods = extractMethods(definition),

        init = definition.init,
    }, ComponentTypePrototype.__mt)

    return componentType
end

function ComponentTypePrototype:spec(...)
    local componentSpec = {
        componentType = self,
        args = { ... },
    }

    return componentSpec
end

return {
    newComponentType = newComponentType,
}
