local PATH = (...):match('(.-bean%.)')

local SparseSet = require(PATH .. 'sparse-set')
local Archetype = require(PATH .. 'archetype')

local EntityPrototype = {}
EntityPrototype.__mt = { __index = EntityPrototype }

local WildcardTag = '*'
local EmptyTagList = {}

local function newEntity(parent, componentSpecs, tags)
    local archetype = Archetype.fromComponentSpecs(componentSpecs, EntityPrototype)

    local entity = setmetatable({
        _parent = parent,
        _children = SparseSet.newSparseSet(),
        _tags = SparseSet.newSparseSet(),
        _tagIndex = {},
        _events = {},
        _archetype = archetype,
    }, archetype.__mt)

    for _, componentSpec in ipairs(componentSpecs) do
        componentSpec.componentType.init(entity, unpack(componentSpec.args))

        for _, event in ipairs(componentSpec.componentType.events) do
            entity:on(event.eventName, event.tagOrHandler, event.handler)
        end
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
    self._children:add(entity)

    return entity
end

function EntityPrototype:tag(tag)
    self._tags:add(tag)
    self:_addToTagIndex(self, tag)

    if self._parent then
        self._parent:_notifyTagWasAddedToChild(self, tag)
    end

    return self
end

function EntityPrototype:untag(tag)
    self._tags:remove(tag)
    self:_removeFromTagIndex(self, tag)

    if self._parent then
        self._parent:_notifyTagWasRemovedFromChild(self, tag)
    end

    return self
end

function EntityPrototype:is(tag)
    return self._tags:contains(tag)
end

function EntityPrototype:get(tag)
    if self._tagIndex[tag] then
        return self._tagIndex[tag]:values()
    end

    return EmptyTagList
end

function EntityPrototype:on(eventName, tagOrHandler, handler)
    local tag = tagOrHandler
    if handler == nil then
        handler = tagOrHandler
        tag = WildcardTag
    end

    if not self._events[eventName] then
        self._events[eventName] = {}
    end

    if not self._events[eventName][tag] then
        self._events[eventName][tag] = {}
    end

    table.insert(self._events[eventName][tag], handler)

    return self
end

function EntityPrototype:emit(eventName, ...)
    self:_handleEmit(self, eventName, ...)

    return self
end

function EntityPrototype:broadcast(eventName, ...)
    self:_handleBroadcast(self, eventName, ...)

    return self
end

function EntityPrototype:_handleBroadcast(entity, eventName, ...)
    for _, child in ipairs(self._children:values()) do
        child:_handleBroadcast(entity, eventName, ...)
    end

    local handlers = self._events[eventName]
    if handlers then
        for _, tag in ipairs(entity._tags:values()) do
            local tagHandlers = handlers[tag]
            if tagHandlers then
                for _, handler in ipairs(tagHandlers) do
                    handler(self, entity, ...)
                end
            end
        end
    end
end

function EntityPrototype:_handleEmit(entity, eventName, ...)
    local handlers = self._events[eventName]
    if handlers then
        for _, tag in ipairs(entity._tags:values()) do
            local tagHandlers = handlers[tag]
            if tagHandlers then
                for _, handler in ipairs(tagHandlers) do
                    handler(self, entity, ...)
                end
            end
        end
    end

    if self._parent then
        self._parent:_handleEmit(entity, eventName, ...)
    end
end

function EntityPrototype:destroy()
    while not self._children:isEmpty() do
        local lastChild = self._children:peek()
        lastChild:destroy()
    end

    for _, componentType in ipairs(self._archetype.componentTypes) do
        componentType.destroy(self)
    end

    if self._parent then
        self._parent:_notifyChildWasDestroyed(self)
    end

    return self
end

function EntityPrototype:_notifyTagWasAddedToChild(child, tag)
    self:_addToTagIndex(child, tag)

    if self._parent then
        self._parent:_notifyTagWasAddedToChild(child, tag)
    end
end

function EntityPrototype:_notifyTagWasRemovedFromChild(child, tag)
    self:_removeFromTagIndex(child, tag)

    if self._parent then
        self._parent:_notifyTagWasRemovedFromChild(child, tag)
    end
end

function EntityPrototype:_notifyChildWasDestroyed(child, isGrandchild)
    if not isGrandchild then
        self._children:remove(child)
    end

    self:_pruneTagsForEntity(child)

    if self._parent then
        self._parent:_notifyChildWasDestroyed(child, true)
    end
end

function EntityPrototype:_pruneTagsForEntity(entity)
    for _, tag in ipairs(entity._tags:values()) do
        self:_removeFromTagIndex(entity, tag)
    end
end

function EntityPrototype:_addToTagIndex(entity, tag)
    local bucket = self._tagIndex[tag]
    if not bucket then
        bucket = SparseSet.newSparseSet()
        self._tagIndex[tag] = bucket
    end

    bucket:add(entity)
end

function EntityPrototype:_removeFromTagIndex(entity, tag)
    local bucket = self._tagIndex[tag]
    if not bucket then
        return
    end

    bucket:remove(entity)
    if bucket:isEmpty() then
        self._tagIndex[tag] = nil
    end
end

return {
    newEntity = newEntity,
}
