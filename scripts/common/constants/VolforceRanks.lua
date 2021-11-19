---@type { color: Color, name: string, step: number, start: integer }[]
local VolforceRanks = {
  {
    name = "[ IMPERIAL ]",
    start = 20,
    step = 1.0,
  },
  {
    name = "[ CRIMSON ]",
    start = 19,
    step = 0.25,
  },
  {
    name = "[ ELDORA ]",
    start = 18,
    step = 0.25,
  },
  {
    name = "[ ARGENTO ]",
    start = 17,
    step = 0.25,
  },
  {
    name = "[ CORAL ]",
    start = 16,
    step = 0.25,
  },
  {
    name = "[ SCARLET ]",
    start = 15,
    step = 0.25,
  },
  {
    name = "[ CYAN ]",
    start = 14,
    step = 0.25,
  },
  {
    name = "[ DANDELION ]",
    start = 12,
    step = 0.5,
  },
  {
    name = "[ COBALT ]",
    start = 10,
    step = 0.5,
  },
  {
    name = "[ SIENNA ]",
    start = 0,
    step = 2.5,
  },
}

---@param volforce number
---@return string
function VolforceRanks:get(volforce)
  for _, rank in ipairs(self) do
    if volforce >= rank.start then
      local start = rank.start

      for i = 1, 4 do
        start = start + rank.step

        if volforce < start then
          return rank.name
        end
      end
    end
  end

  return "[ RANK ]"
end

return VolforceRanks
