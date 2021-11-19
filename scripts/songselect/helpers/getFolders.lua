local JsonTable = require("common/JsonTable")

local foldersJson = JsonTable.new("folders")
local folders = nil

local function getFolders()
	if (not folders) and (getSetting("_isSongSelect", 1) == 1) then
		folders = {}

		for _, folder in ipairs(filters.folder) do
			if not folder:find("Collection: ") then
				folders[#folders + 1] = folder:gsub("Folder: ", "")
			end
		end

		table.insert(folders, 2, "OFFICIAL SOUND VOLTEX CHARTS")

		foldersJson:overwriteContents(folders)
	end
end

return getFolders
