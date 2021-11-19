---@type table<string, string>
local Fonts = {
	JP = "SmartFontUI.otf",
	Bold = "RajdhaniBold.ttf",
	Medium = "RajdhaniMedium.ttf",
	Number = "ContinuumMedium.ttf",
	Regular = "RajdhaniRegular.ttf",
	SemiBold = "RajdhaniSemiBold.ttf",
}

---@param font? string
---@diagnostic disable-next-line
function Fonts:load(font)
	gfx.LoadSkinFont(self[font] or self.JP)
end

return Fonts
