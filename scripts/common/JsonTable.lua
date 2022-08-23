local json = require("lib/json")

---@param fileName string
---@return string
local function getFilePath(fileName)
	---@diagnostic disable-next-line
	return path.Absolute(("skins/%s/JSON/%s.json"):format(game.GetSkin(), fileName))
end

---@class JsonTable: JsonTableBase
local JsonTable = {}
JsonTable.__index = JsonTable

---@param fileName string
---@return JsonTable
function JsonTable.new(fileName)
	---@type nil|table
	local contents = {}
	local filePath = getFilePath(fileName)
	local file = io.open(filePath, "r")

	if file then
		contents = JsonTable:fetchContents(file)
	else
		local newFile = io.open(filePath, "w")

		if newFile then
			newFile:write(json.encode({}))
			newFile:close()
		end
	end

	---@class JsonTableBase
	local self = { contents = contents, filePath = filePath }

	---@diagnostic disable-next-line
	return setmetatable(self, JsonTable)
end

---@param file file*|nil
---@return nil|table
function JsonTable:fetchContents(file)
	---@type any
	local contents = {}
	local isInitialFetch = file ~= nil

	file = file or io.open(self.filePath, "r")

	if file then
		local rawContents = file:read("*all")

		if rawContents == "" then
			file:write(json.encode(contents))
		else
			contents = json.decode(rawContents)
		end

		file:close()
	end

	if isInitialFetch then
		return contents
	end

	self.contents = contents
end

---@param newContents table
function JsonTable:overwriteContents(newContents)
	local file = io.open(self.filePath, "w")

	if file then
		file:write(json.encode(newContents))
		file:close()
	end
end

---@param key string
---@param value any
function JsonTable:set(key, value)
	local file = io.open(self.filePath, "w")

	self.contents[key] = value

	if file then
		file:write(json.encode(self.contents))
		file:close()
	end
end

---@param refetch? boolean
---@param key? string
---@return any
function JsonTable:get(refetch, key)
	if refetch then
		self:fetchContents()
	end

	if key then
		return self.contents[key]
	end

	return self.contents
end

return JsonTable
