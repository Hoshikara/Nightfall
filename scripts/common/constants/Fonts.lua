---@type table<string, string>
local Fonts = {
	JP = "SmartFontUI.otf",
	Medium = "RajdhaniMedium.ttf",
	Number = "ContinuumMedium.ttf",
	Regular = "RajdhaniRegular.ttf",
	SemiBold = "RajdhaniSemiBold.ttf",
}

---@param font? string
function Fonts:load(font)
	gfx.LoadSkinFont(self[font] or self.JP)
end

return Fonts
