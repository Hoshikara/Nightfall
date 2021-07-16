---@class Sort
---@field name string
---@field dir string # 'UP' or 'DOWN'
local sort = {};

---@type table<string, Sort>
local Sorts = {
  ['Artist ^'] = { name = 'ARTIST', sub = { 'A', 'Z' } },
  ['Artist v'] = { name = 'ARTIST', sub = { 'Z', 'A' } },
  ['Badge ^'] = { name = 'CLEAR', sub = { 'LOW', 'HIGH' } },
  ['Badge v'] = { name = 'CLEAR', sub = { 'HIGH', 'LOW' } },
  ['Date ^'] = { name = 'ADDED', sub = { 'OLD', 'NEW' } },
  ['Date v'] = { name = 'ADDED', sub = { 'NEW', 'OLD' } },
  ['Effector ^'] = { name = 'EFFECTOR', sub = { 'A', 'Z' } },
  ['Effector v'] = { name = 'EFFECTOR', sub = { 'Z', 'A' } },
  ['Score ^'] = { name = 'SCORE', sub = { 'LOW', 'HIGH' } },
  ['Score v'] = { name = 'SCORE', sub = { 'HIGH', 'LOW' } },
  ['Title ^'] = { name = 'TITLE', sub = { 'A', 'Z' } },
  ['Title v'] = { name = 'TITLE', sub = { 'Z', 'A' } }, 
};

return Sorts;