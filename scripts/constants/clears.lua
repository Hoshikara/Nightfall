---@class Clear
---@field clear string
---@field rate number
local clear = {};

---@type Clear[]
local Clears = {
  { clear = 'PLAYED', rate = 0.50 },
  { clear = 'NORMAL', rate = 1.00 },
  { clear = 'HARD',   rate = 1.02 },
  { clear = 'UC',     rate = 1.05 },
  { clear = 'PUC',    rate = 1.10 },
};

return Clears;