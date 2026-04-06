local ComponentTypePrototype = {}

local ComponentFactoryPrototypeMt = {
    __index = ComponentTypePrototype,
    __call = function(self, ...)
        return self:spec(...)
    end,
}

local function newComponentType(definition)
    local componentType = setmetatable({
        definition = definition,
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
