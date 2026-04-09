local PATH = (...):match('(.-bean%.)')

local Archetype = require(PATH .. 'archetype')

local EntityPrototype = {}
EntityPrototype.__mt = { __index = EntityPrototype }

local WildcardTag = '*'

local function newEntity(parent, componentSpecs, tags)
    local archetype = Archetype.fromComponentSpecs(componentSpecs, EntityPrototype)

    local entity = setmetatable({
        __parent = parent,
        __children = {},
        __tags = {},
        __archetype = archetype,
    }, archetype.__mt)

    for _, componentSpec in ipairs(componentSpecs) do
        componentSpec.componentType.init(entity, unpack(componentSpec.args))
    end

    for _, tag in ipairs(tags) do
        entity.__tags[tag] = true
    end

    return entity
end

local function extractComponentSpecsAndTags(componentSpecsAndTags)
    local componentSpecs = {}
    local tags = {}

    for _, spec in ipairs(componentSpecsAndTags) do
        if type(spec) == 'table' then
            table.insert(componentSpecs, spec)
        end

        if type(spec) == 'string' then
            table.insert(tags, spec)
        end
    end

    return componentSpecs, tags
end

function EntityPrototype:addEntity(componentSpecsAndTags)
    local componentSpecs, tags = extractComponentSpecsAndTags(componentSpecsAndTags)

    local entity = newEntity(self, componentSpecs, tags)
    table.insert(self.__children, entity)

    return entity
end

function EntityPrototype:tag(tag)
    self.__tags[tag] = true
end

function EntityPrototype:untag(tag)
    self.__tags[tag] = nil
end

function EntityPrototype:is(tag)
    if tag == WildcardTag then
        return true
    end

    return self.__tags[tag] == true
end

return {
    newEntity = newEntity,
}
