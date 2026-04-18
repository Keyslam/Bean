local SparseSetPrototype = {}
SparseSetPrototype.__mt = {
    __index = SparseSetPrototype,
}

local function newSparseSet()
    return setmetatable({
        _count = 0,
        _dense = {},
        _sparse = {},
        _snapshot = {},
        _snapshot_dirty = true,
    }, SparseSetPrototype.__mt)
end

function SparseSetPrototype:add(value)
    local index = self._count + 1

    self._dense[index] = value
    self._sparse[value] = index
    self._count = self._count + 1

    self._snapshot_dirty = true
end

function SparseSetPrototype:remove(value)
    local index = self._sparse[value]

    if not index then
        return
    end

    local lastValue = self._dense[self._count]

    self._dense[index] = lastValue
    self._sparse[lastValue] = index

    self._dense[self._count] = nil
    self._count = self._count - 1
    self._sparse[value] = nil

    self._snapshot_dirty = true
end

function SparseSetPrototype:values()
    if not self._snapshot_dirty then
        return self._snapshot
    end

    for i = 1, self._count do
        self._snapshot[i] = self._dense[i]
    end

    for i = self._count + 1, #self._snapshot do
        self._snapshot[i] = nil
    end

    self._snapshot_dirty = false

    return self._snapshot
end

function SparseSetPrototype:isEmpty()
    return self._count == 0
end

function SparseSetPrototype:peek()
    return self._dense[#self._dense]
end

return {
    newSparseSet = newSparseSet,
}
