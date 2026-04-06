local ComponentTypePrototype = {}

local ComponentFactoryPrototypeMt = {
    __index = ComponentTypePrototype,
    __call = function(self, ...)
        return self:spec(...)
    end,
}

local ignoredMethods = {
    ['id'] = true,
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

        methods[key] = value

        ::continue::
    end

    return methods
end

local function newComponentType(definition)
    local componentType = setmetatable({
        id = definition.id,
        init = definition.init,
        methods = extractMethods(definition),
    }, ComponentFactoryPrototypeMt)

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
