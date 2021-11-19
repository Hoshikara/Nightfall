---@type { color: Color, name: string, step: number, start: integer }[]
local VolforceRanks = {
  {
    color = { 150, 100, 195 },
    name = "IMPERIAL",
    start = 20,
    step = 1.0,
  },
  {
    color = { 195, 50, 50 },
    name = "CRIMSON",
    start = 19,
    step = 0.25,
  },
  {
    color = { 245, 230, 150 },
    name = "ELDORA",
    start = 18,
    step = 0.25,
  },
  {
    color = { 220, 225, 230 },
    name = "ARGENTO",
    start = 17,
    step = 0.25,
  },
  {
    color = { 230, 150, 175 },
    name = "CORAL",
    start = 16,
    step = 0.25,
  },
  {
    color = { 210, 60, 60 },
    name = "SCARLET",
    start = 15,
    step = 0.25,
  },
  {
    color = { 55, 175, 175 },
    name = "CYAN",
    start = 14,
    step = 0.25,
  },
  {
    color = { 240, 170, 30 },
    name = "DANDELION",
    start = 12,
    step = 0.5,
  },
  {
    color = { 60, 95, 175 },
    name = "COBALT",
    start = 10,
    step = 0.5,
  },
  {
    color = { 180, 130, 80 },
    name = "SIENNA",
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

  return "RANK"
end

return VolforceRanks
