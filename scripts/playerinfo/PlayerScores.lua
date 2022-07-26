local PlayerStatsKeys = require("playerinfo/constants/PlayerStatsKeys")

local toString = tostring

---@class PlayerScores: PlayerScoresBase
local PlayerScores = {}
PlayerScores.__index = PlayerScores

---@param window Window
---@return PlayerScores
function PlayerScores.new(window)
	---@class PlayerScoresBase
	---@field categories Label[]
	---@field levels Label[]
	local self = {
		categories = {},
		levelLabel = makeLabel("SemiBold", "LEVEL"),
		levels = {},
		window = window,
	}

	for i, category in ipairs(PlayerStatsKeys.Scores) do
		self.categories[i] = makeLabel("SemiBold", category)
	end

	for i = 1, 20 do
		self.levels[i] = makeLabel("Number", i, 27)
	end

	---@diagnostic disable-next-line
	return setmetatable(self, PlayerScores)
end

---@param x number
---@param y number
---@param w number
---@param stats FormattedPlayerStatsScores
function PlayerScores:draw(x, y, w, stats)
	y = y + 83

	self:drawRows(x, y, w)
	self:drawScores(x, y, stats)
end

---@param x number
---@param y number
---@param w number
function PlayerScores:drawRows(x, y, w)
	local levels = self.levels

	self.levelLabel:draw({
		x = x + 19,
		y = y - 40,
		color = "Standard",
	})

	for i = 10, 20 do
		local tempY = y + ((i - 10) * 59)

		if (i % 2) == 0 then
			drawRect({
				x = x,
				y = tempY,
				w = w,
				h = 59,
				alpha = 0.2,
				color = "Standard",
			})
		end

		levels[i]:draw({
			x = x + 18,
			y = tempY + 12,
			color = "Standard",
		})
	end
end

---@param x number
---@param y number
---@param stats FormattedPlayerStatsScores
function PlayerScores:drawScores(x, y, stats)
	local categories = self.categories
	local offsetX = 1597 / 3

	x = x + 142
	y = y + 12

	for i, _ in ipairs(PlayerStatsKeys.Scores) do
		local scores = stats[i]
		local tempX = x + ((i - 1) * offsetX)

		categories[i]:draw({
			x = tempX,
			y = y - 52,
			color = "Standard",
		})

		for j = 10, 20 do
			scores[toString(j)]:draw({ x = tempX, y = y + ((j - 10) * 59) })
		end
	end
end

return PlayerScores
