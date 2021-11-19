local Image = require("common/Image")

---@param folderPath string
---@param hueSettingKey? string
---@param updateMeshHue? boolean
---@return Image[], integer
local function loadFrames(folderPath, hueSettingKey, updateMeshHue)
  local frames = {}
  local i = 1

  while true do
    local image = Image.new({
      disableFallbackImage = true,
      meshBlendMode = 1,
      hueSettingKey = hueSettingKey,
      isCentered = true,
      isMesh = true,
      path = ("%s/%04d.png"):format(folderPath, i),
      updateMeshHue = updateMeshHue,
    })

    if not image then
      i = i - 1
      
      break
    end

    frames[i] = image
    i = i + 1
  end

  return frames, i
end

---@class Animation
---@field frameTime number
local Animation = {}
Animation.__index = Animation

---@param params Animation.new.params
---@return Animation
function Animation.new(params)
  ---@type Animation
  local self = {
    alpha = params.alpha or 1,
    frameTime = 1 / (params.fps or 60),
    isCentered = params.isCentered or false,
    loop = params.loop or false,
    loopPoint = params.loopPoint or 1,
    scale = params.scale or 1,
    updateData = params.updateData,
  }

  self.frames, self.frameCount = loadFrames(
    params.folderPath,
    params.hueSettingKey,
    params.updateMeshHue
  )

  return setmetatable(self, Animation)
end

---@param dt deltaTime
---@param state AnimationState
---@param effect? function
function Animation:play(dt, state, effect)
  state.timer = state.timer + dt

  if state.timer >= self.frameTime then
    state.frame = state.frame + 1
    state.timer = 0
  end

  if self.frames[state.frame] then
    self.frames[state.frame]:draw({
      alpha = state.alpha or self.alpha,
      isCentered = self.isCentered,
      scale = self.scale,
      updateData = self.updateData,
    })
  end

  if state.frame == self.frameCount then
    if self.loop then
      state.frame = self.loopPoint
    else
      state.frame = 1
      state.queued = false
      state.timer = 0

      if effect then
        effect()
      end
    end
  end
end

return Animation

--#region Interfaces

---@class Animation.new.params
---@field alpha? number
---@field folderPath string
---@field fps? number
---@field hueSettingKey? string
---@field isCentered? boolean
---@field loop? boolean
---@field loopPoint? integer
---@field scale? number
---@field tint? Color
---@field updateData? boolean
---@field updateMeshHue? boolean

---@class AnimationState
---@field alpha? number
---@field frame number
---@field queued boolean
---@field timer number

--#endregion
