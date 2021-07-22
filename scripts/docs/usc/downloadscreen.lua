-- downloadscreen `dlScreen` table

-- Download the selected song
---@param uri string # Encoded URI
---@param header table
---@param id string # Song ID
---@param cb function # Archive callback 
DownloadArchive = function(uri, header, id, cb) end

-- Exit the download screen
Exit = function() end

-- Gets the path to the song folder
GetSongsPath = function() end

-- Play the chart preview
---@param uri string # Encoded URI
---@param header table
---@param id string # Song ID
PlayPreview = function(uri, header, id) end

---@class dlScreen
dlScreen = {
  DownloadArchive = DownloadArchive,
  Exit = Exit,
  GetSongsPath = GetSongsPath,
  PlayPreview = PlayPreview,
};