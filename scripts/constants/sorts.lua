---@class Sort
---@field name string
---@field dir string # 'UP' or 'DOWN'
local sort = {};

---@type table<string, Sort>
local Sorts = {
  ['Artist ^'] = { name = 'ARTIST', dir = 'DOWN' },
  ['Artist v'] = { name = 'ARTIST', dir = 'UP' },
  ['Badge ^'] = { name = 'CLEAR', dir = 'DOWN' },
  ['Badge v'] = { name = 'CLEAR', dir = 'UP' },
  ['Date ^'] = { name = 'ADDED', dir = 'DOWN' },
  ['Date v'] = { name = 'ADDED', dir = 'UP' },
  ['Effector ^'] = { name = 'EFFECTOR', dir = 'DOWN' },
  ['Effector v'] = { name = 'EFFECTOR', dir = 'UP' },
  ['Score ^'] = { name = 'SCORE', dir = 'DOWN' },
  ['Score v'] = { name = 'SCORE', dir = 'UP' },
  ['Title ^'] = { name = 'TITLE', dir = 'DOWN' },
  ['Title v'] = { name = 'TITLE', dir = 'UP' }, 
};

return Sorts;