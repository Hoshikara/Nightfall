---@return Color[]
local function getLaserColors()
  local laserColors = {
    { 0, 0, 0 },
    { 0, 0, 0 },
  }
  
  for i = 1, 2 do
    local r, g, b = game.GetLaserColor(i - 1)

    laserColors[i][1] = r
    laserColors[i][2] = g
    laserColors[i][3] = b
  end

  return laserColors
end

return getLaserColors
