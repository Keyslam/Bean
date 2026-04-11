local PATH = (...):match('(.-bean%.)')

local SparseSet = require(PATH .. 'sparse-set')
local Archetype = require(PATH .. 'archetype')

local EntityPrototype = {}
EntityPrototype.__mt = { __index = EntityPrototype }

local WildcardTag = '*'

local function newEntity(parent, componentSpecs, tags)
    local archetype = Archetype.fromComponentSpecs(componentSpecs, EntityPrototype)

    local entity = setmetatable({
        __parent = parent,
        __children = SparseSet.newSparseSet(),
        __tags = SparseSet.newSparseSet(),
        __tagIndex = {},
        __events = {},
        __archetype = archetype,
    }, archetype.__mt)

    for _, componentSpec in ipairs(componentSpecs) do
        componentSpec.componentType.init(entity, unpack(componentSpec.args))
    end

    for _, tag in ipairs(tags) do
        entity:tag(tag)
    end
    entity:tag(WildcardTag)

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
    self.__children:add(entity)

    return entity
end

function EntityPrototype:tag(tag)
    self.__tags:add(tag)
    self:__addToTagIndex(self, tag)

    if self.__parent then
        self.__parent:__notifyTagWasAddedToChild(self, tag)
    end
end

function EntityPrototype:untag(tag)
    self.__tags:remove(tag)
    self:__removeFromTagIndex(self, tag)

    if self.__parent then
        self.__parent:__notifyTagWasRemovedFromChild(self, tag)
    end
end

function EntityPrototype:is(tag)
    return self.__tags:contains(tag)
end

function EntityPrototype:get(tag)
    if self.__tagIndex[tag] then
        return self.__tagIndex[tag]:values()
    end

    return {}
end

function EntityPrototype:on(eventName, tagOrHandler, handler)
    local tag = tagOrHandler
    if handler == nil then
        handler = tagOrHandler
        tag = WildcardTag
    end

    if not self.__events[eventName] then
        self.__events[eventName] = {}
    end

    if not self.__events[eventName][tag] then
        self.__events[eventName][tag] = {}
    end

    table.insert(self.__events[eventName][tag], handler)
end

function EntityPrototype:emit(eventName, ...)
    self:__handleEmit(self, eventName, ...)
end

function EntityPrototype:__handleEmit(entity, eventName, ...)
    local handlers = self.__events[eventName]
    if handlers then
        for _, tag in ipairs(entity.__tags:values()) do
            local tagHandlers = handlers[tag]
            if tagHandlers then
                for _, handler in ipairs(tagHandlers) do
                    handler(self, entity, ...)
                end
            end
        end
    end

    if self.__parent then
        self.__parent:__handleEmit(entity, eventName, ...)
    end
end

function EntityPrototype:destroy()
    while not self.__children:isEmpty() do
        local lastChild = self.__children:peek()
        lastChild:destroy()
    end

    if self.__parent then
        self.__parent:__notifyChildWasDestroyed(self)
    end
end

function EntityPrototype:__notifyTagWasAddedToChild(child, tag)
    self:__addToTagIndex(child, tag)

    if self.__parent then
        self.__parent:__notifyTagWasAddedToChild(child, tag)
    end
end

function EntityPrototype:__notifyTagWasRemovedFromChild(child, tag)
    self:__removeFromTagIndex(child, tag)

    if self.__parent then
        self.__parent:__notifyTagWasRemovedFromChild(child, tag)
    end
end

function EntityPrototype:__notifyChildWasDestroyed(child, isGrandchild)
    if not isGrandchild then
        self.__children:remove(child)
    end

    for _, tag in ipairs(child.__tags:values()) do
        self:__removeFromTagIndex(child, tag)
    end

    if self.__parent then
        self.__parent:__notifyChildWasDestroyed(child, true)
    end
end

function EntityPrototype:__addToTagIndex(entity, tag)
    local bucket = self.__tagIndex[tag]
    if not bucket then
        bucket = SparseSet.newSparseSet()
        self.__tagIndex[tag] = bucket
    end

    bucket:add(entity)
end

function EntityPrototype:__removeFromTagIndex(entity, tag)
    local bucket = self.__tagIndex[tag]
    if not bucket then
        return
    end

    bucket:remove(entity)
    if bucket:isEmpty() then
        self.__tagIndex[tag] = nil
    end
end

return {
    newEntity = newEntity,
}
