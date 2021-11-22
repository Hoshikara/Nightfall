---@param cachedDiffs CachedDiff[]
---@param itemIndex integer
---@return CachedDiff
local function getDiffInOrder(cachedDiffs, itemIndex)
  local index = nil

  for i, cachedDiff in ipairs(cachedDiffs) do
    if (cachedDiff.diffIndex + 1) == itemIndex then
      index = i
    end
  end

  return cachedDiffs[index]
end

return getDiffInOrder
