local PATH = (...):match('(.-bean%.)')

local Archetype = require(PATH .. 'archetype')

local ScenePrototype = {}
local ScenePrototypeMt = { __index = ScenePrototype }

local function newScene()
    local scene = setmetatable({}, ScenePrototypeMt)

    return scene
end

function ScenePrototype:addEntity(componentSpecs)
    local entity = {}

    for _, componentSpec in ipairs(componentSpecs) do
        componentSpec.componentType.init(entity, unpack(componentSpec.args))
    end

    local archetype = Archetype.fromComponentSpecs(componentSpecs)

    entity.__archetype = archetype
    setmetatable(entity, archetype.__mt)

    return entity
end

return {
    newScene = newScene,
}
