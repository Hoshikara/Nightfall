---@param path? string
---@param extension? string
---@return string
local function getImagePath(path, extension)
	if not path then
		return ""
	end

	return path .. (extension or ".png")
end

---@class Image
---@field hueSettingKey string
---@field image integer
---@field isCentered boolean
---@field mesh ShadedMesh
---@field scale number
---@field updateMeshHue boolean
---@field w number
---@field h number
local Image = {}
Image.__index = Image

---@param params Image.new.params
---@return Image
function Image.new(params)
	---@type Image
	local self = Image.createImage(params)

	if not self then
		return
	end

	return setmetatable(self, Image)
end

---@param params Image.new.params
---@return Image
function Image.createImage(params)
	local image = gfx.CreateSkinImage(getImagePath(params.path), 0)
	local w, h = 0, 0

	if not image then
		if params.disableFallbackImage then
			return
		else
			image = gfx.CreateSkinImage(getImagePath(params.path, ".jpg"), 0)

			if not image then
				image = gfx.CreateSkinImage("image_warning.png", 0)
			end
		end
	end

	w, h = gfx.ImageSize(image)

	if params.isMesh then
		return Image.createMesh(params, w, h)
	end

	---@type Image
	local self = {
		image = image,
		isCentered = params.isCentered,
		scale = params.scale or 1,
		w = w,
		h = h,
	}

	return self
end

---@param params Image.new.params
---@param w number
---@param h number
---@return Image
function Image.createMesh(params, w, h)
	local mesh = gfx.CreateShadedMesh("image")
	local scaledW = w * (params.scale or 1)
	local scaledH = h * (params.scale or 1)

	mesh:AddSkinTexture("mainTex", params.path)
	mesh:SetBlendMode(params.meshBlendMode or 0)
	mesh:SetParam("alpha", 0.999)
	mesh:SetParam("hue", getSetting(params.hueSettingKey, 0))
	mesh:SetPrimitiveType(2)

	if params.isCentered then
		mesh:SetData({
			{ { -(scaledW * 0.5), -(scaledH * 0.5) }, { 0, 0 } },
			{ { scaledW * 0.5, -(scaledH * 0.5) }, { 1, 0 } },
			{ { scaledW * 0.5, scaledH * 0.5 }, { 1, 1 } },
			{ { -(scaledW * 0.5), scaledH * 0.5 }, { 0, 1 } },
		})
	else
		mesh:SetData({
			{ { 0, 0 }, { 0, 0 } },
			{ { scaledW, 0 }, { 1, 0 } },
			{ { scaledW, scaledH }, { 1, 1 } },
			{ { 0, scaledH }, { 0, 1 } },
		})
	end

	---@type Image
	local self = {
		hueSettingKey = params.hueSettingKey,
		isCentered = params.isCentered,
		mesh = mesh,
		scale = params.scale or 1,
		updateMeshHue = params.updateMeshHue,
		w = w,
		h = h,
	}

	return self
end

---@param params Image.draw.params
function Image:draw(params)
	local alpha = params.alpha or 1
	local scale = params.scale or self.scale
	local x = params.x or 0
	local y = params.y or 0
	local w = (params.w or self.w) * scale
	local h = (params.h or self.h) * scale

	if params.isCentered or self.isCentered then
		x = x - (w * 0.5)
		y = y - (h * 0.5)
	end

	if self.mesh then
		self:drawMesh(x, y, w, h, alpha, params.updateData)
	else
		gfx.BeginPath()
		gfx.GlobalCompositeOperation(params.blendOp or 0)

		if params.tint then
			gfx.SetImageTint(params.tint[1], params.tint[2], params.tint[3])
			gfx.ImageRect(x, y, w, h, self.image, alpha, 0)
			gfx.SetImageTint(255, 255, 255)
		else
			gfx.ImageRect(x, y, w, h, self.image, alpha, 0)
		end

		if params.stroke then
			setStroke(params.stroke)
			gfx.Stroke()
		end
	end
end

---@param x number
---@param y number
---@param w number
---@param h number
---@param alpha number
---@param updateData? boolean
function Image:drawMesh(x, y, w, h, alpha, updateData)
	if updateData then
		self.mesh:SetData({
			{ { x, y }, { 0, 0 } },
			{ { x + w, y }, { 1, 0 } },
			{ { x + w, y + h }, { 1, 1 } },
			{ { x, y + h }, { 0, 1 } },
		})
		self.mesh:SetParam("alpha", alpha * 0.999)
	end

	if self.updateMeshHue then
		self.mesh:SetParam("hue", getSetting(self.hueSettingKey, 0))
	end

	self.mesh:Draw()
end

return Image

--#region Interfaces

---@class Image.new.params
---@field disableFallbackImage? boolean
---@field hueSettingKey? string
---@field isCentered? boolean
---@field isMesh? boolean
---@field meshBlendMode? integer
---@field path string
---@field scale? number
---@field updateMeshHue? boolean

---@class Image.draw.params
---@field x? number
---@field y? number
---@field w? number
---@field h? number
---@field alpha? number
---@field blendOp? integer
---@field isCentered? boolean
---@field scale? number
---@field stroke? setStrokeParams
---@field tint? Color
---@field updateData? boolean

--#endregion
