local PATH = (...):match('(.-bean%.)')

local Entity = require(PATH .. 'entity')

local function newScene()
    return Entity.newEntity(nil, {}, {})
end

return {
    newScene = newScene,
}
