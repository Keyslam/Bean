local ScenePrototype = {}
local ScenePrototypeMt = { __index = ScenePrototype }

local function newScene()
    local scene = setmetatable({}, ScenePrototypeMt)

    return scene
end

function ScenePrototype:addEntity(componentSpecs)
    local entity = {}

    for _, componentSpec in ipairs(componentSpecs) do
        local definition = componentSpec.componentType.definition()
        definition.init(entity, unpack(componentSpec.args))
    end

    return entity
end

return {
    newScene = newScene,
}
