local PATH = (...):match('(.-bean%.)')

local Entity = require(PATH .. 'entity')

local function newScene()
    return Entity.newEntity(nil, {}, { 'scene' })
end

return {
    newScene = newScene,
}
