---@param result result
---@return boolean
local function didCrash(result)
  local gauge = result.gauge or 0
  local gaugeType = result.gauge_type or 0

  return (gaugeType == 0) and (gauge < 0.7)
end

---@type Clear[]
local Clears = {
	[0] = { name = "EXIT", rate = 0.00 },
	[1] = { name = "PLAYED", rate = 0.50 },
	[2] = { name = "NORMAL", rate = 1.00 },
	[3] = { name = "HARD", rate = 1.02 },
	[4] = { name = "UC", rate = 1.05 },
	[5] = { name = "PUC", rate = 1.10 },
}

---@param badge integer
---@param getRate boolean
---@param result? result
---@return string
function Clears:get(badge, getRate, result)
  if result then
    if result.autoplay then
      return "AUTOPLAY"
    end

    if result.badge == 0 then
      return "EXIT"
    end

    if didCrash(result) then
      return "CRASH"
    end
  end

  if getRate then
    return self[badge] and self[badge].rate
  end

  return self[badge] and self[badge].name
end

return Clears

---@class Clear
---@field name string
---@field rate number
