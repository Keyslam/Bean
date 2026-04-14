local ComponentTypePrototype = {}
ComponentTypePrototype.__mt = {
    __index = ComponentTypePrototype,
    __call = function(self, ...)
        return self:spec(...)
    end,
}

local NextComponentId = 1
local EmptyFunction = function() end

local function getNextComponentId()
    local id = NextComponentId
    NextComponentId = NextComponentId + 1

    return id
end

local ignoredMethods = {
    ['init'] = true,
    ['destroy'] = true,
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

local function extractEvents(definition)
    local events = {}

    if not definition.on then
        return events
    end

    for key, fnOrTable in pairs(definition.on) do
        if type(fnOrTable) == 'function' then
            local name = key
            local fn = fnOrTable

            table.insert(events, {
                name = name,
                fn = fn,
                tag = nil,
            })
        end

        if type(fnOrTable) == 'table' then
            local eventDefinition = fnOrTable

            local name = eventDefinition[1]
            local tag = eventDefinition[2]
            local fn = eventDefinition[3]

            if fn == nil then
                tag = nil
                fn = eventDefinition[2]
            end

            table.insert(events, {
                name = name,
                fn = fn,
                tag = tag,
            })
        end
    end

    return events
end

local function newComponentType(definition)
    local componentType = setmetatable({
        id = getNextComponentId(),
        methods = extractMethods(definition),
        events = extractEvents(definition),

        init = definition.init or EmptyFunction,
        destroy = definition.destroy or EmptyFunction,
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
