---@meta

---
---The `ShadedMesh` object created with `gfx.CreateShadedMesh`.
---[Official Documentation](https://unnamed-sdvx-clone.readthedocs.io/en/latest/shadedmesh.html)
---
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
}

---
---Adds a shared texture to the material that can be used in the shader code.
---
---@param uniformName uniformName
---@param textureName string # The name of the shared texture loaded with `gfx.LoadSharedTexture`.
function ShadedMesh:AddSharedTexture(uniformName, textureName) end

---
---Adds a texture to the material that can be used in the shader code.
---
---@param uniformName uniformName
---@param imagePath string # The file path to the image within the `textures` folder of the current skin.
function ShadedMesh:AddSkinTexture(uniformName, imagePath) end

---
---Adds a texture to the material that can be used in the shader code.
---
---@param uniformName uniformName
---@param imagePath imagePath
function ShadedMesh:AddTexture(uniformName, imagePath) end

---
---Gets the translation of the current mesh.
---
---@return number x, number y, number z
function ShadedMesh:GetPosition() end

---
---Gets the rotation value of the current mesh in degrees.
---
---@return number roll, number yaw, number pitch
function ShadedMesh:GetRotation() end

---
---Gets the scale of the current mesh.
---
---@return number x, number y, number z
function ShadedMesh:GetScale() end

---
---Sets the blending mode for the current mesh.
---
---@param blendMode blendMode
function ShadedMesh:SetBlendMode(blendMode) end

---
---Sets the geometry data for the current mesh.
---
---@param data table # An array of vertices in clockwise order starting from the top left.
--- A vertex has the form `{ { x, y }, { u, v } }`.
--- Example:
---```lua
---{
---  { { 0, 0 }, { 0, 0 } },
---  { { 50, 0 }, { 1, 0 } },
---  { { 50, 50 }, { 1, 1 } },
---  { { 0, 50 }, { 0, 1 } },
---}
---```
function ShadedMesh:SetData(data) end

---
---Sets the current mesh as opaque or non-opaque.
---Meshes are non-opaque by default.
---
---@param opaque boolean
function ShadedMesh:SetOpaque(opaque) end

---
---Sets the value of the given uniform variable.
---
---@param uniformName uniformName
---@param value number
function ShadedMesh:SetParam(uniformName, value) end

---
---Sets the value of the given 2D vector uniform variable.
---
---@param uniformName uniformName
---@param x number
---@param y number
function ShadedMesh:SetParamVec2(uniformName, x, y) end

---
---Sets the value of the given 3D vector uniform variable.
---
---@param uniformName uniformName
---@param x number
---@param y number
---@param z number
function ShadedMesh:SetParamVec3(uniformName, x, y, z) end

---
---Sets the value of the given 4D vector uniform variable.
---
---@param uniformName uniformName
---@param x number
---@param y number
---@param z number
---@param w number
function ShadedMesh:SetParamVec4(uniformName, x, y, z, w) end

---
---Sets the translation for the current mesh.
---For `ShadedMesh` objects, the translation is relative the screen.
---For `ShadedMeshOnTrack` objects, the translation is relative to the critical line.
---
---@param x number
---@param y number
---@param z? number # Default: `0`
function ShadedMesh:SetPosition(x, y, z) end

---
---Sets the geometry data type provided by `ShadedMesh:SetData`.
---
---@param primitiveType integer
---* `0` = TriangleList (default)
---* `1` = TriangleStrip
---* `2` = TriangleFan
---* `3` = LineList
---* `4` = LineStrip
---* `5` = PointList
function ShadedMesh:SetPrimitiveType(primitiveType) end

---
---Sets the rotation of the current mesh in degrees.
---**WARNING:** For `ShadedMesh` objects, pitch and yaw may clip resulting in portions or
---the entire mesh being invisible.
---
---@param roll number
---@param yaw? number # Default: `0`
---@param pitch? number # Default: `0`
function ShadedMesh:SetRotation(roll, yaw, pitch) end

---
---Sets the scale of the current mesh.
---
---@param x number
---@param y number
---@param z? number # Default: `0`
function ShadedMesh:SetScale(x, y, z) end

---
---Sets the wireframe mode of the object which does not render the texture.
---This is useful for debugging models or geometry shaders.
---
---@param useWireframe boolean
function ShadedMesh:SetWireframe(useWireframe) end

---
---Draws the current `ShadedMesh` object.
---
function ShadedMesh:Draw() end

---
---The `ShadedMeshOnTrack` object created with `track.CreateShadedMesh`.
---
---@class ShadedMeshOnTrack : ShadedMesh
---
---@field BUTTON_TEXTURE_LENGTH number
---
---@field FXBUTTON_TEXTURE_LENGTH number
---
---@field TRACK_LENGTH number
ShadedMeshOnTrack = {}

---
---Gets the length of the current mesh.
---
---@return number length
function ShadedMeshOnTrack:GetLength() end

---
---Sets the y-scale of the current mesh based on its length.
---This is useful for creating fake buttons which may have variable length based on duration.
---
---@param length number
function ShadedMeshOnTrack:ScaleToLength(length) end

---
---Sets the clipping mode of the current mesh.
---
---@param doClip boolean # If `true`, meshes stretching beyond the track will not be drawn.
function ShadedMeshOnTrack:SetClipWithTrack(doClip) end

---
---Sets the length of the current mesh in the y-direction relative to the track.
---
---@param length number #
---Optional constants:
---* `BUTTON_TEXTURE_LENGTH`
---* `FXBUTTON_TEXTURE_LENGTH`
---* `TRACK_LENGTH`
function ShadedMeshOnTrack:SetLength(length) end

---
---Uses an existing game mesh as the current mesh.
---
---@param meshName string #
---Options:
---* `"button"`
---* `"fxbutton"`
---* `"track"`
function ShadedMeshOnTrack:UseGameMesh(meshName) end
