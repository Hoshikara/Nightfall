---@type table<string, Sort>
local Sorts = {
  ["Artist ^"] = { name = "ARTIST", subText = { "A", "Z" } },
  ["Artist v"] = { name = "ARTIST", subText = { "Z", "A" } },
  ["Badge ^"] = { name = "CLEAR", subText = { "LOW", "HIGH" } },
  ["Badge v"] = { name = "CLEAR", subText = { "HIGH", "LOW" } },
  ["Date ^"] = { name = "ADDED", subText = { "OLD", "NEW" } },
  ["Date v"] = { name = "ADDED", subText = { "NEW", "OLD" } },
  ["Effector ^"] = { name = "EFFECTOR", subText = { "A", "Z" } },
  ["Effector v"] = { name = "EFFECTOR", subText = { "Z", "A" } },
  ["Score ^"] = { name = "SCORE", subText = { "LOW", "HIGH" } },
  ["Score v"] = { name = "SCORE", subText = { "HIGH", "LOW" } },
  ["Title ^"] = { name = "TITLE", subText = { "A", "Z" } },
  ["Title v"] = { name = "TITLE", subText = { "Z", "A" } }, 
}

return Sorts

---@class Sort
---@field name string
---@field subText string[]
