-- Adds a texture to the material that can be used in the shader code
---@param uniformName string
---@param fileName string # prepended with `skins/<skin>/textures/`
AddSkinTexture = function(uniformName, fileName) end

-- Adds a texture to the material that can be used in the shader code
---@param uniformName string
---@param fileName string
AddTexture = function(uniformName, fileName) end

-- Sets the blending mode
---@param mode integer # options also available as fields of the object prefixed with `BLEND`  
-- `Normal` = 0 (default)  
-- `Additive` = 1  
-- `Multiply` = 2  
SetBlendMode = function(mode) end

-- Sets the geometry data
---@param data table # array of vertices in clockwise order starting from the top left e.g.
-- ```
-- {
--   { { 0, 0 }, { 0, 0 } },
--   { { 50, 0 }, { 1, 0 } },
--   { { 50, 50 }, { 1, 1 } },
--   { { 0, 50 }, { 0, 1 } },
-- }
-- ```
SetData = function(data) end

-- Sets the material is opaque or non-opaque (default)
---@param opaque boolean
SetOpaque = function(opaque) end

-- Sets the value of the specified uniform
---@param uniformName string
---@param value number # `float`
SetParam = function(uniformName, value) end

-- Sets the value of the specified 2d vector uniform
---@param uniformName string
---@param x number # `float`
---@param y number # `float`
SetParamVec2 = function(uniformName, x, y) end

-- Sets the value of the specified 3d vector uniform
---@param uniformName string
---@param x number # `float`
---@param y number # `float`
---@param z number # `float`
SetParamVec3 = function(uniformName, x, y, z) end

-- Sets the value of the specified 4d vector uniform
---@param uniformName string
---@param x number # `float`
---@param y number # `float`
---@param z number # `float`
---@param w number # `float`
SetParamVec4 = function(uniformName, x, y, z, w) end

-- Sets the format for geometry data provided by `SetData`
---@param type integer # options also available as fields of the object prefixed with `PRIM`  
-- `TriangleList` = 0 (default)  
-- `TriangleStrip` = 1  
-- `TriangleFan` = 2  
-- `LineList` = 3  
-- `LineStrip` = 4  
-- `PointList` = 5  
SetPrimitiveType = function(type) end

-- Renders the `ShadedMesh` object
Draw = function() end

---@class ShadedMesh
ShadedMesh = {
  BLEND_NORM = 0,
  BLEND_ADD = 1,
  BLEND_MULT = 2,

  PRIM_TRILIST = 0,
  PRIM_TRIFAN = 1,
  PRIM_TRISTRIP = 2,
  PRIM_LINELIST = 3,
  PRIM_LINESTRIP = 4,
  PRIM_POINTLIST = 5,

  AddSkinTexture = AddSkinTexture,
  AddTexture = AddTexture,
  Draw = Draw,
  SetBlendMode = SetBlendMode,
  SetData = SetData,
  SetOpaque = SetOpaque,
  SetParam = SetParam,
  SetParamVec2 = SetParamVec2,
  SetParamVec3 = SetParamVec3,
  SetParamVec4 = SetParamVec4,
  SetPrimitiveType = SetPrimitiveType,
};