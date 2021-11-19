local JacketSizes = {
	LOW = 200,
	NORMAL = 400,
	HIGH = 1000,
	ORIGINAL = 0,
}

local fallbackJacket = gfx.CreateSkinImage("loading.png", 0)
local jacketSize = JacketSizes[getSetting("jacketQuality", "NORMAL")] or JacketSizes.NORMAL

---@param diffs Difficulty[]
local function loadJackets(diffs)
	for _, diff in ipairs(diffs) do
		if (not diff.jacket) or (diff.jacket == fallbackJacket) then
			if diff.jacket_url then
				diff.jacket = gfx.LoadWebImageJob(
					diff.jacket_url,
					fallbackJacket,
					jacketSize,
					jacketSize
				)
			else
				diff.jacket = gfx.LoadImageJob(
					diff.jacketPath,
					fallbackJacket,
					jacketSize,
					jacketSize
				)
			end
		end
	end
end

return loadJackets
