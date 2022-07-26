local DifficultyNames = require("common/constants/DifficultyNames")
local TrackInfo = require("gameplay/TrackInfo")

local fallbackJacket = gfx.CreateSkinImage("loading.png", 0)

---@class SongInfo: SongInfoBase
local SongInfo = {}
SongInfo.__index = SongInfo

---@param ctx GameplayContext
---@param window Window
---@return SongInfo
function SongInfo.new(ctx, window)
	---@class SongInfoBase
	local self = {
		artist = makeLabel("JP", gameplay.artist, 32),
		artistTimer = 0,
		ctx = ctx,
		difficulty = makeLabel(
			"Medium",
			DifficultyNames:get(gameplay.jacketPath, gameplay.difficulty),
			30
		),
		jacket = nil,
		jacketSize = 192,
		level = makeLabel("Number", ("%02d"):format(gameplay.level), 27),
		maxWidth = 0,
		title = makeLabel("JP", gameplay.title, 32),
		titleTimer = 0,
		trackInfo = TrackInfo.new(ctx, window),
		window = window,
		windowResized = nil,
		x = 0,
		y = 0,
	}

	---@diagnostic disable-next-line
	return setmetatable(self, SongInfo)
end

---@param dt deltaTime
function SongInfo:draw(dt)
	self:setProps()

	local introAlpha = self.ctx.introAlpha
	local jacketSize = self.jacketSize
	local maxWidth = self.maxWidth

	gfx.Save()
	gfx.Translate(self.x - ((self.window.w / 4) * self.ctx.introOffset), self.y)
	self:drawJacket(introAlpha, jacketSize)
	self:drawMetadata(dt, introAlpha, jacketSize, maxWidth)
	self.trackInfo:draw(dt, jacketSize, maxWidth, introAlpha)
	gfx.Restore()
end

function SongInfo:setProps()
	if self.windowResized ~= self.window.resized then
		if self.window.isPortrait then
			self.x = 24
			self.y = 176
			self.maxWidth = 820
		else
			self.x = self.window.paddingX / 2
			self.y = self.window.paddingY * 0.75
			self.maxWidth = 364
		end

		self.windowResized = self.window.resized
	end
end

---@param introAlpha number
---@param jacketSize number
function SongInfo:drawJacket(introAlpha, jacketSize)
	self:loadJacket(jacketSize)
	drawRect({
		x = 1,
		y = 1,
		w = jacketSize - 2,
		h = jacketSize - 2,
		image = self.jacket,
		stroke = { color = "Medium", size = 2 },
	})
	self:drawDifficulty(introAlpha, jacketSize)
end

---@param introAlpha number
---@param jacketSize number
function SongInfo:drawDifficulty(introAlpha, jacketSize)
	self.difficulty:draw({
		x = 0,
		y = jacketSize + 1,
		alpha = introAlpha,
		color = "White",
	})
	self.level:draw({
		x = jacketSize + 1,
		y = jacketSize + 4,
		align = "RightTop",
		alpha = introAlpha,
		color = "White",
	})
end

---@param dt deltaTime
---@param introAlpha number
---@param jacketSize number
---@param maxWidth number
function SongInfo:drawMetadata(dt, introAlpha, jacketSize, maxWidth)
	local canScroll = self.ctx.introOffset <= 0.2

	if self.title.w > maxWidth then
		if canScroll then
			self.titleTimer = self.titleTimer + dt
		end

		self.title:drawScrolling({
			x = jacketSize + 17,
			y = -8,
			alpha = introAlpha,
			color = "White",
			scale = self.window.scaleFactor,
			timer = self.titleTimer,
			width = maxWidth,
		})
	else
		self.title:draw({
			x = jacketSize + 17,
			y = -8,
			alpha = introAlpha,
			color = "White",
		})
	end

	if self.artist.w > maxWidth then
		if canScroll then
			self.artistTimer = self.artistTimer + dt
		end

		self.artist:drawScrolling({
			x = jacketSize + 17,
			y = 37,
			alpha = introAlpha,
			color = "Standard",
			scale = self.window.scaleFactor,
			timer = self.artistTimer,
			width = maxWidth,
		})
	else
		self.artist:draw({
			x = jacketSize + 17,
			y = 37,
			alpha = introAlpha,
			color = "Standard",
		})
	end
end

---@param jacketSize number
function SongInfo:loadJacket(jacketSize)
	if (not self.jacket) or (self.jacket == fallbackJacket) then
		self.jacket = gfx.LoadImageJob(
			gameplay.jacketPath,
			fallbackJacket,
			jacketSize,
			jacketSize
		)
	end
end

return SongInfo
