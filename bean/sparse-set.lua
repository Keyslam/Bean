local SparseSetPrototype = {}
SparseSetPrototype.__mt = {
    __index = SparseSetPrototype,
}

local function newSparseSet()
    return setmetatable({
        count = 0,
        dense = {},
        sparse = {},
    }, SparseSetPrototype.__mt)
end

function SparseSetPrototype:add(value)
    local index = self.count + 1

    self.dense[index] = value
    self.sparse[value] = index
    self.count = self.count + 1
end

function SparseSetPrototype:remove(value)
    local index = self.sparse[value]

    if not index then
        return
    end

    local lastValue = self.dense[self.count]

    self.dense[index] = lastValue
    self.sparse[lastValue] = index

    self.dense[self.count] = nil
    self.count = self.count - 1
    self.sparse[value] = nil
end

function SparseSetPrototype:has(value)
    return self.sparse[value] ~= nil
end

function SparseSetPrototype:values()
    return self.dense
end

function SparseSetPrototype:count()
    return self.count
end

function SparseSetPrototype:isEmpty()
    return self.count == 0
end

function SparseSetPrototype:peek()
    return self.dense[#self.dense]
end

return {
    newSparseSet = newSparseSet,
}
