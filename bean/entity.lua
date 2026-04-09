local PATH = (...):match('(.-bean%.)')

local Archetype = require(PATH .. 'archetype')

local EntityPrototype = {}
EntityPrototype.__mt = { __index = EntityPrototype }

local function newEntity(parent, componentSpecs)
    local archetype = Archetype.fromComponentSpecs(componentSpecs, EntityPrototype)

    local entity = setmetatable({
        __parent = parent,
        __children = {},
        __archetype = archetype,
    }, archetype.__mt)

    for _, componentSpec in ipairs(componentSpecs) do
        componentSpec.componentType.init(entity, unpack(componentSpec.args))
    end

    return entity
end

function EntityPrototype:addEntity(componentSpecs)
    local entity = newEntity(self, componentSpecs)
    table.insert(self.__children, entity)

    return entity
end

return {
    newEntity = newEntity,
}
