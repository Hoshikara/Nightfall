local FontSizes = {
	Medium = 32,
	Number = 26,
}

local Prefixes = {
	"Collection: ",
	"Folder: ",
	"Level: ",
}

---@param text string
---@return string
local function removePrefixes(text)
	for _, prefix in ipairs(Prefixes) do
		text = text:gsub(prefix, "")
	end

	return text
end

---@param font string
---@param text string
---@return string, string, number
local function formatDropdownItem(font, text)
	text = removePrefixes(text)

	if text == "All" then
		font = "Medium"
	elseif (font == "Number") and (text ~= "∞") then
		text = ("%02d"):format(tonumber(text))
	end

	return font, text, FontSizes[font]
end

return formatDropdownItem
